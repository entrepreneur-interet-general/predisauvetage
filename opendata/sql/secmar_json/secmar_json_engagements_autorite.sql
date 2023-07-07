DROP TABLE IF EXISTS secmar_json_engagements_autorite;

CREATE TABLE secmar_json_engagements_autorite (
  seamis varchar,
  secmar varchar
);

CREATE INDEX ON secmar_json_engagements_autorite(secmar);
CREATE UNIQUE INDEX ON secmar_json_engagements_autorite (seamis);

INSERT INTO secmar_json_engagements_autorite
  (seamis, secmar)
VALUES
  ('SNSM', 'SNSM'),
  ('SDIS', 'Services départementaux d''incendie et de secours'),
  ('MARINE_NATIONALE', 'Marine nationale'),
  ('PRIVE_PARTICULIER', 'Privé / Particulier'),
  ('SANTE', 'Santé'),
  ('GENDARMERIE_NATIONALE', 'Gendarmerie Nationale'),
  ('GENDARMERIE_MARITIME', 'Gendarmerie Marine'),
  ('MAIRIE_COLLECTIVITE_LOCALE', 'Mairie / Collectivité locale'),
  ('SECURITE_CIVILE', 'COZ / Sécurité civile'),
  ('ARMATEUR', 'Armateur'),
  ('SCMM_SAMU_COTIER', 'SCMM / SAMU côtier'),
  ('DOUANE', 'Douane'),
  ('SAMU', 'SCMM / SAMU côtier'),
  ('POLICE_NATIONALE_MUNICIPALE', 'Police nationale / Police municipale'),
  ('COZ_SECURITE_CIVILE', 'COZ / Sécurité civile'),
  ('ADMINISTRATION_ETRANGERE', 'Administration étrangère'),
  ('AFFAIRES_MARITIMES', 'Affaires maritimes'),
  ('AUTORITE_PORTUAIRE', 'Autorité portuaire'),
  ('CENTRE_DE_CONSULTATION_MEDICAL', 'Centre de consultation médical'),
  ('AUTRE_AUTORITE', 'Autre autorité'),
  ('DOUANES', 'Douane'),
  ('AUTRE', 'Autre'),
  ('PROCHE_FAMILLE', 'Proche / Famille'),
  ('POLICE_CRS', 'Police-CRS'),
  ('ARMEE_DE_LAIR', 'Armée de l''air'),
  ('ENTREPRISE_ASSISTANCE_MARITIME', 'Entreprises d''assistance maritime'),
  ('PILOTAGE_MARITIME', 'Pilotage'),
  ('ENTREPRISES_DE_REMORQUAGE_ET_DE_DEPANNAGE', 'Entreprises de remorquage et de dépannage'),
  ('ETABLISSEMENT_PUBLIC_PARC_MARIN', 'Établissement public parc marin'),
  ('FEPSM', 'FEPSM'),
  ('ARMEE_DE_L_AIR', 'Armée de l''air'),
  ('AVIATION_CIVILE', 'Aviation civile'),
  ('AUTRE_ORGANISME_MEDICAL', 'Autre organisme médical'),
  ('ARMEE_DE_TERRE', 'Armée de terre'),
  ('OPERATEUR_TELEPHONIQUE', 'Opérateur téléphonique')
;
