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

from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dummy_operator import DummyOperator
from operators.pg_download_operator import PgDownloadOperator
import pandas as pd

import helpers
from secmar_dags import SECMAR_TABLES, opendata_transformer, out_path
from secmar_dags import secmar_transform, opendata_path

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


def filter_operations_fn(**kwargs):
    operations = pd.read_csv(out_path("operations"))
    operations_stats = pd.read_csv(out_path("operations_stats"))
    df = operations.loc[
        operations["operation_id"].isin(operations_stats["operation_id"]), :
    ]
    df.to_csv(out_path("operations"), index=False)


start = DummyOperator(task_id="start", dag=dag)
end_transform = DummyOperator(task_id="end_transform", dag=dag)

download_operations_stats = PgDownloadOperator(
    task_id="download_operations_stats",
    postgres_conn_id="postgresql_local",
    sql="select * from operations_stats",
    pandas_sql_params={"chunksize": 10000},
    csv_path=out_path("operations_stats"),
    csv_params={"sep": ",", "index": False},
    dag=dag,
)
download_operations_stats.set_downstream(start)

filter_operations = PythonOperator(
    task_id="filter_operations",
    python_callable=filter_operations_fn,
    provide_context=True,
    dag=dag,
)
filter_operations.set_upstream(download_operations_stats)
filter_operations.set_downstream(start)


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
    t.set_upstream(start)
    t.set_downstream(end_transform)

scp_command = "scp *.csv root@{host}:/var/www/secmar-data/".format(
    host=Variable.get("REMOTE_SERVER_CSV_HOST")
)

publish_csv_files = BashOperator(
    task_id="publish_csv_files",
    bash_command=" && ".join(
        ["cd " + helpers.opendata_folder_path(), "rm -f moyens.csv", scp_command]
    ),
    dag=dag,
)
publish_csv_files.set_upstream(end_transform)
