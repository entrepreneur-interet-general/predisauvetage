# Signification des termes employés

## Classification des opérations
Cette section explicite la colonne `operations.type_operation`.

La classification d'une opération n'est pas un pronostic sur l'issue de l'évènement mais son rattachement à une catégorie d'opérations. Elle ne peut être réalisée qu'à la clôture de l'évènement.

Les opérations sont classées de la manière suivante, par ordre de priorité décroissant :
- **SAR** : Recherche et sauvetage de la vie humaine
    - Les personnes impliquées sur le domaine maritime sont face à un danger vital, grave, imminent ou probable ;
    - L'intégrité du flotteur est mise en cause avec une présence humaine à bord ;
    - Les personnes sur le domaine maritime nécessitent une prise en charge ou une consultation médicale ;
    - Une opération de recherche a été menée et coordonnée avec ou sans résultat.
- **MAS** : Opération d'assistance aux navires
    - Les personnes sont saines et sauves et le flotteur est intègre. Une
    demande d'assistance a été formulée dans laquelle le CROSS ou le
    MRCC est actif ;
    - L'intégrité du flotteur est mise en cause sans présence humaine
    confirmée à bord ;
    - Le navire a subi une avarie et procède aux réparations ;
    - Le navire fait l'objet d'une opération de maintenance en mer.
- **SUR** : Mission de sureté des navire
    - Le navire fait l'objet d'une alerte SSAS ou de sûreté ;
    - Le navire fait l'objet d'acte de piraterie, de mutinerie ou de terrorisme ;
    - Le navire cause ou fait l'objet de désordres occasionnant un trouble à l'ordre public.
- **DIV** : Autres évènements générant une activité
Autres évènement générant une activité non contenue dans les classifications ci-dessus.

## Cas particuliers dans les événements
Cette section explicite la colonne `operations.evenement`.

### Fausses alertes
Le cas des fausses alertes doit être abordé au sens premier du terme. Une fausse alerte est une fraude d'urgence, causant une panique inutile et/ou l'utilisation de ressources dans un endroit qui ne nécessite aucune aide. Le centre est capable de prouver par recoupement d'information, par enquête ou contact avec les personnes impliquées que l'alerte initiale était infondée voire déclenchée abusivement.

Une fausse alerte est un évènement clôturé pour lequel il n'y a aucun doute. Une fausse alerte implique des bilans tant sur le flotteur que sur les personnes impliquées.

### Incertitude
L'incertitude est un évènement lorsque le témoignage est cohérent et que l'opération est justifiée au regard des éléments recueillis par le centre. L'opération ne permet cependant pas de retrouver le navire ou l'équipage, l'issue est impossible à vérifier et demeure indéterminée.

Aucun élément ne permet d'établir un scénario probable de fin d'opération, mais pour clôturer une opération, il faut être en mesure de lui attribuer un cas. L'hypothèse de principe pour une issue indéterminée après une opération de recherche et une phase d'enquête est qu'aucun élément ne permet d'affirmer qu'une fortune de mer s'est produite. Par conséquent, le flotteur et les personnes ont, pour la statistique, poursuivi leur route et rejoint la côte par leurs propres moyens. Le navire n'est pas perdu et les personnes n'ont pas disparues.

Ces cas ne sont pas des fausses alertes mais des évènements dont la classification précise est rendue difficile.

Il est possible de modifier une opération pour refléter les changements à la suite d'éléments nouveaux parvenus au centre.

## Autorité
Cette section explicite les colonnes `operations.autorite` et `operations.sous_autorite`.

L'autorité est le responsable juridique de la conduite des opérations. Ce n'est pas le coordonnateur ni l'acteur. Le centre qui reçoit une alerte est responsable de la coordination s'il ne parvient pas à retransmettre l'alerte au centre territorialement compétent.

Le centre qui coordonne une opération dans une zone étrangère parce qu'il n'a pas pu entrer en contact avec l'autorité dont la zone relève, coordonne sous couvert de l'autorité responsable de sa propre zone de compétence.

Le centre qui reçoit une demande d'aide de la part d'une autorité étrangère pour agir dans une zone étrangère, agît sous la responsabilité de l'autorité étrangère.

## Zone de responsabilité
Cette section explicite la colonne `operations.zone_responsabilite`.

Afin d'éviter un nombre d'erreur dans le choix des zones, les choix ont été réduits et doivent être interprétés comme suit.

- **Plage et 300 mètres** : cette zone inclut également l'estran découvert pour les opérations coordonnant principalement des moyens de secours terrestres 
- **Port et accès** : cette zone inclut les chenaux, zones d'attente portuaires à l'intérieur et à l'extérieur des limites administratives du port.
- **Eaux territoriales** : cette zone inclut les eaux intérieures et la mer territoriale à l'exclusion des zones précitées.
- **Responsabilité française** : cette zone inclut toutes les régions de recherche et de sauvetage attribuées des CROSS et MRCC français à l'exclusion des zones précitées. La notion de responsabilité française s'étend aux navires battant pavillon français dans les zones où aucune région de recherche et de sauvetage attribuée n'est déclarée et pour lesquelles aucun centre ne coordonnent l'opération.
- **Responsabilité étrangère** : cette catégorie est attribuées aux autres cas.

