# Langage SQL

Cette page comporte des rappels sur le langage SQL. Le diaporama complet est [disponible en ligne](https://docs.google.com/presentation/d/1hn6SA78FhIaXljEb7Pof9WVl0woEjurLm4VCAlHT1mM/). Il est possible que certaines notions n'aient pas été abordées lors de la formation.

## Requête de sélection
Une requête de sélection peut faire apparaitre les éléments suivants :

- `SELECT` : les colonnes que l'on veut faire apparaitre dans le résultat ;
- `FROM` : la table source des données ;
- `JOIN` : si l'on souhaite travailler avec plusieurs tables, il faut effectuer des jointures et spécifier les colonnes qui doivent correspondre (`operation_id` pour SECMAR) ;
- `WHERE` : les contraintes / filtres à appliquer à nos données (spécifier une année, une situation météo etc.) ;
- `GROUP BY` : lorsque l'on veut résumer l'information, il faut procéder à un aggrégat pour ne pas avoir autant de lignes que le nombre d'opérations qu'il y a. Cette clause permet d'avoir des résultats par année et par CROSS par exemple ;
- `ORDER BY` : permet de trier le résultat obtenu selon l'ordre ascendant, descendant des colonnes. On utilise la position d'une colonne et les mots clés `ASC` ou `DESC`.

Un exemple complet d'une requête (sans intérêt métier) faisant apparaitre les différentes syntaxes possibles est présenté ci-dessous.
```sql
SELECT
  "stats"."annee",
  "op"."cross",
  "op"."type_operation",
  COUNT("op"."operation_id") AS "nb_operations",
  SUM("stats"."nombre_personnes_impliquees") AS "total_impliques"
FROM "operations" AS "op"
JOIN "operations_stats" AS "stats" ON "stats"."operation_id" = "op"."operation_id"
WHERE "op"."cross" = 'Jobourg'
  AND "op"."evenement" IN ('Isolement par la marée / Envasé', 'Suicide')
  AND "stats"."annee" BETWEEN 2010 AND 2013
  AND ("op"."vent_force" <= 4 OR "op"."vent_force" > 7) -- Vent jusqu'à 4 ou strictement supérieur à 7
  AND "stats"."mois_texte" <> 'Juin' -- Tous les mois sauf Juin
GROUP BY 1, 2, 3 -- Aggrège par les colonnes 1, 2 et 3 (année, CROSS et type d'opération)
ORDER BY 1 ASC, 2 DESC -- Tri par l'ordre ascendant la colonne 1 (année) puis descendant par la colonne 2 (CROSS)
```

Il est recommandé de suivre la présentation ci-dessus en terme de respect de la casse, espacements et retours à la ligne pour faciliter la lisibilité des requêtes et conserver une cohérence.

## Fonctions supplémentaires en SQL
Ici sont présentées quelques fonctionnalités supplémentaires du langage SQL qui peuvent être utiles lors de requêtes spécifiques. La liste complète des fonctionnalités peut être trouvée sur un moteur de recherche, pour une base de données PostgreSQL.

### Années glissantes
Il est possible dans une requête de récupérer la date courante lors de l'exécution de la requête à l'aide de `current_date`.

Ainsi, une requête pour calculer l'année d'il y a 10 ans peut s'exprimer de la façon suivante :
```sql
-- `current_date` donne la date courante
-- `date_part('year', current_date)` donne seulement l'année de la date courante
select (date_part('year', current_date) - 10)
```

Cette fonctionnalité permet de calculer des choses sur des années glissantes. Par exemple, le nombre d'opérations SAR/MAS/DIV/SUR pour tous les CROSS par année sur les 10 dernières années :
```sql
SELECT
  "stats"."annee",
  "op"."cross",
  "op"."type_operation",
  count("op"."operation_id") AS "nb_operations"
FROM "operations" AS "op"
JOIN "operations_stats" AS "stats" ON "stats"."operation_id" = "op"."operation_id"
WHERE "stats"."annee" >= (date_part('year', current_date) - 10)
GROUP BY 1, 2, 3
```

### Modifications de la casse
Il est possible de passer du texte tout en majuscules ou tout en minuscules avec les commandes `UPPER` et `LOWER` respectivement.

```sql
SELECT DISTINCT
    "cross",
    LOWER("cross") AS "cross_minuscules",
    UPPER("cross") AS "cross_majuscules"
FROM "operations"
```
