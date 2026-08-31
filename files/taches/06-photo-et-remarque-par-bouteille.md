# Tâche 06 — Photo et remarque rattachées à une bouteille précise

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la demande : `docs/retours-utilisation-et-questions.md`, points 2.6 et 2.7.

---

## Contexte

Le formulaire d'ajout d'échantillon du collecteur
(`lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`, 1319 lignes) est
**un seul formulaire** qui contient : un fournisseur, une localisation, et une **liste de
bouteilles** (`List<BouteilleRow> _bouteilles`, L99). Chaque bouteille donne naissance à un
échantillon séparé (`_save()`, L423-456 ; le formulaire l'annonce lui-même à L877 :
« N bouteilles → N échantillons séparés seront créés »).

Deux problèmes.

### Problème 1 — la photo peut créer une bouteille fantôme

La photo est gérée **au niveau du formulaire**, pas au niveau de la bouteille :
`_photoBytes` / `_photoName` (L103-104), `_pickPhoto` (L106-123), zone d'affichage unique en
bas du formulaire (L614-630).

Le rattachement se fait dans `_targetRowForPhoto()` (L127-141) :
- si la première bouteille n'a pas encore de photo, la photo va sur elle ;
- **sinon, la fonction ajoute une bouteille entièrement nouvelle** et met la photo dessus
  (L134-136).

Autrement dit, prendre une deuxième photo crée une bouteille supplémentaire que l'utilisateur
n'a pas demandée, et qui deviendra un échantillon de plus à l'enregistrement. C'est un vrai
défaut, pas une préférence d'affichage.

De plus, l'aperçu (L185-226) ne montre jamais que la dernière photo prise, et `_removePhoto`
(L145-148) n'efface que l'aperçu, pas `row.photoBytes`.

### Problème 2 — la remarque est recopiée sur toutes les bouteilles

Il y a un seul `_remarquesCtrl` (L86, UI L633-690). À l'enregistrement, son contenu est copié
**à l'identique sur chaque échantillon créé** (L445-447). Impossible d'écrire une remarque qui
ne concerne qu'une bouteille.

---

## CONSIGNE

### Partie A — la photo

1. Supprimer le comportement de `_targetRowForPhoto()` qui ajoute une bouteille. Prendre une
   photo ne doit **jamais** créer de bouteille.

2. Appliquer les trois cas décidés par le propriétaire :

   | Situation | Comportement attendu |
   |---|---|
   | Aucune bouteille saisie (aucune ligne remplie) | Afficher le message : « Remplissez d'abord les détails de l'échantillon pour ajouter une photo. » et ne rien attacher. |
   | Une seule bouteille | La photo est attachée à cette bouteille, sans aucune question. |
   | Deux bouteilles ou plus | Ouvrir une fenêtre « À quelle bouteille appartient cette photo ? » listant les bouteilles saisies (utilise leur référence, ou « Bouteille N » si la référence est vide). |

3. Déplacer l'affichage de la photo dans la carte de chaque bouteille, `_BouteilleCard`
   (L907-1057), pour que l'utilisateur voie quelle bouteille a déjà une photo.
   `BouteilleRow` porte **déjà** `photoBytes` et `photoName`
   (`widgets/dialogs/bouteille_row.dart:5-47`) — n'ajoute pas de nouveau champ pour ça.

4. Corriger `_removePhoto` pour qu'il efface bien la photo de la bouteille concernée, pas
   seulement l'aperçu.

### Partie B — la remarque

5. Ajouter un champ remarque **par bouteille** dans `BouteilleRow` (un `TextEditingController`
   de plus, sur le même modèle que `refCtrl`, `varieteCtrl`, `numCiterneCtrl`, `qteCtrl`), et
   l'afficher dans `_BouteilleCard`.

6. À l'enregistrement (`_save()`, L423-456), chaque `EchantillonCollecteur` reçoit **sa
   propre** remarque, plus la remarque globale recopiée.

