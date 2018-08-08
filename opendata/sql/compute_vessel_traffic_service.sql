-- Determine if operations are inside a vessel traffic service zone
update operations_points set est_dans_stm = false, nom_stm = null;

update operations_points set est_dans_stm = true, nom_stm = t.name
from (
  select
    o.operation_id,
    go.name
  from operations_points o
  join geography_objects go on go.type = 'stm' and ST_Contains(go.geometry, o.point::geometry)
  where o.point is not null
) t
where t.operation_id = operations_points.operation_id;
