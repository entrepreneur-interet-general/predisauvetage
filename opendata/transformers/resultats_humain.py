# -*- coding: utf-8 -*-
from transformers.base import BaseTransformer


class ResultatsHumainTransformer(BaseTransformer):
    def __init__(self, filepath):
        super(ResultatsHumainTransformer, self).__init__(filepath)

    def transform(self, output):
        df = self.read_csv()
        df["categorie_personne"] = df.categorie_personne.replace(
            "Toutes catégories avant 10/08/09", "Toutes catégories"
        )

        self.to_csv(df, output)
