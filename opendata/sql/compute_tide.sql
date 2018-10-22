update operations_stats set
  maree_port = t.maree_port,
  maree_coefficient = t.maree_coefficient,
  maree_categorie = t.maree_categorie
from (
  select
    operation_id,
    t.port as maree_port,
    coefficient as maree_coefficient,
    case
      when coefficient between 20 and 45 then '20-45'
      when coefficient between 46 and 70 then '46-70'
      when coefficient between 71 and 95 then '71-95'
      when coefficient between 95 and 120 then '96-120'
      else null
    end maree_categorie
  from (
    select distinct
      operation_id,
      date,
      first_value(port) over (partition by operation_id order by distance_km asc) port,
      first_value(port_code) over (partition by operation_id order by distance_km asc) code
    from (
      SELECT
        op.operation_id,
        op.date,
        p.code as port_code,
        p.name as port,
        ST_Distance(
          p.point,
          op.point
        )/1000 distance_km
      FROM ports p
      join (
        select
          op.operation_id,
          op.point,
          stats.date
        from operations_points op
        join operations_stats stats on stats.operation_id = op.operation_id
        join operations o on o.operation_id = op.operation_id
        where op.point is not null
          and coalesce(stats.distance_cote_metres, 0) < 20000
          and o."cross" not in ('Antilles-Guyane', 'Corse', 'Guadeloupe', 'Guyane', 'La Garde', 'La Réunion', 'Martinique', 'Mayotte', 'Nouvelle-Calédonie', 'Polynésie')
      ) op on true
    ) t
  ) t
  join tide_data td on td.date = t.date and td.port = t.code
) t
where operations_stats.operation_id = t.operation_id;
