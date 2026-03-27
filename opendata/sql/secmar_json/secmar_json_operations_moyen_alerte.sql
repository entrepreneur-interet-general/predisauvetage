DROP TABLE IF EXISTS secmar_json_operations_moyen_alerte;

CREATE TABLE secmar_json_operations_moyen_alerte (
  seamis varchar primary key,
  secmar varchar,
  categorie_moyen_alerte varchar
);

CREATE INDEX ON secmar_json_operations_moyen_alerte(secmar);

INSERT INTO secmar_json_operations_moyen_alerte
  (seamis, secmar, categorie_moyen_alerte)
VALUES
  ('TELEPHONE_MOBILE_196', 'Téléphonie mobile 196', 'Téléphonie'),
  ('VHF_PHONIE', 'VHF phonie', 'VHF'),
  ('TELEPHONE_MOBILE', 'Téléphone mobile', 'Téléphonie'),
  ('TELEPHONE_FIXE', 'Téléphone fixe', 'Téléphonie'),
  ('AUTRE_MOYEN_ALERTE', 'Autre moyen d''alerte', 'Autre moyen d''alerte'),
  ('BALISE_DETRESSE_EPIRB', 'Balise de détresse EPIRB', 'Balises'),
  ('TELEPHONE_FIXE_196', 'Téléphone fixe 196', 'Téléphonie'),
  ('SIGNAL_PYRO', 'Signal pyrotechnique', 'Pyrotechnie'),
  ('ASN_VHF', 'VHF ASN', 'VHF'),
  ('E_MAIL', 'Email', 'Email'),
  ('TELEPHONE_SATELLITE', 'Téléphone à la mer / satellite', 'Satellites'),
  ('MOB_AIS', 'Mob AIS', 'Radio'),
  ('BALISE_DETRESSE_PLB', 'Balise de détresse PLB', 'Balises'),
  ('INMARSAT_C', 'Inmarsat C', 'Satellites'),
  ('BALISE_DETRESSE_ELT', 'Balise de détresse ELT', 'Balises'),
  ('TELEPHONE_IRIDIUM', 'Téléphone à la mer / satellite', 'Satellites'),
  ('SART', 'SART', 'Radio'),
  ('TELEPHONE_INMARSAT', 'Téléphone à la mer / satellite', 'Satellites'),
  ('ASN_MF_HF', 'MF/HF ASN', 'Radio'),
  ('SSAS', 'SSAS', 'Satellites'),
  ('SIGNAL_REGLEMENTAIRE', 'Autre signal réglementaire', 'Autre moyen d''alerte'),
  ('VHF_AIS', 'VHF AIS', 'VHF'),
  ('MOB_ASN', 'MOB ASN', 'Balises'),
  ('MF_HF_PHONIE', 'MF/HF phonie', 'Radio'),
  ('SYTEME_INDIVIDUEL_ALERTE', 'Système individuel d''alerte', 'Système individuel d''alerte'),
  ('TELECOPIE', 'Télécopie', 'Télécopie'),
  ('TELEPHONE_MER_GSM', 'Téléphone à la mer / GSM', 'Téléphonie'),
  ('TELEPHONE_TERRE_FIXE', 'Téléphone fixe', 'Téléphonie')
;
