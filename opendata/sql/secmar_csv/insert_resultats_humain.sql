ALTER TABLE resultats_humain ALTER COLUMN categorie_personne DROP NOT NULL;
ALTER TABLE resultats_humain ALTER COLUMN resultat_humain DROP NOT NULL;

INSERT INTO resultats_humain (
  "operation_id",
  "categorie_personne",
  "resultat_humain",
  "nombre",
  "dont_nombre_blesse"
)
select
  secmar_operation_id "operation_id",
  "SEC_RESULTAT_HUMAIN_cat_personne_id" "categorie_personne",
  "SEC_RESULTAT_HUMAIN_resultat_humain_id" "resultat_humain",
  "SEC_RESULTAT_HUMAIN_nb" "nombre",
  "SEC_RESULTAT_HUMAIN_dont_nb_blesse" "dont_nombre_blesse"
from secmar_csv_bilan
where secmar_operation_id in (select operation_id from operations);
