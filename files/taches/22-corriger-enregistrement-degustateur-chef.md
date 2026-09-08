# Tâche 22 — Corriger l'accès du dégustateur et du chef dégustateur : pas de nouvelle
# page, juste les boutons ajouter/modifier/supprimer sur leur page existante

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Modules concernés : `3_degustateur/gestion_echantillons`, `5_chef_degustateur/gestion_echantillons`,
`core/services/gestion_echantillons_service.dart`, les deux `tableau_de_bord/widgets/app_drawer.dart`,
`2_collecteur/mes_echantillons/mes_echantillons_page.dart` (retrait uniquement).

---

## Contexte

Les tâches 20 et 21 ont donné au dégustateur et au chef dégustateur l'accès à
`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` — la page du collecteur,
réutilisée telle quelle, ouverte depuis un nouveau lien de tiroir "Mes échantillons".

**Ce n'était pas la demande.** Le propriétaire avait déjà une page "Gestion des
échantillons" pour ces deux rôles (`lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`
et `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`) — présente
dans le tiroir depuis toujours, avec ses propres filtres ("Non évaluée", "Évaluation en
cours", "Évaluation soumise" — pas les filtres du collecteur). Ce qu'il voulait, c'est que
**cette page existante** gagne un bouton "Ajouter" et un bouton "Supprimer" sur chaque
carte, sans rien changer d'autre — pas une deuxième page, pas les filtres du collecteur, pas
son tiroir.

Bonne nouvelle en creusant le code : le plus dur est déjà fait.

- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` et
  `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`
  savent **déjà** fonctionner en mode ajout (`echantillon: null` → titre "Nouvel
  échantillon", bouton "Ajouter") aussi bien qu'en mode modification. Personne ne les
  appelle en mode ajout aujourd'hui.
- `lib/core/widgets/gestion_echantillons/echantillon_card.dart` (`EchantillonCard`, déjà
  partagée par les deux pages) accepte **déjà** `onModifier` et `onSupprimer` — le bouton
  supprimer s'affiche automatiquement dès que `onSupprimer` n'est pas `null`. Personne ne le
  passe aujourd'hui.
- Ce qui manque : un bouton "Ajouter" (FAB) sur les deux pages, `onSupprimer` branché sur la
  carte, et deux méthodes côté service (`createEchantillon`, `deleteEchantillon`) qui
  n'existent pas encore dans `GestionEchantillonsService`.
- Le serveur, lui, n'a rien à changer : la tâche 20 a déjà ouvert `create`/`update`/`destroy`
  sur `/api/echantillons/` au dégustateur et au chef, avec le blocage "un dégustateur/chef
  ne peut pas supprimer un échantillon d'un collecteur" déjà écrit dans `destroy()`
  (`backend_new/echantillons/views.py`, ~L166-190). Ne touche pas à ce fichier.

---

## CONSIGNE

### 1. Retirer ce qui n'aurait pas dû être ajouté

**`lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart`** et
**`lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart`** :
- Supprime l'entrée de tiroir "Mes échantillons" ajoutée en tâche 20/21 (celle qui pousse
  `MesEchantillonsPage(...)`).
- Supprime l'import de `mes_echantillons_page.dart` s'il ne sert plus à rien d'autre dans ce
  fichier.
- Le tiroir retrouve exactement sa liste d'avant la tâche 20 : seule "Gestion des
  échantillons" reste dans la section "Échantillons".

**`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`** : personne d'autre que le
collecteur n'ouvre plus cette page après ce retrait ci-dessus. Retire donc ce que les tâches
20 et 21 y avaient ajouté pour ce partage, qui devient du code mort :
- Le constructeur reperd `drawerPersonnalise` et `afficherExtrasCollecteur` (tâche 21) —
  `MesEchantillonsPage` redevient `const MesEchantillonsPage({super.key})`, `drawer:
  CollecteurDrawer(...)` construit directement comme avant, la cloche de notifications et
  les actions achat/livraison redeviennent inconditionnelles.
- `_loadRoleConnecte`, `_roleConnecte`, `_canDeleteForCurrentRole` (tâche 20) disparaissent ;
  `onSupprimer` repasse par `e.canDelete` directement, comme avant la tâche 20.
- Le résultat doit être : cette page se comporte exactement comme avant la tâche 20, aucune
  trace des deux tâches annulées.

Ne touche à rien d'autre dans ce fichier (le reste — FAB, formulaire, etc. — n'a pas bougé
et ne doit pas bouger).

### 2. `GestionEchantillonsService` — ajouter créer et supprimer

Dans `lib/core/services/gestion_echantillons_service.dart`, à côté de `updateEchantillon` qui
existe déjà, ajoute :

```dart
Future<Echantillon> createEchantillon(Echantillon e) async {
  final response = await apiClient.post('/api/echantillons/', _toDjangoMap(e));
  return Echantillon.fromJson(_toFlutterMap(response));
}

Future<void> deleteEchantillon(String id) async {
  await apiClient.delete('/api/echantillons/$id/');
}
```

Il faut aussi écrire `_toDjangoMap`, qui n'existe pas encore dans ce fichier — construis-le
sur le modèle exact de `_toDjangoMap` dans
`lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart` (même
projet, même endpoint, même serializer côté Django). Regarde en particulier comment ce
fichier gère `code_fournisseur` / `fournisseur_nom` — le serializer
(`backend_new/echantillons/serializers.py`, méthode `_resolve_fournisseur`, ~L67-115) associe
ou crée le fournisseur à partir de ce champ texte libre, exactement ce que le formulaire du
dégustateur/chef propose déjà ("Nom / Code fournisseur"). N'envoie pas `numero`/`ref`, `id`,
ni les champs en lecture seule — le serveur les calcule.

`apiClient` (singleton exporté par `lib/core/api_client.dart`) est déjà utilisé ailleurs dans
ce même fichier (`fetchEchantillons`) — pas besoin de l'injecter, utilise-le directement comme
le fait déjà `fetchEchantillons`.

Ce service n'a pas de mode démonstration simulée (contrairement au service du collecteur,
tâche 17) : les deux pages qui l'utilisent bloquent déjà l'écriture avec un message d'erreur
quand `_estDemonstration` est vrai (voir `_onToggleRecu` dans les deux pages). Fais pareil
pour ajouter/supprimer, ne simule rien.

### 3. Page du dégustateur — ajouter le bouton "Ajouter" et le bouton "Supprimer"

Dans `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` :

- Ajoute un `floatingActionButton` qui ouvre `showFormulaireDialog` en mode ajout
  (`echantillon` omis/`null`, `prochainNumero: _prochainNumero` — le getter existe déjà
  L117), avec un `onSaveMultiple` qui appelle `_service.createEchantillon(...)` pour chaque
  échantillon renvoyé par le dialogue, insère le résultat **renvoyé par le serveur** (pas
  l'objet local créé par le dialogue) dans `_echantillons`, puis affiche `_showSuccess(...)`.
  En cas d'erreur, `_showError(...)` — mêmes noms de méthodes que celles qui existent déjà
  plus bas dans ce fichier. Reprends le style du FAB du collecteur
  (`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`, ~L743-793) mais avec une
  icône simple (`Icons.add`, pas `add_a_photo_outlined` — ce module n'a pas la même logique
  de photo par bouteille) et le label "Ajouter". Couleurs : voir `CLAUDE.md`, section FAB.
  Garde le blocage démonstration comme pour les autres actions d'écriture de cette page.
- Ajoute une méthode `_onSupprimer(Echantillon e)` qui ouvre une boîte de confirmation
  (`AlertDialog`, mêmes titre/texte/boutons que `_onSupprimer` dans
  `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` ~L210-249 — adapte juste le
  texte de confirmation à `e.ref`/`e.referenceBouteille`), qui appelle
  `_service.deleteEchantillon(e.id)`, retire l'élément de `_echantillons` en cas de succès, et
  affiche succès/erreur. Bloque en mode démonstration comme les autres actions.
- Sur la carte (`ListView.builder`, ~L468-475), passe :
  ```dart
  onSupprimer: _peutSupprimer(e) ? () => _onSupprimer(e) : null,
  ```
  où `_peutSupprimer` est une nouvelle petite méthode :
  ```dart
  bool _peutSupprimer(Echantillon e) => e.canDelete && e.collecteurId.trim().isEmpty;
  ```
  `e.canDelete` existe déjà sur `Echantillon` (`lib/core/models/echantillon.dart` ~L111) et
  vaut vrai tant que le statut est "réceptionné" et que l'échantillon n'est pas encore reçu
  physiquement — la même règle que pour le collecteur. `collecteurId.trim().isEmpty` est le
  signal déjà utilisé en tâche 20 pour dire "cet échantillon n'a pas été enregistré par un
  collecteur" (un `collecteur` serveur à `null` devient une chaîne vide côté client, voir
  `_toFlutterMap` juste au-dessus dans ce même fichier de service).
- `onModifier` existe déjà (`_ouvrirModification`, ~L161) — ne le touche pas.

### 4. Page du chef dégustateur — même chose, plus le modifier qui manque

Dans `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`, cette page
n'a **aucun** des trois boutons aujourd'hui (ni ajouter, ni modifier, ni supprimer — la carte
n'y reçoit que `onToggleRecu`). Applique exactement le point 3 ci-dessus à ce fichier, en
ajoutant en plus ce qui existe déjà côté dégustateur mais pas ici :
- `_ouvrirModification(Echantillon e)`, qui ouvre `showFormulaireDialog` en mode modification
  et appelle `_service.updateEchantillon(...)` (`updateEchantillon` existe déjà dans le
  service, rien à y ajouter) — reprends le corps de la méthode équivalente côté dégustateur
  (~L161-174).
- Un getter `_prochainNumero` (comme côté dégustateur, ~L117 : `_echantillons.length + 1`).
- Importe `widgets/dialogs/formulaire_dialog.dart` (le fichier existe déjà dans ce module,
  voir Contexte).
- Passe `onModifier: () => _ouvrirModification(e)` en plus de `onSupprimer` sur la carte.

### 5. Vérifie qu'il n'y a pas d'import circulaire ni de référence cassée

`grep` sur `MesEchantillonsPage` dans `3_degustateur/` et `5_chef_degustateur/` pour
confirmer qu'il ne reste plus aucune référence après le point 1.

---

## Ce que tu ne fais pas

- Tu ne touches pas à `backend_new/echantillons/views.py` ni `serializers.py` : les
  permissions sont déjà correctes depuis la tâche 20, et le serializer sait déjà résoudre
  `code_fournisseur`/`fournisseur_nom`.
- Tu ne touches pas aux filtres de statut ni à l'apparence générale des deux pages
  "Gestion des échantillons" — seuls le FAB et les boutons sur la carte changent.
- Tu ne fusionnes pas les deux `formulaire_dialog.dart` (dégustateur / chef) en un seul
  fichier partagé, même si CLAUDE.md le suggérerait à terme — ce n'est pas demandé ici,
  signale-le sous `## HORS PÉRIMÈTRE` si tu veux, mais n'y touche pas.
- Tu ne corriges pas la capture de photo dans `formulaire_dialog.dart` (dégustateur et chef) :
  en la relisant, la photo choisie (`_photoBytes`/`row.photoBytes`) n'est jamais transmise à
  `onSaveMultiple` ni envoyée au serveur — un bouton qui ne sert à rien aujourd'hui. Si tu
  confirmes ce constat, note-le sous `## HORS PÉRIMÈTRE` sans le corriger : ce n'est pas ce
  qui a été demandé, et y toucher élargirait la tâche.
- Tu ne changes rien à `EchantillonCard` (`lib/core/widgets/gestion_echantillons/`) : elle
  accepte déjà `onModifier`/`onSupprimer`, rien à y ajouter.
- Tu ne changes rien au comportement du collecteur au-delà du retrait décrit au point 1 (qui
  doit le ramener texto à son état d'avant la tâche 20 — pas moins, pas plus).

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport. Référence : 49 diagnostics/0 erreur,
108 tests (107 réussis + 1 échec déjà connu) avant cette tâche.

## RAPPORT

### Fait

- `lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart` : l'entrée "Mes échantillons" a été retirée ; le dégustateur garde uniquement "Gestion des échantillons" dans la section échantillons.
- `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` : l'entrée "Mes échantillons" a été retirée ; le chef garde uniquement "Gestion des échantillons" dans la section échantillons.
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` : la page est redevenue propre au collecteur, avec son constructeur simple, son drawer collecteur, sa cloche de notifications et ses actions achat/livraison sans conditions de partage.
- `lib/core/services/gestion_echantillons_service.dart` : ajout de `createEchantillon`, `deleteEchantillon` et d'un mapping Django qui n'envoie pas `id`, `ref/numero`, collecteur, ni champs de décision Direction depuis les formulaires dégustateur/chef.
- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : ajout du FAB "Ajouter", création via serveur, bouton suppression conditionnel sur les cartes, confirmation de suppression et blocage en mode démonstration.
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : ajout du FAB "Ajouter", création via serveur, bouton modifier, bouton suppression conditionnel sur les cartes, confirmation de suppression et blocage en mode démonstration.

### Vérifié

```bash
rg -n "MesEchantillonsPage|mes_echantillons_page" lib/3_degustateur lib/5_chef_degustateur
```

Sortie brute : aucune sortie, code retour 1 (aucune occurrence trouvée).

```bash
rg -n "drawerPersonnalise|afficherExtrasCollecteur|_loadRoleConnecte|_roleConnecte|_canDeleteForCurrentRole|RoleUtilisateur|authService|widget\." lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart
```

Sortie brute : aucune sortie, code retour 1 (aucune occurrence trouvée).

```bash
git diff --check
```

Sortie brute : code retour 0, uniquement des avertissements CRLF sur les fichiers modifiés et sur `files/taches/ETAT.md` déjà modifié avant cette tâche.

```bash
dart format lib/core/services/gestion_echantillons_service.dart lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart
```

Sortie brute : `command timed out after 120114 milliseconds`, aucune sortie de formatage.

```bash
flutter analyze lib test
```

Sortie brute : `command timed out after 900066 milliseconds`, aucune sortie de diagnostics.

```bash
flutter test
```

Sortie brute : `command timed out after 900116 milliseconds`, aucune sortie de tests.

```bash
dart --version
```

Sortie brute : `command timed out after 30226 milliseconds`.

### Non fait

- Les deux vérifications Flutter demandées n'ont pas produit de chiffres exploitables dans cette session : `flutter analyze lib test` et `flutter test` ont chacune expiré après 15 minutes sans sortie. `dart --version` expire aussi, ce qui indique un blocage de l'outil Dart/Flutter dans l'environnement courant.

### HORS PÉRIMÈTRE

- Confirmé sans correction : dans `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`, la photo choisie via `_photoBytes` / `row.photoBytes` n'est pas transmise à `onSaveMultiple` ni envoyée au serveur.
- Je n'ai pas fusionné les deux `formulaire_dialog.dart` dégustateur/chef, conformément à la consigne.

### Reprise — vérifié par Claude

Codex n'a pas pu conclure ses propres vérifications (même blocage d'environnement que sur
plusieurs tâches précédentes). Claude a relu le diff en entier puis lancé les vérifications
lui-même, hors du bac à sable de Codex.

Un vrai défaut trouvé à la relecture : `lib/core/services/gestion_echantillons_service.dart`
utilisait `e.statutCollecteur.toJson`, un accesseur d'extension défini dans
`core/models/enums.dart` — fichier non importé dans ce service (seul `echantillon.dart` l'était,
qui ne le ré-exporte pas). `flutter analyze` le confirmait par une vraie erreur de compilation
(`undefined_getter`). Corrigé en ajoutant `import 'package:project3/core/models/enums.dart';`
en tête de fichier.

```bash
dart format lib/core/services/gestion_echantillons_service.dart lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart
```
Sortie brute : `Formatted 6 files (4 changed) in 0.30 seconds.`

```bash
flutter analyze lib test
```
Sortie brute (après le correctif) : `49 issues found.` — 0 erreur, conforme à la référence
(49 avant cette tâche).

```bash
flutter test
```
Sortie brute : `108 tests`, **107 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.
