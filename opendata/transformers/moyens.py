# -*- coding: utf-8 -*-
from transformers.base import BaseTransformer


class MoyensTransformer(BaseTransformer):
    DATE_COLUMNS = ['date_heure_debut', 'date_heure_fin']

    def __init__(self, filepath):
        super(MoyensTransformer, self).__init__(filepath)

    def transform(self, output):
        self.to_csv(self.read_csv(), output)
