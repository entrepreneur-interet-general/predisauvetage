# -*- coding: utf-8 -*-
import re
from ddlparse import DdlParse
from codecs import open

from test_schema import TestSchemaMatches


class TestSqlSchema(TestSchemaMatches):
    def test_content(self):
        the_regex = r'(CREATE TABLE.*?\);)+'
        flags = re.MULTILINE | re.DOTALL
        matches = re.findall(the_regex, self.sql_content(), flags)

        open_data = self.open_data_schemas()
        tables = []
        for match in matches:
            table = DdlParse().parse(
                match,
                source_database=DdlParse.DATABASE.postgresql
            )
            tables.append(table.name)

            self.assertEquals(
                open_data[table.name],
                list(table.columns.keys())
            )

        self.assertEquals(
            set(tables),
            set(map(lambda e: e.replace('.csv', ''), open_data.keys()))
        )

    def sql_content(self):
        with open(self.filepath('sql/schema.sql'), 'r', encoding='utf-8') as f:
            content = f.read()
        return content
