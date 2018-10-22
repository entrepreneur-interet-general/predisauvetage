# -*- coding: utf-8 -*-
import datetime

import pandas as pd


class BaseTransformer(object):
    ISO_FORMAT = '%Y-%m-%dT%H:%M:%SZ'
    DATE_COLUMNS = []
    CSV_DTYPE = None

    def __init__(self, filepath):
        super(BaseTransformer, self).__init__()
        self.filepath = filepath

    def read_csv(self):
        return pd.read_csv(
            self.filepath,
            delimiter=',',
            converters=self.date_converters(),
            true_values=['Y'],
            false_values=['N'],
            dtype=self.CSV_DTYPE
        )

    def to_csv(self, df, output):
        # Cast dates columns
        for date_col in [c for c in self.DATE_COLUMNS if c in df.columns]:
            df[date_col] = df[date_col].astype('datetime64[ns]')

        # Sort by operation_id
        df.sort_values(by=['operation_id'], inplace=True)

        # Keep floats with up to 12 decimal if they need it, otherwise display as int
        # https://stackoverflow.com/questions/25789354/exporting-ints-with-missing-values-to-csv-in-pandas
        df.to_csv(
            output,
            index=False,
            float_format='%.12g',
            date_format=self.ISO_FORMAT
        )

    def date_converters(self):
        def to_datetime(val):
            formats = [
                '%Y-%m-%d %H:%M:%S.%f %z',
                '%Y-%m-%d %H:%M:%S',
                '%Y-%m-%d %H:%M:%S%z'
            ]
            for date_format in formats:
                try:
                    return datetime.datetime.strptime(val, date_format)
                except ValueError:
                    pass
            raise ValueError('Cannot parse ' + val)
        res = {}
        for col in self.DATE_COLUMNS:
            res[col] = to_datetime
        return res
