# -*- coding: utf-8 -*-
from transformers.base import BaseTransformer


class NopeTransformer(BaseTransformer):
    def __init__(self, filepath):
        super(NopeTransformer, self).__init__(filepath)

    def transform(self, output):
        self.to_csv(self.read_csv(), output)
