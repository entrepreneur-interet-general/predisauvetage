# -*- coding: utf-8 -*-
import unittest

from converters import CoordinatesConverter, SitRepConverter


class TestSitRepConverter(unittest.TestCase):
    def runner(self, cases, fn):
        for test_case, expected in cases:
            self.assertEquals(
                fn(test_case),
                expected
            )

    def test_extract_sitrep_name(self):
        cases = [
            (u'SITREP SAR UN ET FINAL - CROSS RÉUNION/2017/0722', u'RÉUNION/2017/0722'),
            (u'SITREP SAR UN ET FINAL - CROSS REUNION/2017/0724', u'RÉUNION/2017/0724'),
            (u'SITREP SAR UN ET FINAL - CROSS GRIS NEZ/2017/0712', u'GRIS-NEZ/2017/0712'),
            (u'SITREP SAR UN  ET FINAL - CROSS GRIS-NEZ/2017/0849 TOUTES HEURES UTC', u'GRIS-NEZ/2017/0849'),
            (u'PAS DE SITREP RECU - OP CODEE', None)
        ]
        self.runner(cases, SitRepConverter.extract_sitrep_name)

    def test_extract_cross(self):
        cases = [
            (u'SITREP SAR UN ET FINAL - CROSS RÉUNION/2017/0722', u'RÉUNION'),
            (u'SITREP SAR UN  ET FINAL - CROSS GRIS-NEZ/2017/0849 TOUTES HEURES UTC', u'GRIS-NEZ'),
            (u'PAS DE SITREP RECU - OP CODEE', None),
            (None, None)
        ]
        self.runner(cases, SitRepConverter.extract_cross)

    def test_extract_operation_type(self):
        cases = [
            (u'SITREP SAR UN ET FINAL - CROSS RÉUNION/2017/0722', u'SAR'),
            (u'SITREP MAS UN  ET FINAL - CROSS GRIS-NEZ/2017/0849 TOUTES HEURES UTC', u'MAS'),
            (u'SITREP DIV UN  ET FINAL - - CROSS LA GARDE/2017/0111 TOUTES HEURES UTC', u'DIV'),
            (u'PAS DE SITREP RECU - OP CODEE', None),
            (None, None)
        ]
        self.runner(cases, SitRepConverter.extract_operation_type)


class TestCoordinatesConverter(unittest.TestCase):
    def test_dms_to_dd(self):
        cases = [
            ((u"20°52'S", u"2°47'W"), (-20.8667, -2.7833)),
            ((u"48°38'N", u"004°17'O"), (48.6333, -4.2833)),
            ((u"48°38'N", u"004°17O"), (48.6333, None)),
            ((u"48°38N", u"004°17'O"), (None, -4.2833)),
            ((u"48°38W", u"004°17Z"), (None, None)),
        ]

        for test_case, truth in cases:
            coordinates = CoordinatesConverter.dms_to_dd(*test_case)
            for result, expected in zip(coordinates, truth):
                msg = "Failed got %s but expected %s" % (coordinates, truth)
                if expected is None:
                    self.assertEquals(result, expected, msg=msg)
                else:
                    self.assertAlmostEqual(
                        result,
                        expected,
                        places=4,
                        msg=msg
                    )