7. Décision à prendre et à signaler dans ton rapport : garde-t-on aussi le champ remarque
   global du formulaire (L633-690) ? Si tu penses qu'il faut le supprimer, **ne le supprime
   pas** — pose la question sous `## QUESTION`. C'est un élément visible par l'utilisateur.

### Partie C — ne pas casser l'envoi

8. `mes_echantillons_page.dart:708-743` (`onSaveMultiple`) envoie un échantillon par bouteille
   et appaire `photos[i]` avec `nouveaux[i]`. Cette correspondance par index doit rester juste
   après tes changements. Vérifie-la explicitement.

9. Le mode modification (`_save()`, L398-420) n'écrit que `_bouteilles.first`. Ne change pas ce
   comportement dans cette tâche.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Ajoute au moins un test qui prouve que prendre une photo avec deux bouteilles saisies
n'augmente pas la taille de `_bouteilles`.

Donne les sorties chiffrées réelles dans ton rapport.

## QUESTION

`EchantillonCollecteur` ne possède qu'un seul champ `remarques`. La consigne demande que chaque
échantillon reçoive sa remarque propre « plus la remarque globale recopiée », mais ne précise pas
la valeur à enregistrer lorsque les deux sont renseignées : concaténation, ordre et séparateur.

Quel format exact faut-il envoyer dans ce seul champ ? Ajouter une donnée distincte pour la
remarque globale nécessiterait une modification de modèle et probablement une migration, ce qui
n'est pas autorisé sans votre accord.


### RÉPONSE À LA QUESTION

**Une seule remarque, par bouteille.** Pas de concaténation, pas de nouveau champ, pas de
migration.

Concrètement, le point 7 de la consigne est tranché dans ce sens : **la case remarque globale
du formulaire disparaît** (`_remarquesCtrl`, déclaré L86, affiché L633-690, recopié sur tous
les échantillons L445-447). Elle est remplacée par une remarque portée par chaque
`BouteilleRow`, qui va dans le champ `remarques` de l'échantillon créé pour cette bouteille.

C'est exactement ce que demandait le propriétaire : savoir à quelle bouteille appartient une
remarque. Une remarque recopiée à l'identique sur cinq échantillons ne répond à rien.

**Attention au mode modification** (`_save()` L398-420) : il ne traite que `_bouteilles.first`.
La remarque de cette bouteille doit continuer à être lue et réécrite correctement. Ne change
pas le reste de ce mode.

Reprends la tâche 06 en entier, parties A, B et C.

## RAPPORT

### Fait

- Aucun code modifié : attente de la décision sur la représentation des deux remarques dans le
  champ unique existant.

### Vérifié

- Vérifications Flutter non exécutées : la tâche est arrêtée avant toute modification, en attente
  de la réponse à la question ci-dessus.

### Non fait

- Les changements photo, remarque par bouteille et le test demandé ne sont pas réalisés, car la
  règle de non-supposition bloque d'abord la valeur à écrire pour chaque échantillon.

### HORS PÉRIMÈTRE

- Aucun problème hors périmètre corrigé ou modifié.

### Reprise

#### Fait

- `lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart` — chaque bouteille
  possède désormais sa propre remarque, correctement préremplie en modification et libérée
  avec ses autres champs.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` — une photo ne crée
  plus jamais de bouteille : le formulaire refuse une photo sans ligne saisie, cible directement
  l'unique bouteille saisie, ou demande explicitement la bouteille quand plusieurs lignes sont
  remplies. La photo, son nom et les actions « Remplacer » / « Retirer » sont affichés dans la
  carte de la bouteille concernée.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` — conformément à la
  réponse du propriétaire, le champ remarque global a été supprimé et chaque échantillon reçoit
  uniquement la remarque de sa bouteille. Le mode modification continue de ne traiter que
  `_bouteilles.first`.
