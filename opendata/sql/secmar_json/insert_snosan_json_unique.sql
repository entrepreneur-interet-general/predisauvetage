truncate snosan_json_unique;

-- Keep the latest version of each operation (by JSON id).
-- The source system sometimes gives an already used chrono to another
-- operation, eg when it is transferred to another CROSS
-- (JB-2026-SAR-1290 renumbered GN-2026-DIV-2237 while GN-2026-DIV-2237
-- already existed). In this case:
-- - the chrono goes to the operation which had it first
-- - the other operation falls back to its latest version with a free chrono
with versions as (
  select id row_id, data->>'id' jid, data->>'chrono' chrono, data
  from snosan_json
),
latest as (
  select distinct on (jid) *
  from versions
  order by jid, row_id desc
),
first_seen as (
  select jid, chrono, min(row_id) first_row_id
  from versions
  group by jid, chrono
),
winners as (
  select distinct on (l.chrono) l.jid, l.chrono, l.data
  from latest l
  join first_seen f on f.jid = l.jid and f.chrono = l.chrono
  order by l.chrono, f.first_row_id asc
),
fallback as (
  select distinct on (v.chrono) v.data
  from (
    select distinct on (v.jid) v.*
    from versions v
    where v.jid not in (select jid from winners)
      and v.chrono not in (select chrono from winners)
    order by v.jid, v.row_id desc
  ) v
  order by v.chrono, v.row_id asc
)
insert into snosan_json_unique (data)
select data from winners
union all
select data from fallback
;
