# Site web SNOSAN

Cette page contient des instructions spécifiques au backend du site web SNOSAN accessible à l'adresse [www.snosan.fr/backend](https://www.snosan.fr/backend)

[[toc]]

## Modifier la structure du site
La structure des onglets en haut du site web SNOSAN n'est pas figée. Vous avez la possibilité de la modifier. 

![Onglets](http://image.noelshack.com/fichiers/2018/45/4/1541702756-capture-d-ecran-2018-11-08-a-19-45-44.png)

### Ajouter un onglet sur le site
Voici la marche à suivre pour ajouter un nouvel onglet :
- Cliquez en haut sur `Pages`
- Cliquez sur `+ Add`
- Nommez votre onglet
- Cliquez sur `Save`en dessous du nom

### Ajouter une sous-catégorie à un onglet
Vous pouvez également ajouter plusieurs sous-catégories pour vos onglets. Pour cela, il suffit de :
- Passez votre souris sur l'onglet dans lequel vous souhaitez ajouter votre catégorie
- Cliquez ensuite sur `+ Add subpage`
- Nommez votre catégorie
- Cliquez sur `Save` en dessous du nom

### Déplacer un onglet
Pour changer l'ordre des onglets :
- Passez votre souris sur l'onglet que vous souhaitez déplacer
- Cliquez sur les 3 traits à droite et déplacez votre onglet à la position souhaitée en maintenant votre clique

::: tip Ordre des onglets
Déplacer l'onglet vers le haut le déplacera vers la gauche sur la page du site web. 
:::

### Supprimer un onglet ou une sous-catégorie
- Cochez l'onglet à supprimer 
- Cliquez sur l'icône de la poubelle en haut de la page

### Cacher temporairement un onglet
Pour qu'un onglet n'apparaisse plus sur le site pendant une certaine période :
- Cliquez sur l'onglet concerné
- Cochez `Hidden`et `Hide in Navigation`
- Cliquez sur `Save`

L'onglet n’apparaîtra plus sur le site, vous pouvez vérifier en allant sur le site dans une fenêtre de navigation privée.
Pour réafficher votre onglet, il suffit de décochez les deux cases. 

## Articles
Un des objectifs du SNOSAN est de publier régulièrement des articles dans la section Actualités. 

### Ajouter un nouvel article
Voici la procédure pour créer un nouvel article :
- Cliquez sur `Blog`en haut
- Cliquez sur `+ New post`
- Nommez votre article 
- Rédigez le contenu de l'article 
- Cliquez sur `Save`

Vous retrouvez ensuite tous vos articles en cliquant sur `Post`.

### Publier un article
Une fois votre article enregistré, cela ne signifie pas qu'il est publié sur le site web. Pour le publier, les étapes suivantes sont nécessaires :
- Cliquez sur votre article
- Cliquez sur `Manage`
- Cochez `Published`
- Choisir une date de publication
- Dans Exerpt, définissez un titre pour votre article 
- Cliquez en dessous de Feature images et choisir une photo à associer à l'article 
- Cliquez sur `Save`

::: tip Conseils pour la rédaction d'un article
- Vérifier que chaque graphique possède un titre pertinent, une légende et des titres d'axes
- Chaque graphique présenté doit servir à appuyer le propos et être commenté
- La source des informations qui ne proviennent pas des données SECMAR doit être citée explicitement
- L'article doit raconter une histoire et comporter une conclusion
- Il est possible de citer d'autres articles en ajoutant un lien vers l'article mais sans copié-collé le contenu de l'article
:::

### Supprimer un article
- Allez dans `Post`
- Cochez l'article à supprimer 
- Cliquez sur `Delete selected`

Cependant, il est conseiller de dépublier un article en décochant la case `Published` plutôt que de le supprimer.  

## Écrire du contenu dans un onglet ou sur un article
Vous pouvez écrire du contenu directement dans les pages des onglets ou sur les articles. Il y a ensuite plusieurs manières de mettre en forme le contenu :
- Utiliser la barre de menu de l'éditeur de texte 
![Barre de menu de l'éditeur de texte des onglets](http://image.noelshack.com/fichiers/2018/45/4/1541699497-capture-d-ecran-2018-11-08-a-18-51-20.png) 
- Cliquer sur `</>` dans la barre de menu de l'onglet pour écrire le contenu directement en HTML/CSS
- Écrire le contenu directement en Markdown ou HTML/CSS dans les articles

### Ajouter des images ou des liens
#### Avec le menu
Vous pouvez ajouter des images ou des liens en cliquant sur les icônes correspondantes dans la barre de menu
![](http://image.noelshack.com/fichiers/2018/45/4/1541699497-capture-d-ecran-2018-11-08-a-18-51-20.png) 
#### En Markdown
##### Faire un lien vers une page web
Vous pouvez faire un lien vers une page web à l'aide de la syntaxe suivante :

```markdown
Voici [un lien vers une page](https://example.com/page).
```

##### Inclure une image
Vous pouvez inclure une image déjà hébergée sur Internet à l'aide de la syntaxe suivante :

```markdown
![Description de l'image](https://example.com/lien/vers/image.jpg).
```

Si votre image n'est pas encore sur Internet, vous pouvez utiliser un service proposant de mettre en ligne votre image et copier-coller l'adresse de votre image. Vous pouvez par exemple utiliser [imgur.com](https://imgur.com/upload).

### Ajouter des graphiques Redash
Pour ajouter des graphiques Redash sur le site (dans les articles ou dans l'accidentalité en direct), vous avez besoin d'ajouter des iframes en HTML dans votre contenu. Pour cela :
- Allez sur la requête Redash qui contient votre graphique
- Sélectionnez le graphique
- Cliquez sur `< > Embed`
- Copiez ce qui s'affiche en rouge
![iframe](http://image.noelshack.com/fichiers/2018/45/4/1541701765-capture-d-ecran-2018-11-08-a-19-28-54.png) 
- Collez directement dans les articles ou collez dans la page d'un onglet quand vous êtes en vue "code".

::: tip Améliorer le visuel de l'iframe
- Vous pouvez ajuster la largeur de votre iframe en modifiant la valeur du paramètre width="720"  (un chiffre plus haut signifie un graphique plus large)
- Vous pouvez ajuster la hauteur de votre iframe en modifiant la valeur du paramètre  height="530" un chiffre plus haut signifie un graphique plus haut)
- Ajoutez à la suite des autres le paramètre scrolling="no" permet d'avoir le graphique en entier sans défilement 
- Ajoutez à la suite des autres le paramètre frameborder="0" permet de retirer la bordure noire extérieure

```html
<iframe src="https://redash.snosan.fr/embed/query/124/visualization/279?api_key=ZBP1RgyvtHgOcwkbiJyFDJx6PjSEoFLsqrwhxT3z" width="500" height="600" scrolling="no" frameborder="0"></iframe>
```
:::
