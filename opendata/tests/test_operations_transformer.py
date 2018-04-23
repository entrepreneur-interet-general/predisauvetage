# -*- coding: utf-8 -*-
import unittest
import os.path as op
import os

from transformers.operations import OperationsTransformer


def filepath(f):
    return op.join(op.abspath(op.join(__file__, op.pardir, op.pardir)), f)


class TestOperationsTransformer(unittest.TestCase):
    def test_simple_config(self):
        in_file = filepath('tests/files/operations.csv')
        expected_file = filepath('tests/files/expected_operations.csv')

        self.run_for_files(in_file, expected_file)

    def run_for_files(self, in_file, expected_file):
        out_file = '/tmp/out.csv'

        OperationsTransformer(in_file).transform(out_file)

        self.assertEquals(
            open(out_file, 'r').readlines(),
            open(expected_file, 'r').readlines(),
        )

        os.remove(out_file)
