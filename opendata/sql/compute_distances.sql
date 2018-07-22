-- Delete rows where position has changed
delete from operations_points
where operation_id in (
  select op.operation_id
  from operations_points op
  join operations o on o.operation_id = op.operation_id
  where op.latitude is distinct from o.latitude
     or op.longitude is distinct from o.longitude
);

-- Insert new rows that were not yet in the cache
insert into operations_points (operation_id, "point", latitude, longitude)
select
  operation_id,
  ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography,
  latitude,
  longitude
from operations
where operation_id not in (select operation_id from operations_points);

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
        ST_Distance(fb.geography, o.point) dst
      from operations_points o
      join france_boundaries fb on true
      where o.point is not null
        and o.distance_cote_metres is null
    ) _
  ) _
) t
where t.operation_id = operations_points.operation_id;
