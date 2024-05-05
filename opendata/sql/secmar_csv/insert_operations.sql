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
    "fuseau_horaire",
    "systeme_source"
)
select
    "operation_id",
    "type_operation",
    "pourquoi_alerte",
    "moyen_alerte",
    "qui_alerte",
    "categorie_qui_alerte",
    "cross"::noms_cross,
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
    "fuseau_horaire",
    "systeme_source"
from snosan_json_operations
where cross_sitrep not in (select cross_sitrep from operations);

update operations set latitude = null where longitude is null;
update operations set longitude = null where latitude is null;
