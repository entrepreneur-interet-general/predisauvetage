# -*- coding: utf-8 -*-
import pandas as pd
from pandas.util.testing import assert_frame_equal
import os
import unittest

from collecte.postes_plage_snsm.convert import KMLConverter


class TesKMLConverter(unittest.TestCase):
    def filepath(self, filename):
        return os.path.abspath(__file__ + "/../../../tests/files/" + filename)

    def test_parse(self):
        input_file = self.filepath("snsm-postes-secours.kml")
        test_file = self.filepath("snsm-postes-secours.csv")
        output_file = '/tmp/out.csv'
        KMLConverter(input_file).to_csv(output_file)

        assert_frame_equal(
            pd.read_csv(test_file, encoding='utf-8'),
            pd.read_csv(output_file, encoding='utf-8')
        )

        os.remove(output_file)
