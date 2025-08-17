# -*- coding: utf-8 -*-
import unittest

from transformers.coordinates import parse


class CoordinatesTest(unittest.TestCase):
    def test_coordinates(self):
        self.assertEqual((None, None), parse(""))
        self.assertEqual((None, None), parse("foo"))

        self.assertEqual((47.054833, -2.243167), parse("47°03.29'N - 002°14.59'W"))
        self.assertEqual((-47.054833, 2.243167), parse("47°03.29'S - 002°14.59'E"))
        self.assertEqual((-47.054833, 2.243167), parse("47°03.29'S / 002°14.59'E"))
        self.assertEqual((43.439, 6.919167), parse("43°26'34'N - 006°55,15'E 191.0°"))

        self.assertEqual((49.501111, -1.846944), parse("49°30'04\"N - 001°50'49\"W"))
        self.assertEqual((49.501111, -1.846944), parse("49°30'04\"N / 001°50'49\"W"))
        self.assertEqual((43.0, 6.2), parse("43°00'00N - 006°12'00E"))
        self.assertEqual((5.745, -55.24), parse("5° 44' 42'' N / 55° 14' 24'' W"))

        self.assertEqual((43.28881, 5.29848), parse("43,28881 - 5,29848"))
        self.assertEqual((-43.28881, -5.29848), parse("-43.28881 - -5.29848"))
        self.assertEqual((-20.9355, 55.277833), parse("[55.277833, -20.9355]"))
