# -*- coding: utf-8 -*-
from transformers.nope import NopeTransformer


class MoyensTransformer(NopeTransformer):
    DATE_COLUMNS = ['date_heure_debut', 'date_heure_fin']
