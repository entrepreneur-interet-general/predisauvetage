# -*- coding: utf-8 -*-
from transformers.nope import NopeTransformer
import numpy as np


class MoyensTransformer(NopeTransformer):
    DATE_COLUMNS = ['date_heure_debut', 'date_heure_fin']

    def transform(self, output):
        df = self.read_csv()
        df['duree_engagement_minutes'] = df.apply(lambda r: self.duree_engagement_minutes(r), axis=1)
        self.to_csv(df, output)

    def duree_engagement_minutes(self, row):
        duration = row['date_heure_fin'] - row['date_heure_debut']
        return duration / np.timedelta64(1, 'm')
