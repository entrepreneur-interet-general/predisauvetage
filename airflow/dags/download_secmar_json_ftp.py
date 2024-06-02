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
from airflow.operators.dagrun_operator import TriggerDagRunOperator
from airflow.operators.postgres_operator import PostgresOperator
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import BranchPythonOperator, PythonOperator
from operators.pg_download_operator import PgDownloadOperator
from transformers import secmar_json

default_args = helpers.default_args({"start_date": datetime(2022, 6, 21, 10, 0)})

dag = DAG(
    "download_secmar_json_ftp",
    default_args=default_args,
    max_active_runs=1,
    concurrency=1,
    catchup=True,
    schedule_interval="0 8 * * *",
)
dag.doc_md = __doc__

OPERATIONS_COORDINATES_IN_FILEPATH = helpers.data_path("snosan_json_operations_coordinates.csv")
OPERATIONS_COORDINATES_OUT_FILEPATH = helpers.data_path("snosan_json_operations_cleaned_coordinates.csv")


def setup_ftp_env():
    os.environ["FTP_PROXY"] = "false"
    os.environ["FTP_HOST"] = Variable.get("SECMAR_FTP_HOST")
    os.environ["FTP_USER"] = Variable.get("SECMAR_FTP_USER")
    os.environ["FTP_PASSWORD"] = Variable.get("SECMAR_FTP_PASSWORD")


def ftp_download_fn(**kwargs):
    setup_ftp_env()
    secmar_json.ftp_download_remote_folder(kwargs["templates_dict"]["day"])


def parse_and_save_coordinates_fn(**kwargs):
    secmar_json.parse_and_save_coordinates(OPERATIONS_COORDINATES_IN_FILEPATH, OPERATIONS_COORDINATES_OUT_FILEPATH)
    os.remove(OPERATIONS_COORDINATES_IN_FILEPATH)


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
insert_snosan_json_unique.set_upstream(copy_json_data)

start_create_codes_tables = DummyOperator(task_id="start_create_codes_tables", dag=dag)
start_create_codes_tables.set_upstream(insert_snosan_json_unique)
end_create_codes_tables = DummyOperator(task_id="end_create_codes_tables", dag=dag)

download_operations_coordinates = PgDownloadOperator(
    task_id="download_operations_coordinates",
    postgres_conn_id="postgresql_local",
    sql="""
    select
      data->>'chrono' chrono,
      coalesce(data->'messages'->0->>'paragraphe2', data->'messages'->0->>'paragrapheB') paragraphe
    from snosan_json_unique
    """,
    pandas_sql_params={"chunksize": 10000},
    csv_path=OPERATIONS_COORDINATES_IN_FILEPATH,
    csv_params={"sep": ",", "index": False},
    dag=dag,
)
download_operations_coordinates.set_upstream(insert_snosan_json_unique)

parse_and_save_coordinates = PythonOperator(
    task_id="parse_and_save_coordinates",
    python_callable=parse_and_save_coordinates_fn,
    provide_context=True,
    dag=dag,
)
parse_and_save_coordinates.set_upstream(download_operations_coordinates)

create_snosan_json_operations_coordinates = secmar_json_sql_task(dag, "snosan_json_operations_coordinates")
create_snosan_json_operations_coordinates.set_upstream(parse_and_save_coordinates)

import_snosan_json_operations_coordinates = helpers.embulk_run(
    dag, "snosan_json_operations_coordinates", {"EMBULK_FILEPATH": OPERATIONS_COORDINATES_OUT_FILEPATH}
)
import_snosan_json_operations_coordinates.set_upstream(create_snosan_json_operations_coordinates)
import_snosan_json_operations_coordinates.set_downstream(end_create_codes_tables)

for code in [
    # Opérations
    "snosan_json_operation_id",
    "secmar_json_evenement_codes",
    "secmar_json_operations_cross",
    "secmar_json_operations_moyen_alerte",
    "secmar_json_operations_qui_alerte",
    "secmar_json_operations_zone_responsabilite",
    "secmar_json_operations_vent_categorie",
    "secmar_json_operations_departement",
    # Moyens
    "secmar_json_engagements_autorite",
    "secmar_json_engagements_categorie",
    "secmar_json_engagements_durees",
    "secmar_json_engagements_type",
    # Flotteurs
    "secmar_json_resultat_flotteur_codes",
    "secmar_json_flotteurs_type_flotteur",
    # Résultats humain
    "secmar_json_resultats_humain_categorie",
    "secmar_json_resultats_humain_resultat",
]:
    task = secmar_json_sql_task(dag, code)
    task.set_upstream(start_create_codes_tables)
    task.set_downstream(end_create_codes_tables)

