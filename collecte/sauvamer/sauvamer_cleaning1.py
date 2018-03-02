import numpy as np
import pandas as pd
import unicodedata
import re
from pyexcel_ods import get_data
import uuid


# Read sauvamer export
sauvamer = pd.read_excel("../data/export_snosan.xlsx")

# Function to clean the colnames 
def colname_cleaning(df):
	return df.rename(columns=lambda x: x.replace(' ', '_').lower().replace("é","e").replace("ê","e").replace("(","").replace(")","").replace("'","").replace("?", "").encode('utf-8').decode('ascii', 'ignore'))

# Transform vent to numeric scale of Beaufort
sauvamer['state_mer'] = sauvamer['Mer (Douglas)'].str.split('(').str[0]


di_mer = {'Plate ': 0,
          'Ridée ': 1,
          'Belle ': 2,
          'Peu agitée ': 3 ,
          'Agitée ': 4, 
          'Forte ' : 5,
          'Très forte ' : 6,
          'Grosse ' : 7,
          'Très grosse ' : 8 ,
          'Enorme ': 9}

sauvamer['etat_mer'] = sauvamer['state_mer'].map(di_mer)

# Clean colnames 
sauvamer = colname_cleaning(sauvamer)

# Delete the word station from nom de l'établissement
sauvamer['nom_etablissement'] = sauvamer.nom_etablissement.str.replace("STATION", "")

# Change the type of etat de la mer
sauvamer.etat_mer = sauvamer.etat_mer.astype('category')

# Extract CROSS/Date/Sitrep
sauvamer['sitrep_cross'] = sauvamer.n_sitrep.str.extract("CROSS (.*\/\d+/\d+)")

# Extract sitrep number and remove undesired O's
sauvamer['sitrep'] = sauvamer.sitrep_cross.str.split("/").str[2]
sauvamer['sitrep']= sauvamer.sitrep.str.replace(r'(^0)', "")
sauvamer['sitrep']= sauvamer.sitrep.str.replace(r'(^0)', "")
sauvamer['sitrep']= sauvamer.sitrep.str.replace(r'(^0)', "")

# Extract Cross name and clean it 
sauvamer['cross'] = sauvamer.sitrep_cross.str.split("/").str[0]
sauvamer['cross'] = sauvamer['cross'].str.strip()
sauvamer['cross'] = sauvamer['cross'].str.replace(" ", "-")
sauvamer['cross'] = sauvamer['cross'].str.replace("É", "E")

# Create a cross_sitrep ID
sauvamer['cross_sitrep'] = sauvamer['cross'].str.lower() + '_' + sauvamer['sitrep']

# Create a new column with the type of operations
sauvamer['type_inter'] = sauvamer.n_sitrep.str.extract(r"(MAS|SAR|DIV)")

# Convert the type of code postal
sauvamer.cp = sauvamer.cp.astype('object')

# Read a file that matches code postal and cities
code_poste = pd.read_csv("../data/laposte_hexasmal.csv", sep=";")
code_poste = code_poste[['Nom_commune', 'Code_postal']]
code_poste = code_poste.drop_duplicates()

# Convert all values to uppercase
sauvamer = sauvamer.applymap(lambda x: x.upper() if isinstance(x, str) else x)

# Convert fausses alertes into Boolean
sauvamer.fausse_alerte = sauvamer.fausse_alerte.replace({'OUI': True, 'NON': False})*1

# Drop some useless columns
sauvamer = sauvamer.drop(['mer_douglas', 'type_de_rapport', 'n_sitrep', 'state_mer', 'sitrep_cross'], axis=1)

# Rename some columns 
sauvamer = sauvamer.rename(columns={'nets': 'etablissement_id', 'n_de_rapport': 'numero_de_rapport', 'cp': 'code_postal', 'nb_de_pers._tirees_daffaire_elles-memes':'nb_personnes_tirees_daffaire_elles-memes'})




# Handling duplicated values

duplicates = (sauvamer.cross_sitrep.duplicated(keep=False)) & (sauvamer.cross_sitrep.notnull()) # filter of duplicates

