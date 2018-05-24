# -*- coding: utf-8 -*-
import unittest
import os.path as op
import os

import pandas as pd


class BaseTest(unittest.TestCase):
    def filepath(self, f):
        return op.join(op.abspath(op.join(__file__, op.pardir, op.pardir, op.pardir)), f)

    def run_for_files(self, in_file):
        out_file = '/tmp/out.csv'

        first_transformer, second_transformer = self.transformers()

        first_transformer(in_file).transform(out_file)

        # Columns that we need to drop exist
        df = pd.read_csv(out_file)
        for col in self.cols_to_delete():
            self.assertIn(col, df.columns.values)

        second_transformer(out_file).transform(out_file)

        # Columns that we need to drop have been dropped
        df = pd.read_csv(out_file)
        for col in self.cols_to_delete():
            self.assertNotIn(col, df.columns.values)

        os.remove(out_file)

    def cols_to_delete(self):
        return (self.transformers()[1]).DROP_COLUMNS

    def transformers(self):
        raise NotImplementedError
