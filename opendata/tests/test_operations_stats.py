# -*- coding: utf-8 -*-
from transformers.operations_stats import OperationsStatsTransformer
from base import BaseTest


class TestOperationsStatsTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath("tests/files/operations_stats.csv")
        expected_file = self.filepath("tests/files/expected_operations_stats.csv")

        self.run_for_files(in_file, expected_file)

    def subject(self):
        return OperationsStatsTransformer
