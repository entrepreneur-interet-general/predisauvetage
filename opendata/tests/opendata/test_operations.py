# -*- coding: utf-8 -*-
from transformers.operations import OperationsTransformer
from transformers.opendata.operations import OperationsTransformer as OpendataOperationsTransformer
from opendata.base import BaseTest


class TestOperationsTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath('tests/files/operations.csv')
        self.run_for_files(in_file)

    def transformers(self):
        return [
            OperationsTransformer,
            OpendataOperationsTransformer
        ]

    def test_model(self):
        self.model_is('Operation')
