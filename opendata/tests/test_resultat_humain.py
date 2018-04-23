# -*- coding: utf-8 -*-
from transformers.resultat_humain import ResultatHumainTransformer
from base import BaseTest


class TestResultatHumainTransformer(BaseTest):
    def test_basic_file(self):
        in_file = self.filepath('tests/files/resultat_humain.csv')
        expected_file = self.filepath('tests/files/expected_resultat_humain.csv')

        self.run_for_files(in_file, expected_file)

    def subject(self):
        return ResultatHumainTransformer
