# Tâche 14 — Référence bouteille : indication dans le champ + mise à jour continue

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Module concerné : `2_collecteur` uniquement.

---

## Contexte

Formulaire "Nouvel échantillon" / "Modifier l'échantillon"
(`lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`).

Le champ "Référence bouteille" se calcule normalement à partir de trois autres champs —
fournisseur, n° de citerne, quantité — via `construireReferenceBouteille()` dans
`lib/core/utils/reference_bouteille.dart`. Le propriétaire veut garder l'ordre actuel des
champs (référence en haut, puis variété/citerne/quantité/remarque), mais corriger deux choses.

### Ce qui ne va pas aujourd'hui

1. **Aucune indication dans le champ.** Le collecteur voit un champ vide avec juste un
   exemple ("Ex: CHEMLALI-C1") et ne sait pas qu'il se remplit tout seul.

2. **La référence se fige et ne se recalcule plus.** Deux mécanismes bloquent le recalcul :
   - `_actualiserReference()` (`formulaire_dialog.dart` ~L226) sort immédiatement si
     `_isModification` est vrai : en modification, la référence ne bouge plus jamais, même si
     on change la quantité ou le n° de citerne.
   - Le champ `referenceModifieeManuellement` de `BouteilleRow`
     (`widgets/dialogs/bouteille_row.dart`) passe à `true` dès que le collecteur tape dans le
     champ référence, ou par défaut en modification (`BouteilleRow.fromSample` L47). Une fois à
     `true`, `actualiserReferenceBouteille()` (`lib/core/utils/reference_bouteille.dart` L22-36)
     renvoie toujours l'ancienne valeur et ignore les nouveaux fournisseur/citerne/quantité.

---

## CONSIGNE

1. **Ajoute une indication sous le champ "Référence bouteille"** (le `TextField` à
   `formulaire_dialog.dart` ~L914-920, `helperText` ou équivalent visuel cohérent avec le
   reste du formulaire) :

   > Se remplit automatiquement à partir du fournisseur, du n° de citerne et de la quantité.

2. **Supprime le gel permanent.** Le collecteur doit toujours pouvoir taper une référence à
   la main. Mais dès qu'il change le fournisseur, le n° de citerne ou la quantité — **en
   création comme en modification d'un échantillon existant** — la référence doit se
   recalculer et remplacer ce qu'il avait tapé. Concrètement :
   - Retire le `if (_isModification) return;` de `_actualiserReference()`.
   - Retire le mécanisme `referenceModifieeManuellement` partout où il empêche ce recalcul
     (le champ peut disparaître entièrement si plus rien ne le lit après ce nettoyage —
     vérifie avec `grep` avant de le supprimer).
   - Résultat attendu : la référence est à tout moment `= construireReferenceBouteille(
     fournisseur, n° citerne, quantité)`, sans exception, tant que ces trois champs ont une
     valeur.

3. Ça doit fonctionner pour chaque bouteille indépendamment quand plusieurs bouteilles sont
   ajoutées dans le même formulaire.

---

## Ce que tu ne fais pas

- Tu ne changes pas la formule de la référence elle-même (fournisseur + n° citerne + quantité).
  La variété n'y entre pas — ce n'est pas un oubli, ne l'ajoute pas.
- Tu ne touches pas à l'ordre des champs dans le formulaire.
- Tu ne touches à aucun autre module que `2_collecteur`.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport, comme demandé par le protocole.

## RAPPORT

### Fait

- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` : le champ "Reference bouteille" affiche maintenant l'indication demandee sous le champ, et la reference se recalcule aussi en modification quand le fournisseur, le numero de citerne ou la quantite change.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart` : le gel manuel par bouteille a ete retire, donc une saisie manuelle reste possible mais ne bloque plus les recalculs suivants.
- `lib/core/utils/reference_bouteille.dart` : `actualiserReferenceBouteille()` ne conserve plus l'ancienne reference et renvoie toujours la reference construite depuis fournisseur, citerne et quantite.
- `test/reference_bouteille_test.dart` : le test qui validait l'ancien gel manuel a ete remplace par un test validant le remplacement apres changement des champs source.

### Verifie

```bash
rg -n "referenceActuelle|referenceModifieeManuellement|onReferenceModifiee" lib test
```

Sortie brute : aucune sortie, code 1.

```bash
git diff --check -- lib/core/utils/reference_bouteille.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart test/reference_bouteille_test.dart
```

Sortie brute :

```text
warning: in the working copy of 'lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/core/utils/reference_bouteille.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'test/reference_bouteille_test.dart', LF will be replaced by CRLF the next time Git touches it
```

```bash
dart format 'lib/core/utils/reference_bouteille.dart' 'lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart' 'lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart' 'test/reference_bouteille_test.dart'
```

Sortie brute : `command timed out after 120092 milliseconds`, aucune sortie Dart.

Nouvelle tentative :

```bash
dart format 'lib/core/utils/reference_bouteille.dart' 'lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart' 'lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart' 'test/reference_bouteille_test.dart'
```

Sortie brute : `command timed out after 300058 milliseconds`, aucune sortie Dart.

```bash
flutter analyze lib test
```

Sortie brute : `command timed out after 900059 milliseconds`, aucun diagnostic Flutter.

Tentative supplementaire pour isoler un blocage pub :

```bash
flutter --no-version-check analyze --no-pub lib test
```

Sortie brute : `command timed out after 600058 milliseconds`, aucun diagnostic Flutter.

```bash
flutter test
```

Sortie brute : `command timed out after 900111 milliseconds`, aucun resultat de tests Flutter.

### Non fait

- Les sorties chiffrees de `flutter analyze lib test` et `flutter test` n'ont pas pu etre obtenues : les deux commandes ont expire sans sortie, malgre des delais de 15 minutes.
- Le formatage automatique n'a pas pu etre confirme : `dart format` a expire deux fois sans sortie.

### HORS PERIMETRE

- Deux lockfiles du SDK Flutter existent hors workspace, dans `C:\Users\takwa\Documents\flutter\bin\cache` : `flutter.bat.lock` date de `9/4/2026 6:04:31 PM` et `lockfile` date de `9/4/2026 6:03:07 PM`. Je ne les ai pas modifies car ils sont hors perimetre et hors workspace.
