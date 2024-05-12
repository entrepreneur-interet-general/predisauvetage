# Changements sur le jeu de données
Les changements de schéma du jeu de données SECMAR sont répertoriés ci-dessous.

### 2024-05

Les données provenant de SeaMIS proviennent désormais exclusivement des exports bruts en JSON mis à disposition et non d'un format intermédiaire. Ceci améliore la qualité des données et permet de maitriser les processus d'intégration.

Les données de SeaMIS et de SECMAR (ancien système) cohabitent au sein de la même base de données.

#### Transition d'un système à l'autre
SeaMIS a été déployé progressivement à partir de 2020 avec une montée en puissance jusqu'à la fin de l'année 2021. Ces deux années ont constitué une phase de rodage et de déploiement et a permis des ajustements du logiciel, des règles de saisie et des valeurs des énumérés. Les données à partir de l'année 2022 sont optimales.

Les différents CROSS sont passés progressivement à SEA MIS. En 2024, seul le CROSS Nouvelle-Calédonie n'est pas équipé de SEAMIS.

#### Modèle de données
Le modèle de données reste peu affecté :
- il n'y a pas de tables supprimées ou ajoutées ;
- il n'y a pas de suppressions ou de renommages de colonnes, quelques colonnes ont été ajoutées.

#### Énumérés
Les modifications importantes concernent les valeurs des énumérés. Certaines valeurs ont disparu, d'autres ont été ajoutées. La page [table de codes](tables_codes.md) détaille succinctement les changements principaux sur ces énumérés. De nombreuses colonnes qui ne comportaient pas de valeurs absentes (`NULL`) auparavant peuvent désormais en contenir suite à des modifications de règles de saisie.

#### Nouvelles colonnes
Ajout de la colonne `systeme_source` dans `operations`. Celle-ci permet de distinguer les données provenant de SECMAR ou de SeaMIS.

### 2022-09-19

Intégration des données provenant de SeaMIS

Un nouveau logiciel de coordination des opérations a été déployé dans les CROSS au début de l'année 2021. Ces données n'étaient préalablement pas intégrées dans cette publication open data, c'est désormais le cas. Le système SeaMIS étant en phase de neuvage, certains contrôles de cohérences statistiques ne sont pas encore présents. Ainsi, certaines valeurs sont absentes dans des colonnes qui n'en comportaient pas précédemment.

L'absence de données va se résorber prochainement, à mesure que les contrôles de cohérences sont mis en place et que les systèmes de traitements des données évoluent.

Toute remarque technique peut être adressée à l'adresse tech@snosan.fr

### 2020-10-05
Ajout de la colonne `avec_clandestins` dans `operations_stats`.

