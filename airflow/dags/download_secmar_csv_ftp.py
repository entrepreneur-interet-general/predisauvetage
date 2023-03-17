# -*- coding: utf-8 -*-
"""
# download_secmar_csv_ftp
This DAG download CSV files from the remote FTP server.
"""
import os
from datetime import datetime
from pathlib import Path

import helpers
from airflow import DAG
from airflow.models import Variable
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import BranchPythonOperator, PythonOperator
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


def setup_ftp_env():
    os.environ["FTP_PROXY"] = "false"
    os.environ["FTP_HOST"] = Variable.get("SECMAR_FTP_HOST")
    os.environ["FTP_USER"] = Variable.get("SECMAR_FTP_USER")
    os.environ["FTP_PASSWORD"] = Variable.get("SECMAR_FTP_PASSWORD")


def ftp_download_fn(**kwargs):
    setup_ftp_env()
    secmar_csv.ftp_download_remote_folder(kwargs["templates_dict"]["day"])


def check_if_next_day_exists_fn(**kwargs):
    setup_ftp_env()
    if secmar_csv.day_exists_in_remote_ftp(kwargs["templates_dict"]["day"]):
        return "download_next_day"
    return "process_all_days"


def embulk_import(dag, table):
    script = "secmar_csv_%s" % table
    filepath = str(secmar_csv.AGGREGATE_FOLDER / (table + ".cleaned.csv"))
    return helpers.embulk_run(dag, script, {"EMBULK_FILEPATH": filepath})


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
    python_callable=secmar_csv.process_all_days,
    dag=dag,
    trigger_rule="all_done",
)
process_all_days.set_upstream(download_single_day)
process_all_days.set_upstream(download_next_day)

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

create_cleaned_aggregate_files = PythonOperator(
    task_id="create_cleaned_aggregate_files",
    python_callable=secmar_csv.create_cleaned_aggregate_files,
    dag=dag,
)
create_cleaned_aggregate_files.set_upstream(check_mapping_data)

start_embulk = DummyOperator(task_id="start_embulk", dag=dag)
end_embulk = DummyOperator(task_id="end_embulk", dag=dag)
start_embulk.set_upstream(create_cleaned_aggregate_files)

operation_embulk = embulk_import(dag, "operation")
operation_embulk.set_upstream(start_embulk)
operation_embulk.set_downstream(end_embulk)

for table in [
    Path(f).stem for f in secmar_csv.EXPECTED_FILENAMES if not f.startswith("operation")
]:
    t = embulk_import(dag, table)
    t.set_upstream(operation_embulk)
    t.set_downstream(end_embulk)
