# -*- coding: utf-8 -*-
from transformers.resultats_humain import ResultatsHumainTransformer
from transformers.opendata.resultats_humain import (
    ResultatsHumainTransformer as OpendataResultatsHumainTransformer,
)
from opendata.base import BaseTest


class TestResultatsHumainTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath("tests/files/resultats_humain.csv")
        self.run_for_files(in_file)

    def transformers(self):
        return [ResultatsHumainTransformer, OpendataResultatsHumainTransformer]

    def test_model(self):
        self.model_is("ResultatHumain")
