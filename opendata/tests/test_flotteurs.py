# -*- coding: utf-8 -*-
from transformers.flotteurs import FlotteursTransformer
from base import BaseTest


class TestFlotteursTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath('tests/files/flotteurs.csv')
        expected_file = self.filepath('tests/files/expected_flotteurs.csv')

        self.run_for_files(in_file, expected_file)

    def subject(self):
        return FlotteursTransformer