- `test/formulaire_collecteur_bouteilles_test.dart` — deux tests widget couvrent le refus d'une
  photo sans bouteille saisie et le parcours à deux bouteilles. Le second simule une vraie image,
  vérifie qu'aucune troisième ligne n'apparaît, puis contrôle les deux remarques et la photo à
  l'index 1 lors de l'enregistrement.
- `mes_echantillons_page.dart` n'a pas été modifié. La correspondance reste indexée dans le même
  ordre : le formulaire construit `samples` et `photos` depuis `_bouteilles`, puis la page associe
  toujours `nouveaux[i]` à `photos[i]`.

#### Vérifié

- `dart format lib/2_collecteur/mes_echantillons/widgets/dialogs/bouteille_row.dart
  lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart
  test/formulaire_collecteur_bouteilles_test.dart` → `Formatted 3 files (3 changed) in 0.12
  seconds.`
- Compilation directe du nouveau test avec `frontend_server_aot.dart.snapshot` et le SDK Flutter
  patché → code de sortie 0, sortie finale : `.dart_tool\task06_test.dill 0`. Le formulaire, ses
  dépendances et le test compilent sans erreur.
- `git diff --check` → code de sortie 0, aucune sortie.
- Contrôle d'index exécuté avec
  `rg -n -C 5 "photos: _bouteilles|for \(var i = 0; i < nouveaux.length; i\+\+\)|photos\[i\]|nouveaux\[i\]" ...`
  → le formulaire produit `photos: _bouteilles.map(...)` à la ligne 421 ; la page boucle sur le
  même `i`, lit `nouveaux[i]` ligne 712 et `photos[i]` ligne 714.
- Recherche des anciens états globaux avec
  `rg -n "_photoBytes|_photoName|_targetRowForPhoto|_buildPhotoZone|_remarquesCtrl"
  lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` → aucune occurrence.
- `flutter --no-version-check analyze lib test` → délai dépassé après 30,037 secondes, aucune
  sortie et donc aucun diagnostic produit.
- `flutter --no-version-check test` → délai dépassé après 30,044 secondes, aucune sortie et donc
  0 test exécuté. Le lancement ciblé
  `flutter test test/formulaire_collecteur_bouteilles_test.dart` avait également dépassé 240,020
  secondes sans sortie.
- Le diagnostic direct du lanceur Flutter donne la cause exacte : `Flutter failed to write to a
  file at "C:\Users\takwa\Documents\flutter\bin\cache\libimobiledevice.stamp"` puis `The flutter
  tool cannot access the file or directory.` Le SDK est hors du workspace autorisé en écriture.

#### Non fait

- Les suites `flutter analyze lib test` et `flutter test` n'ont pas pu aller jusqu'aux résultats
  chiffrés de référence, car le sandbox interdit au lanceur Flutter d'écrire ses fichiers de cache
  dans le SDK externe. Aucun succès de test n'est revendiqué ; seule la compilation directe du
  nouveau test est confirmée.

#### HORS PÉRIMÈTRE

- L'impossibilité d'écrire dans le cache du SDK Flutter externe est une contrainte de
  l'environnement d'exécution, pas un défaut corrigé dans le projet.

---

## CONSIGNE DE REPRISE — 2 (les tests)

Le code que tu as écrit a été relu et il est bon. Le défaut de la bouteille fantôme est bien
supprimé, les trois cas de la photo sont là, et la remarque part bien par bouteille.

**Mais tes deux tests échouent.** Tu n'avais pas pu les lancer : mon bac à sable t'empêchait
d'écrire dans le cache du SDK Flutter. C'est corrigé, tu peux maintenant lancer
`flutter analyze` et `flutter test`. **Lance-les avant de conclure quoi que ce soit.**

Sortie exacte des deux échecs :

```
test/formulaire_collecteur_bouteilles_test.dart: refuse une photo tant qu'aucune bouteille n'est saisie
test/formulaire_collecteur_bouteilles_test.dart: une photo choisie pour la deuxième bouteille ne crée pas de bouteille
  EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK
  The following assertion was thrown running a test:
  pumpAndSettle timed out
```

