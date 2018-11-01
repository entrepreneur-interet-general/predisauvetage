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
    'operations_operations_points': '''
        select
            nb_operations_points = nb_operations
        from (
            select count(1) nb_operations
            from operations
        ) operations
        join (
            select count(1) nb_operations_points
            from operations_points
        ) operations_points on true
    ''',
    'concerne_snosan': '''
        select
             nb_operations_snosan = nb_operations_concerne_snosan
        from (
            select count(1) nb_operations_snosan
            from operations op
            join operations_stats stats on stats.operation_id = op.operation_id
            where nombre_flotteurs_plaisance_impliques > 0
               or nombre_flotteurs_loisirs_nautiques_impliques > 0
               or nombre_flotteurs_annexe_impliques > 0
               or op.operation_id in (
                    select op.operation_id
                    from operations op
                    join operations_stats stats on stats.operation_id = op.operation_id and stats.sans_flotteur_implique
                    where op.evenement in (
                     'Sans avarie inexpérience', 'Autre événement', 'Baignade',
                     'Découverte de corps', 'Plongée en apnée', 'Accident en mer',
                     'Isolement par la marée / Envasé', 'Autre accident', 'Blessé EvaMed',
                     'Chasse sous-marine', 'Blessé EvaSan', 'Disparu en mer',
                     'Plongée avec bouteille', 'Sans avarie en dérive', 'Incertitude sur la position',
                     'Homme à la mer', 'Malade EvaMed', 'Ski nautique', 'Accident aéronautique',
                     'Chute falaise / Emporté par une lame', 'Malade EvaSan',
                     'Blessé projection d''une équipe médicale',
                     'Absence d''un moyen de communication'))) snosan
         join (
            select count(1) nb_operations_concerne_snosan
            from operations_stats
            where concerne_snosan
        ) nb_concerne_snosan on true
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
    ''',
    'tss_2017': '''
        select
            count(1) between 45 and 500
        from operations_stats
        where est_dans_dst and annee = 2017
    ''',
    'stm_2017': '''
        select
            count(1) between 650 and 700
        from operations_stats
        where est_dans_stm and annee = 2017
    ''',
    'tss_corse_2016': '''
        select
            count(1) = 0
        from operations_stats
        where date < '2016-12-01' and est_dans_dst and nom_dst = 'dst-corse'
    ''',
    'operations_count_2000_2008': '''
        select
            count(1) between 80000 and 80100
        from operations_stats
        where annee between 2000 and 2008
    ''',
    'unset_tide_data': '''
    select count(1) = 0
    from operations_stats stats
    join operations o on o.operation_id = stats.operation_id
    where stats.distance_cote_metres < 20000
      and o."cross" not in ('Antilles-Guyane', 'Corse', 'Guadeloupe', 'Guyane', 'La Garde', 'La Réunion', 'Martinique', 'Mayotte', 'Nouvelle-Calédonie', 'Polynésie')
      and stats.maree_coefficient is null
    ''',
    'unset_shore_distance': '''
    select count(1) = 0
    from operations_stats stats
    join operations op on op.operation_id = stats.operation_id
    where op.latitude is not null
      and (stats.distance_cote_milles_nautiques is null or stats.distance_cote_metres is null)
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
