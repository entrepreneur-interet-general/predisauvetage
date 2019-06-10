# -*- coding: utf-8 -*-
from transformers.moyens import MoyensTransformer
from base import BaseTest


class TestMoyensTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath("tests/files/moyens.csv")
        expected_file = self.filepath("tests/files/expected_moyens.csv")

        self.run_for_files(in_file, expected_file)

    def subject(self):
        return MoyensTransformer
