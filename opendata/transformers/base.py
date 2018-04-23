# -*- coding: utf-8 -*-


class BaseTransformer(object):
    ISO_FORMAT = '%Y-%m-%dT%H:%M:%SZ'

    def __init__(self, filepath):
        super(BaseTransformer, self).__init__()
        self.filepath = filepath

    def to_csv(self, df, output):
        # Keep floats with up to 12 decimal if they need it, otherwise display as int
        # https://stackoverflow.com/questions/25789354/exporting-ints-with-missing-values-to-csv-in-pandas
        df.to_csv(
            output,
            index=False,
            float_format='%.12g',
            date_format=self.ISO_FORMAT
        )
