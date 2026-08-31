# Tâche 11 — Supprimer l'historique ancienne valeur / nouvelle valeur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la décision : `docs/retours-utilisation-et-questions.md`, section 6.

---

## Contexte

Une règle avait été décidée au début du projet : une fois l'échantillon reçu physiquement,
chaque modification devait garder l'ancienne valeur à côté de la nouvelle, visible par tous les
rôles.

**Le propriétaire du projet a annulé cette règle.** Sa raison : le collecteur ne peut modifier
ou supprimer un échantillon que **tant qu'il n'est pas reçu physiquement**
(`lib/core/models/echantillon.dart:117-120`, `canModify` / `canDelete` exigent
`!recuPhysiquement` ; le serveur bloque aussi la suppression,
`backend_new/echantillons/views.py:202-206`). Une fois l'échantillon reçu, plus rien ne change.
Il n'y a donc jamais de modification « après coup » à tracer.

### Un fait à connaître : la fonction ne marche déjà pas

Les deux côtés ne parlent pas le même langage.

- Django stocke `edit_history` sous la forme
  `{'horodatage', 'modifie_par', 'modifications': {champ: {'avant', 'apres'}}}`
  (`backend_new/echantillons/views.py:179-188`).
- Flutter attend une liste plate sous la clé `historique`, avec `ancienne_valeur` et
  `nouvelle_valeur` (`lib/core/models/modification_champ.dart:70-85`).
- Le mot `edit_history` **n'apparaît nulle part dans `lib/`**, et le mapper
  `lib/core/services/gestion_echantillons_service.dart:16-51` ne le recopie pas.

Résultat : `Echantillon.fromJson` (`lib/core/models/echantillon.dart:166-168`) reçoit toujours
`null`, et l'historique est vide après chaque rechargement. Seules les lignes créées pendant la
session en cours s'affichent. La suppression demandée n'enlève donc pas une fonction qui
marchait.

---

## Où se trouve le code à supprimer

### Côté Flutter

| Fichier | Ce que c'est |
|---|---|
| `lib/core/models/modification_champ.dart` | Le modèle d'une ligne d'historique (`ancienneValeur` L26, `nouvelleValeur` L27) |
| `lib/core/models/echantillon_historique.dart` | La règle elle-même : liste des 7 champs suivis L19-27, `capturerAvantModification()` L32-40, `enregistrerModifications()` L48-75 avec la condition `if (!recuPhysiquement) return;` L53 |
| `lib/core/models/echantillon.dart:71` | Le champ `List<ModificationChamp> historique` (valeur par défaut L108, lecture JSON L166-168) |
| `lib/core/widgets/historique_modifications.dart` | Le panneau dépliable. Ligne ancienne → nouvelle valeur : `_LigneModification` L118-188, flèche `Icons.arrow_forward` L152 |
| `lib/core/widgets/gestion_echantillons/echantillon_card.dart:433-435` | Le seul endroit où le panneau est affiché |
| `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart:388, 407` | Appels `capturerAvantModification` / `enregistrerModifications` |
| `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart:217, 236` | Les mêmes appels côté chef |

Aucun autre rôle n'affiche l'historique : la direction, le collecteur et le laboratoire n'ont
aucune référence à `HistoriqueModifications` ni à `ModificationChamp`.

### Côté Django

| Fichier | Ce que c'est |
|---|---|
| `backend_new/echantillons/views.py:27-32` | `TRACKED_FIELDS` — les 7 champs suivis |
| `backend_new/echantillons/views.py:160-194` | `perform_update` — construit l'entrée d'historique, condition `if obj.recu_physiquement:` L178 |
| `backend_new/echantillons/models.py:110-111` | `edit_history = models.JSONField(default=list, blank=True)` |
| `backend_new/echantillons/serializers.py` | `'edit_history'` dans `fields` et dans `read_only_fields` |

---

## CONSIGNE

1. Supprimer l'affichage : le panneau `HistoriqueModifications` et son montage dans
   `echantillon_card.dart`.

2. Supprimer la construction de l'historique côté Flutter : les deux fichiers de modèle et les
   quatre appels dans les deux `formulaire_dialog.dart`.

3. Supprimer la construction de l'historique côté Django : `TRACKED_FIELDS` et le bloc
   d'historique dans `perform_update`. **Attention** : `perform_update` fait peut-être d'autres
   choses — ne supprime que le bloc d'historique, garde le reste.

