# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np

from transformers.base import BaseTransformer


class OperationsTransformer(BaseTransformer):
    def __init__(self, filepath):
        super(OperationsTransformer, self).__init__(filepath)

    def transform(self, output):
        df = pd.read_csv(
            self.filepath,
            delimiter=',',
            parse_dates=['date_heure_reception_alerte', 'date_heure_fin_operation'],
            true_values=['Y'],
            false_values=['N']
        )
        df['cross_sitrep'] = df.apply(lambda r: self.cross_sitrep(r), axis=1)
        df['fuseau_horaire'] = self.fuseau_horaire(df.cross)
        df['pourquoi_alerte'] = df.pourquoi_alerte.replace({r'^(SAR|MAS|DIV|SUR).*' : r'\1'}, regex=True)
        df.to_csv(output, index=False)

    def cross_sitrep(self, row):
        if pd.isna(row['numero_sitrep']):
            return np.nan
        return '{cross} {year}/{sitrep_nb}'.format(
            cross=row['cross'],
            year=row['date_heure_reception_alerte'].year,
            sitrep_nb=int(row['numero_sitrep'])
        )

    def fuseau_horaire(self, series):
        return series.map({
            'Adge': 'Europe/Paris',
            'Antilles-Guyane': 'America/Cayenne',
            'Corse': 'Europe/Paris',
            'Corsen': 'Europe/Paris',
            'Gris-Nez': 'Europe/Paris',
            'Guadeloupe': 'America/Guadeloupe',
            'Guyane': 'America/Guyana',
            'Jobourg': 'Europe/Paris',
            'La Garde': 'Europe/Paris',
            'La Réunion': 'Indian/Reunion',
            'Martinique': 'America/Martinique',
            'Mayotte': 'Indian/Mayotte',
            'Nouvelle-Calédonie': 'Pacific/Tahiti',
            'Polynésie': 'Pacific/Noumea',
            'Soulac': 'Europe/Paris',
            'Étel': 'Europe/Paris',
        })
