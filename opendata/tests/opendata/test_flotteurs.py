# -*- coding: utf-8 -*-
from transformers.flotteurs import FlotteursTransformer
from transformers.opendata.flotteurs import (
    FlotteursTransformer as OpendataFlotteursTransformer,
)
from opendata.base import BaseTest


class TestFlotteursTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath("tests/files/flotteurs.csv")
        self.run_for_files(in_file)

    def transformers(self):
        return [FlotteursTransformer, OpendataFlotteursTransformer]

    def test_model(self):
        self.model_is("Flotteur")
