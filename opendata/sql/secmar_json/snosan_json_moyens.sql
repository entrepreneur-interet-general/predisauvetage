DROP TABLE IF EXISTS snosan_json_moyens;

CREATE TABLE snosan_json_moyens (
  chrono varchar,
  numero_ordre smallint,
  moyen varchar(100),
  categorie_moyen varchar(100),
  domaine_action varchar(50),
  autorite_moyen varchar(100),
  date_heure_debut timestamptz,
  date_heure_fin timestamptz,
  duree_engagement_minutes integer
);

CREATE INDEX ON snosan_json_moyens(chrono);

INSERT INTO snosan_json_moyens
SELECT
  _.chrono,
  d.numero_ordre,
  t.secmar,
  c.secmar,
  c.domaine_action,
  a.secmar,
  d.date_heure_debut,
  d.date_heure_fin,
  d.duree_engagement_minutes
from (
  select
    data->>'chrono' as chrono,
    jsonb_array_elements(data->'engagements') as e
  from snosan_json_unique
  where data ? 'engagements'
) _
left join secmar_json_engagements_durees d on d.uuid = e->>'uuid'
left join secmar_json_engagements_autorite a on a.seamis = e->>'autorite'
left join secmar_json_engagements_type t on t.seamis = e->>'type'
left join secmar_json_engagements_categorie c on c.seamis = e->>'categorie'
