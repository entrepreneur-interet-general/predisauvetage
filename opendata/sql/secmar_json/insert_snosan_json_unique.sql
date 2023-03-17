truncate snosan_json_unique;

insert into snosan_json_unique (data)
select s.data
from snosan_json s
join (
  select id, max(version) as version
  from (
    select data->>'id' id, data->>'version' as version
    from snosan_json
    group by 1, 2
    having count(1) = 1
  ) t
  group by 1
) t2 on s.data->>'id' = t2.id and s.data->>'version' = t2.version;

insert into snosan_json_unique (data)
select distinct first_value(data) over(partition by ((data->>'id') || (data->>'version'))) as data
from snosan_json s
join (
  select data->>'id' id, data->>'version' as version
  from snosan_json
  group by 1, 2
  having count(1) > 1
) t on s.data->>'id' = t.id and s.data->>'version' = t.version;
