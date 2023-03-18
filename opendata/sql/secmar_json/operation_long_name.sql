select
  replace(s.data->>'chrono', '-', '_') as secmar_json_operation_long_name,
  t.secmar as secmar_evenement
from snosan_json_unique s
join (
  select seamis, secmar
  from secmar_json_evenement_codes
) t on t.seamis = data->'identification'->>'operativeEvent';