4. **Avant de supprimer un fichier, prouve que plus personne ne l'importe.** Le linter de ce
   projet autorise `unused_import` et `unused_element` : il ne signalera jamais un fichier mort.
   Utilise `grep` et donne le résultat brut dans ton rapport.

5. **Mettre à jour `CLAUDE.md`**, section « Sample States ». Elle contient encore la règle
   inverse :
   « *Edit history rule: Once `recuPhysiquement = true`, any field edit must store the previous
   value. All roles see old + new values.* »
   Cette ligne doit disparaître. Le fichier `CLAUDE.md` guide toutes les sessions futures : le
   laisser faux enverrait l'agent suivant reconstruire ce qu'on vient d'enlever.

6. **Ne touche pas à `recu_physiquement` lui-même.** Il sert à verrouiller l'échantillon contre
   la modification et la suppression, et ce verrou reste. Seul l'enregistrement de l'ancienne
   valeur disparaît.

---

## Le champ de base de données : pose la question

`edit_history` est déclaré sur le modèle Django, **mais aucune migration ne l'ajoute** —
`backend_new/echantillons/migrations/0001_initial.py` ne le contient pas, et une recherche du
mot `edit_history` dans le dossier des migrations ne renvoie rien.

Supprimer le champ du modèle va donc probablement produire une migration.
**Tu ne la crées pas de toi-même.** Écris la question sous `## QUESTION` et arrête-toi là pour
cette partie. Tu peux livrer tout le reste (Flutter, `perform_update`, `CLAUDE.md`) avant de
t'arrêter, et le dire dans ton rapport.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Donne aussi le résultat brut de la recherche des mots `ModificationChamp`, `historique` et
`edit_history` dans `lib/` et `backend_new/` après ta modification.

Donne les sorties chiffrées réelles dans ton rapport.

## QUESTION

1. Le fichier de tâche dit que les migrations ne contiennent pas `edit_history`, mais le dépôt contient déjà `backend_new/echantillons/migrations/0006_echantillon_edit_history.py` et `0007_remove_echantillon_ref_echantillon_numero_and_more.py` dépend de cette migration. Faut-il supprimer `edit_history` du modèle Django et du serializer, puis créer la migration de suppression correspondante ?


### RÉPONSE À LA QUESTION

**Tu as raison et le fichier de tâche avait tort.** `0006_echantillon_edit_history.py` existe
bien, et `0007` en dépend. La phrase de la section « Le champ de base de données » qui affirmait
qu'aucune migration n'ajoutait `edit_history` est fausse. Merci de l'avoir vérifiée au lieu de
la croire.

**Oui, supprime le champ et crée la migration.** Enlève `edit_history` du modèle
`backend_new/echantillons/models.py` et du sérialiseur, puis génère la migration de suppression.

Le propriétaire a été prévenu que les données d'historique déjà enregistrées seront perdues. Il
l'accepte : elles ne s'affichaient nulle part, puisque le mot `edit_history` n'apparaît nulle
part dans `lib/`.

**Ne touche pas aux migrations 0006 et 0007 elles-mêmes.** On n'efface pas l'histoire du dépôt,
on ajoute une migration qui retire le champ.

Relance ensuite les trois commandes de vérification, y compris la suite Django.

## RAPPORT

### Fait

- Modifié — `CLAUDE.md` : la règle d'historique ancienne valeur / nouvelle valeur n'est plus donnée aux prochaines sessions.
- Modifié — `lib/core/models/echantillon.dart` : les échantillons Flutter ne portent plus de liste d'historique à afficher ou maintenir.
- Modifié — `lib/core/widgets/gestion_echantillons/echantillon_card.dart` : la carte d'échantillon n'affiche plus le panneau d'historique des modifications.
- Modifié — `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : le formulaire dégustateur ne construit plus de lignes d'historique pendant une modification.
- Modifié — `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : le formulaire chef dégustateur ne construit plus de lignes d'historique pendant une modification.
- Modifié — `backend_new/echantillons/views.py` : les mises à jour Django ne calculent plus d'entrée `edit_history`; le contrôle existant du changement de statut collecteur est conservé.
- Supprimé — `lib/core/models/echantillon_historique.dart` : la règle Flutter de capture ancienne / nouvelle valeur est retirée.
- Supprimé — `lib/core/models/modification_champ.dart` : le modèle Flutter d'une ligne d'historique est retiré.
- Supprimé — `lib/core/widgets/historique_modifications.dart` : le widget Flutter du panneau d'historique est retiré.

### Vérifié

