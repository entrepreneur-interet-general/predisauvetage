truncate snosan_json_unique;

-- Keep the latest version of each operation (by JSON id).
-- The source system sometimes assigns the same chrono to 2 distinct
-- operations (eg GN-2026-DIV-2237): keep the earliest alerted one.
insert into snosan_json_unique (data)
select distinct on (data->>'chrono') data
from (
  select distinct on (data->>'id') data
  from snosan_json
  order by data->>'id', id desc
) latest_by_id
order by data->>'chrono', data->>'gdhAlert' asc, data->>'id' asc
;
