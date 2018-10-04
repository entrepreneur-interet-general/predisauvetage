DROP TYPE IF EXISTS mois_francais;
CREATE TYPE mois_francais AS enum('Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre');
DROP TYPE IF EXISTS jours_semaine_francais;
CREATE TYPE jours_semaine_francais AS enum('Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche');
DROP TYPE IF EXISTS phase_journee;
CREATE TYPE phase_journee AS enum('matinée', 'déjeuner', 'après-midi', 'nuit');

DROP TABLE IF EXISTS public.operations CASCADE;
CREATE TABLE public.operations (
    "operation_id" bigint primary key,
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

CREATE INDEX ON operations(type_operation);
CREATE INDEX ON operations(pourquoi_alerte);
CREATE INDEX ON operations("cross");
CREATE INDEX ON operations(departement);
CREATE INDEX ON operations(date_heure_reception_alerte);
CREATE INDEX ON operations(date_heure_fin_operation);


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
    "nombre_personnes_recommande" smallint,
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
    "date_heure_debut" timestamp with time zone not null,
    "date_heure_fin" timestamp with time zone not null,
    "duree_engagement_minutes" int not null
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

DROP TABLE IF EXISTS public.operations_stats;
CREATE TABLE public.operations_stats (
    "operation_id" bigint primary key references operations on delete cascade not null,
    "date" date not null,
    "annee" smallint not null,
    "mois" smallint not null,
    "jour" smallint not null,
    "mois_texte" mois_francais not null,
    "semaine" smallint not null,
    "annee_semaine" varchar(7) not null,
    "jour_semaine" jours_semaine_francais not null,
    "est_weekend" boolean not null,
    "est_jour_ferie" boolean not null,
    "phase_journee" phase_journee,
    "concerne_snosan" boolean not null,
    "concerne_plongee" boolean not null,
    "distance_cote_metres" int,
    "distance_cote_milles_nautiques" numeric(6, 2),
    "est_dans_stm" boolean not null,
    "nom_stm" varchar(50),
    "est_dans_dst" boolean not null,
    "nom_dst" varchar(50),
    "nombre_personnes_blessees" smallint not null,
    "nombre_personnes_assistees" smallint not null,
    "nombre_personnes_decedees" smallint not null,
    "nombre_personnes_decedees_accidentellement" smallint not null,
    "nombre_personnes_decedees_naturellement" smallint not null,
    "nombre_personnes_disparues" smallint not null,
    "nombre_personnes_impliquees_dans_fausse_alerte" smallint not null,
    "nombre_personnes_retrouvees" smallint not null,
    "nombre_personnes_secourues" smallint not null,
    "nombre_personnes_tirees_daffaire_seule" smallint not null,
    "nombre_personnes_tous_deces" smallint not null,
    "nombre_personnes_tous_deces_ou_disparues" smallint not null,
    "nombre_personnes_impliquees" smallint not null,
    "nombre_personnes_blessees_sans_clandestins" smallint not null,
    "nombre_personnes_assistees_sans_clandestins" smallint not null,
    "nombre_personnes_decedees_sans_clandestins" smallint not null,
    "nombre_personnes_decedees_accidentellement_sans_clandestins" smallint not null,
    "nombre_personnes_decedees_naturellement_sans_clandestins" smallint not null,
    "nombre_personnes_disparues_sans_clandestins" smallint not null,
    "nombre_personnes_impliquees_dans_fausse_alerte_sans_clandestins" smallint not null,
    "nombre_personnes_retrouvees_sans_clandestins" smallint not null,
    "nombre_personnes_secourues_sans_clandestins" smallint not null,
    "nombre_personnes_tirees_daffaire_seule_sans_clandestins" smallint not null,
    "nombre_personnes_tous_deces_sans_clandestins" smallint not null,
    "nombre_personnes_tous_deces_ou_disparues_sans_clandestins" smallint not null,
    "nombre_personnes_impliquees_sans_clandestins" smallint not null,
    "nombre_moyens_nautiques_engages" smallint not null,
    "nombre_moyens_terrestres_engages" smallint not null,
    "nombre_moyens_aeriens_engages" smallint not null,
    "duree_engagement_moyens_nautiques_minutes" int not null,
    "duree_engagement_moyens_terrestres_minutes" int not null,
    "duree_engagement_moyens_aeriens_minutes" int not null,
    "nombre_flotteurs_commerce_impliques" smallint not null,
    "nombre_flotteurs_peche_impliques" smallint not null,
    "nombre_flotteurs_plaisance_impliques" smallint not null,
    "nombre_flotteurs_loisirs_nautiques_impliques" smallint not null,
    "nombre_aeronefs_impliques" smallint not null,
    "nombre_flotteurs_autre_impliques" smallint not null,
    "nombre_flotteurs_annexe_impliques" smallint not null,
    "nombre_flotteurs_autre_loisir_nautique_impliques" smallint not null,
    "nombre_flotteurs_canoe_kayak_aviron_impliques" smallint not null,
    "nombre_flotteurs_engin_de_plage_impliques" smallint not null,
    "nombre_flotteurs_kitesurf_impliques" smallint not null,
    "nombre_flotteurs_plaisance_voile_legere_impliques" smallint not null,
    "nombre_flotteurs_plaisance_a_moteur_moins_8m_impliques" smallint not null,
    "nombre_flotteurs_plaisance_a_moteur_plus_8m_impliques" smallint not null,
    "nombre_flotteurs_plaisance_a_voile_impliques" smallint not null,
    "nombre_flotteurs_planche_a_voile_impliques" smallint not null,
    "nombre_flotteurs_ski_nautique_impliques" smallint not null,
    "nombre_flotteurs_surf_impliques" smallint not null,
    "sans_flotteur_implique" boolean not null
);

CREATE INDEX ON operations_stats(operation_id);
CREATE INDEX ON operations_stats("date");
CREATE INDEX ON operations_stats(annee);
CREATE INDEX ON operations_stats(phase_journee);
CREATE INDEX ON operations_stats(concerne_snosan);
CREATE INDEX ON operations_stats(concerne_plongee);
