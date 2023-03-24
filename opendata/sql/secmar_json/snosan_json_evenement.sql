drop table if exists snosan_json_evenement;
create table snosan_json_evenement (
  chrono varchar,
  operation_long_name varchar primary key unique,
  secmar_evenement varchar
);

create unique index on snosan_json_evenement(chrono);

-- Mapping direct d'un énuméré SEAMIS vers SECMAR
insert into snosan_json_evenement (chrono, operation_long_name, secmar_evenement)
select
  s.data->>'chrono',
  replace(s.data->>'chrono', '-', '_') as secmar_json_operation_long_name,
  t.secmar as secmar_evenement
from snosan_json_unique s
join (
  select seamis, secmar
  from secmar_json_evenement_codes
) t on t.seamis = data->'identification'->>'operativeEvent';

-- Gestion des `operativeEvent` à `NULL` : `Toutes fausses alertes` ou `Incertitude`
insert into snosan_json_evenement (chrono, operation_long_name, secmar_evenement)
select
  s.data->>'chrono',
  replace(s.data->>'chrono', '-', '_') as secmar_json_operation_long_name,
  case when s.data::text ilike '%fausse_alerte%' then 'Toutes fausses alertes' else 'Incertitude' end as secmar_evenement
from snosan_json_unique s
where s.data->>'chrono' not in (select chrono from snosan_json_evenement);

-- Gestion des `operativeEvent` à `SITUATION_INDETERMINEE` possibilité de passer à `Toutes fausses alertes`
update snosan_json_evenement set secmar_evenement = 'Toutes fausses alertes'
where chrono in (
  select data->>'chrono'
  from snosan_json_unique
  where data->'identification'->>'operativeEvent' = 'SITUATION_INDETERMINEE'
    and data::text ilike '%fausse_alerte%'
);
