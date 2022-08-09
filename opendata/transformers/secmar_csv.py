# -*- coding: utf-8 -*-
import csv
import logging
import os
import socket
import sys
from collections import defaultdict
from ftplib import FTP
from io import TextIOWrapper
from pathlib import Path
from zipfile import ZipFile

import pandas as pd
import socks

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

FTP_BASE_FOLDER = "snosan_secmarweb"
BASE_PATH = Path("/Users/antoineaugusti/Documents/predisauvetage/snosan_csv")
AGGREGATE_FOLDER = BASE_PATH / "aggregate"
EXPECTED_FILENAMES = set(["flotteur.csv", "bilan.csv", "moyen.csv", "operation.csv"])


def ftp_download_remote_folder(day):
    (BASE_PATH / day).mkdir(parents=False, exist_ok=True)
    if os.getenv("FTP_PROXY", "false") == "true":
        socks.setdefaultproxy(
            socks.PROXY_TYPE_SOCKS5,
            os.getenv("FTP_PROXY_HOST", "localhost"),
            int(os.getenv("FTP_PROXY_PORT", 8080)),
        )
        socket.socket = socks.socksocket
    env = os.environ
    ftp = FTP(env["FTP_HOST"])
    ftp.login(env["FTP_USER"], env["FTP_PASSWORD"])
    ftp.cwd(FTP_BASE_FOLDER)
    ftp.cwd(day)
    filenames = ftp.nlst()
    logging.debug("Found %s remote files to download for %s" % (len(filenames), day))
    for filename in filenames:
        target_path = BASE_PATH / day / filename
        if target_path.exists():
            logging.debug("%s/%s already exists, skipping" % (day, filename))
            continue
        logging.debug("Downloading %s/%s" % (day, filename))
        ftp.retrbinary("RETR " + filename, open(str(target_path), "wb").write)
    ftp.quit()


def save_csv_for_day(day, data):
    for filename in EXPECTED_FILENAMES:
        with open(str(BASE_PATH / day / filename), "w") as f:
            writer = csv.DictWriter(
                f, fieldnames=["operation_id"] + _headers_for_filename(filename)
            )
            writer.writeheader()
            writer.writerows(data[filename])


def extract_for_day(day):
    result = defaultdict(list)
    files = [f for f in (BASE_PATH / day).iterdir() if f.suffix == ".zip"]
    logging.debug("Extracting %s files for %s" % (len(files), day))
    for zip_filepath in files:
        with ZipFile(str(zip_filepath)) as zf:
            _check_has_required_files(zf.infolist(), zip_filepath)
            for filename in EXPECTED_FILENAMES:
                result[filename].extend(read_rows_for_file(zf, filename, zip_filepath))
    return result


def read_rows_for_file(zipfile, filename, zip_filepath):
    operation_id = operation_id_from_filepath(zip_filepath)
    with zipfile.open(filename, "r") as f:
        reader = csv.DictReader(TextIOWrapper(f, "utf-8"), delimiter=";")
        _check_expected_headers(
            filename, reader.fieldnames, str(zip_filepath / filename)
        )
        rows = []
        for row in reader:
            row["operation_id"] = operation_id
            rows.append(row)
        return rows


def operation_id_from_filepath(zip_filepath):
    return zip_filepath.name.rstrip(".zip")


def _check_has_required_files(zip_info_list, zip_filepath):
    filenames = set([f.filename for f in zip_info_list])
    if filenames != EXPECTED_FILENAMES:
        raise ValueError("Unexpected filenames in %s" % str(zip_filepath))


def _check_expected_headers(filename, detected_headers, csv_path):
    if _headers_for_filename(filename) != detected_headers:
        raise ValueError("Unexpected CSV headers for %s" % csv_path)


def _headers_for_filename(filename):
    return {
        "bilan.csv": [
            "SEC_RESULTAT_HUMAIN_resultat_humain_id",
            "SEC_RESULTAT_HUMAIN_cat_personne_id",
            "SEC_RESULTAT_HUMAIN_nb",
            "SEC_RESULTAT_HUMAIN_dont_nb_blesse",
        ],
        "flotteur.csv": [
            "SEC_FLOTTEUR_IMPLIQUE_mer_force",
            "SEC_FLOTTEUR_IMPLIQUE_type_flotteur_id",
            "SEC_FLOTTEUR_IMPLIQUE_pavillon_id",
            "SEC_FLOTTEUR_IMPLIQUE_num_immat_fr",
            "SEC_FLOTTEUR_IMPLIQUE_num_imo",
            "SEC_FLOTTEUR_IMPLIQUE_nom",
            "SEC_FLOTTEUR_IMPLIQUE_resultat_flotteur_id",
        ],
        "moyen.csv": [
            "SEC_MOYEN_MEO_date_heure_depart",
            "SEC_MOYEN_MEO_duree",
            "SEC_MOYEN_MEO_autorite_moyen_id",
            "SEC_C_MOYEN_cat_moyen_id",
            "SEC_MOYEN_MEO_moyen_id",
        ],
        "operation.csv": [
            "SEC_OPERATION_date_operation",
            "SEC_OPERATION_autorite_id",
            "SEC_OPERATION_no_SITREP",
            "SEC_OPERATION_SEC_OPERATIONcross_id",
            "SEC_C_EVENEMENT_cat_evenement_id_1",
            "SEC_OPERATION_evenement_id_1",
            "SEC_OPERATION_zone_resp_id",
            "SEC_OPERATION_dept_id",
            "SEC_OPERATION_latitude",
            "SEC_OPERATION_longitude",
            "SEC_OPERATION_date_heure_recpt_alerte_id",
            # Correspond à `type_operation` dans SECMAR
            "SEC_OPERATION_pourquoi_alerte_id",
            "EC_OPERATION_moyen_alerte_id",
            "SEC_C_QUI_ALERTE_cat_qui_alerte_id",
            "SEC_OPERATION_qui_alerte_id",
            "SEC_OPERATION_vent_direction",
            "SEC_OPERATION_vent_force",
            "SEC_OPERATION_date_heure_fin_operation",
        ],
    }[filename]


