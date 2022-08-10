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
from transformers.opendata.secmar_csv import ftp_download_remote_folder

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
    ftp_download_remote_folder(kwargs["templates_dict"]["day"])


PythonOperator(
    task_id="download_single_day",
    python_callable=call_fn,
    provide_context=True,
    dag=dag,
    templates_dict={"day": "{{ ds_nodash }}"},
)
