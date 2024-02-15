DROP TABLE IF EXISTS secmar_json_operations_vent_categorie;

CREATE TABLE secmar_json_operations_vent_categorie (
  seamis varchar primary key,
  secmar varchar
);

INSERT INTO secmar_json_operations_vent_categorie
  (seamis, secmar)
VALUES
  ('E', 'est'),
  ('ENE', 'nord-est'),
  ('ESE', 'est'),
  ('N', 'nord'),
  ('NE', 'nord-est'),
  ('NNE', 'nord'),
  ('NNW', 'nord-ouest'),
  ('NW', 'nord-ouest'),
  ('S', 'sud'),
  ('SE', 'sud-est'),
  ('SSE', 'sud-est'),
  ('SSW', 'sud'),
  ('SW', 'sud-ouest'),
  ('W', 'ouest'),
  ('WNW', 'ouest'),
  ('WSW', 'sud-ouest')
;
