update operations set est_metropolitain = t.est_metropolitain
from (
  select distinct est_metropolitain, "cross"
  from operations
  where est_metropolitain is not null and "cross" != 'Gris-Nez'
) t
where operations."cross" = t."cross" and operations.est_metropolitain is null;
