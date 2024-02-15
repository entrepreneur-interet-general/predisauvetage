select
  u.data->>'chrono' chrono,
  u.data->'identification'->>'operativeType' type_operation,
  oc.latitude,
  oc.longitude,
  c.secmar as "cross",
  e.secmar_evenement evenement,
  e.secmar_categorie_evenement categorie_evenement,
  qa.secmar qui_alerte,
  qa.categorie_qui_alerte categorie_qui_alerte,
  ma.secmar moyen_alerte,
  ma.categorie_moyen_alerte categorie_moyen_alerte,
  zr.secmar zone_responsabilite,
  replace(data->'bulletinsMeteo'->0->>'etatMer', 'ETAT_MER_', '')::int mer_force,
  replace(data->'bulletinsMeteo'->0->>'forceVent', 'FORCE_', '')::int vent_force,
  vc.secmar vent_direction_categorie,
  round(degrees((data->'bulletinsMeteo'->0->>'directionVent')::float)) vent_direction
from snosan_json_unique u
join snosan_json_operations_coordinates oc on oc.chrono = u.data->>'chrono'
left join snosan_json_evenement e on e.chrono = u.data->>'chrono'
left join secmar_json_operations_cross c on c.seamis = u.data->>'crossCoordonnateurId'
left join secmar_json_operations_moyen_alerte ma on ma.seamis = u.data->>'moyenAlerte'
left join secmar_json_operations_qui_alerte qa on qa.seamis = u.data->>'quiAlerte'
left join secmar_json_operations_zone_responsabilite zr on zr.seamis = u.data->>'zoneResponsabilite'
left join secmar_json_operations_vent_categorie vc on vc.seamis = u.data->'bulletinsMeteo'->0->>'secteurVent'
;
