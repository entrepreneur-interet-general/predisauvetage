# -*- coding: utf-8 -*-
import re
from datetime import timedelta

from airflow.models import Variable
from airflow.operators.bash_operator import BashOperator


def base_path():
    return Variable.get('BASE_PATH')


def opendata_sql_path(filename):
    return "{base}/opendata_sql/{filename}.sql".format(
        base=base_path(),
        filename=filename
    )


def data_path(filename):
    return "{base}/data/{filename}".format(
        base=base_path(),
        filename=filename
    )


def embulk_filepath(filename):
    return "{base}/../embulk/{filename}.yml.liquid".format(
        base=base_path(),
        filename=filename
    )


def opendata_git_path():
    return Variable.get('OPENDATA_GIT_PATH')


def default_env():
    return {
        # PostgreSQL
        'EMBULK_POSTGRESQL_HOST': Variable.get('EMBULK_POSTGRESQL_HOST'),
        'EMBULK_POSTGRESQL_USER': Variable.get('EMBULK_POSTGRESQL_USER'),
        'EMBULK_POSTGRESQL_PASSWORD': Variable.get('EMBULK_POSTGRESQL_PASSWORD'),
        'EMBULK_POSTGRESQL_DATABASE': Variable.get('EMBULK_POSTGRESQL_DATABASE'),
        # Oracle
        'EMBULK_ORACLE_DRIVER_PATH': Variable.get('EMBULK_ORACLE_DRIVER_PATH'),
        'EMBULK_ORACLE_HOST': Variable.get('EMBULK_ORACLE_HOST'),
        'EMBULK_ORACLE_USER': Variable.get('EMBULK_ORACLE_USER'),
        'EMBULK_ORACLE_PASSWORD': Variable.get('EMBULK_ORACLE_PASSWORD'),
        'EMBULK_ORACLE_DATABASE': Variable.get('EMBULK_ORACLE_DATABASE'),
    }


def resolve_env(env):
    if type(env) == dict:
        return {**(default_env()), **env}
    return default_env()


def embulk_run(dag, script, env=None, task_id=None):
    return BashOperator(
        task_id=task_id or 'embulk_run_' + script,
        bash_command="%s run %s" % (
            Variable.get('EMBULK_BIN'),
            embulk_filepath(script)
        ),
        dag=dag,
        pool='embulk',
        env=resolve_env(env)
    )


def read_sql_query(filename):
    path = '/../opendata/sql/{filename}.sql'.format(filename=filename)
    filepath = base_path() + path
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    return re.sub('\s+', ' ', content)


def default_args(conf):
    default = {
        'owner': 'antoine-augusti',
        'depends_on_past': False,
        'email': [],
        'retries': 2,
        'retry_delay': timedelta(minutes=1),
    }
    return {**(default), **conf}