**La cause.** Le formulaire va chercher la liste des fournisseurs quand il s'ouvre
(`_verifierFournisseur` L297, `FournisseurService.instance` L307, et `ChampAutocomplete`).
Dans un test, rien ne stabilise cette page : `pumpAndSettle` attend une image fixe qui
n'arrive jamais.

### Ce que tu fais

1. Remplace chaque `pumpAndSettle()` de
   `test/formulaire_collecteur_bouteilles_test.dart` par une attente **bornée**, par exemple
   `await tester.pump(const Duration(milliseconds: 300));` répété autant que nécessaire.
   Aucun `pumpAndSettle` ne doit rester dans ce fichier.

2. Les deux tests doivent passer et prouver exactement deux choses :
   - sans aucune bouteille saisie, demander une photo affiche le message et n'attache rien ;
   - avec deux bouteilles saisies, choisir une photo pour la deuxième **n'augmente pas** le
     nombre de bouteilles.

3. Corrige aussi le seul problème d'analyse que tu as introduit :
   `formulaire_dialog.dart:166:35` — `unnecessary_underscores`, tu as écrit `__` au lieu
   de `_`. L'analyse doit redescendre à **50 problèmes, 0 erreur**.

4. **Ne touche à rien d'autre.** Pas au code de production, sauf la ligne 166.

### Sur le paramètre `pickPhoto` que tu as ajouté

Tu as ajouté `PickBottlePhoto? pickPhoto` au formulaire pour pouvoir simuler l'appareil photo.
C'est **accepté, garde-le**. On ne peut pas prendre une vraie photo dans un test, et injecter
l'appareil photo ne change pas la façon dont la page obtient ses données.

C'est différent de ce qui avait été refusé dans la tâche 05, où il s'agissait d'injecter les
**services de données** de la page.

### Vérification

```bash
flutter analyze lib test
flutter test
```

Attendu après ton travail : **50 problèmes, 0 erreur**, et **99 tests réussis** avec un seul
échec, `test/widget_test.dart`, celui qui est connu et listé dans `PROTOCOLE.md`.

Donne les sorties chiffrées réelles sous `### Reprise 2` dans ton rapport.

### Reprise 2

#### Fait

- `test/formulaire_collecteur_bouteilles_test.dart` — les cinq appels à
  `pumpAndSettle()` ont été remplacés par des attentes bornées de 300 ms. Les deux tests
  conservent leurs vérifications : refus et message sans bouteille saisie ; deux bouteilles
  toujours présentes, sans troisième bouteille, après avoir choisi la photo de la seconde.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` — le paramètre
  inutilisé du `separatorBuilder` est maintenant nommé `_` au lieu de `__`. Aucun autre code
  de production n'a été modifié pendant cette reprise.

#### Vérifié

- `dart format lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart
  test/formulaire_collecteur_bouteilles_test.dart` → `Formatted 2 files (1 changed) in 0.06
  seconds.`
- `rg -n 'pumpAndSettle' test/formulaire_collecteur_bouteilles_test.dart` puis comptage de la
  sortie → `PUMP_AND_SETTLE_MATCHES=0 RG_EXIT=1`. Le comptage analogue des attentes bornées
  donne `BOUNDED_PUMP_MATCHES=5`. `rg -n 'separatorBuilder' ...` donne une seule ligne :
  `166: separatorBuilder: (_, _) => const Divider(height: 1),`.
- `flutter analyze lib test` a réellement été lancé → code de sortie 1 après 3,3 secondes,
  avant toute analyse. Sortie finale :
  `Flutter failed to run "git -c log.showSignature=false log HEAD -n 1
  --pretty=format:%ad --date=iso". The flutter tool cannot access the file or directory.`
- `flutter test` a réellement été lancé → code de sortie 1 après 3,1 secondes, avant
  l'exécution d'un test, avec la même erreur d'accès au sous-processus Git. Le lancement ciblé
  avec `--no-version-check --no-pub` dépasse cette étape mais échoue ensuite avec
  `ProcessException: Access is denied` lorsque Flutter tente de lancer le hook Dart
  `objective_c` via `cmd.exe`.
