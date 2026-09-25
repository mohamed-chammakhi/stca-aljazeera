# Tâche 39 — Référence bouteille claire, plus de fenêtre « fournisseurs proches »

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Flutter uniquement. Aucun changement backend.

Fichiers concernés (les trois formulaires d'ajout / modification d'échantillon) :
```
lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart
lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
```

## Ce que la propriétaire a constaté

En modifiant un échantillon du fournisseur « omarr » :
1. À chaque enregistrement, la fenêtre « Des fournisseurs proches existent déjà » s'ouvre
   (« omar » / « omarr »). En modification, `_fournisseurChoisi` est `null` au départ,
   donc `_verifierFournisseur` refait la vérification à chaque fois ; et
   `findNearDuplicates` compte aussi le fournisseur **identique** comme « proche ».
2. En touchant « omarr » dans cette fenêtre, la référence devient `F-0003_4h_14239T` :
   `_fournisseurPourReference` prend `codeFournisseur` (le code interne donné par le
   serveur) dès qu'un fournisseur est choisi, alors qu'il prend le **nom** tapé sinon.
   Et `_actualiserToutesLesReferences()` écrase la référence qu'elle venait de modifier.
   Elle a cru travailler sur des données fictives.

## Décisions de la propriétaire

### A — Supprimer la fenêtre « fournisseurs proches »

La liste de suggestions (tâche 38) s'ouvre déjà quand on touche le champ fournisseur :
si la personne n'a rien choisi, c'est volontaire. Donc :
- supprime l'appel à `_verifierFournisseur()` dans `_save()` et la méthode elle-même,
  dans les trois formulaires ;
- si `DialogDoublonFournisseur` (`lib/core/widgets/dialog_doublon_fournisseur.dart`) et
  `FournisseurService.findNearDuplicates` ne sont plus utilisés nulle part dans `lib/`,
  supprime-les, ainsi que leurs tests. Vérifie avec `grep` avant de supprimer. S'ils sont
  encore utilisés ailleurs, garde-les et dis où dans ton rapport.

### B — La référence utilise le NOM du fournisseur, jamais le code interne

`_fournisseurPourReference` renvoie toujours le texte du champ fournisseur
(`_codeFournisseurCtrl.text`), qu'un fournisseur ait été choisi dans les suggestions ou
non. Plus jamais `codeFournisseur`. Exemple : `omarr_4h_14239T`.

### C — Règle de remplissage automatique (inchangée, à garder telle quelle)

- La référence se remplit toute seule à partir de fournisseur + n° citerne + quantité.
- La personne peut l'effacer et écrire la sienne.
- Si elle change ensuite le fournisseur, la citerne ou la quantité, la référence
  automatique revient (c'est voulu : pour garder sa propre référence, on l'écrit en
  dernier).

### D — En MODIFICATION seulement : demander avant de changer la référence

Au moment d'enregistrer une **modification** (`widget.echantillon != null`), pour chaque
bouteille :
- si la référence actuelle est **différente** de la référence enregistrée au départ
  (`widget.echantillon!.referenceBouteille`)
- **et** si la référence actuelle est exactement la référence automatique
  (`construireReferenceBouteille(...)` avec les valeurs actuelles) — donc elle a changé
  toute seule, pas parce que la personne l'a tapée,

alors, avant d'envoyer, ouvre une fenêtre (avec `barrierDismissible: false`) :
- titre : `La référence a changé`
- texte : `En modifiant la quantité, la citerne ou le fournisseur, la référence a été
  recalculée.`
  puis les deux valeurs, lisibles : `Ancienne : <ancienne>` / `Nouvelle : <nouvelle>`
- boutons : `Garder l'ancienne` et `Utiliser la nouvelle` (bouton principal, couleur
  principale déjà utilisée par le formulaire).

`Garder l'ancienne` remet l'ancienne référence dans la bouteille avant l'envoi.
`Utiliser la nouvelle` envoie la nouvelle. Dans les deux cas, l'enregistrement continue.
À l'**ajout** d'un nouvel échantillon : aucune fenêtre.

Si la personne a tapé elle-même une référence différente de l'automatique : aucune
fenêtre, on envoie ce qu'elle a tapé.

Ne change ni les autres textes, ni les couleurs, ni la mise en page.

## Tests

