DROP TABLE IF EXISTS secmar_json_type_flotteur;

CREATE TABLE secmar_json_type_flotteur (
  seamis varchar primary key,
  secmar varchar,
  categorie_flotteur varchar
);

CREATE INDEX ON secmar_json_type_flotteur(secmar);

INSERT INTO secmar_json_type_flotteur
  (seamis, secmar, categorie_flotteur)
VALUES
  ('PLAISANCE_MOTEUR', 'Plaisance à moteur', 'Plaisance'),
  ('PLAISANCE_VOILE', 'Plaisance à voile', 'Plaisance'),
  ('NAVIRE_DE_PECHE', 'Pêche', 'Pêche'),
  ('NAVIRE_DE_CHARGE', 'Navire de charge ou de servitude', 'Commerce'),
  ('KITE_SURF', 'Kitesurf', 'Loisir nautique'),
  ('NAVIRE_PASSAGERS', 'Navire à passagers', 'Commerce'),
  ('STAND_UP_PADDLE', 'Stand up paddle', 'Loisir nautique'),
  ('VOILE_LEGERE', 'Plaisance voile légère', 'Loisir nautique'),
  ('KAYAK', 'Canoë / Kayak / Aviron', 'Loisir nautique'),
  ('AUTRE_LOISIR_NAUTIQUE', 'Autre loisir nautique', 'Loisir nautique'),
  ('ANNEXE', 'Annexe', 'Plaisance'),
  ('PLANCHE_VOILE', 'Planche à voile', 'Loisir nautique'),
  ('VNM', 'Véhicule nautique à moteur', 'Loisir nautique'),
  ('NAVIRE_DE_SERVITUDE', 'Navire de charge ou de servitude', 'Commerce'),
  ('SURF', 'Surf', 'Loisir nautique'),
  ('NAVIRE_ADMINISTRATION', 'Administration / Armée', 'Autre'),
  ('ENGIN_RADEAU_DE_SURVIE', 'Engin radeau de survie', 'Plaisance'),
  ('NAVIRE_MILITAIRE', 'Administration / Armée', 'Autre'),
  ('FLUVIAL_PENICHE', 'Fluvial / Péniche', 'Plaisance'),
  ('NAVIRE_DE_CULTURE_MARINE', 'Conchylicole / Aquacole', 'Pêche'),
  ('COMMERCE', 'Commerce', 'Commerce'),
  ('SOUSMARIN', 'Sous-marin', 'Autre'),
  ('AUTRE_AERONEF', 'Autre aéronef', 'Aéronef'),
  ('AVION', 'Autre aéronef', 'Aéronef'),
  ('HELICOPTERE', 'Hélicoptère', 'Aéronef'),
  ('PARAPENTE', 'Parapente', 'Aéronef'),
  ('PLANEUR', 'Planeur', 'Aéronef'),
  ('ULM', 'ULM', 'Aéronef')
;
