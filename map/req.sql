select
  cross_sitrep,
  pourquoi_alerte_short "type",
  to_date(date_operation, 'dd/mm/yy') date_operation,
  force_du_vent,
  force_de_la_mer,
  moyen_alerte,
  qui_alerte,
  evenement,
  "nb_personnes_asssistées",
  "nb_décédés_accidentels",
  "nb_décédés_naturels",
  "nb_personnes_disparues",
  "nb_personnes_impliquées_fausses_alertes",
  "nb_personnes_retrouvées",
  "nb_personnes_secourues",
  "nb_personnes_tirées_daffaires_elles_memes",
  replace(latitude, ',', '.') latitude,
  replace(longitude, ',', '.') longitude
from secmar
where latitude is not null and longitude is not null
and evenement in (
  select evenement
  from secmar
  group by 1
  having count(1) > 50
)
order by evenement
