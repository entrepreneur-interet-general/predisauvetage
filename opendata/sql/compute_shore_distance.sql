-- Compute distances when it has not been computed yet
update operations_points set
  distance_cote_metres = t.distance_cote_metres,
  distance_cote_milles_nautiques = t.distance_cote_milles_nautiques
from (
  select
    operation_id,
    distance_cote_metres,
    round((distance_cote_metres*0.000539957)::numeric, 2) distance_cote_milles_nautiques
  from (
    select
      operation_id,
      round(dst / 100.0) * 100 distance_cote_metres
    from (
      select
        o.operation_id,
        min(ST_Distance(go.geography, o.point)) dst
      from operations_points o
      join geography_objects go on go.name in ('frontieres-terrestres-france', 'regions-20140306-100m')
      where o.point is not null
        and o.distance_cote_metres is null
      group by o.operation_id
    ) _
  ) _
) t
where t.operation_id = operations_points.operation_id;
