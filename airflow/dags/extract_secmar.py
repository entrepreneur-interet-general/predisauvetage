# -*- coding: utf-8 -*-
"""
# extract_secmar
Extract, transform and load SECMAR data
"""
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.hooks.postgres_hook import PostgresHook

import config
import helpers

default_args = {
    'owner': 'antoine-augusti',
    'depends_on_past': False,
    'start_date': datetime(2018, 4, 27, 5, 40),
    'email': [],
    'retries': 2,
    'retry_delay': timedelta(minutes=3),
}

dag = DAG(
    'extract_secmar',
    default_args=default_args,
    max_active_runs=1,
    concurrency=2,
    catchup=False,
    schedule_interval=None
)
dag.doc_md = __doc__


def in_path(table):
    return helpers.data_path('in_' + table + '.csv')


def out_path(table):
    return helpers.data_path('out_' + table + '.csv')


def secmar_transform(in_path, out_path, transformer, **kwargs):
    transformer(in_path).transform(out_path)


def create_tables_fn(**kwargs):
    def read_sql_schema():
        filepath = helpers.base_path() + '/../opendata/schema.sql'
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        return content
    PostgresHook('postgresql_local').run(
        read_sql_schema()
    )


def delete_invalid_operations_fn(**kwargs):
    return PostgresHook('postgresql_local').run(
        """
        delete from operations
        where operation_id not in (
            select operation_id
            from operations_valides
        )
        and numero_sitrep is not null;
        drop table operations_valides;
        """
    )


def insert_operations_stats_fn(**kwargs):
    path = helpers.opendata_sql_path('insert_operations_stats')
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    return PostgresHook('postgresql_local').run(content)


def embulk_import(dag, table):
    return helpers.embulk_run(
        dag,
        table,
        {
            'EMBULK_FILEPATH': out_path(table)
        }
    )

start = DummyOperator(task_id='start', dag=dag)
end_transform = DummyOperator(task_id='end_transform', dag=dag)
end_import = DummyOperator(task_id='end_import', dag=dag)

for table in config.SECMAR_TABLES:
    t = PythonOperator(
        task_id='transform_' + table,
        python_callable=secmar_transform,
        provide_context=True,
        dag=dag,
        op_kwargs={
            'in_path': in_path(table),
            'out_path': out_path(table),
            'transformer': config.secmar_transformer(table)
        }
    )
    t.set_upstream(start)
    t.set_downstream(end_transform)

create_tables = PythonOperator(
    task_id='create_tables',
    python_callable=create_tables_fn,
    provide_context=True,
    dag=dag
)
create_tables.set_upstream(end_transform)

embulk_operations = embulk_import(dag, 'operations')
embulk_operations.set_upstream(create_tables)
embulk_operations.set_downstream(end_import)

for table in [t for t in config.SECMAR_TABLES if t not in ['operations']]:
    t = embulk_import(dag, table)
    t.set_upstream(embulk_operations)
    t.set_downstream(end_import)

import_operations_valides = embulk_import(dag, 'operations_valides')
import_operations_valides.set_upstream(end_import)

delete_invalid_operations = PythonOperator(
    task_id='delete_invalid_operations',
    python_callable=delete_invalid_operations_fn,
    provide_context=True,
    dag=dag
)
delete_invalid_operations.set_upstream(import_operations_valides)

insert_operations_stats = PythonOperator(
    task_id='insert_operations_stats',
    python_callable=insert_operations_stats_fn,
    provide_context=True,
    dag=dag
)
insert_operations_stats.set_upstream(delete_invalid_operations)

for table in config.SECMAR_TABLES:
    t = BashOperator(
        task_id='delete_output_csv_' + table,
        bash_command="rm " + out_path(table),
        dag=dag,
    )
    t.set_upstream(insert_operations_stats)
