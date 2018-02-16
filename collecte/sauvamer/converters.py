# -*- coding: utf-8 -*-
import LatLon

import re


class SitRepConverter(object):
    @staticmethod
    def extract_sitrep_name(src):
        return SitRepConverter.normalize_cross_name(
            SitRepConverter.regex_extract(r'CROSS (.+\/\d+\/\d+)', src)
        )

    @staticmethod
    def normalize_cross_name(src):
        if src is None:
            return None
        mapping = {
            u'REUNION': u'RÉUNION',
            u'GRIS NEZ': u'GRIS-NEZ',
        }
        for to_search, to_replace in mapping.iteritems():
            src = src.replace(to_search, to_replace)
        return src

    @staticmethod
    def extract_cross(src):
        return SitRepConverter.normalize_cross_name(
            SitRepConverter.regex_extract(r'CROSS (.+)\/\d+\/\d+', src)
        )

    @staticmethod
    def extract_operation_type(src):
        return SitRepConverter.regex_extract(r'^SITREP (SAR|MAS|DIV) ', src)

    @staticmethod
    def regex_extract(the_regex, src):
        if src is None or type(src) != unicode:
            return None
        res = re.search(the_regex, src)
        if res is None:
            return None
        return res.group(1).strip()


class CoordinatesConverter(object):
    @staticmethod
    def dms_to_dd(latitude, longitude):
        return (
            CoordinatesConverter.latitude_dms_to_dd(latitude),
            CoordinatesConverter.longitude_dms_to_dd(longitude),
        )

    @staticmethod
    def latitude_dms_to_dd(src):
        src = src.encode('utf-8').replace(' ', '').replace(',', '.').upper()
        if src.startswith("0°"):
            return None
        for the_format, zero_value in zip(["d%°%m%'%H", "d%°%S%''%H"], ["0°0'E", "0°0''E"]):
            try:
                lat = LatLon.string2latlon(src, zero_value, the_format).lat
                break
            except ValueError:
                pass
        try:
            return float(repr(lat).replace('Latitude ', ''))
        except UnboundLocalError:
            return None

    @staticmethod
    def longitude_dms_to_dd(src):
        src = src.encode('utf-8').replace(' ', '').replace('O', 'W').replace(',', '.').upper()
        if src.startswith("0°"):
            return None
        for the_format, zero_value in zip(["d%°%m%'%H", "d%°%S%''%H"], ["0°0'N", "0°0''N"]):
            try:
                lon = LatLon.string2latlon(zero_value, src, the_format).lon
                break
            except ValueError:
                pass
        try:
            return float(repr(lon).replace('Longitude ', ''))
        except UnboundLocalError:
            return None
