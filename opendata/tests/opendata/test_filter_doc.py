# -*- coding: utf-8 -*-
import os

from transformers.opendata.filter_doc import FilterYamlDocumentation
from opendata.base import BaseTest


class TestFilterYamlDocumentation(BaseTest):
    def subject(self):
        return FilterYamlDocumentation(self.filepath('tests/files/drop_columns.json'))

    def test_filter_yaml(self):
        expected_file = self.filepath('tests/files/expected_doc.yml')
        out_file = '/tmp/doc.yml'

        self.subject().filter_yaml(
            self.filepath('tests/files/doc.yml'),
            out_file
        )

        self.assertEquals(
            open(out_file, 'r').readlines(),
            open(expected_file, 'r').readlines(),
        )

        os.remove(out_file)
