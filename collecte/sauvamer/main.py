# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np

from collecte.sauvamer.converters import CoordinatesConverter, SitRepConverter

COLS_NAME = [
    'numero_etablissement', 'numero_rapport',
    'mer', 'zone_intervention', 'date_saisie',
    'compte_rendu_patron', 'commentaires_patron',
    'nom_etablissement', 'zone_littorale',
    'code_postal', 'type_rapport',
    'date_sortie', 'date_alerte',
    'motif_alerte', 'fausse_alerte',
    'nb_personnes_tirees_seules',
    'nb_personnes_secourues',
    'nb_personnes_disparues',
    'nb_personnes_decedees',
    'nom_navire',
    'type_embarcation',
    'resultat_embarcation',
    'moyen_principal',
    'position_latitude',
    'position_longitude',
    'delai_appareillage_minutes',
    'duree_reelle_minutes',
    'details_sitrep'
]


def zone_intervention_converter(src):
    mapping = {
        'Eaux Territoriales (300 m à 12 nq)': 'eaux-territoriales',
        'Plage et 300m': 'plage-300m',
        'Eaux Françaises (sup. à 12 nq)': 'eaux-francaises',
        'Eaux Etrangères': 'eaux-etrangeres',
    }
    return mapping.get(src.encode('utf-8'), np.nan)


def douglas_converter(src):
    mapping = {
        'calme': 0,
        'plate': 0,
        'ridée': 1,
        'belle': 2,
        'peu agitée': 3,
        'agitée': 4,
        'forte': 5,
        'très forte': 6,
        'grosse': 7,
        'très grosse': 8,
        'énorme': 9,
    }
    for start, code in mapping.iteritems():
        if src.encode('utf-8').lower().startswith(start):
            return code
    return np.nan

df = pd.read_excel(
    '/Users/antoineaugusti/Desktop/sauvamer.xlsx',
    names=COLS_NAME,
    converters={
        'Mer (Douglas)': douglas_converter,
        "Zone d'intervention": zone_intervention_converter,
        "Zone littorale": lambda e: e.lower().replace(' ', '_'),
        "Fausse alerte": lambda e: e == 'Oui',
        "CP": lambda e: int(e),
        "Position latitude": CoordinatesConverter.latitude_dms_to_dd,
        "Position longitude": CoordinatesConverter.longitude_dms_to_dd,
    },
)

df['numero_sitrep'] = df.details_sitrep.apply(SitRepConverter.extract_sitrep_name)
df['cross'] = df.details_sitrep.apply(SitRepConverter.extract_cross)
df['type_operation'] = df.details_sitrep.apply(SitRepConverter.extract_operation_type)

if not (df.type_rapport == 'Sauvetage').all():
    raise ValueError('Tous les rapports doivent être des sauvetages')

print df['mer'].value_counts(dropna=False)
print df['zone_intervention'].value_counts(dropna=False)
print df['zone_littorale'].value_counts(dropna=False)
print df['fausse_alerte'].value_counts(dropna=False)
print df['motif_alerte'].value_counts(dropna=False)
print df['position_latitude'].value_counts(dropna=False)
print df['position_longitude'].value_counts(dropna=False)
print df['cross'].value_counts(dropna=False)
print df['type_operation'].value_counts(dropna=False)

# print df.head(10)