- L'analyseur Dart a été lancé directement via son protocole, sans l'enveloppe Flutter bloquée :
  `DIAGNOSTICS_TOTAL=67 ERRORS=0 WARNINGS=11 INFOS=56 FILES=235`. Il confirme 0 erreur et
  l'absence du diagnostic `unnecessary_underscores` dans `formulaire_dialog.dart`. Ce résultat
  direct ne remplace pas le résultat attendu de `flutter analyze lib test` et n'est donc pas
  présenté comme les 50 diagnostics de référence.
- La compilation directe actualisée de
  `test/formulaire_collecteur_bouteilles_test.dart` avec `frontend_server_aot.dart.snapshot`
  s'est terminée avec le code de sortie 0 et la sortie finale
  `.dart_tool\\task06_test_updated.dill 0`.
- `git diff --check` → code de sortie 0, aucune erreur d'espaces. Le fichier `.dill` temporaire
  et les rapports de plantage générés pendant le diagnostic ont ensuite été supprimés.

#### Non fait

- Il n'est pas possible d'affirmer que les deux tests ciblés passent ni que la suite atteint
  99 réussites et un seul échec connu : le lanceur Flutter n'a exécuté aucun test avant son
  erreur d'accès aux sous-processus.
- Le résultat demandé de 50 problèmes pour `flutter analyze lib test` n'a pas été produit pour
  la même raison. Aucun résultat de substitution n'est présenté comme équivalent.

#### HORS PÉRIMÈTRE

- L'écriture dans le cache du SDK fonctionne désormais, mais le bac à sable refuse encore les
  sous-processus créés par Flutter (`git`, `cmd.exe`, hooks Dart). C'est une contrainte de
  l'environnement d'exécution, non un défaut du projet, et aucun fichier du SDK n'a été modifié.

---

## CONSIGNE DE REPRISE — 3 (le propriétaire change la solution)

### Ce qui s'est passé

La fenêtre « À quelle bouteille appartient cette photo ? » que tu as écrite
(`_chooseBottleForPhoto`, L153) **plante à l'affichage**. Erreur exacte :

```
RenderShrinkWrappingViewport does not support returning intrinsic dimensions.
The relevant error-causing widget was: AlertDialog
  formulaire_dialog.dart:158
```

Cause : une `AlertDialog` mesure la largeur de son contenu, et un `ListView` ne sait pas
répondre. Ce n'est pas un défaut de test : cette fenêtre planterait aussi dans l'application.

### La nouvelle solution, décidée par le propriétaire

**On supprime complètement la question « à quelle bouteille ? ».** Elle devient inutile.

À la place : **chaque bouteille a son propre bouton photo, dans sa propre carte.** Cliquer sur
le bouton de la bouteille C3 dit déjà que la photo est pour C3. Il n'y a plus rien à demander.

C'est plus simple pour l'utilisateur, et ça enlève le code qui plante.

### Ce que tu fais

1. **Ajoute un bouton photo dans chaque `_BouteilleCard`**, à côté des champs de cette
   bouteille. Une icône suffit.

2. **Au clic, propose trois choix** : *Galerie*, *Appareil photo*, *Annuler*.
   « Annuler » doit exister explicitement : le propriétaire veut pouvoir se retirer s'il a
   cliqué par erreur.

3. **Même chose dans le formulaire de modification**, pour la bouteille affichée.

4. **Supprime** :
   - `_chooseBottleForPhoto` (L153) — la fenêtre qui plante ;
   - `_startPhotoFlow` (L130) — le point d'entrée global n'a plus lieu d'être ;
   - le message « Remplissez d'abord les détails de l'échantillon pour ajouter une photo. »
     (L138) — plus personne ne peut l'atteindre ;
   - le bouton photo global du formulaire (`onAddPhoto: _startPhotoFlow`, L548) et la zone
     photo unique qui l'accompagne.

   Avant chaque suppression, vérifie avec `grep` que plus rien n'appelle ce que tu enlèves, et
   donne le résultat brut.

