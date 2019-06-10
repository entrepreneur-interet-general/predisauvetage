# -*- coding: utf-8 -*-
from transformers.operations import OperationsTransformer
from base import BaseTest


class TestOperationsTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath("tests/files/operations.csv")
        expected_file = self.filepath("tests/files/expected_operations.csv")

        self.run_for_files(in_file, expected_file)

    def subject(self):
        return OperationsTransformer
