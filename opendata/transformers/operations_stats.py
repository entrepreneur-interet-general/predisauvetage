# -*- coding: utf-8 -*-
import numpy as np
from jours_feries_france.compute import JoursFeries
from vacances_scolaires_france import SchoolHolidayDates
from vacances_scolaires_france import UnsupportedYearException

from transformers.sunrise_sunset import SunriseSunset
from transformers.base import BaseTransformer


class OperationsStatsTransformer(BaseTransformer):
    DATE_COLUMNS = ["date_heure_reception_alerte_locale", "date_heure_reception_alerte"]

    def __init__(self, filepath):
        super(OperationsStatsTransformer, self).__init__(filepath)
        self.bank_holidays = {}
        self.school_holiday = SchoolHolidayDates()

    def transform(self, output):
        df = self.read_csv()

        df["phase_journee"] = df.apply(lambda row: self.phase_journee(row), axis=1)
        df["est_jour_ferie"] = df.apply(lambda row: self.est_jour_ferie(row), axis=1)
        df["est_vacances_scolaires"] = df.apply(
            lambda row: self.est_vacances_scolaires(row), axis=1
        )

        df.drop(["latitude", "longitude"] + self.DATE_COLUMNS, axis=1, inplace=True)

        self.to_csv(df, output)

    def phase_journee(self, row):
        heure_locale = row["date_heure_reception_alerte_locale"]
        heure_utc = row["date_heure_reception_alerte"]
        latitude, longitude = row["latitude"], row["longitude"]
        try:
            sunrise, sunset = SunriseSunset(heure_utc, latitude, longitude).calculate()
        except ValueError:
            return np.nan
        # coucher du soleil -> lever du soleil
        if sunset <= heure_utc <= sunrise:
            return "nuit"
        # 12:00 -> 13:59
        elif 12 <= heure_locale.hour <= 13:
            return "déjeuner"
        # lever du soleil -> 10:59
        elif heure_locale.hour <= 11:
            return "matinée"
        # 14:00 -> coucher du soleil
        elif heure_locale.hour >= 14:
            return "après-midi"
        else:
            raise ValueError("Date is invalid " + str(heure_locale))

    def est_jour_ferie(self, row):
        date = row["date_heure_reception_alerte_locale"].date()

        if date.year not in self.bank_holidays:
            dates = JoursFeries.for_year(date.year).values()
            self.bank_holidays[date.year] = dates

        return date in self.bank_holidays[date.year]

    def est_vacances_scolaires(self, row):
        try:
            date = row["date_heure_reception_alerte_locale"].date()
            return self.school_holiday.is_holiday(date)
        except UnsupportedYearException:
            return np.nan
