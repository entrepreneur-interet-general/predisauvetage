DROP TABLE IF EXISTS secmar_json_resultats_humain_categorie;

CREATE TABLE secmar_json_resultats_humain_categorie (
  seamis varchar primary key,
  secmar varchar
);

CREATE INDEX ON secmar_json_resultats_humain_categorie(secmar);

INSERT INTO secmar_json_resultats_humain_categorie
  (seamis, secmar)
VALUES
  ('AUTRE', 'Autre'),
  ('PLAISANCIER', 'Plaisancier français'),
  ('PRATIQUANT_LOISIRS_NAUTIQUES', 'Pratiquant loisirs nautiques'),
  ('PROFESSIONNEL', 'Commerce français'),
  ('MIGRANT', 'Migrant'),
  ('PECHEUR_PRO', 'Pêcheur français'),
  ('PECHEUR_AMATEUR', 'Pêcheur amateur')
;
