# Import packages
import numpy as np
import pandas as pd
import unicodedata
import re
from pyexcel_ods import get_data
import uuid

import sauvamer_clenaing1

# Read secmar extract 2017
secmar = pd.read_csv("../data/secmar_operations_Etel_2017.csv", encoding='latin-1', sep=';')


# Function to clean the colnames 
def colname_cleaning(df):
	return df.rename(columns=lambda x: x.replace(' ', '_').lower().replace("é","e").replace("ê","e").replace("(","").replace(")","").replace("'","").replace("?", "").encode('utf-8').decode('ascii', 'ignore'))

secmar_col_clean = colname_cleaning(secmar)

# Transform all values to uppercase
secmar_col_clean = secmar_col_clean.applymap(lambda x: x.upper() if isinstance(x, str) else x)

# Clean Cross names
di_cross = {'LA GARDE': 'LA-GARDE',
            'ÉTEL': 'ETEL',
            'CORSEN': 'CORSEN',
            'ANTILLES-GUYANE': 'ANTILLES-GUYANE',
            'GRIS-NEZ': 'GRIS-NEZ', 
            'JOBOURG': 'JOBOURG',
            'CORSE': 'CORSE',
            'LA RÉUNION': "REUNION",
            'POLYNÉSIE': 'POLYNESIE',
            'NOUVELLE-CALÉDONIE': 'NOUVELLE-CALEDONIE'}


secmar_col_clean.cross.replace(di_cross, inplace=True)


# Create cross_sitrep ID
secmar_col_clean['cross_sitrep'] = secmar_col_clean['cross'] + '_' + (secmar_col_clean['n_sitrep'].astype(str))


# Extract the type of operation
secmar_col_clean['pourquoi_alerte_short'] =  secmar_col_clean.pourquoi_alerte.str.extract(r"(MAS|SAR|DIV|SUR)")


# Clean zone d'intervention
di_zone_inter = {'EAUX TERRITORIALES (300 M À 12 NQ)': 'EAUX TERRITORIALES ',
                 'PLAGE ET 300M': 'PLAGE ET 300 MÈTRES',
                 'EAUX FRANÇAISES (SUP. À 12 NQ)': 'RESPONSABILITÉ FRANÇAISE',
                 'EAUX ETRANGÈRES': 'RESPONSABILITÉ ÉTRANGÈRE'
                 }

sauvamer.zone_dintervention.replace(di_zone_inter, inplace=True)


# Create a column indicating if the SNSM was involved
secmar_col_clean['snsm_implique'] = secmar_col_clean.autorite_demploi.str.contains("SNSM")*1


# Remove duplicates that have the same cross_sitrep ID
secmar_col_clean = secmar_col_clean.drop_duplicates(['cross_sitrep'], keep="first")


# Change the format of resultat humain
resultat = secmar_col_clean.resultat_humain.str.split(',').apply(pd.Series).add_prefix('resultat_humain')
resultat1 = pd.DataFrame(index=resultat.index)
for col in resultat: 
    resultat1 = resultat1.merge(resultat[col].fillna("NO_INFO").str.split('-').apply(pd.Series).add_prefix(col), left_index=True, right_index=True)

column = np.array([col for col in resultat1 if col.endswith('0')])
value = np.array([col for col in resultat1 if col.endswith('1')])
column_value_combination = [[column[i], value[i]] for i in range(len(column))]

resultat2 = pd.DataFrame(index=resultat1.index)

for tupples in column_value_combination:
    resultat2 = resultat2.merge(resultat1.pivot(columns=tupples[0] ,values= tupples[1]).fillna(0).astype(int), left_index=True, right_index=True)
    
resultat3 = resultat2.rename(columns= lambda x: x.replace("_x", "").replace("_y", ""))

resultat_humain_df = resultat3.groupby(resultat3.columns, axis=1).sum().rename(columns= \
                                                          {"ASSI": "nb_personnes_asssistées",\
                                                           "DCDA": "nb_décédés_accidentels", \
                                                           "DCDN": "nb_décédés_naturels", \
                                                           "DISP": "nb_personnes_disparues", \
                                                           "NOAS": "nb_personnes_impliquées_fausses_alertes", \
                                                           "RETR": "nb_personnes_retrouvées", \
                                                           "SECO": "nb_personnes_secourues", \
                                                           "TAS": "nb_personnes_tirées_daffaires_elles_memes"}).drop('NO_INFO', axis=1)

# Add new resultat humain Data Frame to original Data Frame
secmar_col_clean = secmar_col_clean.merge(resultat_humain_df, left_index=True, right_index=True).drop('resultat_humain', axis=1)


# Merge sauvamer and secmar
secmar_final = secmar_final.merge(secmar_col_clean.autorite_demploi.str.split(',').apply(pd.Series).add_prefix('autorite_demploi_'), left_index=True, right_index=True)

sauvamer_secmar = secmar_final.merge(sauvamer_final, how="outer", 
                                 left_on="cross_sitrep_secmar",
                                 right_on="cross_sitrep_sauvamer",
                                 suffixes=("_secmar", "_sauvamer"),
                                 indicator=True)
#Add suffix to each dataset
secmar_final = secmar_final.add_suffix('_secmar')
sauvamer_final = sauvamer_final.add_suffix('_sauvamer')

    