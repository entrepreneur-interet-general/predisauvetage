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

-- Remove old rows
delete from operations_points
where operation_id not in (select operation_id from operations);
