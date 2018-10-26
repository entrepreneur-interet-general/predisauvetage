# Redash

Cette page contient des instructions spécifiques à l'interface web de Redash en tant qu'utilisateur.

[[toc]]

## Requêtes
### Créer une requête
Pour créer une nouvelle requête, voici la démarche à suivre :
- Cliquer sur le bouton bleu `Create` dans la barre tout en haut
- Sélectionner `Query`
- Taper votre requête SQL dans la partie droite de l'écran
- Exécuter votre requête à l'aide du bouton bleu `Execute`
- Sauvegarder votre requête
- Nommer votre requête, en haut à gauche, en cliquant sur `New Query`
- Donnez une description détaillée de votre requête en cliquant sur `No description`

::: tip Nommer vos requêtes
Pour retrouver facilement un ensemble de requêtes, nous vous recommandons de suivre une convention de nommage. Vous pouvez par exemple nommer vos requêtes de la façon suivante :
- [Etel] [Annuel] : Top 20 des événements
- [CROSS JBG] - Moyens engagés pour isolés par la marée/envasés
- [Infographie DAM] Part d'opérations entre juin et septembre
:::

::: tip Raccourcis clavier
Vous pouvez enregistrer votre requête à l'aide du raccourci `CTRL + S` et exécuter votre requête avec le raccourci `CTRL + Entrée`.
:::

### Rafraîchir automatiquement une requête
::: warning Rafraîchissement par défaut
Par défaut, les requêtes que vous créez **ne sont pas rafraîchies automatiquement**. Ceci signifie que si vous faites par exemple une requête année par année, votre requête ne prendra pas en compte les nouvelles données tant qu'elle n'aura pas été exécutée à nouveau.
:::

Si votre requête répond à un besoin ponctuel, vous pouvez conserver une absence de rafraîchissement et vous contenter de l'exécuter vous-même en cas de besoin. En revanche, si vous souhaitez incorporer celle-ci sur un tableau de bord, il est souhaitable qu'elle soit rafraîchie régulièrement.

Voici la démarche à suivre :
- Vous rendre sur la page de la requête concernée
- En bas à gauche de la page, changer la valeur de `Refresh schedule`
- Choisir entre un rafraîchissement à la journée ou à la semaine

### Proposer des filtres dans ses requêtes
Au lieu d'imposer une contrainte dans une clause `WHERE` d'une requête, vous pouvez laisser la possibilité à l'utilisateur de choisir un ou plusieurs paramètres de votre requête - par exemple le CROSS et l'année. Si plusieurs de vos requêtes possèdent des filtres du même nom, ces filtres peuvent ensuite être utilisés globalement au sein d'un tableau de bord : en changeant la valeur d'un filtre d'une année, toutes les visualisations avec un filtre sur l'année changeront d'année en même temps.

La définition d'un filtre se fait par le **renommage de la colonne en suivant une convention de nommage**. Voici un exemple de requête définissant des filtres :

```sql
SELECT
  "stats"."annee",
  "op"."cross" as "cross::filter", -- ::filter propose un filtre permettant un choix unique
  "op"."type_operation" as "type_operation::multi-filter", -- ::multi-filter propose un filtre offrant plusieurs choix
  count("op"."operation_id") as "nb_operations"
FROM "operations" as "op"
JOIN "operations_stats" as "stats" on "stats"."operation_id" = "op"."operation_id"
WHERE "stats"."annee" >= 2010
GROUP BY 1, 2, 3
ORDER BY 2 ASC -- Le tri ascendant par CROSS permet d'avoir les CROSS dans l'ordre alphabétique dans le filtre
```

Vous obtenez alors le résultat suivant : vous pouvez choisir une valeur de CROSS et une ou plusieurs valeurs possibles pour le type d'opération (SAR / MAS / DIV / SUR).

