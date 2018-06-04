# -*- coding: utf-8 -*-
import yaml
import yamlordereddictloader
from codecs import open

from transformers.opendata.config import ColumnDropper


class FilterYamlDocumentation(object):
    def __init__(self, configuration_filepath):
        super(FilterYamlDocumentation, self)
        self.configuration_filepath = configuration_filepath

    def filter_yaml(self, in_file, out_file):
        content = self.yaml_content(in_file)

        for model_name, values in content['components']['schemas'].items():
            cols_to_drop = self.column_dropper().for_model(model_name)
            for col in cols_to_drop:
                del content['components']['schemas'][model_name]['properties'][col]

        yaml.dump(
            content,
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
