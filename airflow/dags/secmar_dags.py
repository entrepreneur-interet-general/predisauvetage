# -*- coding: utf-8 -*-
import datetime

from transformers.flotteurs import FlotteursTransformer
from transformers.operations import OperationsTransformer
from transformers.moyens import MoyensTransformer
from transformers.resultats_humain import ResultatsHumainTransformer
from transformers.operations_stats import OperationsStatsTransformer
from transformers.operations_valides import OperationsValidesTransformer
from transformers.opendata.flotteurs import FlotteursTransformer as OpendataFlotteursTransformer
from transformers.opendata.operations import OperationsTransformer as OpendataOperationsTransformer
from transformers.opendata.moyens import MoyensTransformer as OpendataMoyensTransformer
from transformers.opendata.resultats_humain import ResultatsHumainTransformer as OpendataResultatsHumainTransformer
from transformers.opendata.operations_stats import OperationsStatsTransformer as OpendataOperationsStatsTransformer

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


def opendata_path(table):
    return helpers.opendata_folder_path() + '/' + table + '.csv'


def secmar_transform(in_path, out_path, transformer, **kwargs):
    transformer(in_path).transform(out_path)


def secmar_transformer(key):
    return {
        'flotteurs': FlotteursTransformer,
        'operations': OperationsTransformer,
        'moyens': MoyensTransformer,
        'resultats_humain': ResultatsHumainTransformer,
        'operations_stats': OperationsStatsTransformer,
        'operations_valides': OperationsValidesTransformer,
    }[key]


def opendata_transformer(key):
    return {
        'flotteurs': OpendataFlotteursTransformer,
        'operations': OpendataOperationsTransformer,
        'moyens': OpendataMoyensTransformer,
        'resultats_humain': OpendataResultatsHumainTransformer,
        'operations_stats': OpendataOperationsStatsTransformer,
    }[key]
