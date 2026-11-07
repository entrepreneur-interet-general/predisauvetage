# -*- coding: utf-8 -*-
"""
# extract_secmar_oracle
Extract SECMAR data from the Oracle database and dump it to CSV.

This DAG can only be executed from within the intranet of the MTES.
"""
from datetime import datetime

import helpers
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from airflow.operators.dummy_operator import DummyOperator
from secmar_dags import SECMAR_TABLES, in_path

default_args = helpers.default_args({"start_date": datetime(2018, 5, 17, 6, 40)})

dag = DAG(
    "extract_secmar_oracle",
    default_args=default_args,
    max_active_runs=1,
    concurrency=2,
    catchup=False,
    schedule_interval=None,
)
dag.doc_md = __doc__


def embulk_export(dag, table):
    return helpers.embulk_run(
        dag,
        "oracle_to_csv",
        env={
            "EMBULK_FILEPATH": in_path(table),
            "EMBULK_QUERY": helpers.read_sql_query(table),
        },
        task_id="export_" + table,
    )


start = DummyOperator(task_id="start", dag=dag)
end = DummyOperator(task_id="end", dag=dag)

for table in SECMAR_TABLES + ["operations_valides"]:
    export = embulk_export(dag, table)
    export.set_upstream(start)

    command = "awk 'NR==1{{$0=tolower($0)}} 1' {filepath} > {tmp} && mv {tmp} {filepath}".format(
        tmp="/tmp/lower_" + table, table=table, filepath=in_path(table)
    )
    lowercase_header = BashOperator(
        task_id="lowercase_header_csv_" + table, bash_command=command, dag=dag
    )
    lowercase_header.set_upstream(export)
    lowercase_header.set_downstream(end)


dag_name = "extract_secmar"
trigger_dag = TriggerDagRunOperator(
    task_id="trigger_" + dag_name + "_dag",
    trigger_dag_id=dag_name,
    python_callable=lambda context, dag_run: dag_run,
    dag=dag,
)
trigger_dag.set_upstream(end)
