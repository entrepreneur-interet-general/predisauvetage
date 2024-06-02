DROP TABLE IF EXISTS secmar_json_resultat_flotteur_codes;

CREATE TABLE secmar_json_resultat_flotteur_codes (
  seamis varchar primary key,
  secmar varchar
);

CREATE INDEX ON secmar_json_resultat_flotteur_codes(secmar);

INSERT INTO secmar_json_resultat_flotteur_codes
  (seamis, secmar)
VALUES
  ('ASSISTE', 'Assisté'),
  ('AU_MOUILLAGE', 'Au mouillage'),
  ('A_LA_DERIVE', 'A la dérive'),
  ('COULE', 'Perdu / Coulé'),
  ('DESECHOUE', 'Déséchoué'),
  ('DETRUIT', 'Perdu / Coulé'),
  ('DIFFICULTE_SURMONTEE_SEUL', 'Difficulté surmontée, reprise de route'),
  ('ECHOUE', 'Échoué'),
  ('FAUSSE_ALERTE', 'Non assisté, cas de fausse alerte'),
  ('IMMOBILISE_DANS_ENGIN', 'Immobilisé dans engin'),
  ('INCONNU', 'Inconnu'),
  ('NON_ASSISTE', 'Non assisté, cas de fausse alerte'),
  ('NON_RETROUVE', 'Perdu / Coulé'),
  ('PERDU_VOLE', 'Volé'),
  ('REMORQUE', 'Remorqué'),
  ('RENFLOUE', 'Renfloué'),
  ('REPRISE_DE_ROUTE', 'Difficulté surmontée, reprise de route'),
  ('RETROUVE_APRES_RECHERCHE', 'Retrouvé après recherche'),
  ('TIRE_DAFFAIRE_SEUL', 'Difficulté surmontée, reprise de route')
;

DROP TABLE IF EXISTS secmar_json_resultat_flotteur;

CREATE TABLE secmar_json_resultat_flotteur (
  seamis jsonb,
  secmar varchar,
  count integer
);

CREATE INDEX ON secmar_json_resultat_flotteur(seamis);

INSERT INTO secmar_json_resultat_flotteur
  (seamis, secmar, count)
select
  resultat,
  case
    when nb_elements = 1 then sjrfc.secmar
    else
      case
        when resultat ? 'REMORQUE' then 'Remorqué'
        when resultat ? 'REPRISE_DE_ROUTE' then 'Difficulté surmontée, reprise de route'
        when resultat ? 'FAUSSE_ALERTE' then 'Non assisté, cas de fausse alerte'
        when resultat ? 'AU_MOUILLAGE' then 'Au mouillage'
        when resultat ? 'DESECHOUE' then 'Déséchoué'
        else 'Inconnu'
      end
  end secmar_resultat,
  count
from (
  select
    vehicule->'resultat' resultat,
    jsonb_array_length(vehicule->'resultat') nb_elements,
    count(1) count
  from (
    select
      data->>'chrono' chrono,
      jsonb_array_elements(data->'vehicules') vehicule
    from snosan_json_unique s
    where s.data->>'chrono' similar to '%202(2|3)%'
  ) t
  group by 1, 2
) t
left join secmar_json_resultat_flotteur_codes sjrfc on sjrfc.seamis = resultat->>0
