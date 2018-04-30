DROP TABLE IF EXISTS public.operations CASCADE;
CREATE TABLE public.operations (
    "operation_id" bigint PRIMARY KEY,
    "type_operation" varchar(3),
    "pourquoi_alerte" varchar(50),
    "moyen_alerte" varchar(100) not null,
    "qui_alerte" varchar(100) not null,
    "categorie_qui_alerte" varchar(100) not null,
    "cross" varchar(50) not null,
    "departement" varchar(100),
    "est_metropolitain" boolean,
    "evenement" varchar(100) not null,
    "categorie_evenement" varchar(50) not null,
    "autorite" varchar(100) not null,
    "sous_autorite" varchar(100) not null,
    "zone_responsabilite" varchar(50) not null,
    "latitude" numeric(7, 4),
    "longitude" numeric(7, 4),
    "vent_direction" smallint,
    "vent_force" smallint,
    "mer_force" smallint,
    "date_heure_reception_alerte" timestamp without time zone not null,
    "date_heure_fin_operation" timestamp without time zone not null,
    "numero_sitrep" smallint,
    "cross_sitrep" varchar(50),
    "fuseau_horaire" varchar(25) not null
);

CREATE INDEX ON operations(type_operation);
CREATE INDEX ON operations(pourquoi_alerte);
CREATE INDEX ON operations("cross");
CREATE INDEX ON operations(departement);
CREATE INDEX ON operations((date_heure_reception_alerte::date));
CREATE INDEX ON operations((date_heure_fin_operation::date));


DROP TABLE IF EXISTS public.flotteurs;
CREATE TABLE public.flotteurs (
    "operation_id" bigint references operations on delete cascade,
    "numero_ordre" smallint not null,
    "pavillon" varchar(50),
    "resultat_flotteur" varchar(50) not null,
    "type_flotteur" varchar(50) not null,
    "categorie_flotteur" varchar(50) not null,
    "numero_immatriculation" varchar(40),
    "marque" varchar(250),
    "nom_serie" varchar(500),
    "assurance" boolean,
    "longueur" numeric(5, 2),
    "largeur" numeric(5, 2),
    "jauge" numeric(6, 2),
    "nombre_personne_recommande" smallint,
    "puissance_maximum_autorisee" numeric(7, 2),
    "surface_voilure" numeric(6, 2),
    "puissance_moteurs" numeric(7, 2),
    "coque" varchar(50),
    "materiau" varchar(50),
    "propulsion" varchar(50),
    "type_moteur" varchar(50),
    "type_navire" varchar(50),
    "utilisation" varchar(50)
);

CREATE INDEX ON flotteurs(operation_id);
CREATE INDEX ON flotteurs(resultat_flotteur);
CREATE INDEX ON flotteurs(type_flotteur);
CREATE INDEX ON flotteurs(categorie_flotteur);


DROP TABLE IF EXISTS public.moyens;
CREATE TABLE public.moyens (
    "operation_id" bigint references operations on delete cascade not null,
    "numero_ordre" smallint not null,
    "moyen" varchar(100) not null,
    "categorie_moyen" varchar(100) not null,
    "domaine_action" varchar(50) not null,
    "autorite_moyen" varchar(100) not null,
    "date_heure_debut" timestamp without time zone not null,
    "date_heure_fin" timestamp without time zone not null
);

CREATE INDEX ON moyens(operation_id);
CREATE INDEX ON moyens(moyen);
CREATE INDEX ON moyens(categorie_moyen);
CREATE INDEX ON moyens(domaine_action);
CREATE INDEX ON moyens(autorite_moyen);


DROP TABLE IF EXISTS public.resultats_humain;
CREATE TABLE public.resultats_humain (
    "operation_id" bigint references operations on delete cascade not null,
    "categorie_personne" varchar(50) not null,
    "resultat_humain" varchar(50) not null,
    "nombre" smallint not null,
    "dont_nombre_blesse" smallint not null
);

CREATE INDEX ON resultats_humain(operation_id);
CREATE INDEX ON resultats_humain(categorie_personne);
CREATE INDEX ON resultats_humain(resultat_humain);
