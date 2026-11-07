# -*- coding: utf-8 -*-
"""
# opendata_secmar
This DAG is triggered by the DAG [extract_secmar](/admin/airflow/graph?dag_id=extract_secmar).

It prepares files for open data after they've been transformed.

`operations_stats` is generated directly in SQL so we need to download it before.

Some `operations` are duplicated and are cleaned directly in SQL. We therefore need to
filter out these operations first before creating final CSV files.

When datasets are available, we push them to a remote server so that they can be served by a webserver + CDN.
"""
from datetime import datetime

import pandas as pd

import helpers
from airflow import DAG
from airflow.models import Variable
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.python_operator import PythonOperator
from operators.pg_download_operator import PgDownloadOperator
from secmar_dags import SECMAR_TABLES, opendata_path, opendata_transformer, out_path, secmar_transform

default_args = helpers.default_args({"start_date": datetime(2018, 5, 22, 5, 40)})

dag = DAG(
    "opendata_secmar",
    default_args=default_args,
    max_active_runs=1,
    concurrency=2,
    catchup=False,
    schedule_interval=None,
)
dag.doc_md = __doc__

start_download = DummyOperator(task_id="start_download", dag=dag)
end_download = DummyOperator(task_id="end_download", dag=dag)
start_transform = DummyOperator(task_id="start_transform", dag=dag)
end_transform = DummyOperator(task_id="end_transform", dag=dag)

start_transform.set_upstream(end_download)

download_operations_stats = PgDownloadOperator(
    task_id="download_operations_stats",
    postgres_conn_id="postgresql_local",
    sql="select * from operations_stats",
    pandas_sql_params={"chunksize": 10000},
    csv_path=out_path("operations_stats"),
    csv_params={"sep": ",", "index": False},
    dag=dag,
)
download_operations_stats.set_upstream(start_download)
download_operations_stats.set_downstream(end_download)

remove_operations_sous_marin = PostgresOperator(
    task_id="remove_operations_sous_marin",
    sql="""
    delete from operations
    where operation_id in (
        select distinct operation_id
        from flotteurs f
        where f.type_flotteur = 'Sous-marin'
    )
    """,
    postgres_conn_id="postgresql_local",
    dag=dag,
)

for table in SECMAR_TABLES:
    task = PgDownloadOperator(
        task_id="download_{table}".format(table=table),
        postgres_conn_id="postgresql_local",
        sql="select * from {table}".format(table=table),
        pandas_sql_params={"chunksize": 10000},
        csv_path=out_path(table),
        csv_params={"sep": ",", "index": False},
        dag=dag,
    )
    task.set_upstream(start_download)
    task.set_downstream(end_download)
    if table == "operations":
        task.set_upstream(remove_operations_sous_marin)

for table in SECMAR_TABLES + ["operations_stats"]:
    t = PythonOperator(
        task_id="transform_" + table,
        python_callable=secmar_transform,
        provide_context=True,
        dag=dag,
        pool="transform",
        op_kwargs={
            "in_path": out_path(table),
            "out_path": opendata_path(table),
            "transformer": opendata_transformer(table),
        },
    )
    t.set_upstream(start_transform)
    t.set_downstream(end_transform)

scp_command = "scp *.csv root@{host}:/var/www/secmar-data/".format(host=Variable.get("REMOTE_SERVER_CSV_HOST"))

publish_csv_files = BashOperator(
    task_id="publish_csv_files",
    bash_command=" && ".join(["cd " + helpers.opendata_folder_path(), "rm -f moyens.csv", scp_command]),
    dag=dag,
)
publish_csv_files.set_upstream(end_transform)
