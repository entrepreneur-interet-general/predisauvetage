# -*- coding: utf-8 -*-
import json
import re


class BaseDropper(object):
    MODELS_TO_TABLES = {
        "Flotteur": "flotteurs",
        "Moyen": "moyens",
        "Operation": "operations",
        "OperationStats": "operations_stats",
        "ResultatHumain": "resultats_humain",
        "MoyenSNSM": "moyens_snsm",
    }

    def __init__(self, configuration_filepath):
        super(BaseDropper, self).__init__()
        self.configuration_filepath = configuration_filepath
        self.conf = self.parse_configuration()

    def for_table(self, table):
        if not re.match(r'^[a-z_]+$', table):
            template = 'Table `{table}` does not match regex ^[a-z_]+$'
            raise ValueError(template.format(table=table))
        return self.conf[table]

    def for_model(self, model):
        return self.for_table(self.MODELS_TO_TABLES[model])


class ColumnDropper(BaseDropper):
    def parse_configuration(self):
        with open(self.configuration_filepath) as f:
            data = json.load(f)
        return data['columns']


class TableDropper(BaseDropper):
    def parse_configuration(self):
        with open(self.configuration_filepath) as f:
            data = json.load(f)
        return data['models']

    def for_table(self, table):
        return table in self.conf
