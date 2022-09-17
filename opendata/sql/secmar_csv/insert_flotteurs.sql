ALTER TABLE flotteurs ALTER COLUMN numero_ordre DROP NOT NULL;
ALTER TABLE flotteurs ALTER COLUMN resultat_flotteur DROP NOT NULL;
ALTER TABLE flotteurs ALTER COLUMN type_flotteur DROP NOT NULL;
ALTER TABLE flotteurs ALTER COLUMN categorie_flotteur DROP NOT NULL;

INSERT INTO flotteurs (
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
WHERE secmar_operation_id IN (SELECT operation_id FROM operations);
