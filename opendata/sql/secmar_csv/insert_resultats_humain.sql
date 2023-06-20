INSERT INTO resultats_humain (
  "operation_id",
  "categorie_personne",
  "resultat_humain",
  "nombre",
  "dont_nombre_blesse"
)
select
  sco.secmar_operation_id,
  sjrh."categorie_personne",
  sjrh."resultat_humain",
  sjrh."nombre",
  sjrh."dont_nombre_blesse"
from snosan_json_resultats_humain sjrh
join secmar_csv_operation sco on sco.operation_long_name = replace(sjrh.chrono, '-', '_')
where sco.secmar_operation_id not in (select distinct operation_id from resultats_humain);
