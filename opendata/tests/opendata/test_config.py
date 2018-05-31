# -*- coding: utf-8 -*-
from transformers.opendata.config import ColumnDropper
from opendata.base import BaseTest


class TestColumnDropper(BaseTest):
    def subject(self):
        return ColumnDropper(self.filepath('config/drop_columns.json'))

    def test_for_table(self):
        conf = self.subject()

        self.assertEquals([], conf.for_table('operations'))
        self.assertEquals(['date_heure_debut', 'date_heure_fin'], conf.for_table('moyens'))

    def test_for_model(self):
        conf = self.subject()

        self.assertEquals([], conf.for_model('Operation'))
        self.assertEquals(['date_heure_debut', 'date_heure_fin'], conf.for_model('Moyen'))