snosan_json_operations = secmar_json_sql_task(dag, "snosan_json_operations")
for (column, json_path) in [
    ("cross", "crossCoordonnateurId"),
    ("moyen_alerte", "moyenAlerte"),
    ("qui_alerte", "quiAlerte"),
    ("zone_responsabilite", "zoneResponsabilite"),
    ("departement", "departement"),
]:
    table = "secmar_json_operations_{column}".format(column=column)
    task = PostgresOperator(
        task_id="check_completness_operations_{column}".format(column=column),
        sql="""
        select count(1) = 0
        from (
          select distinct data->>'{json_path}'
          from snosan_json_unique
          where data->>'chrono' not similar to '%20(19|20|21)%' and data->>'{json_path}' not in (select seamis from {table})
        ) _
        """.format(
            json_path=json_path, table=table
        ),
        postgres_conn_id="postgresql_local",
        dag=dag,
    )
    task.set_upstream(end_create_codes_tables)
    task.set_downstream(snosan_json_operations)

check_completness_operations_force_vent = PostgresOperator(
    task_id="check_completness_operations_force_vent",
    sql="""
    select count(1) = 0
    from snosan_json_unique
    where not data->'bulletinsMeteo'->0->>'forceVent' ~ '^FORCE_([\d]{1}|10|11|12)$'
    """,
    postgres_conn_id="postgresql_local",
    dag=dag,
)
check_completness_operations_force_vent.set_upstream(end_create_codes_tables)
check_completness_operations_force_vent.set_downstream(snosan_json_operations)

check_completness_operations_etat_mer = PostgresOperator(
    task_id="check_completness_operations_etat_mer",
    sql="""
    select count(1) = 0
    from snosan_json_unique
    where not data->'bulletinsMeteo'->0->>'etatMer' ~ '^ETAT_MER_[0-8]$'
    """,
    postgres_conn_id="postgresql_local",
    dag=dag,
)
check_completness_operations_etat_mer.set_upstream(end_create_codes_tables)
check_completness_operations_etat_mer.set_downstream(snosan_json_operations)

check_completeness_snosan_json_operative_event = CheckOperator(
    task_id="check_completeness_snosan_json_operative_event",
    sql="""
    select
        count(1) = 0
    from (
        select distinct data->'identification'->>'operativeEvent' operative_event
        from snosan_json_unique
        where data->>'chrono' not similar to '%20(19|20|21)%'
    ) _
    where operative_event not in (select seamis from secmar_json_evenement_codes);
    """,
    conn_id="postgresql_local",
    dag=dag,
)
check_completeness_snosan_json_operative_event.set_upstream(end_create_codes_tables)
check_completeness_snosan_json_operative_event.set_downstream(snosan_json_operations)

snosan_json_resultats_humain = secmar_json_sql_task(dag, "snosan_json_resultats_humain")
for column in ["categorie"]:
    table = "secmar_json_resultats_humain_{column}".format(column=column)
    task = PostgresOperator(
        task_id="check_completness_resultats_humain_{column}".format(column=column),
        sql="""
        select count(1) = 0
        from (
          select distinct personne->>'{column}'
            from (
                select jsonb_array_elements(data->'personnes') personne
                from snosan_json_unique
            ) _
          where personne->>'{column}' not in (select seamis from {table})
        ) _
        """.format(
            column=column, table=table
        ),
        postgres_conn_id="postgresql_local",
        dag=dag,
    )
    task.set_upstream(end_create_codes_tables)
    task.set_downstream(snosan_json_resultats_humain)

