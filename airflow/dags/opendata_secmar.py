# -*- coding: utf-8 -*-
"""
# opendata_secmar
Prepare files for open data after they've been transformed.
"""
from datetime import datetime

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.dummy_operator import DummyOperator
from operators.pg_download_operator import PgDownloadOperator


import helpers

from secmar_dags import SECMAR_TABLES, opendata_transformer, out_path
from secmar_dags import secmar_transform, opendata_path

default_args = helpers.default_args({
    'start_date': datetime(2018, 5, 22, 5, 40),
})

dag = DAG(
    'opendata_secmar',
    default_args=default_args,
    max_active_runs=1,
    concurrency=2,
    catchup=False,
    schedule_interval=None
)
dag.doc_md = __doc__

start = DummyOperator(task_id='start', dag=dag)

download_operations_stats = PgDownloadOperator(
    task_id='download_operations_stats',
    postgres_conn_id='postgresql_local',
    sql='select * from operations_stats',
    pandas_sql_params={
        'chunksize': 10000,
    },
    csv_path=out_path('operations_stats'),
    csv_params={
        'sep': ',',
        'index': False,
    },
    dag=dag
)
download_operations_stats.set_downstream(start)

for table in SECMAR_TABLES + ['operations_stats']:
    t = PythonOperator(
        task_id='transform_' + table,
        python_callable=secmar_transform,
        provide_context=True,
        dag=dag,
        op_kwargs={
            'in_path': out_path(table),
            'out_path': opendata_path(table),
            'transformer': opendata_transformer(table)
        }
    )
    t.set_upstream(start)
