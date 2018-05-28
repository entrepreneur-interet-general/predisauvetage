delete from operations_stats;

insert into operations_stats
select
  o.operation_id,
  extract(year from o.date_heure_reception_alerte) annee,
  extract(month from o.date_heure_reception_alerte) mois,
  extract(day from o.date_heure_reception_alerte) jour,
  '' mois_texte,
  null phase_journee,
  false concerne_snosan,
  false concerne_plongee,
  false sans_flotteur,
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
  coalesce(f.nombre_flotteurs_surf_impliques, 0) nombre_flotteurs_surf_impliques
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
      sum(case when resultat_humain = 'Personne assistée' then nombre else 0 end) nombre_personnes_assistees,
      sum(case when resultat_humain = 'Personne décédée' then nombre else 0 end) nombre_personnes_decedees,
      sum(case when resultat_humain = 'Personne décédée naturellement' then nombre else 0 end) nombre_personnes_decedees_naturellement,
      sum(case when resultat_humain = 'Personne décédée accidentellement' then nombre else 0 end) nombre_personnes_decedees_accidentellement,
      sum(case when resultat_humain = 'Personne disparue' then nombre else 0 end) nombre_personnes_disparues,
      sum(case when resultat_humain = 'Personne impliquée dans fausse alerte' then nombre else 0 end) nombre_personnes_impliquees_dans_fausse_alerte,
      sum(case when resultat_humain = 'Personne retrouvée' then nombre else 0 end) nombre_personnes_retrouvees,
      sum(case when resultat_humain = 'Personne secourue' then nombre else 0 end) nombre_personnes_secourues,
      sum(case when resultat_humain = 'Personne tirée d''affaire seule' then nombre else 0 end) nombre_personnes_tirees_daffaire_seule,
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
    sum((type_flotteur = 'Surf')::int) nombre_flotteurs_surf_impliques
  from flotteurs f
  group by f.operation_id
) f on f.operation_id = o.operation_id
;

update operations_stats set concerne_snosan = true where
  nombre_flotteurs_plaisance_impliques > 0 or
  nombre_flotteurs_loisirs_nautiques_impliques > 0 or
  nombre_flotteurs_annexe_impliques > 0
;

update operations_stats set concerne_plongee = true
where operation_id in (
  select operation_id
  from operations
  where evenement in ('Plongée avec bouteille', 'Plongée en apnée', 'Chasse sous-marine', 'Plongée en bouteille')
);

update operations_stats set mois_texte = t.mois_texte
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

update sans_flotteur set sans_flotteur= true where
  nombre_flotteurs_plaisance_impliques = 0 and  
  nombre_flotteurs_loisirs_nautiques_impliques  = 0 and
  nombre_flotteurs_peche_impliques = 0 and
  nombre_flotteurs_autre_impliques = 0 and 
  nombre_aeronefs_impliques = 0 and
  nombre_flotteurs_commerce_impliques = 0
;
