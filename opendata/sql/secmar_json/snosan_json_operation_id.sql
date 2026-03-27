DROP TABLE IF EXISTS snosan_json_operation_id;

CREATE TABLE snosan_json_operation_id (
  chrono varchar primary key,
  operation_id bigint unique
);

CREATE INDEX ON snosan_json_operation_id(operation_id);

INSERT INTO snosan_json_operation_id
select
  u.data->>'chrono' chrono,
  (
    '1' ||
    cross_id.code::varchar ||
    type_id.code::varchar ||
    (u.data->'identification'->>'yearOfCreation') ||
    (u.data->'identification'->>'numberInYear')
  )::bigint operation_id
from snosan_json_unique u
join (
  select distinct
    u.data->>'crossCoordonnateurId' cross_code,
    dense_rank() over(order by u.data->>'crossCoordonnateurId') code
  from snosan_json_unique u
) cross_id on cross_id.cross_code = u.data->>'crossCoordonnateurId'
join (
  select distinct
    u.data->'identification'->>'operativeType' type_code,
    dense_rank() over(order by u.data->'identification'->>'operativeType') code
  from snosan_json_unique u
) type_id on type_id.type_code = u.data->'identification'->>'operativeType'
;
