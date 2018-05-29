# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np

from transformers.base import BaseTransformer


class OperationsTransformer(BaseTransformer):
    DATE_COLUMNS = ['date_heure_reception_alerte', 'date_heure_fin_operation']

    def __init__(self, filepath):
        super(OperationsTransformer, self).__init__(filepath)

    def transform(self, output):
        df = self.read_csv()

        df['cross_sitrep'] = df.apply(lambda r: self.cross_sitrep(r), axis=1)
        df['fuseau_horaire'] = self.fuseau_horaire(df.cross)
        df.insert(1, 'type_operation', self.type_operation(df.pourquoi_alerte))
        df['pourquoi_alerte'] = self.pourquoi_alerte(df.pourquoi_alerte)

        # Clean coordinates:
        # - 0 to NULL
        # - if at least a coordinate is null, both should be NULL
        df.replace({'latitude': {0.0: np.nan}, 'longitude': {0.0: np.nan}}, inplace=True)
        df.loc[df.longitude.isna(), 'latitude'] = np.nan
        df.loc[df.latitude.isna(), 'longitude'] = np.nan

        self.to_csv(df, output)

    def cross_sitrep(self, row):
        if pd.isna(row['numero_sitrep']):
            return np.nan
        return '{cross} {year}/{sitrep_nb}'.format(
            cross=row['cross'],
            year=row['date_heure_reception_alerte'].year,
            sitrep_nb=int(row['numero_sitrep'])
        )

    def pourquoi_alerte(self, series):
        return series.replace({r'^(SAR|MAS|DIV|SUR).*' : np.nan}, regex=True)

    def type_operation(self, series):
        return series.replace(
                {r'^(SAR|MAS|DIV|SUR).*' : r'\1'}, regex=True
            ).replace(
                {r'^(?!SAR|MAS|DIV|SUR).*' : np.nan}, regex=True
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
