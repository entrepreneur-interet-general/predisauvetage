ALTER TABLE flotteurs ALTER COLUMN numero_ordre DROP NOT NULL;
ALTER TABLE flotteurs ALTER COLUMN resultat_flotteur DROP NOT NULL;
ALTER TABLE flotteurs ALTER COLUMN type_flotteur DROP NOT NULL;
ALTER TABLE flotteurs ALTER COLUMN categorie_flotteur DROP NOT NULL;

INSERT INTO flotteurs (
  "operation_id",
  "pavillon",
  "resultat_flotteur",
  "type_flotteur",
  "categorie_flotteur",
  "longueur"
)
SELECT
  sco.secmar_operation_id operation_id,
  sjf.pavillon "pavillon",
  sjf.resultat_flotteur "resultat_flotteur",
  sjf.type_flotteur "type_flotteur",
  sjf.categorie_flotteur "categorie_flotteur",
  sjf.longueur longueur
FROM snosan_json_flotteurs sjf
JOIN secmar_csv_operation sco on sco.operation_long_name = replace(sjf.chrono, '-', '_')
WHERE sco.secmar_operation_id not in (select distinct operation_id from flotteurs) and sco.secmar_operation_id IN (SELECT operation_id FROM operations);
