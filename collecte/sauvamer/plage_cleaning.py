import numpy as np
import pandas as pd
import unicodedata
import re
from pyexcel_ods import get_data
import uuid



# Read fiches des postes de plage 2017
plage = pd.read_excel("../data/Fiches opération 2017.xlsx")


# Function to clean the colnames 
def colname_cleaning(df):
	return df.rename(columns=lambda x: x.replace(' ', '_').lower().replace("é","e").replace("ê","e").replace("(","").replace(")","").replace("'","").replace("?", "").encode('utf-8').decode('ascii', 'ignore'))

plage_col_clean = colname_cleaning(plage)

# Transform all values to uppercase
plage_col_clean = plage_col_clean.applymap(lambda x: x.upper() if isinstance(x, str) else x)

# Separate moyens into different columns
plage_col_clean['moyens'] = plage_col_clean['moyens'].replace('^;', "", regex=True)

plage_col_clean[['moyens0', 'moyens1', 'moyens2', 'moyens3', 'moyens4', 'moyens5']] = plage_col_clean.moyens.str.split(";", expand=True)


# Create an ID

plage_col_clean['cross_sitrep']= range(sauvamer_null_sitrep + 2, len(plage_col_clean) + sauvamer_null_sitrep + 2) #

# # Transform vent to numeric scale of Beaufort
di_vent = {'00 - CALME (MOINS DE 1 NOEUD)': 0,
           '01 - TRÈS LÉGÈRE BRISE (1 À 3)': 1,
           '02 - LÉGÈRE BRISE (4 À 6)': 2,
           '03 - PETITE BRISE (7 À 10)': 3,
           '04 - JOLIE BRISE (11 À 16)': 4,
           '05 - BONNE BRISE (17 À 21)': 5,
           '06 - VENT FRAIS (22 À 27)': 6,
           '07 - GRAND FRAIS (28 À 33)': 7,
           '08 - COUP DE VENT (34 À 40)': 8
           }

plage_col_clean.vent.replace(di_vent, inplace=True)

# Transform etat de la mer to numeric scale of Beaufort
di_mer2 = {'1 RIDÉE (0 À 0.1M)': 1,
           '2 BELLE (0.1 À 0.5M)': 2,
           '3 PEU AGITÉE (0.5 À 1.25M)': 3, 
           '0 PLATE (0M)': 0,
           '4 AGITÉE (1.25 À 2.5M)': 4, 
           '5 FORTE (2.5 À 4M)': 5,
           '6 TRÈS FORTE (4 À 6M)': 6, 
           '7 GROSSE (6 À 9M)': 7
          }

plage_col_clean.mer.replace(di_mer2, inplace=True)


# Transform OUI NON into Boolean
for col in ('operation_liee__plusieurs_victimes', 
            'fiche_bilan', 'cross_avise', 
            'codis_avise', 'samu_avise', 
            'evacuation'):
    plage_col_clean[col]= plage_col_clean[col].replace({'OUI': True, 'NON': False})*1

# Extract the city
plage_col_clean["ville"] = plage_col_clean.nom_du_poste_plage.str.split("/").apply(pd.Series).iloc[:,0].str.strip().str.split(" - ").apply(pd.Series).iloc[:,0]

# Add a unique ID
plage_col_clean['id'] = [uuid.uuid4() for x in range(len(plage_col_clean))]
plage_col_clean['id'] = plage_col_clean.id.apply(lambda x: str(x))

plage_final = plage_col_clean