drop table if exists sitrep_messages;

CREATE TABLE sitrep_messages (
  operation_id bigint primary key,
  sitrep text
);

INSERT INTO sitrep_messages
  (operation_id, sitrep)
select
  sjoi.operation_id,
  array_to_string(array_agg(value order by coalesce(mapping.dst, key) asc), ' ')
from (
  select
    u.data->>'chrono' as chrono,
    replace(key, 'paragraphe', '') as key,
    value
  from snosan_json_unique u, jsonb_each(u.data->'messages'->0) AS obj(key, value)
  where key like 'paragraphe%'
) t
join snosan_json_operation_id sjoi on sjoi.chrono = t.chrono
left join (
  select '1' src, 'A' dst
  union select '2' src, 'B' dst
  union select '3' src, 'C' dst
  union select '4' src, 'D' dst
  union select '5' src, 'E' dst
  union select '6' src, 'F' dst
  union select '7' src, 'G' dst
  union select '8' src, 'H' dst
  union select '9' src, 'I' dst
  union select '10' src, 'J' dst
  union select '11' src, 'K' dst
  union select '12' src, 'L' dst
  union select '13' src, 'M' dst
  union select '14' src, 'N' dst
) mapping on mapping.src = key
group by 1;
