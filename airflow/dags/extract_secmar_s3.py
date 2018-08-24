# -*- coding: utf-8 -*-
"""
# extract_secmar_s3
Download SECMAR extracts from AWS S3
"""
from datetime import datetime

from airflow import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dagrun_operator import TriggerDagRunOperator

import helpers
from secmar_dags import in_path, SECMAR_TABLES

BASE_PATH = '/tmp/data'

default_args = helpers.default_args({
    'start_date': datetime(2018, 7, 30, 6, 40),
})

dag = DAG(
    'extract_secmar_s3',
    default_args=default_args,
    max_active_runs=1,
    concurrency=5,
    catchup=False,
    schedule_interval='0 6 * * 1-5'
)
dag.doc_md = __doc__

start = DummyOperator(task_id='start', dag=dag)
end = DummyOperator(task_id='end', dag=dag)

download_s3 = BashOperator(
    task_id='download_s3',
    bash_command='mkdir {base} && aws s3 sync s3://secmar {base}'.format(
        base=BASE_PATH
    ),
    dag=dag,
)
download_s3.set_downstream(start)

for table in SECMAR_TABLES + ['operations_valides']:
    command = "awk 'NR==1{{$0=tolower($0)}} 1' {in_path} > {tmp} && mv {tmp} {out_path}".format(
        tmp='/tmp/lower_' + table,
        in_path=BASE_PATH + '/' + table + '.csv',
        out_path=in_path(table)
    )
    lowercase_header = BashOperator(
        task_id='lowercase_header_csv_' + table,
        bash_command=command,
        dag=dag,
    )
    lowercase_header.set_upstream(start)
    lowercase_header.set_downstream(end)

dag_name = 'extract_secmar'
trigger_dag = TriggerDagRunOperator(
    task_id='trigger_' + dag_name + '_dag',
    trigger_dag_id=dag_name,
    python_callable=lambda context, dag_run: dag_run,
    dag=dag
)
trigger_dag.set_upstream(end)

clean_tmp_dir = BashOperator(
    task_id='clean_tmp_dir',
    bash_command='rm -rf {base}'.format(base=BASE_PATH),
    dag=dag,
)
clean_tmp_dir.set_upstream(end)
