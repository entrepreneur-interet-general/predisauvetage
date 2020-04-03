delete from operations_stats;

insert into operations_stats
select
  o.operation_id,
  (o.date_heure_reception_alerte at time zone o.fuseau_horaire)::date "date",
  extract(year from o.date_heure_reception_alerte at time zone o.fuseau_horaire) annee,
  extract(month from o.date_heure_reception_alerte at time zone o.fuseau_horaire) mois,
  extract(day from o.date_heure_reception_alerte at time zone o.fuseau_horaire) jour,
  'Janvier' mois_texte,
  to_char(o.date_heure_reception_alerte at time zone o.fuseau_horaire, 'IW')::int semaine,
  to_char(o.date_heure_reception_alerte at time zone o.fuseau_horaire, 'IYYY-IW') annee_semaine,
  jour_semaine.jour_semaine::jours_semaine_francais jour_semaine,
  extract(isodow from o.date_heure_reception_alerte at time zone o.fuseau_horaire) in (6, 7) est_weekend,
  false est_jour_ferie,
  null est_vacances_scolaires,
  null phase_journee,
  false concerne_snosan,
  false concerne_plongee,
  op.distance_cote_metres distance_cote_metres,
  op.distance_cote_milles_nautiques distance_cote_milles_nautiques,
  op.est_dans_stm est_dans_stm,
  op.nom_stm nom_stm,
  op.est_dans_dst est_dans_dst,
  op.nom_dst nom_dst,
  case
    when o."cross" in ('Gris-Nez', 'Jobourg', 'Corsen') then 'manche'
    when o."cross" in ('Étel') then 'atlantique'
    when o."cross" in ('La Garde', 'Corse') then 'mediterranee'
    else null
  end prefecture_maritime,
  null maree_port,
  null maree_coefficient,
  null maree_categorie,
  coalesce(mas_omi.nb_flotteurs, 0) nombre_navires_mas_omi,
  coalesce(rh.nombre_personnes_blessees, 0) nombre_personnes_blessees,
  coalesce(rh.nombre_personnes_assistees, 0) nombre_personnes_assistees,
  coalesce(rh.nombre_personnes_decedees, 0) nombre_personnes_decedees,
  coalesce(rh.nombre_personnes_decedees_accidentellement, 0) nombre_personnes_decedees_accidentellement,
  coalesce(rh.nombre_personnes_decedees_naturellement, 0) nombre_personnes_decedees_naturellement,
  coalesce(rh.nombre_personnes_disparues, 0) nombre_personnes_disparues,
  coalesce(rh.nombre_personnes_impliquees_dans_fausse_alerte, 0) nombre_personnes_impliquees_dans_fausse_alerte,
  coalesce(rh.nombre_personnes_retrouvees, 0) nombre_personnes_retrouvees,
  coalesce(rh.nombre_personnes_secourues, 0) nombre_personnes_secourues,
  coalesce(rh.nombre_personnes_tirees_daffaire_seule, 0) nombre_personnes_tirees_daffaire_seule,
  coalesce(rh.nombre_personnes_tous_deces, 0) nombre_personnes_tous_deces,
  coalesce(rh.nombre_personnes_tous_deces_ou_disparues, 0) nombre_personnes_tous_deces_ou_disparues,
  coalesce(rh.nombre_personnes_impliquees, 0) nombre_personnes_impliquees,
  coalesce(rh.nombre_personnes_blessees_sans_clandestins, 0) nombre_personnes_blessees_sans_clandestins,
  coalesce(rh.nombre_personnes_assistees_sans_clandestins, 0) nombre_personnes_assistees_sans_clandestins,
  coalesce(rh.nombre_personnes_decedees_sans_clandestins, 0) nombre_personnes_decedees_sans_clandestins,
  coalesce(rh.nombre_personnes_decedees_accidentellement_sans_clandestins, 0) nombre_personnes_decedees_accidentellement_sans_clandestins,
  coalesce(rh.nombre_personnes_decedees_naturellement_sans_clandestins, 0) nombre_personnes_decedees_naturellement_sans_clandestins,
  coalesce(rh.nombre_personnes_disparues_sans_clandestins, 0) nombre_personnes_disparues_sans_clandestins,
  coalesce(rh.nombre_personnes_impliquees_dans_fausse_alerte_sans_clandestins, 0) nombre_personnes_impliquees_dans_fausse_alerte_sans_clandestins,
  coalesce(rh.nombre_personnes_retrouvees_sans_clandestins, 0) nombre_personnes_retrouvees_sans_clandestins,
  coalesce(rh.nombre_personnes_secourues_sans_clandestins, 0) nombre_personnes_secourues_sans_clandestins,
  coalesce(rh.nombre_personnes_tirees_daffaire_seule_sans_clandestins, 0) nombre_personnes_tirees_daffaire_seule_sans_clandestins,
  coalesce(rh.nombre_personnes_tous_deces_sans_clandestins, 0) nombre_personnes_tous_deces_sans_clandestins,
  coalesce(rh.nombre_personnes_tous_deces_ou_disparues_sans_clandestins, 0) nombre_personnes_tous_deces_ou_disparues_sans_clandestins,
  coalesce(rh.nombre_personnes_impliquees_sans_clandestins, 0) nombre_personnes_impliquees_sans_clandestins,
  coalesce(m.nombre_moyens_nautiques_engages, 0) nombre_moyens_nautiques_engages,
  coalesce(m.nombre_moyens_terrestres_engages, 0) nombre_moyens_terrestres_engages,
  coalesce(m.nombre_moyens_aeriens_engages, 0) nombre_moyens_aeriens_engages,
  round((coalesce(m.duree_engagement_moyens_nautiques_minutes, 0)/60)::numeric, 2) duree_engagement_moyens_nautiques_heures,
  round((coalesce(m.duree_engagement_moyens_terrestres_minutes, 0)/60)::numeric, 2) duree_engagement_moyens_terrestres_heures,
  round((coalesce(m.duree_engagement_moyens_aeriens_minutes, 0)/60)::numeric, 2) duree_engagement_moyens_aeriens_heures,
  coalesce(m.duree_engagement_moyens_nautiques_minutes, 0) duree_engagement_moyens_nautiques_minutes,
  coalesce(m.duree_engagement_moyens_terrestres_minutes, 0) duree_engagement_moyens_terrestres_minutes,
  coalesce(m.duree_engagement_moyens_aeriens_minutes, 0) duree_engagement_moyens_aeriens_minutes,
  coalesce(f.nombre_flotteurs_commerce_impliques, 0) nombre_flotteurs_commerce_impliques,
  coalesce(f.nombre_flotteurs_peche_impliques, 0) nombre_flotteurs_peche_impliques,
  coalesce(f.nombre_flotteurs_plaisance_impliques, 0) nombre_flotteurs_plaisance_impliques,
  coalesce(f.nombre_flotteurs_loisirs_nautiques_impliques, 0) nombre_flotteurs_loisirs_nautiques_impliques,
  coalesce(f.nombre_aeronefs_impliques, 0) nombre_aeronefs_impliques,
  coalesce(f.nombre_flotteurs_autre_impliques, 0) nombre_flotteurs_autre_impliques,
  coalesce(f.nombre_flotteurs_annexe_impliques, 0) nombre_flotteurs_annexe_impliques,
  coalesce(f.nombre_flotteurs_autre_loisir_nautique_impliques, 0) nombre_flotteurs_autre_loisir_nautique_impliques,
  coalesce(f.nombre_flotteurs_canoe_kayak_aviron_impliques, 0) nombre_flotteurs_canoe_kayak_aviron_impliques,
  coalesce(f.nombre_flotteurs_engin_de_plage_impliques, 0) nombre_flotteurs_engin_de_plage_impliques,
  coalesce(f.nombre_flotteurs_kitesurf_impliques, 0) nombre_flotteurs_kitesurf_impliques,
  coalesce(f.nombre_flotteurs_plaisance_voile_legere_impliques, 0) nombre_flotteurs_plaisance_voile_legere_impliques,
  coalesce(f.nombre_flotteurs_plaisance_a_moteur_moins_8m_impliques, 0) nombre_flotteurs_plaisance_a_moteur_moins_8m_impliques,
  coalesce(f.nombre_flotteurs_plaisance_a_moteur_plus_8m_impliques, 0) nombre_flotteurs_plaisance_a_moteur_plus_8m_impliques,
  coalesce(f.nombre_flotteurs_plaisance_a_voile_impliques, 0) nombre_flotteurs_plaisance_a_voile_impliques,
  coalesce(f.nombre_flotteurs_planche_a_voile_impliques, 0) nombre_flotteurs_planche_a_voile_impliques,
  coalesce(f.nombre_flotteurs_ski_nautique_impliques, 0) nombre_flotteurs_ski_nautique_impliques,
  coalesce(f.nombre_flotteurs_surf_impliques, 0) nombre_flotteurs_surf_impliques,
  coalesce(f.nombre_flotteurs_vehicule_nautique_a_moteur_impliques, 0) nombre_flotteurs_vehicule_nautique_a_moteur_impliques,
  false sans_flotteur_implique
