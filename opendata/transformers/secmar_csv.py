# -*- coding: utf-8 -*-
import csv
import datetime
import logging
import os
import socket
import sys
from collections import defaultdict
from ftplib import FTP
from functools import lru_cache
from io import TextIOWrapper
from pathlib import Path
from zipfile import ZipFile

import numpy as np
import pandas as pd
import socks

FTP_BASE_FOLDER = "snosan_secmarweb"
BASE_PATH = Path(__file__).resolve().parent.parent.parent / "snosan_csv"
AGGREGATE_FOLDER = BASE_PATH / "aggregate"
EXPECTED_FILENAMES = set(["flotteur.csv", "bilan.csv", "moyen.csv", "operation.csv"])
ADDED_COLUMNS = ["deduplication_id", "operation_id", "extraction_date"]


@lru_cache(maxsize=None)
def cross_mapping():
    mapping = read_mapping_file("SEC_OPERATION_SEC_OPERATIONcross_id.csv")[
        "libelle_court"
    ].to_dict()
    return {v: k for k, v in mapping.items()}


@lru_cache(maxsize=None)
def pourquoi_alerte_mapping():
    mapping = read_mapping_file("SEC_OPERATION_pourquoi_alerte_id.csv")[
        "libelle"
    ].to_dict()
    return {v: k for k, v in mapping.items()}


def _setup_ftp_connexion():
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
    return ftp


def day_exists_in_remote_ftp(day):
    folders = [name for name, _ in _setup_ftp_connexion().mlsd()]
    return day in folders


def ftp_delete_remote_folder(day):
    if not day_exists_in_remote_ftp(day):
        return
    ftp = _setup_ftp_connexion()
    ftp.cwd(day)
    for filename in ftp.nlst():
        ftp.delete(filename)
    ftp.cwd(FTP_BASE_FOLDER)
    ftp.rmd(day)
    ftp.quit()


def ftp_download_remote_folder(day):
    (BASE_PATH / day).mkdir(parents=False, exist_ok=True)
    ftp = _setup_ftp_connexion()
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


def download_latest_remote_days():
    for day in pd.date_range(end=pd.to_datetime("today").date(), periods=365)[::-1]:
        day_str = day.strftime("%Y%m%d")
        if (BASE_PATH / day_str).exists():
            logging.debug(
                "%s is already available locally, stopping remote download" % day_str
            )
            break
        ftp_download_remote_folder(day_str)


def save_csv_for_day(day, data):
    for filename in EXPECTED_FILENAMES:
        with open(str(BASE_PATH / day / filename), "w") as f:
            writer = csv.DictWriter(
                f, fieldnames=ADDED_COLUMNS + _headers_for_filename(filename)
            )
            writer.writeheader()
            writer.writerows(data[filename])


def extract_for_day(day):
    result = defaultdict(list)
    files = [f for f in (BASE_PATH / day).iterdir() if f.suffix == ".zip"]
    logging.debug("Extracting %s files for %s" % (len(files), day))
    for zip_filepath in files:
        logging.debug("Zip_filepath %s" % (zip_filepath))
        with ZipFile(str(zip_filepath)) as zf:
            _check_has_required_files(zf.infolist(), zip_filepath)
            for filename in EXPECTED_FILENAMES:
                result[filename].extend(read_rows_for_file(zf, filename, zip_filepath))
    return result


def read_rows_for_file(zipfile, filename, zip_filepath):
    operation_id = operation_id_from_filepath(zip_filepath)
    extraction_date = extraction_date_from_filepath(zip_filepath)
    with zipfile.open(filename, "r") as f:
        reader = csv.DictReader(TextIOWrapper(f, "utf-8"), delimiter=";")
        _check_expected_headers(
            filename, reader.fieldnames, str(zip_filepath / filename)
        )
        rows = []
        for row in reader:
            row["deduplication_id"] = operation_id + "_" + extraction_date
            row["operation_id"] = operation_id
            row["extraction_date"] = extraction_date
            rows.append(row)
        return rows


def operation_id_from_filepath(zip_filepath):
    # ~/predisauvetage/snosan_csv/20230405/ET_2023_MAS_0705_1.zip
    # Keep ET_2023_MAS_0705_1
    return zip_filepath.name.rstrip(".zip")


def extraction_date_from_filepath(zip_filepath):
    # ~/predisauvetage/snosan_csv/20230405/ET_2023_MAS_0705_1.zip
    # Keep 20230405
    return zip_filepath.parent.name


