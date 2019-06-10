# -*- coding: utf-8 -*-
from transformers.moyens import MoyensTransformer
from transformers.opendata.moyens import MoyensTransformer as OpendataMoyensTransformer
from opendata.base import BaseTest


class TestMoyensTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath("tests/files/moyens.csv")
        self.run_for_files(in_file)

    def transformers(self):
        return [MoyensTransformer, OpendataMoyensTransformer]

    def test_model(self):
        self.model_is("Moyen")
