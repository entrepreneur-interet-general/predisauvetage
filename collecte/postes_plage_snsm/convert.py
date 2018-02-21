# -*- coding: utf-8 -*-
from bs4 import BeautifulSoup
import pandas as pd


class KMLConverter(object):
    def __init__(self, filepath):
        self.filepath = filepath
        self.postes = []
        self.parse()

    def clean_key(self, key):
        return {
            u'DÉPARTEMENT': 'departement',
            'NB DE SAUVETEURS SNSM': 'nb_sauveteurs',
            'CP': 'code_postal',
            'VILLE': 'ville',
        }[key]

    def parse_coordinates(self, value):
        if value is None:
            return None, None
        parts = map(float, value.text.split(','))
        latitude, longitude = parts[1], parts[0]
        return latitude, longitude

    def parse(self):
        with open(self.filepath, 'r') as f:
            soup = BeautifulSoup(f, 'lxml')
            for placemark in soup.folder.find_all('placemark'):
                poste = {}
                poste['nom'] = placemark.find('name').text
                poste['latitude'], poste['longitude'] = self.parse_coordinates(
                    placemark.find('coordinates')
                )
                for data in placemark.find_all('data'):
                    key, value = data['name'], data.text.strip()
                    if key != 'gx_media_links':
                        cleaned_key = self.clean_key(key)
                        if cleaned_key == 'nb_sauveteurs':
                            poste[cleaned_key] = int(float(value))
                        else:
                            poste[cleaned_key] = value
                self.postes.append(poste)

    def to_csv(self, filepath):
        df = pd.DataFrame(self.postes)
        df.to_csv(filepath, encoding='utf-8', index=False)
