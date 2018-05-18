# -*- coding: utf-8 -*-
from transformers.operations_valides import OperationsValidesTransformer
from base import BaseTest


class TestOperationsValidesTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath('tests/files/operations_valides.csv')
        expected_file = self.filepath('tests/files/expected_operations_valides.csv')

        self.run_for_files(in_file, expected_file)

    def subject(self):
        return OperationsValidesTransformer