5. **Garde** `_pickPhoto(ImageSource source, BouteilleRow row)` (L106) : elle prend déjà une
   bouteille précise, c'est exactement ce qu'il faut. Garde aussi le paramètre `pickPhoto`
   injecté, il reste utile pour les tests.

6. **Quand une bouteille a une photo**, la carte doit le montrer — une vignette ou une marque
   claire — et permettre de la retirer.

7. L'appariement `photos[i]` avec `nouveaux[i]` à l'enregistrement doit rester juste.
   Vérifie-le explicitement.

### Les tests

Le test « refuse une photo tant qu'aucune bouteille n'est saisie » n'a plus de sens :
supprime-le, il teste un message qui n'existe plus.

Le test « une photo choisie pour la deuxième bouteille ne crée pas de bouteille » **reste, et
c'est le plus important**. Réécris-le pour la nouvelle interface : deux bouteilles saisies,
clic sur le bouton photo de la **deuxième**, choix *Galerie* → la photo est attachée à la
deuxième bouteille, et le nombre de bouteilles **n'augmente pas**.

Pas de `pumpAndSettle` dans ce fichier : le formulaire ne se stabilise jamais, il va chercher
la liste des fournisseurs à l'ouverture. Utilise des attentes bornées, comme tu l'as déjà fait.

### Vérification

```bash
flutter analyze lib test
flutter test
```

Attendu : **50 problèmes, 0 erreur**, et **aucun échec autre que `test/widget_test.dart`**.

Si `flutter` refuse de s'exécuter chez toi, dis-le franchement comme tu l'as fait deux fois,
ne revendique aucun chiffre. Écris ton compte rendu sous `### Reprise 3`.

### Reprise 3

#### Fait

- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` — chaque carte
  bouteille possède maintenant son propre bouton photo, aussi bien en création qu'en
  modification. Le clic propose explicitement « Galerie », « Appareil photo » et « Annuler »,
  puis rattache la photo directement à la bouteille concernée. La vignette, le nom du fichier,
  le remplacement et le retrait restent visibles dans cette même carte.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` — le parcours photo
  global, la question « À quelle bouteille appartient cette photo ? », son message préalable et
  le bouton photo global ont été supprimés. `_pickPhoto(ImageSource source, BouteilleRow row)`
  et l'injection `pickPhoto` sont conservés.
- `test/formulaire_collecteur_bouteilles_test.dart` — l'ancien test du message sans bouteille a
  été supprimé. Le test restant crée deux bouteilles, clique sur le bouton photo de la seconde,
  vérifie les trois choix, sélectionne la galerie et contrôle qu'il existe toujours exactement
  deux bouteilles et que la photo enregistrée reste à l'index 1.

#### Vérifié

- Avant suppression, les recherches exactes ont donné : `_chooseBottleForPhoto` → 2
  occurrences (appel L148, déclaration L153), `_startPhotoFlow` → 2 occurrences (déclaration
  L130, appel L548), `_isRowEmpty` → 2 occurrences, `ajouter-photo-bouteille` → 3
  occurrences (deux dans le test, une dans le formulaire), et le message supprimé → 2
  occurrences (une dans le test, une dans le formulaire). Commande exécutée :
  `rg -n -F -- <motif> lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart
  test/formulaire_collecteur_bouteilles_test.dart`.
- Après suppression,
  `rg -n "_chooseBottleForPhoto|_startPhotoFlow|_isRowEmpty|ajouter-photo-bouteille|Remplissez
  d'abord les détails de l'échantillon pour ajouter une photo\." ...` → aucune sortie,
  `RG_EXIT=1`. La recherche de `pumpAndSettle` dans le test donne aussi aucune sortie,
  `RG_EXIT=1`.
