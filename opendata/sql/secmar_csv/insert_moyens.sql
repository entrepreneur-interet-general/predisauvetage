DROP TABLE IF EXISTS public.moyens_copy;
CREATE TABLE public.moyens_copy (
    "operation_id" bigint references operations_copy on delete cascade not null,
    "numero_ordre" smallint not null,
    "moyen" varchar(100) not null,
    "categorie_moyen" varchar(100) not null,
    "domaine_action" varchar(50) not null,
    "autorite_moyen" varchar(100) not null,
    "date_heure_debut" timestamp with time zone not null,
    "date_heure_fin" timestamp with time zone not null,
    "duree_engagement_minutes" int not null
);

CREATE INDEX ON moyens_copy(operation_id);
CREATE INDEX ON moyens_copy(moyen);
CREATE INDEX ON moyens_copy(categorie_moyen);
CREATE INDEX ON moyens_copy(domaine_action);
CREATE INDEX ON moyens_copy(autorite_moyen);

insert into moyens_copy select * from moyens;

ALTER TABLE moyens_copy ALTER COLUMN numero_ordre DROP NOT NULL;
ALTER TABLE moyens_copy ALTER COLUMN categorie_moyen DROP NOT NULL;
ALTER TABLE moyens_copy ALTER COLUMN moyen DROP NOT NULL;
ALTER TABLE moyens_copy ALTER COLUMN domaine_action DROP NOT NULL;
ALTER TABLE moyens_copy ALTER COLUMN autorite_moyen DROP NOT NULL;
ALTER TABLE moyens_copy ALTER COLUMN date_heure_debut DROP NOT NULL;
ALTER TABLE moyens_copy ALTER COLUMN date_heure_fin DROP NOT NULL;
ALTER TABLE moyens_copy ALTER COLUMN duree_engagement_minutes DROP NOT NULL;

INSERT INTO moyens_copy (
  "operation_id",
  "numero_ordre",
  "moyen",
  "categorie_moyen",
  "domaine_action",
  "autorite_moyen",
  "date_heure_debut",
  "date_heure_fin",
  "duree_engagement_minutes"
)
SELECT
  secmar_operation_id operation_id,
  null numero_ordre,
  "SEC_MOYEN_MEO_moyen_id" moyen,
  "SEC_C_MOYEN_cat_moyen_id" categorie_moyen,
  t.domaine_action,
  "SEC_MOYEN_MEO_autorite_moyen_id" autorite_moyen,
  "SEC_MOYEN_MEO_date_heure_depart" date_heure_debut,
  "SEC_MOYEN_MEO_duree" date_heure_fin,
  extract(epoch from "SEC_MOYEN_MEO_date_heure_depart" - "SEC_MOYEN_MEO_duree")/60 duree_engagement_minutes
FROM secmar_csv_moyen m
LEFT JOIN (
  SELECT DISTINCT moyen, domaine_action FROM moyens
) t on t.moyen = m."SEC_MOYEN_MEO_moyen_id"
WHERE secmar_operation_id IN (SELECT operation_id FROM operations_copy);
