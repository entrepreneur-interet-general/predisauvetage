# -*- coding: utf-8 -*-
from __future__ import print_function

import pandas as pd


class MoyensTransformer(object):
    def __init__(self, filepath):
        super(MoyensTransformer, self).__init__()
        self.filepath = filepath

    def transform(self, output):
        df = pd.read_csv(
            self.filepath,
            parse_dates=['date_heure_debut', 'date_heure_fin']
        )
        df.to_csv(output, index=False)
