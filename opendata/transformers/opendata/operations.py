# -*- coding: utf-8 -*-
from transformers.opendata.default import DefaultTransformer


class OperationsTransformer(DefaultTransformer):
    MODEL = 'Operation'
