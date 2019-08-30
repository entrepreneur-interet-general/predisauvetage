# Le SNOSAN

## Présentation du SNOSAN
Le Système National d'Observation de la Sécurité des Activités Nautiques (SNOSAN) est un observatoire interministériel qui répond à la volonté de mieux connaître les caractéristiques des accidents relatifs à la plaisance et aux activités nautiques récréatives et sportives en eaux françaises.

Le SNOSAN dispose d'un [site web](https://www.snosan.fr) et d'[un portail listant les différents outils](https://outils.snosan.fr).

## Opérations CROSS dans le cadre d'étude du SNOSAN
Le SNOSAN s'intéresse aux opérations relevant de la plaisance ou des loisirs nautiques. Une colonne est dédiée au SNOSAN (`operations_stats.concerne_snosan`), permettant de savoir immédiatement si une opération rentre dans le cadre d'étude du SNOSAN ou non.

On définit qu'une opération rentre dans le cadre d'étude du SNOSAN dès lors que :
- un flotteur de plaisance est impliqué dans l'opération
- un flotteur de loisirs nautiques est impliqué dans l'opération
- aucun flotteur n'est impliqué dans l'opération et le motif de déclenchement de l'opération est l'un des suivants :
    - Absence d'un moyen de communication
    - Accident aéronautique
    - Accident en mer
    - Autre accident
    - Autre événement
    - Baignade
    - Blessé EvaMed
    - Blessé EvaSan
    - Blessé projection d'une équipe médicale
    - Chasse sous-marine
    - Chute falaise / Emporté par une lame
    - Disparu en mer
    - Découverte de corps
    - Homme à la mer
    - Incertitude sur la position
    - Isolement par la marée / Envasé
    - Malade EvaMed
    - Malade EvaSan
    - Plongée avec bouteille
    - Plongée en apnée
    - Sans avarie en dérive
    - Sans avarie inexpérience
    - Ski nautique

## Filtres classiques
Le SNOSAN s'intéresse aux opérations relevant de la plaisance ou des loisirs nautiques. Il peut être nécessaire de ne s'intéresser qu'à certaines activités. Voici les différents cas et les filtres à appliquer :

- **Plaisance uniquement** : `concerne_snosan` à vrai, `nombre_flotteurs_plaisance_impliques` >= 1, `nombre_flotteurs_loisirs_nautiques_impliques` = 0, `sans_flotteur_implique` à faux
- **Loisirs nautiques uniquement** : `concerne_snosan` à vrai, `nombre_flotteurs_plaisance_impliques` = 0, `nombre_flotteurs_loisirs_nautiques_impliques` >= 1, `sans_flotteur_implique` à faux
- **Plaisance et loisirs nautiques (avec plongée)** : `concerne_snosan` à vrai, `sans_flotteur_implique` à faux
- **Plaisance et loisirs nautiques (sans plongée)** : `concerne_snosan` à vrai, `sans_flotteur_implique` à faux, `concerne_plongee` à faux
- **Uniquement la plongée** : `concerne_plongee` à vrai

## Contact
Vous pouvez contacter le SNOSAN par message électronique aux adresses :
- `contact@snosan.fr` pour les problématiques métier ;
- `tech@snosan.fr` pour les problématiques techniques.
