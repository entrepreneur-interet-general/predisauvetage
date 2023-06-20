drop table if exists snosan_json_resultats_humain;
create table snosan_json_resultats_humain (
  chrono varchar not null,
  categorie_personne varchar not null,
  resultat_humain varchar not null,
  nombre integer not null,
  dont_nombre_blesse integer not null
);

create index on snosan_json_resultats_humain(chrono);

insert into snosan_json_resultats_humain (chrono, categorie_personne, resultat_humain, nombre, dont_nombre_blesse)
select
  t.chrono chrono,
  case
    when personne->>'categorie' = 'PLAISANCIER' then 'Plaisancier français'
    when personne->>'categorie' = 'PRATIQUANT_LOISIRS_NAUTIQUES' then 'Pratiquant loisirs nautiques'
    when personne->>'categorie' = 'PROFESSIONNEL' then 'Commerce français'
    when personne->>'categorie' = 'MIGRANT' then 'Migrant'
    when personne->>'categorie' = 'PECHEUR_PRO' then 'Pêcheur français'
    when personne->>'categorie' = 'PECHEUR_AMATEUR' then 'Pêcheur amateur'
    else 'Autre'
  end categorie_personne,
  case
    when personne->'resultat' ? 'DECEDE' then 'Personne décédée'
    when personne->'resultat' ? 'DISPARU' then 'Personne disparue'
    when personne->'resultat' ? 'SECOURU' then 'Personne secourue'
    when personne->'resultat' ? 'ASSISTE' or personne->'resultat' ? 'ASSITE' then 'Personne assistée'
    when personne->'resultat' ? 'RETROUVE_RECHERCHE' or personne->'resultat' ? 'RETROUVE_APRES_RECHERCHE' then 'Personne retrouvée'
    when personne->'resultat' ? 'FAUSSE_ALERTE' or personne->'resultat' ? 'IMPL_FAUSSE_ALERTE' then 'Personne impliquée dans fausse alerte'
    else 'Personne tirée d''affaire seule'
  end resultat_humain,
  coalesce((personne->>'npi')::int, 1) nombre
  case
    when personne->'etatInitial' ? 'BLESSE' then coalesce((personne->>'npi')::int, 1)
    else 0
  end dont_nombre_blesse
from (
  select
    data->>'chrono' chrono,
    jsonb_array_elements(data->'personnes') personne
  from snosan_json_unique
) t
where personne->>'isInvolved' = 'true';