check_completness_resultats_humain_resultat = PostgresOperator(
    task_id="check_completness_resultats_humain_resultat",
    sql="""
    select count(1) = 0
    from (
      select value
      from (
        select distinct jsonb_array_elements(personne->'resultat')->>0 as value
        from (
          select jsonb_array_elements(data->'personnes') personne
          from snosan_json_unique
          where data->>'chrono' not similar to '%20(19|20|21)%'
        ) _
      )_
      where value not in (select seamis from secmar_json_resultats_humain_resultat)
    ) _
    """,
    postgres_conn_id="postgresql_local",
    dag=dag,
)
check_completness_resultats_humain_resultat.set_upstream(end_create_codes_tables)
check_completness_resultats_humain_resultat.set_downstream(snosan_json_resultats_humain)

snosan_json_moyens = secmar_json_sql_task(dag, "snosan_json_moyens")
for column in ["autorite", "type", "categorie"]:
    table = "secmar_json_engagements_{column}".format(column=column)
    task = PostgresOperator(
        task_id="check_completness_engagements_{column}".format(column=column),
        sql="""
        select count(1) = 0
        from (
          select distinct e->>'{column}'
          from (
            select jsonb_array_elements(data->'engagements') as e
            from snosan_json_unique
            where data ? 'engagements'
          ) _
          where e->>'{column}' not in (select seamis from {table})
        ) _
        """.format(
            column=column, table=table
        ),
        postgres_conn_id="postgresql_local",
        dag=dag,
    )
    task.set_upstream(end_create_codes_tables)
    task.set_downstream(snosan_json_moyens)

check_completness_secmar_json_type_flotteur = CheckOperator(
    task_id="check_completness_secmar_json_type_flotteur",
    sql="""
    select count(1) = 0
    from (
        select distinct coalesce(v->>'type', v->>'typeAero') type_flotteur
        from (
            select jsonb_array_elements(data->'vehicules') as v
            from snosan_json_unique
            where data ? 'vehicules' and data->>'chrono' not similar to '%20(19|20|21)%'
        ) _
    ) _
    where type_flotteur not in (select seamis from secmar_json_type_flotteur)
    """,
    conn_id="postgresql_local",
    dag=dag,
)
check_completness_secmar_json_type_flotteur.set_upstream(end_create_codes_tables)

check_completness_secmar_json_resultat_flotteur = CheckOperator(
    task_id="check_completness_secmar_json_resultat_flotteur",
    sql="""
    select count(1) = 0
    from secmar_json_resultat_flotteur f
    where f.seamis != '["INCONNU"]' and f.seamis::text like '%INCONNU%' and f.count > 25
    """,
    conn_id="postgresql_local",
    dag=dag,
)
check_completness_secmar_json_resultat_flotteur.set_upstream(end_create_codes_tables)

snosan_json_flotteurs = secmar_json_sql_task(dag, "snosan_json_flotteurs")
snosan_json_flotteurs.set_upstream(check_completness_secmar_json_type_flotteur)
snosan_json_flotteurs.set_upstream(check_completness_secmar_json_resultat_flotteur)

snosan_json_evenement = secmar_json_sql_task(dag, "snosan_json_evenement")
snosan_json_evenement.set_upstream(start_create_codes_tables)
check_completeness_count_rows_secmar_json_evenement = CheckOperator(
    task_id="check_completeness_count_rows_secmar_json_evenement",
    sql="""
    select
        count(1) = 0
    from snosan_json_unique
    where
      data->>'chrono' not in (select chrono from snosan_json_evenement)
      and data->>'chrono' not similar to '%20(19|20|21)%'
      and not data->'identification'->>'operativeEvent' is null
    """,
    conn_id="postgresql_local",
    dag=dag,
)
check_completeness_count_rows_secmar_json_evenement.set_upstream(snosan_json_evenement)
check_completeness_count_rows_secmar_json_evenement.set_downstream(snosan_json_operations)

download_secmar_csv_ftp = TriggerDagRunOperator(
    task_id="trigger_download_secmar_csv_ftp_dag",
    trigger_dag_id="download_secmar_csv_ftp",
    python_callable=lambda context, dag_run: dag_run,
    dag=dag,
)
download_secmar_csv_ftp.set_upstream(snosan_json_operations)
download_secmar_csv_ftp.set_upstream(snosan_json_flotteurs)
download_secmar_csv_ftp.set_upstream(snosan_json_moyens)
download_secmar_csv_ftp.set_upstream(snosan_json_resultats_humain)
