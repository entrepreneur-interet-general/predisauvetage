select
  -- operation_id
  u.data->>'chrono' chrono,
  u.data->'identification'->>'operativeType' type_operation,
  ma.secmar moyen_alerte,
  ma.categorie_moyen_alerte categorie_moyen_alerte,
  qa.secmar qui_alerte,
  qa.categorie_qui_alerte categorie_qui_alerte,
  c.secmar::noms_cross as "cross",
  d.secmar departement,
  coalesce(c.est_metropolitain, d.est_metropolitain) est_metropolitain
  e.secmar_evenement evenement,
  e.secmar_categorie_evenement categorie_evenement,
  null autorite,
  zr.secmar zone_responsabilite,
  oc.latitude,
  oc.longitude,
  round(degrees((data->'bulletinsMeteo'->0->>'directionVent')::float)) vent_direction,
  replace(data->'bulletinsMeteo'->0->>'forceVent', 'FORCE_', '')::int vent_force,
  vc.secmar vent_direction_categorie,
  replace(data->'bulletinsMeteo'->0->>'etatMer', 'ETAT_MER_', '')::int mer_force,
  u.data->'identification'->>'numberInYear' numero_sitrep,
  (
    c.secmar || ' ' ||
    (u.data->'identification'->>'operativeType') || ' ' ||
    (u.data->'identification'->>'yearOfCreation') || '/' ||
    (u.data->'identification'->>'numberInYear')
  ) cross_sitrep
  'UTC' fuseau_horaire
from snosan_json_unique u
join snosan_json_operations_coordinates oc on oc.chrono = u.data->>'chrono'
left join snosan_json_evenement e on e.chrono = u.data->>'chrono'
left join secmar_json_operations_cross c on c.seamis = u.data->>'crossCoordonnateurId'
left join secmar_json_operations_moyen_alerte ma on ma.seamis = u.data->>'moyenAlerte'
left join secmar_json_operations_qui_alerte qa on qa.seamis = u.data->>'quiAlerte'
left join secmar_json_operations_zone_responsabilite zr on zr.seamis = u.data->>'zoneResponsabilite'
left join secmar_json_operations_vent_categorie vc on vc.seamis = u.data->'bulletinsMeteo'->0->>'secteurVent'
left join secmar_json_operations_departement d on d.seamis = u.data->>'departement'
;
