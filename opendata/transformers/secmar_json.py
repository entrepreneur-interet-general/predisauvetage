# -*- coding: utf-8 -*-
import logging
import os
import socket
import sys
from ftplib import FTP
from pathlib import Path

import pandas as pd
import socks

FTP_BASE_FOLDER = "JSON"
BASE_PATH = Path(__file__).resolve().parent.parent.parent / "snosan_json"
AGGREGATE_FOLDER = BASE_PATH / "aggregate"
AGGREGATE_FILEPATH = AGGREGATE_FOLDER / "all.json"


class FTP_PassiveMode_IgnoreHost(FTP):
    def makepasv(self):
        # See https://stumbles.id.au/python-ftps-and-mis-configured-servers.html
        _, port = super().makepasv()
        return self.host, port


def _setup_ftp_connexion():
    if os.getenv("FTP_PROXY", "false") == "true":
        socks.setdefaultproxy(
            socks.PROXY_TYPE_SOCKS5,
            os.getenv("FTP_PROXY_HOST", "localhost"),
            int(os.getenv("FTP_PROXY_PORT", 8080)),
        )
        socket.socket = socks.socksocket
    env = os.environ
    ftp = FTP_PassiveMode_IgnoreHost(env["FTP_HOST"])
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


def save_json_for_day(day, data):
    with open(str(BASE_PATH / day / "data.json"), "w") as f:
        f.write("\n".join(data) + "\n")


def process_all_days():
    all = []
    for day in list_of_days():
        data_for_day = extract_for_day(day)
        save_json_for_day(day, data_for_day)
        all.extend(data_for_day)

    AGGREGATE_FOLDER.mkdir(parents=False, exist_ok=True)
    with open(str(AGGREGATE_FILEPATH), "w") as f:
        f.write("\n".join(all) + "\n")


def extract_for_day(day):
    result = []
    files = [
        f
        for f in (BASE_PATH / day).iterdir()
        if f.suffix == ".json" and f.name != "data.json"
    ]
    logging.debug("Extracting %s files for %s" % (len(files), day))
    for filepath in files:
        with open(str(filepath), "r") as f:
            result.append(f.read())
    return result


def list_of_days():
    return filter(
        lambda x: x.is_dir() and x.name.isdigit(), sorted(BASE_PATH.iterdir())
    )


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
    # download_latest_remote_days()
    process_all_days()
