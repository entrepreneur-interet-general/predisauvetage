# -*- coding: utf-8 -*-
import pandas as pd

from transformers.base import BaseTransformer


class MoyensTransformer(BaseTransformer):
    def __init__(self, filepath):
        super(MoyensTransformer, self).__init__(filepath)

    def transform(self, output):
        df = pd.read_csv(
            self.filepath,
            parse_dates=['date_heure_debut', 'date_heure_fin']
        )
        df.to_csv(output, index=False)
