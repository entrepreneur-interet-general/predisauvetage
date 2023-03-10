# -*- coding: utf-8 -*-
"""
# download_secmar_json_ftp
This DAG downloads JSON files from the remote FTP server.
"""
import os
from datetime import datetime

import helpers
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator, BranchPythonOperator
from transformers import secmar_json

default_args = helpers.default_args({"start_date": datetime(2022, 6, 21, 10, 0)})

dag = DAG(
    "download_secmar_json_ftp",
    default_args=default_args,
    max_active_runs=1,
    concurrency=1,
    catchup=True,
    schedule_interval="0 10 * * *",
)
dag.doc_md = __doc__


def setup_ftp_env():
    os.environ["FTP_PROXY"] = "false"
    os.environ["FTP_HOST"] = Variable.get("SECMAR_FTP_HOST")
    os.environ["FTP_USER"] = Variable.get("SECMAR_FTP_USER")
    os.environ["FTP_PASSWORD"] = Variable.get("SECMAR_FTP_PASSWORD")


def ftp_download_fn(**kwargs):
    setup_ftp_env()
    secmar_json.ftp_download_remote_folder(kwargs["templates_dict"]["day"])


def check_if_next_day_exists_fn(**kwargs):
    setup_ftp_env()
    if secmar_json.day_exists_in_remote_ftp(kwargs["templates_dict"]["day"]):
        return "download_next_day"
    return "process_all_days"


download_single_day = PythonOperator(
    task_id="download_single_day",
    python_callable=ftp_download_fn,
    provide_context=True,
    dag=dag,
    templates_dict={"day": "{{ ds_nodash }}"},
)

check_if_next_day_exists = BranchPythonOperator(
    task_id="check_if_next_day_exists",
    python_callable=check_if_next_day_exists_fn,
    provide_context=True,
    dag=dag,
    templates_dict={"day": "{{ tomorrow_ds_nodash }}"},
)
check_if_next_day_exists.set_upstream(download_single_day)

download_next_day = PythonOperator(
    task_id="download_next_day",
    python_callable=ftp_download_fn,
    provide_context=True,
    dag=dag,
    templates_dict={"day": "{{ tomorrow_ds_nodash }}"},
)
download_next_day.set_upstream(check_if_next_day_exists)

process_all_days = PythonOperator(
    task_id="process_all_days",
    python_callable=secmar_json.process_all_days,
    dag=dag,
    trigger_rule="all_done",
)
process_all_days.set_upstream(download_single_day)
process_all_days.set_upstream(download_next_day)
