DROP TABLE IF EXISTS secmar_json_engagements_durees;

CREATE TABLE secmar_json_engagements_durees (
  chrono varchar,
  uuid varchar primary key,
  date_heure_debut timestamptz not null,
  date_heure_fin timestamptz not null,
  duree_engagement_minutes integer not null,
  numero_ordre smallint not null
);

CREATE INDEX ON secmar_json_engagements_durees(chrono);

INSERT INTO secmar_json_engagements_durees (
  chrono, uuid, date_heure_debut, date_heure_fin, duree_engagement_minutes, numero_ordre
)
select
  *,
  row_number() over(partition by chrono order by date_heure_debut asc) numero_ordre
from (
  select
    chrono,
    uuid,
    min(dt) date_heure_debut,
    max(dt) date_heure_fin,
    round(extract(epoch from max(dt) - min(dt)) / 60) duree_engagement_minutes
  from (
    select
      chrono,
      e->>'uuid' uuid,
      ((jsonb_each_text(e->'etapesEngagement')).value)::timestamptz dt
    from (
      select
        data->>'chrono' as chrono,
        jsonb_array_elements(data->'engagements') as e
      from snosan_json_unique
      where data ? 'engagements'
    ) t
  ) t
  group by 1, 2
) t
;
