# -*- coding: utf-8 -*-
"""
# extract_secmar
This DAG is triggered by the DAG [extract_secmar_oracle](/admin/airflow/graph?dag_id=extract_secmar_oracle).

Extract, transform and load SECMAR data
"""
from datetime import datetime

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.operators.bash_operator import BashOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.check_operator import CheckOperator
from airflow.hooks.postgres_hook import PostgresHook
from operators.pg_download_operator import PgDownloadOperator
from airflow.operators.dagrun_operator import TriggerDagRunOperator


import helpers
from secmar_dags import in_path, out_path, secmar_transform
from secmar_dags import SECMAR_TABLES, secmar_transformer
from secmar_checks import checks

default_args = helpers.default_args({
    'start_date': datetime(2018, 4, 27, 5, 40),
})

dag = DAG(
    'extract_secmar',
    default_args=default_args,
    max_active_runs=1,
    concurrency=2,
    catchup=False,
    schedule_interval=None
)
dag.doc_md = __doc__


def create_tables_fn(**kwargs):
    PostgresHook('postgresql_local').run(
        helpers.read_sql_query('schema')
    )


def delete_invalid_operations_fn(**kwargs):
    return PostgresHook('postgresql_local').run(
        """
        delete from operations
        where operation_id not in (
            select operation_id
            from operations_valides
        )
        and length(operation_id::text) < 10;
        drop table operations_valides;
        """
    )


def set_operations_stats_extra_attributes_fn(**kwargs):
    return PostgresHook('postgresql_local').run(
        """
        update operations_stats set
            phase_journee = t.phase_journee::phase_journee,
            est_jour_ferie = t.est_jour_ferie,
            est_vacances_scolaires = t.est_vacances_scolaires
        from (
            select *
            from operations_stats_extras
        ) t
        where t.operation_id = operations_stats.operation_id;
        drop table operations_stats_extras;
        """
    )


def insert_operations_stats_fn(**kwargs):
    return execute_sql_file('insert_operations_stats')


def insert_moyens_snsm_fn(**kwargs):
    return execute_sql_file('moyens_snsm')


def set_tide_data_fn(**kwargs):
    return execute_sql_file('compute_tide')


def execute_sql_file(filename):
    path = helpers.opendata_sql_path(filename)
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    return PostgresHook('postgresql_local').run(content)


def make_distance_fn(distance):
    return lambda **kwargs: execute_sql_file(distance)


def embulk_import(dag, table):
    return helpers.embulk_run(
        dag,
        table,
        {
            'EMBULK_FILEPATH': out_path(table)
        }
    )

start = DummyOperator(task_id='start', dag=dag)
end_transform = DummyOperator(task_id='end_transform', dag=dag)
end_import = DummyOperator(task_id='end_import', dag=dag)
start_checks = DummyOperator(task_id='start_checks', dag=dag)
end_checks = DummyOperator(task_id='end_checks', dag=dag)

# Convert input CSV files
for table in SECMAR_TABLES + ['operations_valides']:
    t = PythonOperator(
        task_id='transform_' + table,
        python_callable=secmar_transform,
        provide_context=True,
        dag=dag,
        pool='transform',
        op_kwargs={
            'in_path': in_path(table),
            'out_path': out_path(table),
            'transformer': secmar_transformer(table)
        }
    )
    t.set_upstream(start)
    t.set_downstream(end_transform)

create_tables = PythonOperator(
    task_id='create_tables',
    python_callable=create_tables_fn,
    provide_context=True,
    dag=dag
)
create_tables.set_upstream(end_transform)

# Import CSV files into PostgreSQL
embulk_operations = embulk_import(dag, 'operations')
embulk_operations.set_upstream(create_tables)
embulk_operations.set_downstream(end_import)

tables = [t for t in SECMAR_TABLES + ['operations_valides'] if t not in ['operations']]
for table in tables:
    t = embulk_import(dag, table)
    t.set_upstream(embulk_operations)
    t.set_downstream(end_import)

delete_invalid_operations = PythonOperator(
    task_id='delete_invalid_operations',
    python_callable=delete_invalid_operations_fn,
    provide_context=True,
    dag=dag
)
delete_invalid_operations.set_upstream(end_import)

insert_operations_stats = PythonOperator(
    task_id='insert_operations_stats',
    python_callable=insert_operations_stats_fn,
    provide_context=True,
    dag=dag
)
insert_operations_stats.set_downstream(start_checks)

