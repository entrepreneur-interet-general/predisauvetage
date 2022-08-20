DROP TABLE IF EXISTS public.operations_copy CASCADE;
CREATE TABLE public.operations_copy (
    "operation_id" bigint primary key,
    "type_operation" varchar(3),
    "pourquoi_alerte" varchar(50),
    "moyen_alerte" varchar(100) not null,
    "qui_alerte" varchar(100) not null,
    "categorie_qui_alerte" varchar(100) not null,
    "cross" noms_cross not null,
    "departement" varchar(100),
    "est_metropolitain" boolean,
    "evenement" varchar(100) not null,
    "categorie_evenement" varchar(50) not null,
    "autorite" varchar(100) not null,
    "seconde_autorite" varchar(100),
    "zone_responsabilite" varchar(50) not null,
    "latitude" numeric(7, 4),
    "longitude" numeric(7, 4),
    "vent_direction" smallint,
    "vent_direction_categorie" varchar(10),
    "vent_force" smallint,
    "mer_force" smallint,
    "date_heure_reception_alerte" timestamp with time zone not null,
    "date_heure_fin_operation" timestamp with time zone not null,
    "numero_sitrep" smallint not null,
    "cross_sitrep" varchar(50) not null,
    "fuseau_horaire" varchar(25) not null
);

CREATE INDEX ON operations_copy(type_operation);
CREATE INDEX ON operations_copy(pourquoi_alerte);
CREATE INDEX ON operations_copy("cross");
CREATE INDEX ON operations_copy(departement);
CREATE INDEX ON operations_copy(date_heure_reception_alerte);
CREATE INDEX ON operations_copy(date_heure_fin_operation);

insert into operations_copy select * from operations;

ALTER TABLE operations_copy ALTER COLUMN evenement DROP NOT NULL;
ALTER TABLE operations_copy ALTER COLUMN categorie_evenement DROP NOT NULL;
ALTER TABLE operations_copy ALTER COLUMN moyen_alerte DROP NOT NULL;
ALTER TABLE operations_copy ALTER COLUMN autorite DROP NOT NULL;
ALTER TABLE operations_copy ALTER COLUMN qui_alerte DROP NOT NULL;
ALTER TABLE operations_copy ALTER COLUMN zone_responsabilite DROP NOT NULL;
ALTER TABLE operations_copy ALTER COLUMN categorie_qui_alerte DROP NOT NULL;
ALTER TABLE operations_copy ALTER COLUMN date_heure_reception_alerte DROP NOT NULL;
ALTER TABLE operations_copy ALTER COLUMN date_heure_fin_operation DROP NOT NULL;

insert into operations_copy (
    "operation_id",
    "type_operation",
    "pourquoi_alerte",
    "moyen_alerte",
    "qui_alerte",
    "categorie_qui_alerte",
    "cross",
    "departement",
    "est_metropolitain",
    "evenement",
    "categorie_evenement",
    "autorite",
    "seconde_autorite",
    "zone_responsabilite",
    "latitude",
    "longitude",
    "vent_direction",
    "vent_direction_categorie",
    "vent_force",
    "mer_force",
    "date_heure_reception_alerte",
    "date_heure_fin_operation",
    "numero_sitrep",
    "cross_sitrep",
    "fuseau_horaire"
)
select
    "secmar_operation_id" operation_id,
    "SEC_OPERATION_pourquoi_alerte_id" type_operation,
    null pourquoi_alerte,
    "EC_OPERATION_moyen_alerte_id" moyen_alerte,
    "SEC_OPERATION_qui_alerte_id" qui_alerte,
    "SEC_C_QUI_ALERTE_cat_qui_alerte_id" categorie_qui_alerte,
    "SEC_OPERATION_SEC_OPERATIONcross_id"::noms_cross "cross",
    "SEC_OPERATION_dept_id" departement,
    "est_metropolitain" est_metropolitain,
    "SEC_OPERATION_evenement_id_1" evenement,
    "SEC_C_EVENEMENT_cat_evenement_id_1" categorie_evenement,
    "SEC_OPERATION_autorite_id" autorite,
    null seconde_autorite,
    "SEC_OPERATION_zone_resp_id" zone_responsabilite,
    "SEC_OPERATION_latitude" latitude,
    "SEC_OPERATION_longitude" longitude,
    "SEC_OPERATION_vent_direction" vent_direction,
    "vent_direction_categorie" vent_direction_categorie,
    "SEC_OPERATION_vent_force" vent_force,
    null mer_force,
    "SEC_OPERATION_date_heure_recpt_alerte_id" date_heure_reception_alerte,
    "SEC_OPERATION_date_heure_fin_operation" date_heure_fin_operation,
    -- "SEC_OPERATION_date_operation",
    "SEC_OPERATION_no_SITREP" numero_sitrep,
    "cross_sitrep" cross_sitrep,
    "fuseau_horaire" fuseau_horaire
from secmar_csv_operation
where cross_sitrep not in (select cross_sitrep from operations_copy);
