# -*- coding: utf-8 -*-
import yaml
import yamlordereddictloader
import pandas as pd
from codecs import open

from base import BaseTest


class TestSchemaMatches(BaseTest):
    """
    Make sure that CSV files we are testing are in sync the OpenAPI schema
    """

    MODELS = [
        "operations",
        "resultats_humain",
        "moyens",
        "flotteurs",
        "operations_stats",
        "moyens_snsm",
    ]

    AGGREGATES = ["operations_stats", "moyens_snsm"]

    def test_schema_matches(self):
        open_data_schema = self.open_data_schemas()
        tables = self.transformers_mapping()

        for table_name in tables:
            self.assertEquals(
                open_data_schema[table_name],
                self.csv_schema("expected_" + table_name + ".csv"),
            )

    def test_we_test_each_object_in_open_data_schema(self):
        content = self.yaml_content()

        self.assertEquals(
            set(content.keys()) - set(self.AGGREGATES), set(self.transformers_mapping())
        )

    def transformers_mapping(self):
        return [m for m in self.MODELS if m not in self.AGGREGATES]

    def csv_schema(self, filename):
        path = self.filepath("tests/files/" + filename)
        return pd.read_csv(path).columns.values.tolist()

    def open_data_schemas(self):
        content = self.yaml_content()
        acc = {}
        for object_name, values in content.items():
            acc[object_name] = list(values["properties"].keys())

        return acc

    def yaml_content(self):
        with open(self.filepath("doc.yml"), "r", encoding="utf-8") as f:
            content = yaml.load(f, Loader=yamlordereddictloader.Loader)
        return content["components"]["schemas"]