def _check_has_required_files(zip_info_list, zip_filepath):
    filenames = set([f.filename for f in zip_info_list])
    if filenames != EXPECTED_FILENAMES:
        raise ValueError("Unexpected filenames in %s" % str(zip_filepath))


def _check_expected_headers(filename, detected_headers, csv_path):
    if _headers_for_filename(filename) != detected_headers:
        raise ValueError("Unexpected CSV headers for %s" % csv_path)


def _dates_for_filename(filename):
    return {
        "bilan.csv": [],
        "flotteur.csv": [],
        "moyen.csv": [
            "SEC_MOYEN_MEO_date_heure_depart",
            "SEC_MOYEN_MEO_duree",
        ],
        "operation.csv": [
            "SEC_OPERATION_date_operation",
            "SEC_OPERATION_date_heure_recpt_alerte_id",
            "SEC_OPERATION_date_heure_fin_operation",
        ],
    }[filename]


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
            csv.writer(f).writerow(ADDED_COLUMNS + _headers_for_filename(filename))
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
    return Path(__file__).resolve().parent.parent / "codes/" / filename


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


def cross_sitrep(row):
    # JB_2020_SAR_0941_3
    year = row["operation_id"].split("_")[1]
    return "%s %s %s/%s" % (
        row["SEC_OPERATION_SEC_OPERATIONcross_id"],
        row["SEC_OPERATION_pourquoi_alerte_id"],
        year,
        row["SEC_OPERATION_no_SITREP"],
    )


def secmar_operation_id(row):
    # JB_2020_SAR_0941_3
    cross, year, pourquoi_alerte, numero_sitrep, _ = row["operation_id"].split("_")
    seamis_code = "1"
    cross_id = cross_mapping()[cross]
    pourquoi_alerte_id = pourquoi_alerte_mapping()[pourquoi_alerte]
    return "".join(
        map(str, [seamis_code, cross_id, pourquoi_alerte_id, year, numero_sitrep])
    )


def date_converters(date_columns):
    def to_datetime(val):
        if val == "":
            return np.nan
        formats = ["%Y-%m-%dT%H:%M:%S.%fZ", "%Y-%m-%dT%H:%M:%SZ"]
        for date_format in formats:
            try:
                dt = datetime.datetime.strptime(val, date_format)
                # Found 0819-08-12T00:00:00Z for ET_2021_DIV_3490
                if dt.year <= 2000:
                    return np.nan
                return dt
            except ValueError:
                pass
        raise ValueError("Cannot parse %s as a datetime" % val)

    return {date_column: to_datetime for date_column in date_columns}


def read_aggregate_file(filename, replace_mapping=True):
    logging.debug("Reading aggregate file %s", filename)
    df = pd.read_csv(
        str(AGGREGATE_FOLDER / filename),
        converters=date_converters(_dates_for_filename(filename)),
    )

    # Keep only the most recent version of the operation
    versions = (
        df.sort_values("deduplication_id", ascending=True)
        .groupby(["operation_long_name"])
        .last()["deduplication_id"]
    )
    df = df.loc[df.deduplication_id.isin(versions)]

    # Generic transformations
    df["secmar_operation_id"] = df.apply(lambda r: secmar_operation_id(r), axis=1)

    # Transformations for each file
    if filename == "flotteur.csv":
        df["SEC_FLOTTEUR_IMPLIQUE_mer_force"] = df[
            "SEC_FLOTTEUR_IMPLIQUE_mer_force"
        ].str.extract(r"ETAT_MER_(\d)")
    if filename == "operation.csv":
        df["SEC_C_QUI_ALERTE_cat_qui_alerte_id"] = df[
            "SEC_C_QUI_ALERTE_cat_qui_alerte_id"
        ].apply(lambda v: str(v).rstrip(".0"))
        df["SEC_OPERATION_vent_direction"] = np.rad2deg(
            df["SEC_OPERATION_vent_direction"]
        ).round()
        df["SEC_OPERATION_vent_force"] = df["SEC_OPERATION_vent_force"].str.extract(
            r"FORCE_(\d)"
        )

    if replace_mapping:
        df.replace(to_replace=build_replacement_mapping(filename), inplace=True)

    if filename == "operation.csv":
        df["cross_sitrep"] = df.apply(lambda r: cross_sitrep(r), axis=1)
        df = df.sort_values(
            "SEC_OPERATION_evenement_id_1", na_position="first"
        ).drop_duplicates(subset=["secmar_operation_id"], keep="last")
        df["vent_direction_categorie"] = vent_direction_categorie(
            df["SEC_OPERATION_vent_direction"]
        )
        df["fuseau_horaire"] = fuseau_horaire(df["SEC_OPERATION_SEC_OPERATIONcross_id"])
        df["est_metropolitain"] = df.apply(lambda r: est_metropolitain(r), axis=1)
    return df


