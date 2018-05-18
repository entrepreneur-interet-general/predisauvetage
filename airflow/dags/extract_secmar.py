# -*- coding: utf-8 -*-
"""
# extract_secmar
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

import helpers
from secmar_dags import in_path, out_path, secmar_transform
from secmar_dags import SECMAR_TABLES, secmar_transformer

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
        and numero_sitrep is not null;
        drop table operations_valides;
        """
    )


def set_operations_stats_extra_attributes_fn(**kwargs):
    return PostgresHook('postgresql_local').run(
        """
        update operations_stats set phase_journee = t.phase_journee
        from (
            select *
            from operations_stats_extras
        ) t
        where t.operation_id = operations_stats.operation_id;
        drop table operations_stats_extras;
        """
    )


def insert_operations_stats_fn(**kwargs):
    path = helpers.opendata_sql_path('insert_operations_stats')
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    return PostgresHook('postgresql_local').run(content)


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
insert_operations_stats.set_upstream(delete_invalid_operations)
insert_operations_stats.set_downstream(start_checks)

# Handle extra attributes for operations_stats
sql = """
select
    op.operation_id,
    op.date_heure_reception_alerte,
    op.date_heure_reception_alerte at time zone 'utc' at time zone op.fuseau_horaire date_heure_reception_alerte_locale,
    latitude,
    longitude
from operations op
where latitude is not null
    and longitude is not null
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

# Check consistency of data
queries = {
    'operations_operations_stats': '''
        select
            nb_operations_stats = nb_operations
        from (
            select count(1) nb_operations
            from operations
        ) operations
        join (
            select count(1) nb_operations_stats
            from operations_stats
        ) operations_stats on true
    ''',
    'concerne_snosan': '''
        select count(1) = 0
        from (
            select distinct operation_id
            from flotteurs
            where categorie_flotteur in ('Plaisance', 'Loisir nautique') and type_flotteur = 'Annexe'
              and operation_id not in (
                select operation_id
                from operations_stats
                where concerne_snosan
            )
        ) t
    ''',
    'operations_count_2017': '''
        select count(1) between 11100 and 11300
        from operations_stats
        where annee = 2017
    ''',
    'dead_people_2017': '''
        select
            sum(os.nombre_personnes_tous_deces_ou_disparues) between 300 and 320
        from operations_stats os
        where annee = 2017
    '''
}

for query_name, query in queries.items():
    t = CheckOperator(
        task_id='check_consistency_' + query_name,
        sql=query,
        conn_id='postgresql_local',
        dag=dag
    )
    t.set_upstream(start_checks)
    t.set_downstream(end_checks)

# Remove temporary CSV files
for table in SECMAR_TABLES + ['operations_stats_extras', 'operations_valides']:
    t = BashOperator(
        task_id='delete_output_csv_' + table,
        bash_command="rm " + out_path(table),
        dag=dag,
    )
    t.set_upstream(end_checks)
