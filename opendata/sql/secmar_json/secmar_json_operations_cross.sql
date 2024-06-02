DROP TABLE IF EXISTS secmar_json_operations_cross;

CREATE TABLE secmar_json_operations_cross (
  seamis varchar primary key,
  secmar varchar not null,
  est_metropolitain boolean
);

CREATE INDEX ON secmar_json_operations_cross(secmar);

INSERT INTO secmar_json_operations_cross
  (seamis, secmar, est_metropolitain)
VALUES
  ('ET_ETEL', 'Étel', true),
  ('LG_LAGARDE', 'La Garde', true),
  ('GN_GRISNEZ', 'Gris-Nez', null),
  ('CN_CORSEN', 'Corsen', true),
  ('JB_JOBOURG', 'Jobourg', true),
  ('AJ_CORSE', 'Corse', true),
  ('AG_ANTILLESGUYANE', 'Antilles-Guyane', false),
  ('PP_PAPEETE', 'Polynésie', false),
  ('OI_SUDOCEANINDIEN', 'Sud océan Indien', false),
  ('MC_CORSE', 'Corse', true)
;
