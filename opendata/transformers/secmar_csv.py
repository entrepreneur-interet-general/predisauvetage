# -*- coding: utf-8 -*-
import logging
from pathlib import Path
import csv
from io import TextIOWrapper
from zipfile import ZipFile
import sys
from collections import defaultdict

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

BASE_PATH = Path("/Users/antoineaugusti/Documents/predisauvetage/snosan_csv")
EXPECTED_FILENAMES = set(["flotteur.csv", "bilan.csv", "moyen.csv", "operation.csv"])


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
    logging.debug("Found %s files for %s" % (len(files), day))
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
    for day in filter(_should_process_day, BASE_PATH.iterdir()):
        save_csv_for_day(day, extract_for_day(day))


def _should_process_day(day):
    is_dir = (BASE_PATH / day).is_dir()
    return is_dir and any(
        [not (BASE_PATH / day / f).exists() for f in EXPECTED_FILENAMES]
    )


process_all_days()
