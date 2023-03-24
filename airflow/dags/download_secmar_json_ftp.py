# -*- coding: utf-8 -*-
"""
# download_secmar_json_ftp
This DAG downloads JSON files from the remote FTP server and imports them in the database.
"""
import os
from datetime import datetime

import helpers
from airflow import DAG
from airflow.hooks.postgres_hook import PostgresHook
from airflow.models import Variable
from airflow.operators.check_operator import CheckOperator
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.python_operator import BranchPythonOperator, PythonOperator
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


def _execute_secmar_json_sql_file(filename):
    path = helpers.secmar_json_sql_path(filename)
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    return PostgresHook("postgresql_local").run(content)


def secmar_json_sql_task(dag, filename):
    return PythonOperator(
        task_id="run_" + filename,
        python_callable=lambda **kwargs: _execute_secmar_json_sql_file(filename),
        provide_context=True,
        dag=dag,
    )


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

create_tables = secmar_json_sql_task(dag, "create_tables")
create_tables.set_upstream(process_all_days)

secmar_json_evenement_codes = secmar_json_sql_task(dag, "secmar_json_evenement_codes")
secmar_json_evenement_codes.set_upstream(process_all_days)

# The PostgreSQL user running the `COPY` command needs to be superuser
# `ALTER USER secmar WITH SUPERUSER;`
copy_json_sql = "COPY {table_name} (data) FROM '{input}' csv quote e'\x01' delimiter e'\x02';".format(
    table_name="snosan_json", input=str(secmar_json.AGGREGATE_FILEPATH)
)
copy_json_data = PostgresOperator(
    task_id="copy_json_data",
    sql=copy_json_sql,
    postgres_conn_id="postgresql_local",
    dag=dag,
)
copy_json_data.set_upstream(create_tables)

insert_snosan_json_unique = secmar_json_sql_task(dag, "insert_snosan_json_unique")

check_completeness_snosan_json_operative_event = CheckOperator(
    task_id="check_completeness_snosan_json_operative_event",
    sql="""
    select
        count(1) = 0
    from secmar_json_evenement_codes
    where seamis not in (
        select distinct data->'identification'->>'operativeEvent'
        from snosan_json_unique
    );
    """,
    conn_id="postgresql_local",
    dag=dag,
)
check_completeness_snosan_json_operative_event.set_upstream(insert_snosan_json_unique)
check_completeness_snosan_json_operative_event.set_upstream(secmar_json_evenement_codes)
insert_snosan_json_unique.set_upstream(copy_json_data)

snosan_json_evenement = secmar_json_sql_task(dag, "snosan_json_evenement")
snosan_json_evenement.set_upstream(check_completeness_snosan_json_operative_event)

check_completeness_count_rows_secmar_json_evenement = CheckOperator(
    task_id="check_completeness_count_rows_secmar_json_evenement",
    sql="""
    select nb = nb1
    from  (
        select count(1) nb1 from secmar_json_evenement
    ) t2
    join (
        select count(1) nb from snosan_json_unique
    ) t on true = true;
    """,
    conn_id="postgresql_local",
    dag=dag,
)
check_completeness_count_rows_secmar_json_evenement.set_upstream(snosan_json_evenement)
