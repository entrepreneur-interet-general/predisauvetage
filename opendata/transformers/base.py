# -*- coding: utf-8 -*-
import pandas as pd


class BaseTransformer(object):
    ISO_FORMAT = '%Y-%m-%dT%H:%M:%SZ'
    DATE_COLUMNS = []

    def __init__(self, filepath):
        super(BaseTransformer, self).__init__()
        self.filepath = filepath

    def read_csv(self):
        return pd.read_csv(
            self.filepath,
            delimiter=',',
            parse_dates=self.DATE_COLUMNS,
            true_values=['Y'],
            false_values=['N']
        )

    def to_csv(self, df, output):
        # Keep floats with up to 12 decimal if they need it, otherwise display as int
        # https://stackoverflow.com/questions/25789354/exporting-ints-with-missing-values-to-csv-in-pandas
        for date_col in self.DATE_COLUMNS:
            df[date_col] = df[date_col].astype('datetime64[ns]')
        df.to_csv(
            output,
            index=False,
            float_format='%.12g',
            date_format=self.ISO_FORMAT
        )
