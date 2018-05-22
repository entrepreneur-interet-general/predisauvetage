# -*- coding: utf-8 -*-
from transformers.base import BaseTransformer


class DefaultTransformer(BaseTransformer):
    DROP_COLUMNS = []

    def __init__(self, filepath):
        super(DefaultTransformer, self).__init__(filepath)

    def transform(self, output):
        df = self.read_csv()

        if len(self.DROP_COLUMNS) > 0:
            df.drop(self.DROP_COLUMNS, axis=1, inplace=True)

        self.to_csv(df, output)
