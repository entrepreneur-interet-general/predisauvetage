# -*- coding: utf-8 -*-
from transformers.opendata.default import DefaultTransformer


class FlotteursTransformer(DefaultTransformer):
    DROP_COLUMNS = [
        'numero_immatriculation', 'marque', 'nom_serie', 'assurance',
        'longueur', 'largeur', 'jauge', 'nombre_personnes_recommande',
        'puissance_maximum_autorisee', 'surface_voilure', 'puissance_moteurs',
        'coque', 'materiau', 'propulsion', 'type_moteur', 'type_navire',
        'utilisation'
    ]
