create table operations_points (
  "operation_id" bigint primary key,
  "point" geography(point)
);
create index operations_points_point_idx on operations_points using gist(point);

insert into operations_points
select
  operation_id,
  ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography
from operations;

vacuum analyze operations_points;

select
  o.operation_id,
  ST_Distance(b.geography, o.point)/1000
from operations_points o
join france_boundaries b on true
where o.point is not null;
