select
  o."OPERATION_ID" operation_id,
  o."DATE_HEURE_RECEPTION_ALERTE" date_reception_alerte,
  o."LATITUDE" latitude,
  o."LONGITUDE" longitude,
  min(f."TYPE_FLOTTEUR") type_flotteur,
  rh."RESULTAT_HUMAIN" resultat_humain,
  o."EST_METROPOLITAIN" est_metropolitain,
  sum(rh."NOMBRE") nb_personnes
from operations o
join flotteurs f on f."OPERATION_ID" = o."OPERATION_ID" and f."CATEGORIE_FLOTTEUR" = 'Plaisance'
join resultats_humain rh on rh."OPERATION_ID" = o."OPERATION_ID" and rh."RESULTAT_HUMAIN" not in ('Clandestin')
where extract(year from o."DATE_HEURE_RECEPTION_ALERTE") between 2012 and 2017
  and o."EVENEMENT" = 'Homme à la mer'
  and o."LATITUDE" is not null
  and o."LONGITUDE" is not null
group by 1, 2, 3, 4, 6, 7;
