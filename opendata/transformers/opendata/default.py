# -*- coding: utf-8 -*-
from transformers.base import BaseTransformer
from transformers.opendata.config import ColumnDropper
import os.path as op


class DefaultTransformer(BaseTransformer):
    MODEL = None

    def __init__(self, filepath):
        super(DefaultTransformer, self).__init__(filepath)

    def transform(self, output):
        df = self.read_csv()

        cols_to_drop = self.columns_to_drop()
        if len(cols_to_drop) > 0:
            df.drop(cols_to_drop, axis=1, inplace=True)

        self.to_csv(df, output)

    def columns_to_drop(self):
        return self.column_dropper().for_model(self.MODEL)

    def column_dropper(self):
        return ColumnDropper(self.resolve_filepath('config/drop_columns.json'))

    def resolve_filepath(self, f):
        return op.join(op.abspath(op.join(__file__, op.pardir, op.pardir, op.pardir)), f)
