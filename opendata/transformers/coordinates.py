# -*- coding: utf-8 -*-
import re

# Example: 47°03.29'N - 002°14.59'W
PATTERN_DM = re.compile(
    r"(?P<lat>\d+)°(?P<lat_m>\d+.\d+)'(?P<lat_dir>N|S) - (?P<lon>\d+)°(?P<lon_m>\d+.\d+)'(?P<lon_dir>W|E)"
)
# Example: 43°32'27"N - 003°58'41"E
PATTERN_DMS = re.compile(
    r"(?P<lat>\d+)°(?P<lat_m>\d+)'(?P<lat_s>\d+)\"(?P<lat_dir>N|S) - (?P<lon>\d+)°(?P<lon_m>\d+)'(?P<lon_s>\d+)\"(?P<lon_dir>W|E)"
)
# Example: -51,033333 - 2,0515
PATTERN_DD = re.compile(r"(?P<lat>-?\d+(,|.)\d+) - (?P<lon>-?\d+(,|.)\d+)")


def parse(content):
    m = re.match(PATTERN_DM, content)
    if m:
        return (convert_dm(m, "lat"), convert_dm(m, "lon"))

    m = re.match(PATTERN_DMS, content)
    if m:
        return (convert_dms(m, "lat"), convert_dms(m, "lon"))

    m = re.match(PATTERN_DD, content)
    if m:
        return (
            round(float(m.group("lat").replace(",", ".")), 6),
            round(float(m.group("lon").replace(",", ".")), 6),
        )

    return (None, None)


def convert_dm(groups, coordinate):
    return round(
        sign(groups.group(coordinate + "_dir"))
        * (float(groups.group(coordinate + "")) + float(groups.group(coordinate + "_m")) / 60),
        6,
    )


def convert_dms(groups, coordinate):
    return round(
        sign(groups.group(coordinate + "_dir"))
        * (
            float(groups.group(coordinate + ""))
            + float(groups.group(coordinate + "_m")) / 60
            + float(groups.group(coordinate + "_s")) / 3600
        ),
        6,
    )


def sign(direction):
    if direction in ["N", "E"]:
        return 1
    if direction in ["S", "W"]:
        return -1
