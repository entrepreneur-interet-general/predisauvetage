# -*- coding: utf-8 -*-
"""
# ftp_delete_folder
This DAG removes folders on the remote FTP server older than 60 days.
"""
import os
from datetime import datetime

import helpers
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator
from transformers import secmar_csv, secmar_json

default_args = helpers.default_args({"start_date": datetime(2022, 6, 22, 10, 0)})

dag = DAG(
    "ftp_delete_folder",
    default_args=default_args,
    max_active_runs=1,
    concurrency=1,
    catchup=True,
    schedule_interval=None,
)
dag.doc_md = __doc__


def setup_ftp_env():
    os.environ["FTP_PROXY"] = "false"
    os.environ["FTP_HOST"] = Variable.get("SECMAR_FTP_HOST")
    os.environ["FTP_USER"] = Variable.get("SECMAR_FTP_USER")
    os.environ["FTP_PASSWORD"] = Variable.get("SECMAR_FTP_PASSWORD")


def ftp_delete_fn(**kwargs):
    setup_ftp_env()
    secmar_csv.ftp_delete_remote_folder(kwargs["templates_dict"]["day"])
    secmar_json.ftp_delete_remote_folder(kwargs["templates_dict"]["day"])


PythonOperator(
    task_id="ftp_delete_folder",
    python_callable=ftp_delete_fn,
    provide_context=True,
    dag=dag,
    templates_dict={
        "day": '{{ macros.ds_format(macros.ds_add(ds, -60), "%Y-%m-%d", "%Y%m%d") }}'
    },
)