**Pull request**: [#135](https://github.com/entrepreneur-interet-general/predisauvetage/pull/135)

### 2020-04-03
Ajout de la colonne `prefecture_maritime` dans `operations_stats`.

**Pull request**: [#133](https://github.com/entrepreneur-interet-general/predisauvetage/pull/133)

### 2019-09-02
Amélioration de la précision des colonnes de distance à la côte : `distance_cote_metres` et `distance_cote_milles_nautiques` dans `operations_stats`. Certaines petites îles françaises n'étaient pas présentes dans le jeu de données précédemment utilisé pour calculer les distances. Ceci avait pour effet une distance plus élevée que la réalité.

Ce problème est corrigé par l'utilisation du jeu de données [Contours des régions françaises sur OpenStreetMap](https://www.data.gouv.fr/fr/datasets/contours-des-regions-francaises-sur-openstreetmap/) en complètement des données existantes.

### 2018-11-13
Ajout de la colonne `immatriculation_omi` dans `flotteurs` et `nombre_navires_mas_omi` dans `operations_stats`.

**Commits**: [predisauvetage@a0858f](https://github.com/entrepreneur-interet-general/predisauvetage/commit/a0858f7d92c99c1d8f17b105377f740975ce53d5), [predisauvetage@6a6e55](https://github.com/entrepreneur-interet-general/predisauvetage/commit/6a6e557ec366a58e1cbfd26c0a2960e5eacc8677)

### 2018-11-01
Modification de la colonne `concerne_snosan` dans `operations_stats` pour prendre en compte les opérations qui n'ont pas de flotteurs impliqués mais qui sont pour des événements qui s'apparentent à du loisir.

**Issue**: [Issue #123](https://github.com/entrepreneur-interet-general/predisauvetage/issues/123)

### 2018-10-31
Ajout de la colonne `nombre_flotteurs_vehicule_nautique_a_moteur_impliques` dans `operations_stats` qui dénombre le nombre de véhicules nautique à moteur impliqués lors d'une opération.

**Issue**: [Issue #117](https://github.com/entrepreneur-interet-general/predisauvetage/issues/117)

### 2018-10-27
Nous ne prenions pas en compte les frontières de la Nouvelle-Calédonie lors du calcul des distances par rapport à la côte. Ceci est désormais réparé. Ainsi, les distances à la côte pour les interventions coordonnées par le CROSS en Nouvelle-Calédonie sont désormais cohérentes.

**Issue**: [Issue #116](https://github.com/entrepreneur-interet-general/predisauvetage/issues/116)

### 2018-10-22
Ajout de colonnes concernant la marée. On ajoute des informations sur la marée pour les opérations se déroulant sur les façades Atlantique et de la Manche, pour les opérations se déroulant à moins de 20km des côtes. Une trentaine de ports de référence sont utilisés pour avoir les coefficients des marées, jour par jour, depuis 1985.

Ajout des colonnes suivantes :
- `operations_stats.maree_port`
- `operations_stats.maree_coefficient`
- `operations_stats.maree_categorie`

**Commit**: [predisauvetage@d26d698](https://github.com/entrepreneur-interet-general/predisauvetage/commit/d26d698900a92dc4e7aed3f1ec5faf942317b910)

### 2018-10-10
La durée d'engagement des différents moyens est comptabilisée en heures en plus des minutes dans `operations_stats`.

Ajout des colonnes suivantes :
- `operations_stats.duree_engagement_moyens_nautiques_heures`
- `operations_stats.duree_engagement_moyens_terrestres_heures`
- `operations_stats.duree_engagement_moyens_aeriens_heures`

**Commit**: [predisauvetage@57c1d80](https://github.com/entrepreneur-interet-general/predisauvetage/commit/57c1d80d20694715afaf84f5641aaab294693a5d)

### 2018-10-06
- Ajout d'une colonne `operations_stats.est_vacances_scolaires` qui indique si l'opération se déroule pendant les vacances scolaires de la zone A, B ou C
- La plaisance légère est désormais catégorisée comme un loisir nautique (préalablement plaisance)

**Commits**: [predisauvetage@f35d711](https://github.com/entrepreneur-interet-general/predisauvetage/commit/f35d711ca32aca127db3961f2fe1ceb91e16d98e) [predisauvetage@c6e1574](https://github.com/entrepreneur-interet-general/predisauvetage/commit/c6e1574f4f0ac0d1b46970d2e96e4ca776636e0d)

### 2018-10-03
- La colonne `operations_stats.numero_semaine` a été renommée en `operations_stats.annee_semaine`. Elle contient l'année et la semaine, par exemple `2018-10`
- La colonne `operation_stats.semaine` a été ajoutée. Elle contient uniquement le numéro de la semaine, par exemple `10`

**Commits**: [predisauvetage@e85941f](https://github.com/entrepreneur-interet-general/predisauvetage/commit/e85941f836d6a718d1164a36afd119cde8b374e3)

### 2018-09-18
- Correction des fuseaux horaires pour les CROSS de Nouvelle-Calédonie et Polynésie
- La colonne `operations.numero_sitrep` est désormais renseignée pour les opérations avant 2010
- Ajout des colonnes `operations_stats.nombre_personnes_blessees` et `operations_stats.nombre_personnes_blessees_sans_clandestins` dénombrant le nombre de personnes blessées dans chaque opération
- Ajout de la colonne `operations.vent_direction_categorie` indiquant la direction du vent (par exemple : `nord-ouest`)

**Commits**: [predisauvetage@ee04005](https://github.com/entrepreneur-interet-general/predisauvetage/commit/ee04005d8778bcbf2e1566ad5b6010980e5b0dfd) [predisauvetage@9a3a271](https://github.com/entrepreneur-interet-general/predisauvetage/commit/9a3a271188a0001e69b18f617e862e1f5ff91465) [predisauvetage@3d4d21a](https://github.com/entrepreneur-interet-general/predisauvetage/commit/3d4d21a244c36979cee300ee70782e4982e9c919) [predisauvetage@a158bbc](https://github.com/entrepreneur-interet-general/predisauvetage/commit/a158bbcc2ca8da0f9c043de3938667216264045d)

### 2018-08-23
Les fichiers CSV sont désormés triés dans l'ordre croissant selon la valeur de la colonne `operation_id`.

**Commit**: [predisauvetage@699d489](https://github.com/entrepreneur-interet-general/predisauvetage/commit/699d48987f95fc05892f8fdd8d63e42320d677d9)

### 2018-08-08
Table `operations_stats`:
- ajout de la colonne `est_dans_stm`
- ajout de la colonne `nom_stm`
- ajout de la colonne `est_dans_dst`
- ajout de la colonne `nom_dst`

**Commit**: [predisauvetage@765dfdb](https://github.com/entrepreneur-interet-general/predisauvetage/commit/765dfdbebedbac642a0eacd6017312b2803fa5db)

### 2018-07-22
Table `operations_stats`:
- ajout de la colonne `distance_cote_metres`
- ajout de la colonne `distance_cote_milles_nautiques`

**Pull request**: [PR #42](https://github.com/entrepreneur-interet-general/predisauvetage/pull/42)

### 2018-07-10
Table `operations_stats`:
- ajout de la colonne `date`
- ajout de la colonne `jour_semaine`

**Pull request**: [PR #40](https://github.com/entrepreneur-interet-general/predisauvetage/pull/40)

### 2018-07-09
Table `operations_stats`:
- ajout de la colonne `est_jour_ferie`
- ajout de la colonne `est_weekend`
- ajout de la colonne `jour_semaine`
- la colonne `annee` utilise la date de l'alerte en heure locale du CROSS coordinateur et non l'heure UTC
- la colonne `mois` utilise la date de l'alerte en heure locale du CROSS coordinateur et non l'heure UTC
- la colonne `jour` utilise la date de l'alerte en heure locale du CROSS coordinateur et non l'heure UTC

**Pull request**: [PR #38](https://github.com/entrepreneur-interet-general/predisauvetage/pull/38)

### 2018-07-02
Publication initiale
