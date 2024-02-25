DROP TABLE IF EXISTS secmar_json_resultats_humain_resultat;

CREATE TABLE secmar_json_resultats_humain_resultat (
  seamis varchar primary key,
  secmar varchar
);

CREATE INDEX ON secmar_json_resultats_humain_resultat(secmar);

INSERT INTO secmar_json_resultats_humain_resultat
  (seamis, secmar)
VALUES
  ('ASSISTE', 'Personne assistée'),
  ('BLESSE', 'Personne blessée'),
  ('DECEDE', 'Personne décédée'),
  ('DISPARU', 'Personne disparue'),
  ('FAUSSE_ALERTE', 'Personne impliquée dans fausse alerte'),
  ('INCONNU', 'Inconnu'),
  ('INDEMNE', 'Personne indemne'),
  ('MALADE', 'Personne malade'),
  ('RETROUVE_APRES_RECHERCHE', 'Personne retrouvée'),
  ('SECOURU', 'Personne secourue'),
  ('TIRE_DAFFAIRE_SEUL', 'Personne tirée d''affaire seule')
;
