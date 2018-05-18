# -*- coding: utf-8 -*-
from transformers.nope import NopeTransformer


class OperationsValidesTransformer(NopeTransformer):
    DATE_COLUMNS = []