## Catégorie qui alerte
Cette section explicite les colonnes `operations.qui_alerte` et `operations.categorie_qui_alerte`.

Cette catégorie représente les personnes, navires, centres ou organismes qui donnent ou relaient l'alerte au premier CROSS ou MRCC coordonnateur.

## Moyens de sauvetage
Cette section explicite la table des `moyens`.

Les moyens de sauvetage sont les unités privées, publics ou d'organisme agrées de toute nature, qui interviennent dans l'opération. Leur participation peut être spontanée ou ordonnée par le centre coordonnateur. Ils agissent sous son autorité pour toutes opérations de recherche et de sauvetage.

Le cas particulier du plongeur n'est utilisé que pour les demandes d'intervention dans le cadre d'un travail subaquatique. Il ne s'agît pas du plongeur embarqué dans un aéronefs au titre de l'équipage d'intervention.

## Catégories et types de flotteur impliqués
Cette section explicite la table des `flotteurs`.

Le type de flotteur répond dans un premier temps à la norme de construction dont il relève, puis à l'utilisation qui en est faite.

Exemple :
- Un navire déclaré à usage professionnel pour la pêche est considéré comme un navire de pêche, même s'il est issu d'une série de plaisance.
- Un navire qui réalise des activités illicites, relève de la catégorie des navires professionnels s'il est déclaré comme tel, sinon c'est un navire de plaisance.

## Résultat sur un flotteur
Cette section explicite la colonne `flotteurs.resultat_flotteur`.

Le résultat sur le flotteur représente l'état du flotteur à la clôture de l'opération.

- **Difficulté surmontée seul**
    - Le flotteur n'a pas eu recours à une assistance extérieure et reprend son voyage.
    - Le flotteur n'a pas eu recours à une assistance extérieure et rejoint la terre.
- **Non assisté, cas de fausse alerte**
    - Le flotteur est impliqué dans une fausse alerte
- **Échoué**
- **Perdu / coulé**
    - Le flotteur n'a pas été sauvé ou retrouvé.
- **Remorqué**
- **Retrouvé après recherche**
    - La position du flotteur était inconnue. Il a fait l'objet d'une opération de recherche par un moyen de sauvetage. Cet élément est primordial. Ce résultat est privilégié même si le navire retrouvé a été remorqué ou a surmonté lui-même ses difficultés.
- **Assisté**
    - La notion d'assistance dénote une aide extérieure directe au flotteur. Une escorte est une assistance.

## Résultat sur les personnes
Cette section explicite la table des `resultats_humain`.

Le résultat sur les personnes est précisé à la clôture de l'opération.

Par contre, pour ce qui concerne les personnes disparues une vigilance particulière est adoptée. À la découverte d'un corps, le CROSS ou le MRCC met tout en œuvre pour obtenir l'identification de la personne. L'objectif est de ne pas additionner aux disparus les personnes découvertes décédées. En cas de corrélation entre une disparition et la découverte d'un corps, il est possible de revenir sur une opération a posteriori en invalidant en venant la corriger. La donnée statistique sera représentative de la réalité.

La découverte d'un corps fait l'objet d'un enregistrement, soit initial avec un numéro d'opération et une classification en DIV si le corps découvert ne peut être lié à une opération, soit d'une modification à l'opération relative à la disparition.

Les résultats possibles sont :
- **Personne tirée d'affaire seule**
    - La personne n'a pas eu besoin d'aide extérieure pour surmonter sa difficulté.
- **Personne retrouvée**
    - La personne est retrouvée vivante. Sa position était inconnue. Elle a fait l'objet d'une opération de recherche par un moyen de sauvetage. Cet élément est primordial. Ce résultat est privilégié même si la personne retrouvé a fait l'objet d'un secours médical.
- **Personne secourue**
    - La personne a fait l'objet d'une opération SAR ou SUR.
- **Personne décédée**
- **Personne disparue**
- **Personne assistée**
    - La personne a fait l'objet d'une opération MAS, DIV ou SUR.
- **Personne impliquée dans une fausse alerte**
    - La personne était potentiellement en danger avant que la situation soit confirmée.

Le résultat **Personne blessée** n'est utilisé que pour les personnes qui ont été accidentellement blessées qu'elles soient vivantes, décédées ou disparues. Une personne malade n'entre pas dans cette catégorie. La prise en charge médicale d'une personne malade donne un bilan de : 1 secouru / 0 blessé.

## Catégories de personne
Cette section explicite la colonne `resultats_humain.categorie_personne`.

- **Commerce français** : marin de nationalité française immatriculé à l'Établissement National des Invalides de la Marine (ENIM) ;
- **Plaisancier français** : personne de nationalité française à bord d'un navire de plaisance, français ou étranger ;
- **Pêcheur français** : marin de nationalité française immatriculé à l'Établissement National des Invalides de la Marine (ENIM) ;
- **Marin étranger** : marin professionnel étranger toutes activités confondues ;
- **Clandestin** : personne en situation irrégulière ou ne figurant pas sur la liste des personnes embarquées ;
- **Autre** : toute personne autre que celles déjà mentionnées.
