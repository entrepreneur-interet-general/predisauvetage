CREATE TABLE snosan_json (data jsonb);

CREATE INDEX ON snosan_json((data ->> 'id'::text) text_ops);
CREATE INDEX ON snosan_json((data ->> 'version'::text) text_ops);
CREATE INDEX ON snosan_json((data ->> 'chrono'::text) text_ops);


CREATE TABLE snosan_json_unique (data jsonb);

CREATE INDEX ON snosan_json_unique((data ->> 'version'::text) text_ops);
CREATE INDEX ON snosan_json_unique(((data -> 'identification') ->> 'operativeEvent'::text) text_ops);
CREATE UNIQUE INDEX ON snosan_json_unique((data ->> 'id'::text) text_ops);
CREATE UNIQUE INDEX ON snosan_json_unique((data ->> 'chrono'::text) text_ops);

-- Run this in psql to load data from a file containing JSON lines
-- COPY snosan_json (data) FROM '/tmp/data.json' csv quote e'\x01' delimiter e'\x02';

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
