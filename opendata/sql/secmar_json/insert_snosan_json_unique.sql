truncate snosan_json_unique;

insert into snosan_json_unique (data)
select distinct
  first_value(data) over(partition by data->>'id' order by id desc) as data
from snosan_json
;
