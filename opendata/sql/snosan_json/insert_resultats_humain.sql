INSERT INTO resultats_humain (
  "operation_id",
  "categorie_personne",
  "resultat_humain",
  "nombre",
  "dont_nombre_blesse"
)
select
  scoi."operation_id",
  sjrh."categorie_personne",
  sjrh."resultat_humain",
  sjrh."nombre",
  sjrh."dont_nombre_blesse"
from snosan_json_resultats_humain sjrh
JOIN snosan_json_operation_id scoi on scoi.chrono = sjrh.chrono
where scoi.operation_id not in (select distinct operation_id from resultats_humain) and scoi.operation_id IN (SELECT operation_id FROM operations);
