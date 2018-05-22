# -*- coding: utf-8 -*-
from transformers.opendata.default import DefaultTransformer


class OperationsStatsTransformer(DefaultTransformer):
    DROP_COLUMNS = ['concerne_snosan']
