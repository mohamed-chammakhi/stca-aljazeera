# Tâche 19 — Un champ pour un lieu précis, hors de la liste gouvernorat/délégation

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Modules concernés : `2_collecteur`, `3_degustateur`, `5_chef_degustateur`.

---

## Contexte

Vérifié avant d'écrire cette tâche : la liste des gouvernorats et délégations
(`assets/img/delegations.geojson`, lue par `GeoService`) est déjà complète — **24
gouvernorats, 264 délégations**, comptés directement dans le fichier. Ce n'est donc pas la
liste qu'il faut agrandir.

Ce qui manque : un endroit précis (village, lieu-dit, ferme...) ne rentre jamais dans une
liste de délégations, quelle qu'elle soit — une délégation couvre une zone entière. Le
propriétaire veut un champ texte libre pour que le collecteur précise ce niveau de détail
quand le gouvernorat + la délégation ne suffisent pas.

Bonne nouvelle : ce champ **existe déjà à moitié**. `EchantillonCollecteur` a un champ
`cite` (`lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart` L85), lu
depuis l'API (`fromJson` L192), mais **jamais renvoyé** — `toJson()` (L226-247) ne l'inclut
pas. Le modèle partagé du dégustateur/chef dégustateur
(`lib/core/models/echantillon_evaluation.dart`) n'a pas ce champ du tout.

---

## CONSIGNE

### 1. Collecteur

- Dans `EchantillonCollecteur.toJson()`, ajoute `'cite': cite ?? '',` — le champ existe déjà
  côté modèle, il manque juste à l'envoi.
- Dans `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`, ajoute un
  champ texte libre juste après le champ "Délégation" (~L517), label **"Lieu précis
  (optionnel)"**, indice **"Ex: nom du village, du lieu-dit..."**, lié à `_gouvernorat`'s
  voisin `_delegation` — utilise le champ `cite` du modèle. Pré-remplis-le en modification
  (`e?.cite`), envoie sa valeur dans `_save()` comme les autres champs texte du formulaire
  (vide → `null`, comme `remarques`).

### 2. Dégustateur et chef dégustateur

- Ajoute `cite` à `lib/core/models/echantillon_evaluation.dart` (`String? cite`), avec
  lecture/écriture JSON comme `gouvernorat`/`delegation` (~L27-28, L41-42, L57-58, L73-74).
- Dans les deux formulaires
  (`lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` ~L546 et
  `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`,
  section "SHARED: LOCALISATION" équivalente), ajoute le même champ, au même endroit
  (juste après "Délégation"), avec le même label et le même indice que pour le collecteur.
  **Les deux formulaires doivent avoir exactement le même texte** — c'est la règle 1 du
  `CLAUDE.md`.

---

## Ce que tu ne fais pas

- Tu ne touches pas à `assets/img/delegations.geojson` ni à `GeoService` : la liste
  gouvernorat/délégation ne change pas.
- Tu ne fusionnes pas les deux formulaires dégustateur/chef dégustateur en un seul fichier —
  ce n'est pas le sujet ici (voir tâche 09 pour le pourquoi de cette séparation actuelle).
- Tu ne rends pas ce champ obligatoire.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport.

## RAPPORT

### Fait

- `lib/core/models/echantillon_evaluation.dart` : les listes d'évaluation du dégustateur et du chef peuvent maintenant lire et renvoyer le lieu précis `cite`.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` : le collecteur dispose d'un champ libre "Lieu précis (optionnel)" après la délégation, prérempli en modification et enregistré avec l'échantillon.
- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : le dégustateur dispose du même champ libre, au même endroit, avec le même texte.
- `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : le chef dégustateur dispose du même champ libre, au même endroit, avec le même texte.

### Vérifié

```bash
dart format lib/core/models/echantillon_evaluation.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
```

Sortie réelle : `Exit code 124`, `command timed out after 120100 milliseconds`. Aucune sortie stdout/stderr avant expiration.

```bash
flutter analyze lib test
```

Sortie réelle : `Exit code 124`, `command timed out after 900132 milliseconds`. Aucune sortie stdout/stderr avant expiration.

```bash
flutter test
```

Sortie réelle : `Exit code 124`, `command timed out after 900056 milliseconds`. Aucune sortie stdout/stderr avant expiration.

Commandes de diagnostic également tentées après le blocage initial de Flutter/Dart :

```bash
flutter --version
```

Sortie réelle : `Exit code 124`, `command timed out after 120137 milliseconds`. Aucune sortie stdout/stderr avant expiration.

```bash
flutter --no-version-check analyze lib test
```

Sortie réelle : `Exit code 124`, `command timed out after 900136 milliseconds`. Aucune sortie stdout/stderr avant expiration.

```bash
flutter --no-version-check test
```

Sortie réelle : `Exit code 124`, `command timed out after 900118 milliseconds`. Aucune sortie stdout/stderr avant expiration.

### Non fait

- Rien de demandé n'a été laissé volontairement de côté. `EchantillonCollecteur.toJson()` contenait déjà `'cite': cite ?? '',` à l'ouverture de la tâche, donc aucun diff n'était nécessaire dans ce fichier.

### HORS PÉRIMÈTRE

- L'outil Flutter/Dart local bloque avant toute sortie, y compris sur `flutter --version`; je n'ai pas modifié l'environnement SDK.

### Complément — vérification par Claude

Le blocage de l'outillage venait de l'extension Dart/Flutter de VS Code, tombée dans un état
corrompu (Dart Analyzer et Flutter Daemon plantés) à force de commandes `flutter` lancées en
parallèle par Claude et par Codex. Une fois VS Code rechargé, Claude a vérifié :

```bash
dart format lib/core/models/echantillon_evaluation.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
```
Sortie brute : `Formatted 4 files (3 changed) in 0.08 seconds.`

```bash
flutter analyze lib test
```
Sortie brute : `49 issues found. (ran in 3.0s)` — 0 erreur, conforme à la référence.

```bash
flutter test
```
Sortie brute : `103 tests`, **102 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.

Vérifié aussi côté serveur : `backend_new/echantillons/models.py` et `serializers.py`
possèdent déjà le champ `cite` (migration `0004`) — aucune migration Django nécessaire,
la donnée sera bien reçue et persistée.
