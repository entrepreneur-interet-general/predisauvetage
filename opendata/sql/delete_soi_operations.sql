delete from operations where operation_id in (
  select o.operation_id
  from operations o
  join operations_stats s on s.operation_id = o.operation_id
  where o."cross" in ('La Réunion', 'Mayotte') and s.annee >= 2021
);