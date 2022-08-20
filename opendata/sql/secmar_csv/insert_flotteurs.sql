DROP TABLE IF EXISTS public.flotteurs_copy;
CREATE TABLE public.flotteurs_copy (
    "operation_id" bigint references operations_copy on delete cascade,
    "numero_ordre" smallint not null,
    "pavillon" varchar(50),
    "resultat_flotteur" varchar(50) not null,
    "type_flotteur" varchar(50) not null,
    "categorie_flotteur" varchar(50) not null,
    "numero_immatriculation" varchar(40),
    "immatriculation_omi" varchar(20),
    "marque" varchar(250),
    "nom_serie" varchar(500),
    "assurance" boolean,
    "longueur" numeric(5, 2),
    "largeur" numeric(5, 2),
    "jauge" numeric(6, 2),
    "nombre_personnes_recommande" smallint,
    "puissance_maximum_autorisee" numeric(7, 2),
    "surface_voilure" numeric(6, 2),
    "puissance_moteurs" numeric(7, 2),
    "coque" varchar(50),
    "materiau" varchar(50),
    "propulsion" varchar(50),
    "type_moteur" varchar(50),
    "type_navire" varchar(50),
    "utilisation" varchar(50),
    UNIQUE ("operation_id", "numero_ordre")
);

CREATE INDEX ON flotteurs_copy(operation_id);
CREATE INDEX ON flotteurs_copy(resultat_flotteur);
CREATE INDEX ON flotteurs_copy(type_flotteur);
CREATE INDEX ON flotteurs_copy(categorie_flotteur);

insert into flotteurs_copy select * from flotteurs;

ALTER TABLE flotteurs_copy ALTER COLUMN numero_ordre DROP NOT NULL;
ALTER TABLE flotteurs_copy ALTER COLUMN resultat_flotteur DROP NOT NULL;
ALTER TABLE flotteurs_copy ALTER COLUMN type_flotteur DROP NOT NULL;
ALTER TABLE flotteurs_copy ALTER COLUMN categorie_flotteur DROP NOT NULL;

INSERT INTO flotteurs_copy (
  "operation_id",
  "numero_ordre",
  "pavillon",
  "resultat_flotteur",
  "type_flotteur",
  "categorie_flotteur",
  "numero_immatriculation",
  "immatriculation_omi"
)
SELECT
  secmar_operation_id operation_id,
  null numero_ordre,
  "SEC_FLOTTEUR_IMPLIQUE_pavillon_id" pavillon,
  "SEC_FLOTTEUR_IMPLIQUE_resultat_flotteur_id" resultat_flotteur,
  "SEC_FLOTTEUR_IMPLIQUE_type_flotteur_id" type_flotteur,
  t.categorie_flotteur categorie_flotteur,
  "SEC_FLOTTEUR_IMPLIQUE_num_immat_fr" numero_immatriculation,
  "SEC_FLOTTEUR_IMPLIQUE_num_imo" immatriculation_omi
  -- "SEC_FLOTTEUR_IMPLIQUE_nom",
FROM secmar_csv_flotteur f
LEFT JOIN (
  SELECT DISTINCT type_flotteur, categorie_flotteur FROM flotteurs
) t ON t.type_flotteur = f."SEC_FLOTTEUR_IMPLIQUE_type_flotteur_id"
WHERE secmar_operation_id IN (SELECT operation_id FROM operations_copy);
