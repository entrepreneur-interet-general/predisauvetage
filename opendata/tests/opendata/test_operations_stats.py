# -*- coding: utf-8 -*-
from transformers.opendata.operations_stats import OperationsStatsTransformer
from opendata.base import BaseTest


class TestOperationsStatsTransformer(BaseTest):
    def test_columns(self):
        self.assertEquals(
            OperationsStatsTransformer('/tmp/fake').columns_to_drop(),
            ['concerne_snosan']
        )

    def transformers(self):
        return [None, OperationsStatsTransformer]

    def test_model(self):
        self.model_is('OperationStats')
