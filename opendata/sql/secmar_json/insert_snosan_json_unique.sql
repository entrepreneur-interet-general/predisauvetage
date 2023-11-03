truncate snosan_json_unique;

insert into snosan_json_unique (data)
select distinct
  first_value(data) over(partition by data->>'id' order by s.id desc) as data
from snosan_json s
join (
  select
    data->>'id' id,
    max(data->>'version') max_version
  from snosan_json
  group by 1
) t on s.data->>'id' = t.id and s.data->>'version' = t.max_version;