```powershell
dart format lib/core/models/echantillon.dart lib/core/widgets/gestion_echantillons/echantillon_card.dart lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
```

Sortie chiffrée :

```text
Formatted lib/core/models/echantillon.dart
Formatted lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
Formatted lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
Formatted 4 files (3 changed) in 0.30 seconds.
```

Preuve `grep` avant suppression de `lib/core/models/echantillon_historique.dart` :

```powershell
& 'C:\Program Files\Git\usr\bin\grep.exe' -R "echantillon_historique.dart" lib --exclude=echantillon_historique.dart
```

Sortie brute :

```text
```

Preuve `grep` avant suppression de `lib/core/widgets/historique_modifications.dart` :

```powershell
& 'C:\Program Files\Git\usr\bin\grep.exe' -R "historique_modifications.dart" lib --exclude=historique_modifications.dart
```

Sortie brute :

```text
```

Preuve `grep` avant suppression de `lib/core/models/modification_champ.dart` :

```powershell
& 'C:\Program Files\Git\usr\bin\grep.exe' -R "modification_champ.dart" lib --exclude=modification_champ.dart
```

Sortie brute :

```text
```

Recherche finale demandée :

```powershell
rg -n "ModificationChamp|historique|edit_history" lib backend_new -S
```

Sortie brute :

```text
backend_new\echantillons\models.py:111:    edit_history = models.JSONField(default=list, blank=True)
backend_new\echantillons\serializers.py:30:            'edit_history',
backend_new\echantillons\serializers.py:37:            'id', 'numero', 'collecteur', 'edit_history',
backend_new\echantillons\migrations\0007_remove_echantillon_ref_echantillon_numero_and_more.py:9:        ('echantillons', '0006_echantillon_edit_history'),
backend_new\echantillons\migrations\0006_echantillon_edit_history.py:15:            name='edit_history',
lib\core\classification\classification_interne.dart:340:/// Les défauts gardent les seuils historiques 3 et 6 sur 0–10 ; les attributs
```

Vérification Flutter :

```powershell
flutter analyze lib test
```

Sortie chiffrée :

```text
Analyzing 2 items...
50 issues found. (ran in 226.9s)
```

Vérification tests Flutter :

```powershell
flutter test
```

Sortie chiffrée et échec exact :

```text
00:18 +88: C:/Users/takwa/Desktop/flash5/more/flutterpfe/project3/test/widget_test.dart: Counter increments smoke test
══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "0": []>
   Which: means none were found but one was expected

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///C:/Users/takwa/Desktop/flash5/more/flutterpfe/project3/test/widget_test.dart:19:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1952:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/Users/takwa/Desktop/flash5/more/flutterpfe/project3/test/widget_test.dart line 19
The test description was:
  Counter increments smoke test
════════════════════════════════════════════════════════════════════════════════════════════════════
00:18 +88 -1: C:/Users/takwa/Desktop/flash5/more/flutterpfe/project3/test/widget_test.dart: Counter increments smoke test [E]
  Test failed. See exception logs above.
  The test description was: Counter increments smoke test

00:19 +97 -1: Some tests failed.

Failing tests:
  C:/Users/takwa/Desktop/flash5/more/flutterpfe/project3/test/widget_test.dart: Counter increments smoke test
```

Vérification Django demandée :

```powershell
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Sortie brute :

```text
ValueError: Invalid truth value: release
```

Relance avec `DEBUG=True` limité au processus, pour dépasser le blocage d'environnement :

```powershell
$env:DEBUG='True'
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Sortie chiffrée :

```text
----------------------------------------------------------------------
Ran 0 tests in 0.000s

NO TESTS RAN
Found 0 test(s).
System check identified no issues (0 silenced).
```

### Non fait

- Non fait — suppression de `backend_new/echantillons/models.py:edit_history`, de son exposition dans `backend_new/echantillons/serializers.py`, et de la migration associée : cela touche au schéma Django / à l'API et demande une décision. Question posée ci-dessus.

### HORS PÉRIMÈTRE

- `files/role_degustateur.md`, `files/role_chef_degustateur.md` et plusieurs documents sous `files/notifications/` mentionnent encore l'ancienne règle d'historique. La consigne demande uniquement de corriger `CLAUDE.md`; ces documents n'ont donc pas été modifiés.
- Le dépôt contenait déjà des changements hors tâche 11 dans les fichiers des tâches 05-08, plusieurs fichiers collecteur et `lib/core/utils/montant_achat.dart`; ils n'ont pas été modifiés dans cette tâche.
