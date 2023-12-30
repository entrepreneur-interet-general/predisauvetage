update secmar_csv_operation SET
    "SEC_OPERATION_evenement_id_1" = t.secmar_evenement,
    "SEC_C_EVENEMENT_cat_evenement_id_1" = t.secmar_categorie_evenement
from (
    select
        sje.operation_long_name,
        sje.secmar_evenement,
        sje.secmar_categorie_evenement
    from snosan_json_evenement sje
) t
where t.operation_long_name = secmar_csv_operation.operation_long_name;

ALTER TABLE operations ALTER COLUMN evenement DROP NOT NULL;
ALTER TABLE operations ALTER COLUMN categorie_evenement DROP NOT NULL;
ALTER TABLE operations ALTER COLUMN moyen_alerte DROP NOT NULL;
ALTER TABLE operations ALTER COLUMN autorite DROP NOT NULL;
ALTER TABLE operations ALTER COLUMN qui_alerte DROP NOT NULL;
ALTER TABLE operations ALTER COLUMN zone_responsabilite DROP NOT NULL;
ALTER TABLE operations ALTER COLUMN categorie_qui_alerte DROP NOT NULL;
ALTER TABLE operations ALTER COLUMN date_heure_reception_alerte DROP NOT NULL;
ALTER TABLE operations ALTER COLUMN date_heure_fin_operation DROP NOT NULL;

insert into operations (
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
    coalesce("SEC_OPERATION_date_heure_recpt_alerte_id", "SEC_OPERATION_date_heure_fin_operation") date_heure_reception_alerte,
    "SEC_OPERATION_date_heure_fin_operation" date_heure_fin_operation,
    -- "SEC_OPERATION_date_operation",
    "SEC_OPERATION_no_SITREP" numero_sitrep,
    "cross_sitrep" cross_sitrep,
    "fuseau_horaire" fuseau_horaire
from secmar_csv_operation
where cross_sitrep not in (select cross_sitrep from operations);

update operations set latitude = null where longitude is null;
update operations set longitude = null where latitude is null;
