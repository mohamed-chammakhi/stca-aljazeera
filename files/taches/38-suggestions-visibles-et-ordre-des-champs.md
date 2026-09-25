# Tâche 38 — Suggestions visibles + nouvel ordre des champs d'une bouteille

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Flutter uniquement. Aucun changement backend.

## Pourquoi

Sur son téléphone, la propriétaire ne voit **jamais** la liste de suggestions pour le
fournisseur et la variété, ni à l'ajout ni à la modification d'un échantillon.
Vérifié par Claude : les données arrivent bien (`GET /api/fournisseurs/` → 200 dans le
journal du serveur). Le problème est l'affichage, dans
`lib/core/widgets/champ_autocomplete.dart` :

1. La liste ne s'ouvre qu'après avoir tapé une lettre (`suggest('')` renvoie `[]`, et
   `_rechercher` n'est appelé que dans `_onTexteChange`). Quand on touche le champ, rien
   n'apparaît.
2. La liste s'affiche **sous** le champ, dans le formulaire qui défile. Sur un téléphone,
   le clavier la recouvre.
3. La variété est dans une demi-colonne (`Row` avec le n° citerne), donc la liste est
   très étroite.

Elle veut que ça marche « comme Google » : on touche le champ, les valeurs déjà
utilisées apparaissent, on tape pour filtrer, on choisit ou on continue à taper.

## Partie A — `ChampAutocomplete` (un seul fichier partagé)

1. **Ouvrir à la prise de focus** : quand le champ reçoit le focus, lance `_rechercher()`
   tout de suite, même si le texte est vide.
2. **Texte vide = les valeurs connues** : dans `FournisseurService.suggest` et
   `VarieteService.suggest`, une saisie vide renvoie les `limite` premières valeurs
   (ordre alphabétique déjà en place) au lieu de `[]`. Mets à jour les commentaires qui
   disent le contraire (« An empty query returns nothing… »).
   - En modification, le champ est déjà rempli : on affiche les valeurs qui
     correspondent au texte, sauf la valeur exactement identique (règle déjà en place
     pour la variété ; applique la même au fournisseur).
3. **Visible au-dessus du clavier** : quand la liste s'ouvre, fais défiler le formulaire
   pour que le champ **et** sa liste soient visibles. Utilise une `GlobalKey` sur le bloc
   (champ + liste) et `Scrollable.ensureVisible(..., alignment: 0.1, duration: 200 ms)`
   après le `setState` (dans un `WidgetsBinding.instance.addPostFrameCallback`). Ne fais
   rien s'il n'y a pas de `Scrollable` parent.
4. **Fermer** : la liste se ferme quand on choisit une valeur ou quand le champ perd le
   focus (déjà le cas, garde-le).
5. **Ne touche pas** à la règle du projet : la saisie reste libre, on peut toujours taper
   une valeur nouvelle.

## Partie B — Nouvel ordre des champs d'une bouteille

Dans les **trois** formulaires d'ajout / modification d'échantillon :

```
lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart
lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
```

L'ordre actuel dans chaque carte bouteille est :
Référence bouteille → [Variété | N° citerne] sur une ligne → Quantité estimée → Remarque.

Le nouvel ordre voulu est :

1. Référence bouteille
2. N° citerne
3. Quantité estimée
4. Variété d'olive — **sur toute la largeur**, plus dans une demi-colonne
5. Remarque (inchangée, à la fin)

- N° citerne et Quantité estimée : mets-les **côte à côte** dans le `Row` (la moitié de
  la largeur chacun), puisque ce sont deux champs courts. La variété prend une ligne
  entière pour que la liste de suggestions soit lisible.
- Garde les mêmes contrôleurs, les mêmes `onChanged`
  (`onDonneesReferenceChangees`), les mêmes `key`, textes, indications et formats.
  Seul l'ordre et la disposition changent.
- Si un des trois fichiers a une structure différente (par exemple pas de n° citerne),
  ne devine pas : écris-le sous `## QUESTION` et fais les autres.

## Partie C — Tests

Ajoute `test/champ_autocomplete_test.dart` :
- toucher le champ vide affiche des suggestions (service fictif passé dans `chercher`) ;
- taper filtre la liste ;
- choisir une suggestion remplit le champ et ferme la liste ;
- on peut garder un texte qui n'est dans aucune suggestion.

Si un test existant vérifie qu'une saisie vide ne renvoie rien, mets-le à jour avec la
nouvelle règle et signale-le dans ton rapport.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera
`flutter analyze lib test` et `flutter test` (attendu : 0 erreur, 0 échec).

## RAPPORT

### Fait

- `lib/core/widgets/champ_autocomplete.dart` — toucher un champ d'autocomplétion lance maintenant les suggestions immédiatement, y compris champ vide, et le formulaire se repositionne pour garder le champ et la liste visibles au-dessus du clavier quand un parent scrollable existe.
- `lib/core/services/fournisseur_service.dart` — une recherche vide renvoie maintenant les premiers fournisseurs connus, et la valeur déjà tapée exactement n'est plus reproposée.
- `lib/core/services/variete_service.dart` — une recherche vide renvoie maintenant les premières variétés connues.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` — dans chaque carte bouteille, `N° citerne` et `Quantité estimée` sont côte à côte, puis `Variété d'olive` occupe toute la largeur avant la remarque.
- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` — dans chaque carte bouteille, `N° citerne` et `Quantité estimée` sont côte à côte, puis `Variété d'olive` occupe toute la largeur.
- `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` — dans chaque carte bouteille, `N° citerne` et `Quantité estimée` sont côte à côte, puis `Variété d'olive` occupe toute la largeur.
- `test/champ_autocomplete_test.dart` — ajout des tests demandés pour l'ouverture au focus, le filtrage, la sélection et la saisie libre.

### Vérifié

```bash
dart format lib/core/widgets/champ_autocomplete.dart lib/core/services/fournisseur_service.dart lib/core/services/variete_service.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart test/champ_autocomplete_test.dart
```

Sortie : échec par timeout après 120052 ms. Le processus `dart` restant a été arrêté ensuite. Aucun résultat de formatage réussi n'est revendiqué.

```bash
git diff --check
```

Sortie : exit code 0. Aucune erreur d'espaces invalides ; seulement 6 avertissements `LF will be replaced by CRLF` pour les fichiers Dart modifiés.

```bash
rg -n "empty query returns nothing|An empty query returns nothing|query returns nothing|saisie vide|requête vide" lib test
```

Sortie : exit code 1, aucun résultat. Aucun test/commentaire existant à mettre à jour pour l'ancienne règle "saisie vide = rien".

`flutter analyze lib test` et `flutter test` non exécutés, conformément à la consigne de la tâche : "Ton sandbox ne peut pas lancer Flutter : n'essaie pas."

### Non fait

- Aucun lancement Flutter. Claude doit lancer `flutter analyze lib test` et `flutter test`.
- Aucun ajout de champ `Remarque` par bouteille dans les formulaires dégustateur et chef : ces deux fichiers ont seulement une remarque globale existante, qui a été laissée inchangée.

### HORS PÉRIMÈTRE

- L'arbre de travail contenait déjà des éléments hors tâche avant modification, notamment `files/taches/FILE-ATTENTE.md`, `backend_new/backup_propre.json`, `backend_new/media/` et plusieurs fichiers `files/taches/codex_*.txt`. Ils n'ont pas été modifiés.
