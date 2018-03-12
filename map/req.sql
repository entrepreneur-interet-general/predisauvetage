select
  cross_sitrep,
  pourquoi_alerte_short "type",
  to_date(date_operation, 'dd/mm/yy') date_operation,
  force_du_vent,
  force_de_la_mer,
  moyen_alerte,
  qui_alerte,
  evenement,
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
