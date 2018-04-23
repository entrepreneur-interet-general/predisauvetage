# -*- coding: utf-8 -*-
import pandas as pd

from transformers.base import BaseTransformer


class ResultatHumainTransformer(BaseTransformer):
    def __init__(self, filepath):
        super(ResultatHumainTransformer, self).__init__(filepath)

    def transform(self, output):
        df = pd.read_csv(self.filepath)
        df['categorie_personne'] = df.categorie_personne.replace('Toutes catégories avant 10/08/09', 'Toutes catégories')

        self.to_csv(df, output)
