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
  coalesce(rhc.secmar, 'Autre') categorie_personne,
  case
    when personne->'resultat' ? 'DECEDE' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'DECEDE')
    when personne->'resultat' ? 'DISPARU' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'DISPARU')
    when personne->'resultat' ? 'SECOURU' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'SECOURU')
    when personne->'resultat' ? 'ASSISTE' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'ASSISTE')
    when personne->'resultat' ? 'RETROUVE_APRES_RECHERCHE' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'RETROUVE_APRES_RECHERCHE')
    when personne->'resultat' ? 'FAUSSE_ALERTE' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'FAUSSE_ALERTE')
    when personne->'resultat' ? 'BLESSE' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'BLESSE')
    when personne->'resultat' ? 'MALADE' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'MALADE')
    when personne->'resultat' ? 'TIRE_DAFFAIRE_SEUL' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'TIRE_DAFFAIRE_SEUL')
    when personne->'resultat' ? 'INDEMNE' then (select secmar from secmar_json_resultats_humain_resultat where seamis = 'INDEMNE')
    else 'Inconnu'
  end resultat_humain,
  coalesce((personne->>'npi')::int, 1) nombre,
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
left join secmar_json_resultats_humain_categorie rhc on rhc.seamis = personne->>'categorie'
where personne->>'isInvolved' = 'true' and personne->>'principalImpl' = 'true';
