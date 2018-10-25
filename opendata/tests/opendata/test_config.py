# -*- coding: utf-8 -*-
from transformers.opendata.config import ColumnDropper
from transformers.opendata.config import ModelDropper
from transformers.opendata.config import ModelRenamer
from opendata.base import BaseTest


class TestColumnDropper(BaseTest):
    def subject(self):
        return ColumnDropper(self.filepath('config/filter_doc.json'))

    def test_for_table(self):
        conf = self.subject()

        self.assertEquals([], conf.for_table('operations'))
        self.assertEquals(['date_heure_debut', 'date_heure_fin'], conf.for_table('moyens'))
        with self.assertRaises(KeyError):
            conf.for_table('nope')

    def test_for_model(self):
        conf = self.subject()

        self.assertEquals([], conf.for_model('Operation'))
        self.assertEquals(['date_heure_debut', 'date_heure_fin'], conf.for_model('Moyen'))

        with self.assertRaises(KeyError):
            conf.for_model('nope')


class TestModelDropper(BaseTest):
    def subject(self):
        return ModelDropper(self.filepath('config/filter_doc.json'))

    def test_for_table(self):
        conf = self.subject()

        self.assertTrue(conf.for_table('moyens_snsm'))
        self.assertFalse(conf.for_table('operations'))

        self.assertFalse(conf.for_table('nope'))

    def test_for_model(self):
        conf = self.subject()

        self.assertTrue(conf.for_model('MoyenSNSM'))
        self.assertFalse(conf.for_model('Operation'))

        with self.assertRaises(KeyError):
            conf.for_model('nope')


class TestModelRenamer(BaseTest):
    def subject(self):
        return ModelRenamer(self.filepath('config/filter_doc.json'))

    def test_model_to_table(self):
        subject = self.subject()

        self.assertEquals(subject.model_to_table('Operation'), 'operations')
        self.assertEquals(subject.model_to_table('MoyenSNSM'), 'moyens_snsm')

        with self.assertRaises(KeyError):
            subject.model_to_table('nope')
