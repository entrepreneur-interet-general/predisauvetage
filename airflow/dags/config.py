# -*- coding: utf-8 -*-

from transformers.flotteurs import FlotteursTransformer
from transformers.operations import OperationsTransformer
from transformers.moyens import MoyensTransformer
from transformers.resultats_humain import ResultatHumainTransformer

SECMAR_TABLES = [
    'flotteurs',
    'operations',
    'moyens',
    'resultats_humain'
]


def secmar_transformer(key):
    return {
        'flotteurs': FlotteursTransformer,
        'operations': OperationsTransformer,
        'moyens': MoyensTransformer,
        'resultats_humain': ResultatHumainTransformer,
    }[key]
