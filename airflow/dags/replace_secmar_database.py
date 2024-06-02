# -*- coding: utf-8 -*-
"""
# replace_secmar_database
Dump SECMAR database from Airflow instance to target
remote server
"""
from datetime import datetime

import helpers
from airflow import DAG
from airflow.hooks.postgres_hook import PostgresHook
from airflow.operators.bash_operator import BashOperator
from secmar_dags import SECMAR_TABLES

OUTPUT_PATH = "/tmp/secmar_dump.sql"

default_args = helpers.default_args({"start_date": datetime(2018, 8, 23, 14, 40)})

dag = DAG(
    "replace_secmar_database",
    default_args=default_args,
    max_active_runs=1,
    concurrency=2,
    catchup=False,
    schedule_interval=None,
)
dag.doc_md = __doc__

tables = SECMAR_TABLES + ["operations_stats", "moyens_snsm"]

template = "sudo -u postgres pg_dump -c --no-owner {tables} {schema} > {output}"
dump_command = template.format(
    schema=PostgresHook.get_connection("postgresql_local").schema,
    output=OUTPUT_PATH,
    tables=" ".join(["-t " + t for t in tables]),
)

dump_local_database = BashOperator(
    task_id="dump_local_database", bash_command=dump_command, dag=dag
)

template = "psql -U {user} -h {host} {schema} < {input}"
target_connection = PostgresHook.get_connection("target_secmar")
import_command = template.format(
    user=target_connection.login,
    host=target_connection.host,
    schema=target_connection.schema,
    input=OUTPUT_PATH,
)
import_remote_database = BashOperator(
    task_id="import_remote_database",
    bash_command=import_command,
    dag=dag,
    env={"PGPASSWORD": target_connection.password},
)
import_remote_database.set_upstream(dump_local_database)

delete_dump_file = BashOperator(
    task_id="delete_dump_file", bash_command="rm " + OUTPUT_PATH, dag=dag
)
delete_dump_file.set_upstream(import_remote_database)
