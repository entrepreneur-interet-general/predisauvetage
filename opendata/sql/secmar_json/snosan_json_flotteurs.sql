DROP TABLE IF EXISTS snosan_json_flotteurs;

CREATE TABLE snosan_json_flotteurs (
  "chrono" varchar,
  "pavillon" varchar,
  "resultat_flotteur" varchar,
  "type_flotteur" varchar,
  "categorie_flotteur" varchar,
  "longueur" numeric(5, 2)
);

CREATE INDEX ON snosan_json_flotteurs(chrono);

INSERT INTO snosan_json_flotteurs (
  chrono,
  pavillon,
  resultat_flotteur,
  type_flotteur,
  categorie_flotteur,
  longueur
)
SELECT
  _.chrono,
  case when v->>'flag' in ('FRA', 'France') then 'Français' else 'Étranger' end pavillon,
  sjrf.secmar resultat_flotteur,
  sjtf.secmar type_flotteur,
  sjtf.categorie_flotteur categorie_flotteur,
  case when (v->>'longueur')::numeric <= 1000 then (v->>'longueur')::numeric else null end longueur
from (
  select
    data->>'chrono' as chrono,
    jsonb_array_elements(data->'vehicules') as v
  from snosan_json_unique
  where data ? 'vehicules'
) _
left join secmar_json_resultat_flotteur sjrf on sjrf.seamis = v->'resultat'
left join secmar_json_type_flotteur sjtf on sjtf.seamis = coalesce(v->>'type',
    v->>'typeAero')
;

-- Colonnes existantes
-- autreFaitGenerateur
-- builtYear
-- callsign
-- categorie
-- classSociety
-- commentaire
-- contact
-- contactList
-- couleurCoque
-- descriptionAutreFlotteur
-- draught
-- etatInitial
-- facteurAggravant
-- fait
-- flag
-- flotteurImmatricule
-- flotteurPrincipal
-- gauge
-- iff
-- immatriculation
-- imo
-- indicatif
-- inmarsatNum
-- isPinned
-- isShip
-- longueur
-- mmsi
-- nom
-- nomCompagnie
-- pays
-- positions
-- propulsion
-- quartierImmat
-- referentielType
-- resultat
-- technicalId
-- type
-- typeAero
-- uuid
