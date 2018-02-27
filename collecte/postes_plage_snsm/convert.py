# -*- coding: utf-8 -*-
from bs4 import BeautifulSoup
import pandas as pd

# Likely coming from
# https://www.google.com/maps/d/viewer?mid=151Itl_57S7UlpC7P-TdfvT2Pz7Y


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
            soup = BeautifulSoup(f, 'xml')
            for placemark in soup.kml.Document.Folder.find_all('Placemark'):
                poste = {}
                poste['nom'] = placemark.find('name').text.strip()
                poste['latitude'], poste['longitude'] = self.parse_coordinates(
                    placemark.find('coordinates')
                )
                for data in placemark.ExtendedData.find_all('Data'):
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
        df = df.sort_values(by='code_postal').reset_index(drop=True)
        df.index += 1
        df.to_csv(filepath, encoding='utf-8', index=True, index_label='id')
