DROP TABLE IF EXISTS secmar_json_operations_zone_responsabilite;

CREATE TABLE secmar_json_operations_zone_responsabilite (
  seamis varchar primary key,
  secmar varchar
);

CREATE INDEX ON secmar_json_operations_zone_responsabilite(secmar);

INSERT INTO secmar_json_operations_zone_responsabilite
  (seamis, secmar)
VALUES
  ('EAUX_TERRITORIALES', 'Eaux territoriales'),
  ('PLAGE_300M', 'Plage et 300 mètres'),
  ('RESP_FRANCAISE', 'Responsabilité française'),
  ('RESP_ETRANGERE', 'Responsabilité étrangère'),
  ('TERRESTRE', 'Terrestre'),
  ('PLAN_EAU_SALEE', 'Plan eau salée'),
  ('PORT', 'Port et accès'),
  ('ACCES_PORTUAIRES', 'Port et accès'),
  ('PORT_ACCES', 'Port et accès')
;
