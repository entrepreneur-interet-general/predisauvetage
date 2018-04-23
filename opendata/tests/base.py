# -*- coding: utf-8 -*-
import unittest
import os.path as op
import os

from transformers.base import BaseTransformer


class BaseTest(unittest.TestCase):
    def filepath(self, f):
        return op.join(op.abspath(op.join(__file__, op.pardir, op.pardir)), f)

    def run_for_files(self, in_file, expected_file):
        out_file = '/tmp/out.csv'

        self.subject()(in_file).transform(out_file)

        self.assertEquals(
            open(out_file, 'r').readlines(),
            open(expected_file, 'r').readlines(),
        )

        os.remove(out_file)

    def test_is_subclass(self):
        if self.subject() == self:
            return
        self.assertTrue(issubclass(self.subject(), BaseTransformer))

    def subject(self):
        return self
