DROP TABLE IF EXISTS secmar_json_engagements_categorie;

CREATE TABLE secmar_json_engagements_categorie (
  seamis varchar primary key,
  secmar varchar,
  domaine_action varchar
);

CREATE INDEX ON secmar_json_engagements_categorie(secmar);

INSERT INTO secmar_json_engagements_categorie
  (seamis, secmar, domaine_action)
VALUES
  ('NAUTIQUE', 'Nautique', 'Nautique'),
  ('SEA', 'Nautique', 'Nautique'),
  ('TERRESTRE', 'Terrestre', 'Terrestre'),
  ('ORGANISME', 'Organisme', null),
  ('AERIEN', 'Aérien', 'Aérien'),
  ('GROUND', 'Terrestre', 'Terrestre'),
  ('STATION_COTIERE', 'Station côtière', 'Terrestre'),
  ('ORG', 'Organisme', null),
  ('HELICOPTER', 'Hélicoptère', 'Aérien'),
  ('POSTE_DE_PLAGE', 'Poste de plage', 'Terrestre'),
  ('COAST_STATION', 'Station côtière', 'Terrestre'),
  ('AUTRE_CATEGORIE', 'Autre catégorie', null),
  ('BEACH_STATION', 'Poste de plage', 'Terrestre'),
  ('OTHERS', 'Autre', null),
  ('AIRPLANE', 'Aérien', 'Aérien'),
  ('STATION', 'Station côtière', 'Terrestre')
;
