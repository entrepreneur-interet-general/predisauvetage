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

        self.assertEqual((49.501111, -1.846944), parse("49°30'04\"N - 001°50'49\"W"))
        self.assertEqual((49.501111, -1.846944), parse("49°30'04\"N / 001°50'49\"W"))
        self.assertEqual((43.0, 6.2), parse("43°00'00N - 006°12'00E"))

        self.assertEqual((43.28881, 5.29848), parse("43,28881 - 5,29848"))
        self.assertEqual((-43.28881, -5.29848), parse("-43.28881 - -5.29848"))
