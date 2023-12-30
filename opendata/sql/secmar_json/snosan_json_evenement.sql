drop table if exists snosan_json_evenement;
create table snosan_json_evenement (
  chrono varchar not null,
  operation_long_name varchar primary key unique,
  secmar_evenement varchar,
  secmar_categorie_evenement varchar
);

create unique index on snosan_json_evenement(chrono);

insert into snosan_json_evenement (
  chrono,
  operation_long_name,
  secmar_evenement,
  secmar_categorie_evenement
)
select
  s.data->>'chrono',
  replace(s.data->>'chrono', '-', '_') as secmar_json_operation_long_name,
  t.secmar as secmar_evenement,
  t.categorie_evenement as secmar_categorie_evenement
from snosan_json_unique s
join (
  select seamis, secmar, categorie_evenement
  from secmar_json_evenement_codes
) t on t.seamis = data->'identification'->>'operativeEvent'
where s.data->>'chrono' not similar to '%20(19|20|21)%';
