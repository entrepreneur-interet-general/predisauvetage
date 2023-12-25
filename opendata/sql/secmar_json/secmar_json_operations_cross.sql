DROP TABLE IF EXISTS secmar_json_operations_cross;

CREATE TABLE secmar_json_operations_cross (
  seamis varchar primary key,
  secmar varchar
);

CREATE INDEX ON secmar_json_operations_cross(secmar);

INSERT INTO secmar_json_operations_cross
  (seamis, secmar)
VALUES
  ('ET_ETEL', 'Étel'),
  ('LG_LAGARDE', 'La Garde'),
  ('GN_GRISNEZ', 'Gris-Nez'),
  ('CN_CORSEN', 'Corsen'),
  ('JB_JOBOURG', 'Jobourg'),
  ('AJ_CORSE', 'Corse'),
  ('AG_ANTILLESGUYANE', 'Antilles-Guyane'),
  ('PP_PAPEETE', 'Polynésie'),
  ('OI_SUDOCEANINDIEN', 'Sud océan Indien'),
  ('MC_CORSE', 'Corse')
;
