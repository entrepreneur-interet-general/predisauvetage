# -*- coding: utf-8 -*-
from transformers.resultats_humain import ResultatsHumainTransformer
from base import BaseTest


class TestResultatsHumainTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath("tests/files/resultats_humain.csv")
        expected_file = self.filepath("tests/files/expected_resultats_humain.csv")

        self.run_for_files(in_file, expected_file)

    def subject(self):
        return ResultatsHumainTransformer