from operations o
left join (
  select
    t.*,
    (nombre_personnes_decedees + nombre_personnes_decedees_naturellement + nombre_personnes_decedees_accidentellement) nombre_personnes_tous_deces,
    (nombre_personnes_decedees + nombre_personnes_decedees_naturellement + nombre_personnes_decedees_accidentellement + nombre_personnes_disparues) nombre_personnes_tous_deces_ou_disparues,
    (nombre_personnes_assistees + nombre_personnes_decedees + nombre_personnes_decedees_naturellement + nombre_personnes_decedees_accidentellement + nombre_personnes_disparues + nombre_personnes_impliquees_dans_fausse_alerte + nombre_personnes_retrouvees + nombre_personnes_secourues + nombre_personnes_tirees_daffaire_seule) nombre_personnes_impliquees,
    (nombre_personnes_decedees_sans_clandestins + nombre_personnes_decedees_naturellement_sans_clandestins + nombre_personnes_decedees_accidentellement_sans_clandestins) nombre_personnes_tous_deces_sans_clandestins,
    (nombre_personnes_decedees_sans_clandestins + nombre_personnes_decedees_naturellement_sans_clandestins + nombre_personnes_decedees_accidentellement_sans_clandestins + nombre_personnes_disparues_sans_clandestins) nombre_personnes_tous_deces_ou_disparues_sans_clandestins,
    (nombre_personnes_assistees_sans_clandestins + nombre_personnes_decedees_sans_clandestins + nombre_personnes_decedees_naturellement_sans_clandestins + nombre_personnes_decedees_accidentellement_sans_clandestins + nombre_personnes_disparues_sans_clandestins + nombre_personnes_impliquees_dans_fausse_alerte_sans_clandestins + nombre_personnes_retrouvees_sans_clandestins + nombre_personnes_secourues_sans_clandestins + nombre_personnes_tirees_daffaire_seule_sans_clandestins) nombre_personnes_impliquees_sans_clandestins
  from (
    select
      rh.operation_id,
      sum(dont_nombre_blesse) nombre_personnes_blessees,
      sum(case when resultat_humain = 'Personne assistée' then nombre else 0 end) nombre_personnes_assistees,
      sum(case when resultat_humain = 'Personne décédée' then nombre else 0 end) nombre_personnes_decedees,
      sum(case when resultat_humain = 'Personne décédée naturellement' then nombre else 0 end) nombre_personnes_decedees_naturellement,
      sum(case when resultat_humain = 'Personne décédée accidentellement' then nombre else 0 end) nombre_personnes_decedees_accidentellement,
      sum(case when resultat_humain = 'Personne disparue' then nombre else 0 end) nombre_personnes_disparues,
      sum(case when resultat_humain = 'Personne impliquée dans fausse alerte' then nombre else 0 end) nombre_personnes_impliquees_dans_fausse_alerte,
      sum(case when resultat_humain = 'Personne retrouvée' then nombre else 0 end) nombre_personnes_retrouvees,
      sum(case when resultat_humain = 'Personne secourue' then nombre else 0 end) nombre_personnes_secourues,
      sum(case when resultat_humain = 'Personne tirée d''affaire seule' then nombre else 0 end) nombre_personnes_tirees_daffaire_seule,
      sum(case when categorie_personne <> 'Clandestin' then dont_nombre_blesse else 0 end) nombre_personnes_blessees_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne assistée' then nombre else 0 end) nombre_personnes_assistees_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne décédée' then nombre else 0 end) nombre_personnes_decedees_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne décédée naturellement' then nombre else 0 end) nombre_personnes_decedees_naturellement_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne décédée accidentellement' then nombre else 0 end) nombre_personnes_decedees_accidentellement_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne disparue' then nombre else 0 end) nombre_personnes_disparues_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne impliquée dans fausse alerte' then nombre else 0 end) nombre_personnes_impliquees_dans_fausse_alerte_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne retrouvée' then nombre else 0 end) nombre_personnes_retrouvees_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne secourue' then nombre else 0 end) nombre_personnes_secourues_sans_clandestins,
      sum(case when categorie_personne <> 'Clandestin' and resultat_humain = 'Personne tirée d''affaire seule' then nombre else 0 end) nombre_personnes_tirees_daffaire_seule_sans_clandestins
    from resultats_humain rh
    group by rh.operation_id
   ) t
) rh on rh.operation_id = o.operation_id
left join (
  select
    m.operation_id,
    sum((domaine_action = 'Nautique')::int) nombre_moyens_nautiques_engages,
    sum((domaine_action = 'Terrestre')::int) nombre_moyens_terrestres_engages,
    sum((domaine_action = 'Aérien')::int) nombre_moyens_aeriens_engages,
    sum(case when domaine_action = 'Nautique' then duree_minutes else 0 end) duree_engagement_moyens_nautiques_minutes,
    sum(case when domaine_action = 'Terrestre' then duree_minutes else 0 end) duree_engagement_moyens_terrestres_minutes,
    sum(case when domaine_action = 'Aérien' then duree_minutes else 0 end) duree_engagement_moyens_aeriens_minutes
  from (
    select
      m.*,
      extract(day from m.date_heure_fin - m.date_heure_debut) * 60 * 24 +
      extract(hour from m.date_heure_fin - m.date_heure_debut) * 60 +
      extract(minute from m.date_heure_fin - m.date_heure_debut) duree_minutes
    from moyens m
  ) m
  group by m.operation_id
) m on m.operation_id = o.operation_id
left join (
  select
    f.operation_id,
    sum((categorie_flotteur = 'Commerce')::int) nombre_flotteurs_commerce_impliques,
    sum((categorie_flotteur = 'Pêche')::int) nombre_flotteurs_peche_impliques,
    sum((categorie_flotteur = 'Plaisance')::int) nombre_flotteurs_plaisance_impliques,
    sum((categorie_flotteur = 'Loisir nautique')::int) nombre_flotteurs_loisirs_nautiques_impliques,
    sum((categorie_flotteur = 'Aéronef')::int) nombre_aeronefs_impliques,
    sum((categorie_flotteur = 'Autre')::int) nombre_flotteurs_autre_impliques,
    sum((type_flotteur = 'Annexe')::int) nombre_flotteurs_annexe_impliques,
    sum((type_flotteur = 'Autre loisir nautique')::int) nombre_flotteurs_autre_loisir_nautique_impliques,
    sum((type_flotteur = 'Canoë / Kayak / Aviron')::int) nombre_flotteurs_canoe_kayak_aviron_impliques,
    sum((type_flotteur = 'Engin de plage')::int) nombre_flotteurs_engin_de_plage_impliques,
    sum((type_flotteur = 'Kitesurf')::int) nombre_flotteurs_kitesurf_impliques,
    sum((type_flotteur = 'Plaisance voile légère')::int) nombre_flotteurs_plaisance_voile_legere_impliques,
    sum((type_flotteur = 'Plaisance à moteur < 8m')::int) nombre_flotteurs_plaisance_a_moteur_moins_8m_impliques,
    sum((type_flotteur = 'Plaisance à moteur > 8m')::int) nombre_flotteurs_plaisance_a_moteur_plus_8m_impliques,
    sum((type_flotteur = 'Plaisance à voile')::int) nombre_flotteurs_plaisance_a_voile_impliques,
    sum((type_flotteur = 'Planche à voile')::int) nombre_flotteurs_planche_a_voile_impliques,
    sum((type_flotteur = 'Ski nautique')::int) nombre_flotteurs_ski_nautique_impliques,
    sum((type_flotteur = 'Surf')::int) nombre_flotteurs_surf_impliques,
    sum((type_flotteur = 'Véhicule nautique à moteur')::int) nombre_flotteurs_vehicule_nautique_a_moteur_impliques
  from flotteurs f
  group by f.operation_id
) f on f.operation_id = o.operation_id
left join (
  select
    o.operation_id,
    count(1) nb_flotteurs
  from operations o
  join flotteurs f on f.operation_id = o.operation_id and f.immatriculation_omi is not null
  where o.type_operation = 'MAS'
  group by 1
) mas_omi on mas_omi.operation_id = o.operation_id
join (
  select
    o.operation_id,
    t.jour_semaine
  from operations o
  join (
    select 1 jour, 'Lundi' jour_semaine union
    select 2 jour, 'Mardi' jour_semaine union
    select 3 jour, 'Mercredi' jour_semaine union
    select 4 jour, 'Jeudi' jour_semaine union
    select 5 jour, 'Vendredi' jour_semaine union
    select 6 jour, 'Samedi' jour_semaine union
    select 7 jour, 'Dimanche' jour_semaine
  ) t on t.jour = extract(isodow from o.date_heure_reception_alerte at time zone o.fuseau_horaire)
) jour_semaine on jour_semaine.operation_id = o.operation_id
join operations_points op on op.operation_id = o.operation_id
;

