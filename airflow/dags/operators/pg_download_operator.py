# Airflow Operator to download results of a sql query to a file on the worker
# Pass chunksize parameter to download large tables without the
# worker running out of memory
# https://gist.github.com/rahul-pande/e0df1b080e76563b47c9d2b1a6392855

import logging

from airflow.hooks.postgres_hook import PostgresHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


class PgDownloadOperator(BaseOperator):
    """
    Executes sql code in a specific Postgres database
    and saves the result in given file name

    :param postgres_conn_id: reference to a specific postgres database
    :type postgres_conn_id: string
    :param sql: the sql code to be executed
    :type sql: Can receive a str representing a sql statement,
        a list of str (sql statements), or reference to a template file.
        Template reference are recognized by str ending in '.sql'
    :param csv_path: absolute path to save the pandas df to, can be used with templating
    :type csv_path: str
        for example: /path/to/dag/storage/{{ task.task_id }}_{{ ds }}.csv
    :param csv_params: params passed to the df.to_csv() function
    :type csv_params: dict
    :param pandas_sql_params: params passed to the
        pandas.io.sql.read_sql() function
    :type pandas_sql_params: dict

    """

    template_fields = ("sql", "csv_path")
    template_ext = (".sql",)
    ui_color = "#ededed"

    @apply_defaults
    def __init__(
        self,
        sql,
        csv_path,
        postgres_conn_id="postgres_default",
        autocommit=False,
        pandas_sql_params=None,
        csv_params=None,
        *args,
        **kwargs
    ):
        super(PgDownloadOperator, self).__init__(*args, **kwargs)
        self.sql = sql
        self.postgres_conn_id = postgres_conn_id
        self.csv_path = csv_path
        self.autocommit = autocommit
        self.pandas_sql_params = pandas_sql_params
        self.csv_params = csv_params

    def execute(self, context):
        logging.info("Executing: " + str(self.sql))
        self.hook = PostgresHook(postgres_conn_id=self.postgres_conn_id)
        pandas_df = self.hook.get_pandas_df(self.sql, parameters=self.pandas_sql_params)
        logging.info("Saving to: " + str(self.csv_path))
        pandas_df.to_csv(self.csv_path, **self.csv_params)
