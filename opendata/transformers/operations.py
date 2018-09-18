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

        df['numero_sitrep'] = df.apply(lambda r: self.numero_sitrep(r), axis=1)
        df['cross_sitrep'] = df.apply(lambda r: self.cross_sitrep(r), axis=1)
        df['fuseau_horaire'] = self.fuseau_horaire(df.cross)
        df.insert(1, 'type_operation', self.type_operation(df.pourquoi_alerte))
        df['pourquoi_alerte'] = self.pourquoi_alerte(df.pourquoi_alerte)
        df.insert(
            loc=df.columns.get_loc('vent_direction') + 1,
            column='vent_direction_categorie',
            value=self.vent_direction_categorie(df.vent_direction)
        )
        df['evenement'].replace(
            to_replace='Plongée en bouteille',
            value='Plongée avec bouteille',
            inplace=True
        )

        # Clean coordinates:
        # - 0 to NULL
        # - if at least a coordinate is null, both should be NULL
        df.replace({'latitude': {0.0: np.nan}, 'longitude': {0.0: np.nan}}, inplace=True)
        df.loc[df.longitude.isna(), 'latitude'] = np.nan
        df.loc[df.latitude.isna(), 'longitude'] = np.nan

        self.to_csv(df, output)

    def vent_direction_categorie(self, series):
        bins = [0, 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5, np.inf]
        labels = [
            'nord', 'nord-est', 'est', 'sud-est', 'sud',
            'sud-ouest', 'ouest', 'nord-ouest', 'nord2'
        ]
        return pd.cut(series, bins=bins, labels=labels) \
            .replace('nord2', 'nord')

    def numero_sitrep(self, row):
        if pd.isna(row['numero_sitrep']):
            # If operation_id: 2120050002
            # 21: CROSS code
            # 2005: year
            # 0002: sitrep
            operation_id = str(int(row['operation_id']))
            if len(operation_id) != 10:
                msg = 'Unexpected length for operation_id ' + operation_id
                raise ValueError(msg)
            return int(operation_id[6:10])
        return row['numero_sitrep']

    def cross_sitrep(self, row):
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
            'Nouvelle-Calédonie': 'Pacific/Noumea',
            'Polynésie': 'Pacific/Tahiti',
            'Soulac': 'Europe/Paris',
            'Étel': 'Europe/Paris',
        })
