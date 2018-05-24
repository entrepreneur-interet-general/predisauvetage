# -*- coding: utf-8 -*-
from transformers.opendata.operations_stats import OperationsStatsTransformer
from opendata.base import BaseTest


class TestOperationsStatsTransformer(BaseTest):
    def test_columns(self):
        self.assertEquals(
            OperationsStatsTransformer.DROP_COLUMNS,
            ['concerne_snosan']
        )
