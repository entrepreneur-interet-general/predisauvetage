# -*- coding: utf-8 -*-
from transformers.opendata.default import DefaultTransformer


class MoyensTransformer(DefaultTransformer):
    DROP_COLUMNS = ['date_heure_debut', 'date_heure_fin']