prepare_operations_points = PythonOperator(
    task_id='prepare_operations_points',
    python_callable=lambda **kwargs: execute_sql_file('prepare_operations_points'),
    provide_context=True,
    dag=dag
)
prepare_operations_points.set_upstream(delete_invalid_operations)

insert_moyens_snsm = PythonOperator(
    task_id='insert_moyens_snsm',
    python_callable=insert_moyens_snsm_fn,
    provide_context=True,
    dag=dag
)
insert_moyens_snsm.set_upstream(delete_invalid_operations)
insert_moyens_snsm.set_downstream(start_checks)

distances = [
    ('compute_shore_distance', lambda **kwargs: execute_sql_file('compute_shore_distance')),
    ('compute_vessel_traffic_service', lambda **kwargs: execute_sql_file('compute_vessel_traffic_service')),
    ('compute_traffic_separation_scheme', lambda **kwargs: execute_sql_file('compute_traffic_separation_scheme')),
]

for name, python_fn in distances:
    t = PythonOperator(
        task_id=name,
        python_callable=python_fn,
        provide_context=True,
        dag=dag
    )
    t.set_upstream(prepare_operations_points)
    t.set_downstream(insert_operations_stats)

# Handle extra attributes for operations_stats
sql = """
select
    op.operation_id,
    op.date_heure_reception_alerte at time zone 'utc' date_heure_reception_alerte,
    op.date_heure_reception_alerte at time zone op.fuseau_horaire date_heure_reception_alerte_locale,
    latitude,
    longitude
from operations op
"""
download_operations_local_time = PgDownloadOperator(
    task_id='download_operations_local_time',
    postgres_conn_id='postgresql_local',
    sql=sql,
    pandas_sql_params={
        'chunksize': 10000,
    },
    csv_path=in_path('operations_stats_extras'),
    csv_params={
        'sep': ',',
        'index': False,
    },
    dag=dag
)
download_operations_local_time.set_upstream(delete_invalid_operations)

transform_operations_stats = PythonOperator(
    task_id='transform_operations_stats',
    pool='transform',
    python_callable=secmar_transform,
    provide_context=True,
    dag=dag,
    op_kwargs={
        'in_path': in_path('operations_stats_extras'),
        'out_path': out_path('operations_stats_extras'),
        'transformer': secmar_transformer('operations_stats')
    }
)
transform_operations_stats.set_upstream(download_operations_local_time)

embulk_operations_stats_extras = embulk_import(dag, 'operations_stats_extras')
embulk_operations_stats_extras.set_upstream(transform_operations_stats)

set_operations_stats_extra_attributes = PythonOperator(
    task_id='set_operations_stats_extra_attributes',
    python_callable=set_operations_stats_extra_attributes_fn,
    provide_context=True,
    dag=dag
)
set_operations_stats_extra_attributes.set_upstream(embulk_operations_stats_extras)
set_operations_stats_extra_attributes.set_upstream(insert_operations_stats)
set_operations_stats_extra_attributes.set_downstream(start_checks)

set_tide_data = PythonOperator(
    task_id='set_tide_data',
    python_callable=set_tide_data_fn,
    provide_context=True,
    dag=dag
)
set_tide_data.set_upstream(set_operations_stats_extra_attributes)
set_tide_data.set_downstream(start_checks)

for check_name, query in checks().items():
    t = CheckOperator(
        task_id='check_consistency_' + check_name,
        sql=query,
        conn_id='postgresql_local',
        dag=dag
    )
    t.set_upstream(start_checks)
    t.set_downstream(end_checks)

# Remove temporary CSV files
for table in ['operations_stats_extras', 'operations_valides']:
    t = BashOperator(
        task_id='delete_output_csv_' + table,
        bash_command="rm " + out_path(table),
        dag=dag,
    )
    t.set_upstream(end_checks)

# Trigger DAG to generate final open data files
# Trigger DAG to replace SECMAR database in remote database
for dag_name in ['opendata_secmar', 'replace_secmar_database']:
    trigger_dag = TriggerDagRunOperator(
        task_id='trigger_' + dag_name + '_dag',
        trigger_dag_id=dag_name,
        python_callable=lambda context, dag_run: dag_run,
        dag=dag
    )
    trigger_dag.set_upstream(end_checks)