![Résultat de la requête avec des filtres](https://i.imgur.com/izuytNo.png)

### Naviguer parmi les requêtes existantes
#### Voir toutes les requêtes
Vous pouvez retrouver la liste complète des requêtes déjà publiées en cliquant sur le bouton `Queries` dans la barre de menu tout en haut de chaque page. Il est possible de chercher une requête par mot-clé depuis l'onglet `Search`.

#### Voir ses requêtes
Vous pouvez retrouver la liste complète de vos requêtes publiées en cliquant sur le bouton `Queries` dans la barre de menu tout en haut de chaque page puis choisir l'onglet `My Queries`.

#### Consulter la requête source d'une visualisation
Pour retrouver la requête source d'une visualisation que vous voyez depuis un tableau de bord, vous pouvez passer votre souris sur la visualisation, cliquer sur les points bleus en haut à droite et choisir le menu `View Query`.

### Reprendre une requête existante
Il est parfois souhaitable de reprendre une requête existante pour l'adapter pour ses besoins ou comme base de travail. Redash facilite ce besoin en proposant de reprendre la requête SQL et les visualisations d'une requête existante. Voyez ceci comme un copier coller, plus efficace.

La démarche à suivre est la suivante :
- Vous rendre sur la requête sur laquelle vous souhaitez vous baser
- En haut à droite de la page, cliquer sur `...` et choisir le menu `Fork`
- Renommer votre requête, adapter la requête SQL et les visualisations

::: warning Rafraîchissement de la requête copiée
Attention, par défaut, si la requête source avait un rafraîchissement défini, votre nouvelle requête ne sera pas rafraîchie par défaut. Pensez à la rafraîchir automatiquement si nécessaire.
:::

## Visualisations
### Créer une visualisation graphique
Instructions en cours de rédaction.

### Créer un compteur
Instructions en cours de rédaction.

### Créer un tableau croisé dynamique
Instructions en cours de rédaction.


## Tableaux de bord
### Créer un tableau de bord
Pour créer un tableau de bord, il faut cliquer sur le bouton bleu `Create` dans la barre tout en haut, puis sélectionner `Dashboard`.

On demande ensuite de nommer votre tableau de bord.

::: tip Regrouper des tableaux de bord
Vous pouvez regrouper plusieurs tableaux de bord à l'aide d'un hashtag en début de nom. Ce hashtag ne doit pas contenir d'espaces, seulement des caractères alphanumériques.
:::

Des exemples possibles de noms de tableaux de bord. Notez le hashtag au début du nom du tableau de bord :
- #SNOSAN Suivi de la saison estivale
- #CROSS-A Activité dans les STM et DST
- #CROSS-JBG Isolement par la marée
- #CROSS-AG Suivi des navires de pêches
- #SM1 Bilan annuel des CROSS

### Ajouter des visualisations à un tableau de bord
Après avoir créé des visualisations et un tableau de bord, vous pouvez les ajouter à un tableau de bord en suivant la démarche suivante :

- Vous rendre sur le tableau de bord en question
- Cliquer sur le bouton, en haut à droite, `...`
- Choisir le menu `Edit`
- Une barre blanche apparaît en bas de l'écran, cliquer le bouton le `Add Widget`
- Taper le nom de la requête qui contient les visualisations souhaitées
- Choisir la visualisation désirée dans le menu déroulant

Il est ensuite possible de réorganiser et d'adapter la taille de chaque visualisation à l'aide de la souris.

Dès que vous obtenez un résultat satisfaisant, vous pouvez enregistrer le travail à l'aide du bouton bleu `Apply Changes`, en haut à droite.

### Ajouter du texte à un tableau de bord
Il est possible d'ajouter du texte et du contenu média à un tableau de bord. Les cas d'utilisation classiques sont par exemple :
- l'ajout de texte explicatif ;
- la séparation d'un tableau de bord en plusieurs parties logiques ;
- l'inclusion d'images ;
- le référencement de liens externes.

Pour ajouter du texte à un tableau de bord, voici la démarche à suivre :
- Vous rendre sur le tableau de bord en question
- Cliquer sur le bouton, en haut à droite, `...`
- Choisir le menu `Edit`
- Une barre blanche apparaît en bas de l'écran, cliquer le bouton le `Add Widget`
- Sélectionner l'onglet `Text Box`
- Renseigner votre texte
- Cliquer sur `Add to dashboard`

Il est ensuite possible de réorganiser et d'adapter la taille du bloc de texte à l'aide de la souris.

#### Avoir des titres
Pour avoir des titres de différents niveaux, vous pouvez utiliser la syntaxe suivante :

```markdown
# Titre de 1er niveau (le plus gros)
Un paragraphe.
## Titre de 2ème niveau
Du texte.
### Titre de 3ème niveau (le moins gros)
Toujours plus de texte.
```

#### Mettre du texte en gras
Vous pouvez mettre du texte en gras à l'aide de la syntaxe suivante :

```markdown
**Ceci est en gras**. Mais là non.
```

#### Mettre du texte en italique
Vous pouvez mettre du texte en italique à l'aide de la syntaxe suivante :

```markdown
*Ceci est en gras*. Mais là non.
```

#### Faire un lien vers une page web
Vous pouvez faire un lien vers une page web à l'aide de la syntaxe suivante :

```markdown
Voici [un lien vers une page](https://example.com/page).
```

#### Inclure une image
Vous pouvez inclure une image déjà hébergée sur Internet à l'aide de la syntaxe suivante :

```markdown
![Description de l'image](https://example.com/lien/vers/image.jpg).
```

Si votre image n'est pas encore sur Internet, vous pouvez utiliser un service proposant de mettre en ligne votre image et copier-coller l'adresse de votre image. Vous pouvez par exemple utiliser [imgur.com](https://imgur.com/upload).

### Collaborer sur un tableau de bord
Par défaut, après avoir créé un tableau de bord, seule la personne qui l'a créé peut modifier l'agencement et les visualisations du tableau de bord. Vous pouvez faire en sorte que plusieurs personnes aient ces droits en suivant la démarche suivante :

- Vous rendre sur le tableau de bord en question
- Cliquer sur le bouton, en haut à droite, `...`
- Choisir le menu `Manage Permissions`
- Renseigner le nom de la personne qui doit pouvoir éditer le tableau de bord (vous pouvez également supprimer d'anciens collaborateurs)
- Fermer la fenêtre à l'aide de la croix en haut à droite

### Partager un tableau de bord
Par défaut, tout tableau de bord créé est visible par les autres utilisateurs de Redash ayant un compte et étant connectés. Toutefois, il est parfois souhaitable de partager un tableau de bord à quelqu'un n'ayant pas de compte Redash et dont il n'est pas souhaitable que la personne possède un compte (puisse voir ou éditer des requêtes, naviguer à sa guise etc).

Ainsi, Redash propose la possibilité de créer un lien unique, que vous pouvez partager et qui donne accès uniquement à un tableau de bord précis. Ce lien permet ainsi de consulter ce tableau de bord spécifique, sans avoir besoin de compte et ne donne pas d'autres privilèges sur Redash.

La démarche à suivre est la suivante :
- Vous rendre sur le tableau de bord en question
- Sélectionner la case `Allow public access (using a secret URL).`
- Copier-coller le lien 
- Fermer la fenêtre
- Le partager avec les personnes souhaitées

### Mettre fin au partage d'un tableau de bord
Si vous avez partagé un tableau de bord à l'aide d'un lien unique et que vous souhaitez qu'il ne soit plus possible d'y accéder via ce lien unique, vous pouvez désactiver ce partage en suivant la démarche suivante :

- Vous rendre sur le tableau de bord en question
- Cliquer sur l'icône de partage, avant dernière icône en haut à droite de la page
- Décocher la case `Allow public access (using a secret URL).`
- Fermer la fenêtre