Ajoute ou adapte des tests (par ex. `test/reference_modification_test.dart`) :
- choisir un fournisseur dans les suggestions donne une référence avec son **nom** ;
- modification + changement de quantité → la fenêtre apparaît ; `Garder l'ancienne`
  envoie l'ancienne référence ; `Utiliser la nouvelle` envoie la nouvelle ;
- modification + référence tapée à la main → pas de fenêtre ;
- ajout → pas de fenêtre.
Si tester le formulaire complet est trop lourd, extrais la règle de décision dans une
petite fonction pure (dans `lib/core/utils/reference_bouteille.dart`) et teste-la, plus un
test widget de la fenêtre elle-même.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera
`flutter analyze lib test` et `flutter test` (attendu : 0 erreur, 0 échec).

## RAPPORT

### Fait

- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` : l'enregistrement n'ouvre plus la fenêtre "fournisseurs proches"; la référence bouteille est recalculée avec le nom visible dans le champ fournisseur, et une modification demande confirmation avant d'envoyer une référence recalculée automatiquement.
- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : même correction pour le formulaire dégustateur, avec préremplissage du champ fournisseur par le nom quand il existe.
- `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : même correction pour le formulaire chef dégustateur, avec la couleur principale du rôle sur le bouton de confirmation.
- `lib/core/utils/reference_bouteille.dart` : ajout de la règle pure qui décide si une référence recalculée doit être confirmée.
- `lib/core/widgets/dialog_reference_bouteille.dart` : ajout de la fenêtre "La référence a changé" avec les choix "Garder l'ancienne" et "Utiliser la nouvelle".
- `lib/core/services/fournisseur_service.dart` : suppression de `findNearDuplicates`, qui n'est plus appelée.
- `lib/core/widgets/dialog_doublon_fournisseur.dart` : supprimé, car plus aucun usage ne reste dans `lib/` ou `test/`.
- `test/reference_bouteille_test.dart` : ajout des tests pour le nom fournisseur, la décision de confirmation et les deux boutons de la fenêtre.

### Vérifié

```bash
rg -n "DialogDoublonFournisseur|dialog_doublon_fournisseur|findNearDuplicates|_verifierFournisseur" lib test
```

Sortie : aucune ligne, code retour 1.

```bash
Test-Path lib/core/widgets/dialog_doublon_fournisseur.dart
```

Sortie :

```text
False
```

```bash
rg -n "text: e\?\.fournisseurNom \?\? e\?\.codeFournisseur|String get _fournisseurPourReference|referenceRecalculeeAConfirmer|demanderChoixReferenceBouteilleRecalculee" lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/core/utils/reference_bouteille.dart lib/core/widgets/dialog_reference_bouteille.dart
```

Sortie : 14 lignes trouvées, dont les 3 getters `_fournisseurPourReference`, les 3 préremplissages `fournisseurNom ?? codeFournisseur`, les 3 appels à `referenceRecalculeeAConfirmer`, les 3 appels à `demanderChoixReferenceBouteilleRecalculee`, et les 2 définitions partagées.

```bash
git diff --check
```

Sortie : uniquement des avertissements `LF will be replaced by CRLF`, aucune erreur d'espace.

```bash
dart format lib/core/utils/reference_bouteille.dart lib/core/widgets/dialog_reference_bouteille.dart lib/core/services/fournisseur_service.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart test/reference_bouteille_test.dart
```

Sortie :

```text
command timed out after 120120 milliseconds
```

Relance fichier par fichier sur `lib/core/utils/reference_bouteille.dart`, `lib/core/widgets/dialog_reference_bouteille.dart`, `test/reference_bouteille_test.dart`, `lib/core/services/fournisseur_service.dart` : chaque commande a expiré après environ 30000 ms.

`flutter analyze lib test` et `flutter test` non exécutés : la tâche dit explicitement que le sandbox ne peut pas lancer Flutter et demande de ne pas essayer.

### Non fait

- Aucun test Flutter lancé, conformément à la consigne de cette tâche.
- `dart format` n'a pas terminé dans ce sandbox malgré plusieurs essais; les fichiers ont été relus manuellement.

### HORS PÉRIMÈTRE

- L'arbre de travail contenait déjà des changements non liés avant cette tâche (`files/taches/FILE-ATTENTE.md`, `files/taches/PROTOCOLE.md`, `lib/core/widgets/champ_autocomplete.dart`, `lib/core/services/variete_service.dart`, `test/champ_autocomplete_test.dart`, fichiers de sauvegarde backend, etc.). Je n'y ai pas touché.