def process_all_days(skip_if_existing=True):
    for day in filter(_should_process_day, list_of_days()):
        save_csv_for_day(day, extract_for_day(day))


def list_of_days():
    return filter(
        lambda x: x.is_dir() and x.name.isdigit(), sorted(BASE_PATH.iterdir())
    )


def _should_process_day(day):
    result = any([not (BASE_PATH / day / f).exists() for f in EXPECTED_FILENAMES])
    if result:
        logging.debug("Processing %s" % day)
    else:
        logging.debug("Skipping %s" % day)
    return result


def build_aggregate_files():
    AGGREGATE_FOLDER.mkdir(parents=False, exist_ok=True)
    for filename in EXPECTED_FILENAMES:
        buff = []
        for day in list_of_days():
            with open(str(BASE_PATH / day / filename), "r") as f:
                buff.extend(f.readlines()[1:])
        target_path = str(AGGREGATE_FOLDER / filename)
        with open(target_path, "w") as f:
            csv.writer(f).writerow(["operation_id"] + _headers_for_filename(filename))
            f.writelines(buff)
        df = pd.read_csv(target_path)
        df["operation_long_name"] = df["operation_id"].apply(
            lambda v: "_".join(v.split("_")[:-1])
        )
        df["operation_version"] = df["operation_id"].apply(
            lambda v: int(v.split("_")[-1])
        )
        df.to_csv(target_path, index=False)
        logging.debug("Created aggregate for %s " % (filename))


def describe_aggregate_files():
    for filename in EXPECTED_FILENAMES:
        df = read_aggregate_file(filename)
        for col in df.columns:
            if df[col].nunique() < 60:
                print(df[col].value_counts())


def _mapping_filepath(filename):
    if not filename.endswith(".csv"):
        raise ValueError("Unexpected mapping filename " + filename)
    return Path("../codes/" + filename)


def _mapping_file_exists(filename):
    return _mapping_filepath(filename).exists()


def read_mapping_file(filename):
    logging.debug("Reading %s" % filename)
    df = pd.read_csv(_mapping_filepath(filename), index_col="code")
    if filename == "SEC_C_QUI_ALERTE_cat_qui_alerte_id.csv":
        df.index = df.index.map(lambda v: str(v).rstrip(".0"))
    if not df.index.is_unique:
        raise ValueError("Duplicate index values for %s" % filename)
    return df


def read_aggregate_file(filename):
    logging.debug("Reading aggregate file %s", filename)
    df = pd.read_csv(str(AGGREGATE_FOLDER / filename))
    versions = (
        df.groupby(["operation_long_name"], sort=False)[
            ["operation_version", "operation_id"]
        ]
        .max()
        .reset_index()
    ).set_index("operation_id")
    df = df.loc[df.operation_id.isin(versions.index)]
    if filename == "flotteur.csv":
        df["SEC_FLOTTEUR_IMPLIQUE_mer_force"] = df[
            "SEC_FLOTTEUR_IMPLIQUE_mer_force"
        ].str.replace('"', "")
    if filename == "operation.csv":
        df["SEC_C_QUI_ALERTE_cat_qui_alerte_id"] = df[
            "SEC_C_QUI_ALERTE_cat_qui_alerte_id"
        ].apply(lambda v: str(v).rstrip(".0"))
        df["SEC_OPERATION_vent_force"] = df["SEC_OPERATION_vent_force"].str.replace(
            '"', ""
        )
    df.to_csv(str(AGGREGATE_FOLDER / filename) + ".debug", index=False)
    return df


def check_mapping_data():
    for filename in EXPECTED_FILENAMES:
        df = read_aggregate_file(filename)
        for col in _headers_for_filename(filename):
            mapping_filename = col + ".csv"
            if _mapping_file_exists(mapping_filename):
                mapping_data = read_mapping_file(mapping_filename)
                mapped_values = mapping_data.index.unique()
                for unique_value in df[col].unique():
                    res = unique_value not in mapped_values
                    if res:
                        logging.error(
                            "Value `%s` is not mapped for `%s` in `%s`"
                            % (unique_value, col, filename)
                        )


# ftp_download_remote_folder("20220809")
process_all_days()
build_aggregate_files()
# describe_aggregate_files()
check_mapping_data()
