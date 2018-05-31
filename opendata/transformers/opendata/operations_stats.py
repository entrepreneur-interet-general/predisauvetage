# -*- coding: utf-8 -*-
from transformers.opendata.default import DefaultTransformer


class OperationsStatsTransformer(DefaultTransformer):
    MODEL = 'OperationStats'