fusion_duplicate = sauvamer[duplicates].sort_values(['cross_sitrep','date_de_sortie']).groupby('cross_sitrep', as_index=False).agg(lambda x: x.tolist()) # Group rows that have same cross_sitrep into one row

fusion_col = pd.DataFrame(index=fusion_duplicate.index)

for col in fusion_duplicate:
    fusion_col = fusion_col.merge(fusion_duplicate[col].apply(pd.Series).add_prefix(col), left_index=True, right_index=True) # Split the list into columns
    
# Change the name of cross_sitrep column
fusion_col.rename(columns={'cross_sitrep0': 'cross_sitrep'}, inplace=True)

# Replace nan if we want to keep only one columns and remove all other columns 
drop_list= []
flattened_list = []

for column in ('nom_du_navire', 'numero_de_rapport', 'zone_dintervention', 'date_de_saisie', 'zone_littoral', 'code_postal', 'heure_de_lalerte', 'fausse_alerte', 'type_embarcation', 'position_latitude','position_longitude', 'etat_mer', 'sitrep', 'cross'):
    fusion_col[column] = fusion_col[[col for col in fusion_col if col.startswith(column)]]. bfill(axis=1).iloc[:, 0]
    drop_list.append(([col for col in fusion_col if (col.startswith(column)) & ((col.endswith('0'))|(col.endswith('1')) | (col.endswith('2')) |(col.endswith('3')) | (col.endswith('4')) | (col.endswith('5')) | (col.endswith('6')) | (col.endswith('7'))|(col.endswith('8'))| (col.endswith('9')))]))
    for x in drop_list:
        for y in x:
            flattened_list.append(y)
fusion_col2 = fusion_col.drop(flattened_list, axis=1)

# Combine text reports into one column
drop_list1= []
flattened_list1 = []

for column in ('compte_rendu_patron', 'commentaires_patron'):
    fusion_col2[column] = fusion_col2[[col for col in fusion_col2 if col.startswith(column)]].fillna("").apply(';'.join, axis=1)
    
    drop_list1.append(([col for col in fusion_col2 if (col.startswith(column)) & ((col.endswith('0'))|(col.endswith('1')) | (col.endswith('2')) |(col.endswith('3')) | (col.endswith('4')) | (col.endswith('5')) | (col.endswith('6'))                                    | (col.endswith('7'))|(col.endswith('8'))| (col.endswith('9')))]))
    for x in drop_list1:
        for y in x:
            flattened_list1.append(y)
            
fusion_col_final = fusion_col2.drop(flattened_list1, axis=1)

# New Data set that contains only duplicated cross_sitrep
sauvamer_duplicates = fusion_col_final.rename(columns= lambda x: x.replace("0", ""))


# Data set with no duplicated cross_sitrep
sauvamer_no_duplicates = sauvamer[~duplicates]

#Create a column with only day and month of operations
sauvamer_no_duplicates = sauvamer_no_duplicates.assign(jour_alerte = sauvamer_no_duplicates.heure_de_lalerte.dt.date)

# Define operations that have no sitrep number and are likely to be duplicated operations
inter_to_delete =  (sauvamer_no_duplicates.cross_sitrep.isnull()) & (sauvamer_no_duplicates.heure_de_lalerte.duplicated(keep='first')) & (sauvamer_no_duplicates.nom_etablissement.duplicated(keep='first') & (sauvamer_no_duplicates.compte_rendu_patron.duplicated(keep='first')))

#Delete those operations
sauvamer_no_duplicates = sauvamer_no_duplicates[~inter_to_delete]


# Assign a cross_sitrep id to those with NaN values
sauvamer_no_duplicates.loc[sauvamer_no_duplicates.cross_sitrep.isnull(),'cross_sitrep'] = [uuid.uuid4() for x in range(sauvamer_no_duplicates.cross_sitrep.isnull().sum())]
sauvamer_no_duplicates['cross_sitrep'] = sauvamer_no_duplicates['cross_sitrep'].apply(lambda x: str(x))


# Combine the two data sets
sauvamer_final = pd.concat([sauvamer_duplicates, sauvamer_no_duplicates])

