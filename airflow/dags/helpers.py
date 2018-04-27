# -*- coding: utf-8 -*-
from airflow.models import Variable
from airflow.operators.bash_operator import BashOperator


def base_path():
    return Variable.get('BASE_PATH')


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


def default_env():
    return {
        'EMBULK_POSTGRESQL_HOST': Variable.get('EMBULK_POSTGRESQL_HOST'),
        'EMBULK_POSTGRESQL_USER': Variable.get('EMBULK_POSTGRESQL_USER'),
        'EMBULK_POSTGRESQL_PASSWORD': Variable.get('EMBULK_POSTGRESQL_PASSWORD'),
        'EMBULK_POSTGRESQL_DATABASE': Variable.get('EMBULK_POSTGRESQL_DATABASE'),
    }


def resolve_env(env):
    if type(env) == dict:
        return {**(default_env()), **env}
    return default_env()


def embulk_run(dag, script, env=None):
    return BashOperator(
        task_id='embulk_run_' + script,
        bash_command="%s run %s" % (
            Variable.get('EMBULK_BIN'),
            embulk_filepath(script)
        ),
        dag=dag,
        pool='embulk',
        env=resolve_env(env)
    )
