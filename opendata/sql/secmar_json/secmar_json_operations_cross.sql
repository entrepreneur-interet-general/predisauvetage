DROP TABLE IF EXISTS secmar_json_operations_cross;

CREATE TABLE secmar_json_operations_cross (
  seamis varchar primary key,
  secmar varchar not null,
  est_metropolitain boolean,
  fuseau_horaire varchar not null
);

CREATE INDEX ON secmar_json_operations_cross(secmar);

INSERT INTO secmar_json_operations_cross
  (seamis, secmar, est_metropolitain, fuseau_horaire)
VALUES
  ('ET_ETEL', 'Étel', true, 'Europe/Paris'),
  ('LG_LAGARDE', 'La Garde', true, 'Europe/Paris'),
  ('GN_GRISNEZ', 'Gris-Nez', true, 'Europe/Paris'),
  ('CN_CORSEN', 'Corsen', true, 'Europe/Paris'),
  ('JB_JOBOURG', 'Jobourg', true, 'Europe/Paris'),
  ('AJ_CORSE', 'Corse', true, 'Europe/Paris'),
  ('AG_ANTILLESGUYANE', 'Antilles-Guyane', false, 'America/Cayenne'),
  ('PP_PAPEETE', 'Polynésie', false, 'Pacific/Tahiti'),
  ('OI_SUDOCEANINDIEN', 'Sud océan Indien', false, 'Indian/Reunion'),
  ('MC_CORSE', 'Corse', true, 'Europe/Paris')
;
