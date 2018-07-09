# -*- coding: utf-8 -*-
import numpy as np
from jours_feries_france.compute import JoursFeries

from datetime import timedelta

from transformers.sunrise_sunset import SunriseSunset
from transformers.base import BaseTransformer


class OperationsStatsTransformer(BaseTransformer):
    DATE_COLUMNS = [
        'date_heure_reception_alerte_locale',
        'date_heure_reception_alerte'
    ]

    def __init__(self, filepath):
        super(OperationsStatsTransformer, self).__init__(filepath)
        self.bank_holidays = {}

    def transform(self, output):
        def phase_journee(row):
            heure_locale = row['date_heure_reception_alerte_locale']
            heure_utc = row['date_heure_reception_alerte']
            latitude, longitude = row['latitude'], row['longitude']
            try:
                sunrise, sunset = SunriseSunset(heure_utc, latitude, longitude).calculate()
            except ValueError:
                return np.nan
            # 30mn avant coucher du soleil -> 30mn après lever du soleil
            if (sunset - timedelta(minutes=30)) <= heure_utc <= (sunrise + timedelta(minutes=30)):
                return 'nuit'
            # 11:00 -> 14:59
            elif 11 <= heure_locale.hour <= 14:
                return 'déjeuner'
            # lever du soleil -> 10:59
            elif heure_locale.hour <= 10:
                return 'matinée'
            # 15:00 -> coucher du soleil
            elif heure_locale.hour >= 15:
                return 'après-midi'
            else:
                raise ValueError('Date is invalid' + heure_locale)

        def est_jour_ferie(row):
            date = row['date_heure_reception_alerte_locale'].date()

            if date.year not in self.bank_holidays:
                dates = JoursFeries.for_year(date.year).values()
                self.bank_holidays[date.year] = dates

            return date in self.bank_holidays[date.year]

        df = self.read_csv()
        df['phase_journee'] = df.apply(lambda row: phase_journee(row), axis=1)
        df['est_jour_ferie'] = df.apply(lambda row: est_jour_ferie(row), axis=1)

        df.drop(
            ['latitude', 'longitude'] + self.DATE_COLUMNS,
            axis=1,
            inplace=True
        )

        self.to_csv(df, output)
