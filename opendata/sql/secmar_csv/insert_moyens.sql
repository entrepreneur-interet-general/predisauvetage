ALTER TABLE moyens ALTER COLUMN numero_ordre DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN categorie_moyen DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN moyen DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN domaine_action DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN autorite_moyen DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN date_heure_debut DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN date_heure_fin DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN duree_engagement_minutes DROP NOT NULL;

INSERT INTO moyens (
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
  extract(epoch from "SEC_MOYEN_MEO_duree" - "SEC_MOYEN_MEO_date_heure_depart")/60 duree_engagement_minutes
FROM secmar_csv_moyen m
LEFT JOIN (
  SELECT DISTINCT moyen, domaine_action FROM moyens
) t on t.moyen = m."SEC_MOYEN_MEO_moyen_id"
WHERE secmar_operation_id IN (SELECT operation_id FROM operations);
