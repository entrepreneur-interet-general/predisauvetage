# -*- coding: utf-8 -*-
from transformers.flotteurs import FlotteursTransformer
from transformers.operations import OperationsTransformer
from transformers.moyens import MoyensTransformer
from transformers.resultats_humain import ResultatHumainTransformer
from transformers.operations_stats import OperationsStatsTransformer
from transformers.operations_valides import OperationsValidesTransformer

import helpers

SECMAR_TABLES = [
    'flotteurs',
    'operations',
    'moyens',
    'resultats_humain',
]


def in_path(table):
    return helpers.data_path('in_' + table + '.csv')


def out_path(table):
    return helpers.data_path('out_' + table + '.csv')


def secmar_transform(in_path, out_path, transformer, **kwargs):
    transformer(in_path).transform(out_path)


def secmar_transformer(key):
    return {
        'flotteurs': FlotteursTransformer,
        'operations': OperationsTransformer,
        'moyens': MoyensTransformer,
        'resultats_humain': ResultatHumainTransformer,
        'operations_stats': OperationsStatsTransformer,
        'operations_valides': OperationsValidesTransformer,
    }[key]
