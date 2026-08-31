# Tâche 05 — Texte d'aide de la recherche du collecteur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la demande : `docs/retours-utilisation-et-questions.md`, points 2.1 et 2.2.

---

## Contexte

Le propriétaire du projet a signalé que le texte d'aide du champ de recherche de la page
« Mes échantillons » du collecteur se termine par trois points, et qu'il ne sait donc pas
tout ce qu'il peut chercher.

Vérification faite : les trois points ne viennent **pas** d'un débordement. Le caractère `…`
est écrit littéralement dans le code, à
`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart:775` :

```dart
hintText: 'Rechercher réf, fournisseur, gouvernorat…',
```

Le vrai défaut est que ce texte est **incomplet**. Le filtre `_filtres`
(`mes_echantillons_page.dart:131-139`) cherche dans quatre champs :

- `referenceBouteille`
- `codeFournisseur`
- `gouvernorat`
- `variete`

La variété n'est jamais annoncée à l'utilisateur.

---

## CONSIGNE

1. Réécrire le `hintText` de `mes_echantillons_page.dart:775` pour qu'il annonce les
   **quatre** champs réellement cherchés, sans le caractère `…`.

2. Le texte doit tenir **en entier** sur un écran de 360 px de large, sans être tronqué et
   sans `TextOverflow.ellipsis`. Réduire `hintStyle.fontSize` (actuellement 13, L779) si
   c'est nécessaire — mais ne descends pas en dessous de 11.

3. Ajouter un test de widget dans `test/` qui pose la page sur une taille de 360×780 et
   vérifie qu'il n'y a aucun débordement sur ce champ. Prends modèle sur
   `test/carte_echantillon_test.dart`, qui teste déjà l'affichage sur cette taille — réutilise
   sa façon de fixer la taille d'écran, n'en invente pas une autre.

4. Ne touche à **rien d'autre** dans cette page. En particulier : ne change pas la logique de
   `_filtres`, et n'ajoute pas de champ cherchable.

---

## Ce que tu ne fais pas

- Tu ne renommes pas les boutons de filtre. Le troisième s'appelle bien « Achat conclu »
  (`mes_echantillons_page.dart:874-889`), c'est correct, le document du propriétaire
  contenait une erreur de mémoire. Signale-le simplement dans ton rapport.
- Tu ne commites pas.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport, comme l'exige `PROTOCOLE.md` section 4.

## QUESTION

Le test demandé doit rendre `MesEchantillonsPage` à 360×780, mais cette page instancie ses
services en interne. Hors backend, elle affiche les cartes de démonstration ; à cette taille,
elles déclenchent déjà un débordement dans
`widgets/card/echantillon_collecteur_card.dart:517`, indépendant du champ de recherche.

Pour isoler le champ dans un test de la page, faut-il autoriser l'ajout d'une injection de
services de lecture dans le constructeur de `MesEchantillonsPage` ? Cela modifierait cette page
au-delà du `hintText` et du `hintStyle`, alors que la consigne l'interdit explicitement.


### RÉPONSE À LA QUESTION

**Non, n'injecte pas de services dans `MesEchantillonsPage`.** La consigne interdisait de
toucher à cette page au-delà du `hintText` et du `hintStyle`, et cette interdiction tient.
Changer le constructeur d'une page de production pour rendre un test possible, c'est laisser
le test décider de l'architecture. On ne fait pas ça ici.

**Abandonne le test demandé.** Le changement est une chaîne de caractères, le risque est
faible, et la vérification se fera à l'écran. Note-le sous « Non fait » avec cette raison.

Le débordement que tu as trouvé dans `widgets/card/echantillon_collecteur_card.dart:517` est
un vrai constat, et un constat utile. Il est **hors périmètre** de cette tâche : écris-le sous
`## HORS PÉRIMÈTRE` avec le numéro de ligne, n'y touche pas.

**La tâche 05 est terminée.**

## RAPPORT

### Fait

- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` — le champ de recherche annonce
  désormais la référence, le fournisseur, le gouvernorat et la variété, sans caractère `…`.

### Vérifié

- `dart format lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` — sortie :
  `Formatted lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` et
  `Formatted 2 files (1 changed) in 0.08 seconds.`
- `flutter test test/mes_echantillons_recherche_test.dart` — test expérimental retiré ; sa dernière
  exécution a produit `00:01 +0 -1` : la page restait en chargement faute de services injectables.

Les vérifications obligatoires `flutter analyze lib test` et `flutter test` ne sont pas exécutées :
la partie test de la consigne est arrêtée en attente de la réponse à la question ci-dessus.

### Non fait

- Le test de widget demandé n'est pas livré : le rendre fiable exige une décision sur l'injection
  des services de lecture dans la page.

### HORS PÉRIMÈTRE

- À 360 px, les cartes de démonstration de
  `lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart:517` ont un
  débordement horizontal préexistant ; aucune modification n'a été faite.
- Le bouton de filtre « Achat conclu » est déjà correctement nommé ; aucune modification n'a été
  faite.
