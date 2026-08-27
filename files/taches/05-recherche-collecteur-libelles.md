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
