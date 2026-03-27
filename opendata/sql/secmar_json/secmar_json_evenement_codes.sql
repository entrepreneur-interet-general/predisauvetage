DROP TABLE IF EXISTS secmar_json_evenement_codes;

CREATE TABLE secmar_json_evenement_codes (
  seamis varchar primary key,
  secmar varchar,
  categorie_evenement varchar
);

CREATE INDEX ON secmar_json_evenement_codes(secmar);

INSERT INTO secmar_json_evenement_codes
  (seamis, secmar, categorie_evenement)
VALUES
  ('ABORDAGE', 'Abordage', 'Accidents de navire'),
  ('ACCIDENT_AERONAUTIQUE', 'Accident aéronautique', 'Autres affaires nécessitant opération'),
  ('ACCIDENT_CORPOREL', 'Accident corporel', 'Accidents individuels à personnes'),
  ('ACTE_DE_PIRATERIE', 'Acte de piraterie / terrorisme', 'Autres affaires nécessitant opération'),
  ('ATTAQUE_TERRORISTE', 'Acte de piraterie / terrorisme', 'Autres affaires nécessitant opération'),
  ('AUTRE_EVENEMENT', 'Autre événement', 'Autres affaires nécessitant opération'),
  ('AVARIE_AERONAUTIQUE', 'Accident aéronautique', 'Autres affaires nécessitant opération'),
  ('AVARIE_APPAREIL_A_GOUVERNER', 'Avarie de l''appareil à gouverner', 'Accidents de navire'),
  ('AVARIE_DE_COMMUNICATION', 'Avarie des systèmes de communication', 'Avaries non suivies d''accident navire'),
  ('AVARIE_DE_GREEMENT', 'Avarie de gréement', 'Accidents de navire'),
  ('AVARIE_DE_LAPPAREIL_A_GOUVERNER', 'Avarie de l''appareil à gouverner', 'Autres affaires nécessitant opération'),
  ('AVARIE_DE_PROPULSION', 'Avarie du système de propulsion', 'Autres affaires nécessitant opération'),
  ('AVARIE_ELECTRIQUE', 'Avarie électrique', 'Autres affaires nécessitant opération'),
  ('BAIGNADE', 'Baignade', 'Accidents individuels à personnes'),
  ('CHASSE_SOUSMARINE', 'Chasse sous-marine', 'Accidents individuels à personnes'),
  ('CHAVIREMENT', 'Chavirement', 'Accidents de navire'),
  ('CHUTE_A_LA_MER', 'Homme à la mer', 'Accidents individuels à personnes'),
  ('CHUTE_DUNE_FALAISE', 'Chute falaise / Emporté par une lame', 'Accidents individuels à personnes'),
  ('COLLISION', 'Collision', 'Accidents de navire'),
  ('DECOUVERTE_DE_CORPS', 'Découverte de corps', 'Accidents individuels à personnes'),
  ('DECOUVERTE_DOBJET', 'Découverte d''explosif', 'Autres affaires nécessitant opération'),
  ('DEMATAGE', 'Démâtage', 'Accidents de navire'),
  ('DESARRIMAGE_DE_CARGAISON', 'Désarrimage cargaison', 'Accidents de navire'),
  ('DIFFICULTE_A_MANOEUVRER', 'Difficulté de manoeuvre', 'Autres affaires nécessitant opération'),
  ('ECHOUEMENT', 'Échouement', 'Accidents de navire'),
  ('EMPORTE_PAR_UNE_LAME', 'Chute falaise / Emporté par une lame', 'Accidents individuels à personnes'),
  ('ENCALMINAGE', 'Encalminage', 'Autres affaires nécessitant opération'),
  ('ENGIN_DANGEREUX_A_BORD', 'Engin dangereux à bord', 'Autres affaires nécessitant opération'),
  ('ENVASEMENT', 'Isolement par la marée / Envasé', 'Accidents individuels à personnes'),
  ('EXPLOSION', 'Explosion', 'Accidents de navire'),
  ('HELICE_ENGAGEE', 'Immobilisé dans engins / hélice engagée', 'Autres affaires nécessitant opération'),
  ('HEURT', 'Heurt', 'Accidents de navire'),
  ('IMMIGRATION_CLANDESTINE', 'Immigration clandestine', 'Autres affaires nécessitant opération'),
  ('IMMOBILISE_DANS_ENGIN', 'Immobilisé dans engins / hélice engagée', 'Autres affaires nécessitant opération'),
  ('INCAPACITE_DE_SE_POSITIONNER', 'Incertitude sur la position', 'Autres affaires nécessitant opération'),
  ('INCENDIE', 'Incendie', 'Accidents de navire'),
  ('INEXPERIENCE', 'Inexpérience', 'Autres affaires nécessitant opération'),
  ('ISOLEMENT_PAR_LA_MAREE', 'Isolement par la marée / Envasé', 'Autres affaires nécessitant opération'),
  ('MOUILLAGE_IMMOBILISE', 'Mouillage immobilisé', 'Autres affaires nécessitant opération'),
  ('NAUFRAGE', 'Naufrage', 'Accidents de navire'),
  ('PANNE_DE_CARBURANT', 'Panne de carburant', 'Autres affaires nécessitant opération'),
  ('PERTE_DE_PONTEE', 'Perte de pontée', 'Accidents de navire'),
  ('PERTE_DE_STABILITE', 'Perte de stabilité / Ripage de cargaison', 'Accidents de navire'),
  ('PLONGEE_AUTONOME', 'Plongée avec bouteille', 'Accidents individuels à personnes'),
  ('PLONGEE_EN_APNEE', 'Plongée en apnée', 'Accidents individuels à personnes'),
  ('PROBLEME_MEDICAL', 'Problème médical', 'Autres affaires nécessitant opération'),
  ('RIPAGE_DE_CARGAISON', 'Perte de stabilité / Ripage de cargaison', 'Accidents de navire'),
  ('RUPTURE_DE_MOUILLAGE', 'Rupture de mouillage', 'Accidents de navire'),
  ('RUPTURE_MOUILLAGE', 'Rupture de mouillage', 'Accidents de navire'),
  ('SITUATION_INDETERMINEE', 'Situation indéterminée', 'Autres affaires nécessitant opération'),
  ('TALONNAGE', 'Talonnage', 'Accidents de navire'),
  ('TENTATIVE_DE_SUICIDE', 'Suicide', 'Accidents individuels à personnes'),
  ('TRANSPORT_SANITAIRE_ILECONTINENT', 'Transport sanitaire île-continent', 'Autres affaires nécessitant opération'),
  ('TROUBLE_A_LORDRE_PUBLIC', 'Trouble à l''ordre public', 'Autres affaires nécessitant opération'),
  ('VOIE_DEAU', 'Voie d''eau', 'Accidents de navire')
;