def est_metropolitain(row):
    cross = row["SEC_OPERATION_SEC_OPERATIONcross_id"]
    dept_hors_metropole = [
        "Guadeloupe",
        "Guyane",
        "La Réunion",
        "Martinique",
        "Mayotte",
        "Nouvelle-Calédonie",
        "Polynésie française",
        "Saint-Barthélemy",
        "Saint-Martin",
        "Saint-Pierre-et-Miquelon",
        "Terres australes et antarctiques françaises",
        "Wallis-et-Futuna",
        "Île de Clipperton",
    ]
    cross_hors_metropole = [
        "Antilles-Guyane",
        "Guadeloupe",
        "Guyane",
        "La Réunion",
        "Martinique",
        "Mayotte",
        "Nouvelle-Calédonie",
        "Polynésie",
    ]
    if cross in cross_hors_metropole:
        return False
    if cross not in cross_hors_metropole and cross != "Gris-Nez":
        return True
    if pd.isna(row["SEC_OPERATION_dept_id"]):
        return np.nan
    return row["SEC_OPERATION_dept_id"] not in dept_hors_metropole


def vent_direction_categorie(series):
    bins = [0, 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5, np.inf]
    labels = [
        "nord",
        "nord-est",
        "est",
        "sud-est",
        "sud",
        "sud-ouest",
        "ouest",
        "nord-ouest",
        "nord2",
    ]
    return pd.cut(series, bins=bins, labels=labels).replace("nord2", "nord")


def fuseau_horaire(series):
    return series.map(
        {
            "Antilles-Guyane": "America/Cayenne",
            "Corse": "Europe/Paris",
            "Corsen": "Europe/Paris",
            "Gris-Nez": "Europe/Paris",
            "Guadeloupe": "America/Guadeloupe",
            "Guyane": "America/Guyana",
            "Jobourg": "Europe/Paris",
            "La Garde": "Europe/Paris",
            "La Réunion": "Indian/Reunion",
            "Martinique": "America/Martinique",
            "Mayotte": "Indian/Mayotte",
            "Nouvelle-Calédonie": "Pacific/Noumea",
            "Polynésie": "Pacific/Tahiti",
            "Étel": "Europe/Paris",
        }
    )


def create_cleaned_aggregate_files():
    for filename in EXPECTED_FILENAMES:
        target_filename = filename.replace(".csv", ".cleaned.csv")
        df = read_aggregate_file(filename, replace_mapping=True)
        df.to_csv(
            str(AGGREGATE_FOLDER / target_filename),
            index=False,
            float_format="%.6g",
            date_format="%Y-%m-%dT%H:%M:%SZ",
        )
        logging.debug("Saved aggregated and cleaned file %s" % target_filename)


def check_mapping_data():
    for filename in EXPECTED_FILENAMES:
        df = read_aggregate_file(filename, replace_mapping=False)
        for col in _headers_for_filename(filename):
            mapping_filename = col + ".csv"
            if _mapping_file_exists(mapping_filename):
                mapping_data = read_mapping_file(mapping_filename)
                mapped_values = mapping_data.index.unique()
                for unique_value in df[col].unique():
                    if unique_value not in mapped_values:
                        logging.error(
                            "Value `%s` is not mapped for `%s` in `%s`"
                            % (unique_value, col, filename)
                        )


def build_replacement_mapping(filename):
    mapping = {}
    for column in _headers_for_filename(filename):
        mapping_filename = column + ".csv"
        if _mapping_file_exists(mapping_filename):
            mapping_data = read_mapping_file(mapping_filename)
            mapping[column] = mapping_data["libelle"].to_dict()
    return mapping


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
    # download_latest_remote_days()
    process_all_days()
    build_aggregate_files()
    # describe_aggregate_files()
    # check_mapping_data()
    create_cleaned_aggregate_files()
