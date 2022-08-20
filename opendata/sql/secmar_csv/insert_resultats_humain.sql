DROP TABLE IF EXISTS public.resultats_humain_copy;
CREATE TABLE public.resultats_humain_copy (
    "operation_id" bigint references operations_copy on delete cascade not null,
    "categorie_personne" varchar(50) not null,
    "resultat_humain" varchar(50) not null,
    "nombre" smallint not null,
    "dont_nombre_blesse" smallint not null
);

CREATE INDEX ON resultats_humain_copy(operation_id);
CREATE INDEX ON resultats_humain_copy(categorie_personne);
CREATE INDEX ON resultats_humain_copy(resultat_humain);

insert into resultats_humain_copy select * from resultats_humain;

ALTER TABLE resultats_humain_copy ALTER COLUMN categorie_personne DROP NOT NULL;
ALTER TABLE resultats_humain_copy ALTER COLUMN resultat_humain DROP NOT NULL;

INSERT INTO resultats_humain_copy (
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
where secmar_operation_id in (select operation_id from operations_copy);
