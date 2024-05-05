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
  scoi.operation_id "operation_id",
  sjf.pavillon "pavillon",
  sjf.resultat_flotteur "resultat_flotteur",
  sjf.type_flotteur "type_flotteur",
  sjf.categorie_flotteur "categorie_flotteur",
  sjf.longueur "longueur"
FROM snosan_json_flotteurs sjf
JOIN snosan_json_operation_id scoi on scoi.chrono = sjf.chrono
WHERE scoi.operation_id not in (select distinct operation_id from flotteurs) and scoi.operation_id IN (SELECT operation_id FROM operations);
