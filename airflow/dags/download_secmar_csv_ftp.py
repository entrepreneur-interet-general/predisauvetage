# -*- coding: utf-8 -*-
"""
# download_secmar_csv_ftp
This DAG download CSV files from the remote FTP server.
"""
import os
from datetime import datetime

from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator

import helpers
from transformers import secmar_csv

default_args = helpers.default_args({"start_date": datetime(2022, 6, 22, 10, 0)})

dag = DAG(
    "download_secmar_csv_ftp",
    default_args=default_args,
    max_active_runs=1,
    concurrency=1,
    catchup=True,
    schedule_interval="0 10 * * *",
)
dag.doc_md = __doc__


def call_fn(**kwargs):
    os.environ["FTP_PROXY"] = "false"
    os.environ["FTP_HOST"] = Variable.get("SECMAR_CSV_FTP_HOST")
    os.environ["FTP_USER"] = Variable.get("SECMAR_CSV_FTP_USER")
    os.environ["FTP_PASSWORD"] = Variable.get("SECMAR_CSV_FTP_PASSWORD")
    secmar_csv.ftp_download_remote_folder(kwargs["templates_dict"]["day"])


download_single_day = PythonOperator(
    task_id="download_single_day",
    python_callable=call_fn,
    provide_context=True,
    dag=dag,
    templates_dict={"day": "{{ ds_nodash }}"},
)

process_all_days = PythonOperator(
    task_id="process_all_days",
    python_callable=secmar_csv.process_all_days,
    dag=dag,
)
process_all_days.set_upstream(download_single_day)

build_aggregate_files = PythonOperator(
    task_id="build_aggregate_files",
    python_callable=secmar_csv.build_aggregate_files,
    dag=dag,
)
build_aggregate_files.set_upstream(process_all_days)

check_mapping_data = PythonOperator(
    task_id="check_mapping_data",
    python_callable=secmar_csv.check_mapping_data,
    dag=dag,
)
check_mapping_data.set_upstream(build_aggregate_files)
