# -*- coding: utf-8 -*-
import pandas as pd
from sunrise_sunset import SunriseSunset
from datetime import timedelta


def statut_journee(row):
    base = row['date_reception_alerte']
    latitude, longitude = row['latitude'], row['longitude']
    sunrise, sunset = SunriseSunset(base, latitude, longitude).calculate()
    if sunrise + timedelta(minutes=30) <= base <= sunset - timedelta(minutes=30):
        return 'jour'
    return 'nuit'


def agg_resultat_humain(row):
    if row['resultat_humain'] == 'Personne disparue':
        return 'Personne décédée accidentellement'
    return row['resultat_humain']

df = pd.read_csv('homme_a_la_mer.csv', delimiter=',', parse_dates=['date_reception_alerte'])
df = df[pd.notnull(df.est_metropolitain)]
df = df[df.est_metropolitain]
df['resultat_humain'] = df.apply(lambda row:  agg_resultat_humain(row), axis=1)
df['statut_journee'] = df.apply(lambda row: statut_journee(row), axis=1)
df['annee'] = df.apply(lambda row: row['date_reception_alerte'].year, axis=1)
df['mois'] = df.apply(lambda row: row['date_reception_alerte'].month, axis=1)
df.to_csv('res.csv', index=False)

print df[['operation_id', 'statut_journee']].drop_duplicates(keep='first').statut_journee.value_counts()

df2 = df.groupby(['statut_journee', 'resultat_humain', 'mois']).agg({'nb_personnes': 'sum', 'operation_id': 'nunique'})
df2 = df2.rename(columns={'operation_id': 'nb_operations'})
df2.to_csv('homme_mer_mois.csv')

df3 = df.groupby(['statut_journee', 'resultat_humain']).agg({'nb_personnes': 'sum', 'operation_id': 'nunique'})
df3 = df3.rename(columns={'operation_id': 'nb_operations'})
df3.to_csv('homme_mer_statut_journee.csv')
