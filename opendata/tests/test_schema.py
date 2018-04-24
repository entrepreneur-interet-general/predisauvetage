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
    MAPPING = {
        'Operation': 'operations.csv',
        'ResultatHumain': 'resultat_humain.csv',
        'Moyen': 'moyens.csv',
        'Flotteur': 'flotteurs.csv'
    }

    def test_schema_matches(self):
        open_data_schema = self.open_data_schemas()
        files = self.MAPPING.values()

        for filename in files:
            self.assertEquals(
                open_data_schema[filename],
                self.csv_schema(filename)
            )

            self.assertEquals(
                open_data_schema[filename],
                self.csv_schema('expected_' + filename)
            )

    def test_we_test_each_object_in_open_data_schema(self):
        content = self.yaml_content()

        self.assertItemsEqual(
            content.keys(),
            self.MAPPING.keys()
        )

    def csv_schema(self, filename):
        path = self.filepath('tests/files/' + filename)
        return pd.read_csv(path).columns.values.tolist()

    def open_data_schemas(self):
        content = self.yaml_content()
        acc = {}
        for object_name, values in content.items():
            acc[self.MAPPING[object_name]] = values['properties'].keys()

        return acc

    def yaml_content(self):
        with open(self.filepath('doc.yml'), 'r', encoding='utf-8') as f:
            content = yaml.load(f, Loader=yamlordereddictloader.Loader)
        return content['components']['schemas']
