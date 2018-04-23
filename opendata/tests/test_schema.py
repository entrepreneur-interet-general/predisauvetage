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
    def test_schema_matches(self):
        open_data_schema = self.open_data_schemas()
        files = ['operations.csv', 'resultat_humain.csv', 'moyens.csv']
        expected_files = map(lambda e: 'expected_' + e, files)

        for file in files + expected_files:
            self.assertEquals(
                open_data_schema[file.replace('expected_', '')],
                self.csv_schema(file)
            )

    def csv_schema(self, filename):
        path = self.filepath('tests/files/' + filename)
        return pd.read_csv(path).columns.values.tolist()

    def open_data_schemas(self):
        mapping = {
            'Operation': 'operations.csv',
            'ResultatHumain': 'resultat_humain.csv',
            'Moyen': 'moyens.csv',
            'Flotteur': 'flotteurs.csv'
        }
        with open(self.filepath('doc.yml'), 'r', encoding='utf-8') as f:
            content = yaml.load(f, Loader=yamlordereddictloader.Loader)

        acc = {}
        for object_name, values in content['components']['schemas'].items():
            acc[mapping[object_name]] = values['properties'].keys()

        return acc
