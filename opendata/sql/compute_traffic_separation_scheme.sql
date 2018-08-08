-- Determine if operations are inside a traffic separation scheme zone

update operations_points set est_dans_dst = false, nom_dst = null;

update operations_points set est_dans_dst = true, nom_dst = t.name
from (
  select
    o.operation_id,
    go.name
  from operations_points o
  join geography_objects go on go.type = 'dst' and ST_Contains(go.geometry, o.point::geometry)
  where o.point is not null
) t
where t.operation_id = operations_points.operation_id;

-- The Corse TSS was introduced on 2016-12-01
update operations_points set est_dans_dst = false, nom_dst = null
where operation_id in (
  select p.operation_id
  from operations_points p
  join operations_stats s on s.operation_id = p.operation_id and s.date < '2016-12-01'
  where p.est_dans_dst and p.nom_dst = 'dst-corse'
);
