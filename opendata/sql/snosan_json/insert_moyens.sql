ALTER TABLE moyens ALTER COLUMN numero_ordre DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN categorie_moyen DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN moyen DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN domaine_action DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN autorite_moyen DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN date_heure_debut DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN date_heure_fin DROP NOT NULL;
ALTER TABLE moyens ALTER COLUMN duree_engagement_minutes DROP NOT NULL;

INSERT INTO moyens (
  operation_id,
  numero_ordre,
  moyen,
  categorie_moyen,
  domaine_action,
  autorite_moyen,
  date_heure_debut,
  date_heure_fin,
  duree_engagement_minutes
)
select
  scoi.operation_id,
  sjm.numero_ordre,
  sjm.moyen,
  sjm.categorie_moyen,
  sjm.domaine_action,
  sjm.autorite_moyen,
  sjm.date_heure_debut,
  sjm.date_heure_fin,
  sjm.duree_engagement_minutes
from snosan_json_moyens sjm
JOIN snosan_json_operation_id scoi on scoi.chrono = sjm.chrono
where scoi.operation_id not in (select distinct operation_id from moyens) and scoi.operation_id IN (SELECT operation_id FROM operations);
