CREATE TABLE public.operations (
    "operation_id" int PRIMARY KEY,
    "pourquoi_alerte" varchar(50),
    "moyen_alerte" varchar(100),
    "qui_alerte" varchar(100),
    "categorie_qui_alerte" varchar(100),
    "cross" varchar(50),
    "departement" varchar(100),
    "est_metropolitain" boolean,
    "evenement" varchar(100),
    "categorie_evenement" varchar(50),
    "autorite" varchar(100),
    "sous_autorite" varchar(100),
    "zone_responsabilite" varchar(50),
    "latitude" numeric(7, 4),
    "longitude" numeric(7, 4),
    "vent_direction" smallint,
    "vent_force" smallint,
    "mer_force" smallint,
    "date_heure_reception_alerte" timestamp with time zone,
    "date_heure_fin_operation" timestamp with time zone,
    "numero_sitrep" smallint,
    "cross_sitrep" varchar(50),
    "fuseau_horaire" varchar(25)
);

CREATE INDEX ON operations(pourquoi_alerte);
CREATE INDEX ON operations(cross);
CREATE INDEX ON operations(departement);
CREATE INDEX ON operations((date_heure_reception_alerte::date));
CREATE INDEX ON operations((date_heure_fin_operation::date));


CREATE TABLE public.flotteurs (
    "operation_id" int references operations,
    "numero_ordre" smallint,
    "pavillon" varchar(50),
    "resultat_flotteur" varchar(50),
    "type_flotteur" varchar(50),
    "categorie_flotteur" varchar(50),
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


CREATE TABLE public.moyens (
    "operation_id" int references operations,
    "numero_ordre" smallint,
    "moyen" varchar(100),
    "categorie_moyen" varchar(100),
    "domaine_action" varchar(50),
    "autorite_moyen" varchar(100),
    "date_heure_debut" timestamp with time zone,
    "date_heure_fin" timestamp with time zone
);

CREATE INDEX ON moyens(operation_id);
CREATE INDEX ON moyens(moyen);
CREATE INDEX ON moyens(categorie_moyen);
CREATE INDEX ON moyens(domaine_action);
CREATE INDEX ON moyens(autorite_moyen);


CREATE TABLE public.resultats_humain (
    "operation_id" int references operations,
    "categorie_personne" varchar(50),
    "resultat_humain" varchar(50),
    "nombre" smallint,
    "dont_nombre_blesse" smallint
);

CREATE INDEX ON resultats_humain(operation_id);
CREATE INDEX ON resultats_humain(categorie_personne);
CREATE INDEX ON resultats_humain(resultat_humain);