update operations_stats set sans_flotteur_implique = true
where operation_id in (
  select
    os.operation_id
  from operations_stats os
  left join flotteurs f on f.operation_id = os.operation_id
  where f.operation_id is null
);

update operations_stats set concerne_snosan = true
where nombre_flotteurs_plaisance_impliques > 0
   or nombre_flotteurs_loisirs_nautiques_impliques > 0
   or nombre_flotteurs_annexe_impliques > 0
   or operation_id in (
    select op.operation_id
    from operations op
    join operations_stats stats on stats.operation_id = op.operation_id and stats.sans_flotteur_implique
    where op.evenement in (
      'Sans avarie inexpérience', 'Autre événement', 'Baignade',
      'Découverte de corps', 'Plongée en apnée', 'Accident en mer',
      'Isolement par la marée / Envasé', 'Autre accident', 'Blessé EvaMed',
      'Chasse sous-marine', 'Blessé EvaSan', 'Disparu en mer',
      'Plongée avec bouteille', 'Sans avarie en dérive', 'Incertitude sur la position',
      'Homme à la mer', 'Malade EvaMed', 'Ski nautique', 'Accident aéronautique',
      'Chute falaise / Emporté par une lame', 'Malade EvaSan',
      'Blessé projection d''une équipe médicale',
      'Absence d''un moyen de communication'
    )
   );

update operations_stats set concerne_plongee = true
where operation_id in (
  select operation_id
  from operations
  where evenement in ('Plongée avec bouteille', 'Plongée en apnée', 'Chasse sous-marine')
);

update operations_stats set mois_texte = t.mois_texte::mois_francais
from (
  select 1 mois, 'Janvier' mois_texte union
  select 2 mois, 'Février' mois_texte union
  select 3 mois, 'Mars' mois_texte union
  select 4 mois, 'Avril' mois_texte union
  select 5 mois, 'Mai' mois_texte union
  select 6 mois, 'Juin' mois_texte union
  select 7 mois, 'Juillet' mois_texte union
  select 8 mois, 'Août' mois_texte union
  select 9 mois, 'Septembre' mois_texte union
  select 10 mois, 'Octobre' mois_texte union
  select 11 mois, 'Novembre' mois_texte union
  select 12 mois, 'Décembre' mois_texte
) t
where t.mois = operations_stats.mois;
