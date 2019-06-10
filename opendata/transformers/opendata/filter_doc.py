# -*- coding: utf-8 -*-
import yaml
import yamlordereddictloader
from codecs import open

from transformers.opendata.config import ColumnDropper
from transformers.opendata.config import TableDropper


class FilterYamlDocumentation(object):
    def __init__(self, configuration_filepath):
        super(FilterYamlDocumentation, self)
        self.configuration_filepath = configuration_filepath

    def filter_yaml(self, in_file, out_file):
        content = self.yaml_content(in_file)

        for table_name, values in content["components"]["schemas"].items():
            if self.table_dropper().for_table(table_name):
                del content["components"]["schemas"][table_name]
                continue

            cols_to_drop = self.column_dropper().for_table(table_name)
            for col in cols_to_drop:
                del content["components"]["schemas"][table_name]["properties"][col]

        yaml.dump(
            content,
            open(out_file, "w"),
            Dumper=yamlordereddictloader.Dumper,
            default_flow_style=False,
        )

    def yaml_content(self, filepath):
        return yaml.load(
            open(filepath, "r", encoding="utf-8"), Loader=yamlordereddictloader.Loader
        )

    def column_dropper(self):
        return ColumnDropper(self.configuration_filepath)

    def table_dropper(self):
        return TableDropper(self.configuration_filepath)
