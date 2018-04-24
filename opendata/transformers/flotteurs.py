# -*- coding: utf-8 -*-
import pandas as pd
import numpy as np
from hashlib import sha1
from os import getenv

from transformers.base import BaseTransformer


class FlotteursTransformer(BaseTransformer):
    def __init__(self, filepath):
        super(FlotteursTransformer, self).__init__(filepath)
        self.hash_cache = {np.nan: np.nan}

    def transform(self, output):
        df = pd.read_csv(self.filepath)
        df['numero_immatriculation'] = self.build_numero_immatriculation(df)
        df['assurance'] = self.assurance(df.assurance)
        self.to_csv(df, output)

    def assurance(self, series):
        return series.map({
            np.nan: np.nan,
            0.0: False,
            1.0: True
        })

    def build_numero_immatriculation(self, df):
        return df.apply(
            lambda r: self.numero_immatriculation(r, self.hash_secret()),
            axis=1
        )

    def numero_immatriculation(self, row, secret):
        val = row['numero_immatriculation']
        if val in self.hash_cache:
            return self.hash_cache[val]
        hashed = sha1('{secret}{immatriculation}'.format(
            secret=secret,
            immatriculation=val
        )).hexdigest()
        self.hash_cache[val] = hashed
        return hashed

    def hash_secret(self):
        val = getenv('SECMAR_OPENDATA_HASH_SECRET', None)
        if val is None:
            raise ValueError('Env variable SECMAR_OPENDATA_HASH_SECRET needs to be set')
        return val