- `dart format lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart
  test/formulaire_collecteur_bouteilles_test.dart` → `Formatted 2 files (2 changed) in 0.07
  seconds.`
- Compilation directe de `test/formulaire_collecteur_bouteilles_test.dart` avec
  `frontend_server_aot.dart.snapshot` et le SDK Flutter patché → code de sortie 0 en 9,5
  secondes, sortie finale : `.dart_tool\task06_reprise3_test.dill 0`. Ce résultat prouve que
  le formulaire et le test compilent, mais pas que le test s'exécute avec succès.
- Contrôle explicite de l'appariement avec
  `rg -n -C 4 "final samples = _bouteilles\.asMap|photos: _bouteilles|for \(var i = 0; i <
  nouveaux.length; i\+\+\)|nouveaux\[i\]|photos\[i\]" ...` → `samples` est construit depuis
  `_bouteilles.asMap()` L322, `photos` depuis `_bouteilles` L358, puis la page lit toujours
  `nouveaux[i]` L712 et `photos[i]` L714 dans la même boucle.
- `rg -n 'testWidgets\(' test/formulaire_collecteur_bouteilles_test.dart` → une occurrence,
  ligne 49 (`TEST_WIDGET_MATCHES=1`).
- `git diff --check` → code de sortie 0, aucune erreur d'espaces.
- `flutter analyze lib test` a réellement été lancé → code de sortie 1 après 3,0 secondes,
  avant toute analyse. Sortie finale : `Flutter failed to run "git -c
  log.showSignature=false log HEAD -n 1 --pretty=format:%ad --date=iso". The flutter tool
  cannot access the file or directory.`
- `flutter test` a réellement été lancé → code de sortie 1 après 3,1 secondes, avant
  l'exécution d'un test, avec la même erreur d'accès au sous-processus Git. Le test ciblé
  échoue au même stade ; avec `--no-version-check --no-pub`, Flutter échoue avant le test
  sur `Flutter failed to run "ver"`.

#### Non fait

- Les 50 diagnostics attendus et l'absence d'un nouvel échec de test ne peuvent pas être
  affirmés : le lanceur Flutter n'atteint ni l'analyseur ni l'exécuteur de tests dans cet
  environnement. Aucun chiffre de substitution n'est présenté comme équivalent.

#### HORS PÉRIMÈTRE

- Le bac à sable refuse toujours les sous-processus lancés par Flutter (`git`, puis `ver` avec
  les options de contournement). Cette contrainte d'environnement n'a pas été corrigée dans
  le projet.

---

## DÉCISION FINALE — le test automatique est abandonné

Le fichier `test/formulaire_collecteur_bouteilles_test.dart` a été **supprimé**, sur décision
du propriétaire, après trois tentatives.

**Pourquoi.** Le test ne parvenait pas à cliquer sur « Galerie » : son faux appareil photo
n'était jamais appelé, parce que le menu glissant est encore en animation au moment du clic
simulé. Le code de l'application, lui, est correct — le clic sur « Galerie » ferme le menu puis
appelle `_pickPhoto(ImageSource.gallery, row)`.

C'est le même mur que dans la tâche 05 : les écrans du collecteur vont chercher des données à
l'ouverture et ne se stabilisent jamais dans un test.

**Conséquence assumée :** rien ne protège automatiquement contre le retour du défaut de la
bouteille fantôme. La vérification est manuelle.

**À vérifier à l'écran, avec le serveur Django démarré :**
1. Ouvrir le formulaire d'ajout d'échantillon.
2. Saisir deux bouteilles.
3. Cliquer sur le bouton photo de la **deuxième**.
4. Les trois choix apparaissent : Galerie, Appareil photo, Annuler.
5. Choisir Galerie → la photo se rattache à la deuxième bouteille, et **le nombre de bouteilles
   n'augmente pas**.
6. Recommencer et choisir « Annuler » → rien ne se passe, aucune photo, aucune bouteille en plus.
