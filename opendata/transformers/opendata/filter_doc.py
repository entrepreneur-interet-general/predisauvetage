# -*- coding: utf-8 -*-
import yaml
import yamlordereddictloader
from codecs import open
import copy

from transformers.opendata.config import ColumnDropper
from transformers.opendata.config import ModelDropper
from transformers.opendata.config import ModelRenamer


class FilterYamlDocumentation(object):
    def __init__(self, configuration_filepath):
        super(FilterYamlDocumentation, self)
        self.configuration_filepath = configuration_filepath

    def filter_yaml(self, in_file, out_file):
        content = self.yaml_content(in_file)

        for model_name, values in content['components']['schemas'].items():
            if self.model_dropper().for_model(model_name):
                del content['components']['schemas'][model_name]
                continue

            cols_to_drop = self.column_dropper().for_model(model_name)
            for col in cols_to_drop:
                del content['components']['schemas'][model_name]['properties'][col]

        # Rename from model name to table name
        res = copy.deepcopy(content)
        for model_name, values in content['components']['schemas'].items():
            new_model_name = self.model_renamer().model_to_table(model_name)
            res['components']['schemas'][new_model_name] = content['components']['schemas'][model_name]
            del res['components']['schemas'][model_name]

        yaml.dump(
            res,
            open(out_file, 'w'),
            Dumper=yamlordereddictloader.Dumper,
            default_flow_style=False
        )

    def yaml_content(self, filepath):
        return yaml.load(
            open(filepath, 'r', encoding='utf-8'),
            Loader=yamlordereddictloader.Loader
        )

    def column_dropper(self):
        return ColumnDropper(self.configuration_filepath)

    def model_dropper(self):
        return ModelDropper(self.configuration_filepath)

    def model_renamer(self):
        return ModelRenamer(self.configuration_filepath)
