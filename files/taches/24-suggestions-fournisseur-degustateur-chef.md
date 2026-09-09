# Tâche 24 — Suggestions de fournisseur (façon Google) pour le dégustateur et le chef

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Modules concernés : `3_degustateur/gestion_echantillons`, `5_chef_degustateur/gestion_echantillons`.
Rien à toucher côté backend — tout ce qu'il faut existe déjà et fonctionne.

---

## Contexte

Le propriétaire veut, pour le champ "Nom / Code fournisseur" des formulaires
d'enregistrement, un champ à suggestions comme la barre de recherche Google : on tape,
des suggestions de fournisseurs déjà connus apparaissent, on clique sur une pour la
reprendre, ou on continue de taper librement pour en créer un nouveau. Le but réel : éviter
qu'un même fournisseur soit enregistré sous plusieurs orthographes ("Ben Ali", "ben ali",
"BenAli"), ce qui fausserait les statistiques du tableau de bord (comptage par fournisseur).

**Cette fonctionnalité existe déjà, entièrement construite et déjà utilisée par le
collecteur** — elle n'est simplement pas branchée dans les formulaires du dégustateur et du
chef. Rien de nouveau à concevoir, seulement à répliquer un branchement existant.

Regarde `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` comme
référence complète :

1. Le widget partagé `ChampAutocomplete<T>`
   (`lib/core/widgets/champ_autocomplete.dart`) : un champ texte avec liste de suggestions
   qui s'ouvre sous le champ pendant la frappe (debounce 200ms), qu'on peut ignorer et
   continuer à taper librement. Déjà générique, rien à y changer.
2. `FournisseurService.instance.suggest` (`lib/core/services/fournisseur_service.dart`,
   méthode `suggest`, ~L52) : donne jusqu'à 6 fournisseurs déjà enregistrés qui correspondent
   à ce qui est tapé. Déjà écrite, déjà branchée à `GET /api/fournisseurs/` (endpoint déjà
   ouvert au dégustateur et au chef côté serveur — vérifié dans
   `backend_new/fournisseurs/views.py`, `permission_classes` inclut déjà `IsDegustateur` et
   `IsChefDegustation`).
3. Le branchement lui-même, dans le formulaire du collecteur
   (`2_collecteur/.../formulaire_dialog.dart`, ~L470-487) :

```dart
ChampAutocomplete<Fournisseur>(
  label: 'Nom / Code fournisseur',
  controller: _codeFournisseurCtrl,
  hint: 'Ex: Domaine Bel-Air',
  chercher: FournisseurService.instance.suggest,
  libelle: (f) => f.nom,
  sousTitre: (f) => f.region,
  onSelection: (f) {
    _fournisseurChoisi = f;
    _actualiserToutesLesReferences();
  },
  onSaisieLibre: () {
    _fournisseurChoisi = null;
    _actualiserToutesLesReferences();
  },
),
```

   `_actualiserToutesLesReferences()` est propre au collecteur (référence de bouteille
   auto-calculée, tâche 14) — **le dégustateur et le chef n'ont pas cette méthode et ne
   doivent pas l'appeler.**

4. Le filet de sécurité au moment d'enregistrer, dans le même fichier collecteur
   (méthode `_verifierFournisseur()`, ~L265-296, appelée depuis `_save()` juste avant
   `Navigator.pop(context)`) : si ce qui a été tapé ressemble beaucoup à un fournisseur déjà
   connu (typo, casse différente...) mais n'a pas été choisi dans les suggestions,
   `DialogDoublonFournisseur.afficher(...)` (`lib/core/widgets/dialog_doublon_fournisseur.dart`)
   propose de reprendre le fournisseur existant plutôt que d'en créer un doublon. C'est ce
   filet, en plus des suggestions à la frappe, qui protège vraiment les statistiques — les
   deux vont ensemble.

---

## CONSIGNE

Fais exactement la même chose dans les deux fichiers suivants :

- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`
- `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`

### 1. Imports

Ajoute, dans chaque fichier :

```dart
import '../../../../core/models/fournisseur.dart';
import '../../../../core/services/fournisseur_service.dart';
import '../../../../core/widgets/champ_autocomplete.dart';
import '../../../../core/widgets/dialog_doublon_fournisseur.dart';
```

(Ajuste le nombre de `../` si besoin pour que ça pointe bien vers `lib/core/...` — vérifie en
regardant les imports déjà présents dans le même fichier, ex. celui vers
`core/models/echantillon.dart`.)

### 2. État

Dans la classe d'état du dialogue (`_FormulaireDialogState`), ajoute :

```dart
Fournisseur? _fournisseurChoisi;
```

### 3. Remplace le champ

Là où se trouve aujourd'hui (dégustateur ~L509-513, chef ~L338-342) :

```dart
_FormField(
  label: 'Nom / Code fournisseur',
  controller: _codeFournisseurCtrl,
  hint: 'Ex: Domaine Bel-Air',
),
```

remplace par :

```dart
ChampAutocomplete<Fournisseur>(
  label: 'Nom / Code fournisseur',
  controller: _codeFournisseurCtrl,
  hint: 'Ex: Domaine Bel-Air',
  chercher: FournisseurService.instance.suggest,
  libelle: (f) => f.nom,
  sousTitre: (f) => f.region,
  onSelection: (f) => _fournisseurChoisi = f,
  onSaisieLibre: () => _fournisseurChoisi = null,
),
```

Pas d'appel à `_actualiserToutesLesReferences()` : cette méthode n'existe pas dans ces deux
fichiers, et ce n'est pas demandé de l'y ajouter.

### 4. Le filet de sécurité au moment d'enregistrer

Ajoute une méthode, copiée du collecteur (adapte juste le message si tu veux, le
comportement doit rester identique) :

```dart
Future<void> _verifierFournisseur() async {
  final saisi = _codeFournisseurCtrl.text.trim();
  if (saisi.isEmpty) return;

  if (_fournisseurChoisi != null && _fournisseurChoisi!.nom.trim() == saisi) {
    return;
  }

  final resultatProches =
      await FournisseurService.instance.findNearDuplicates(saisi);
  if (resultatProches.estDemonstration) return;

  final proches = resultatProches.donnees;
  if (proches.isNotEmpty && mounted) {
    final choisi = await DialogDoublonFournisseur.afficher(
      context,
      nomSaisi: saisi,
      proches: proches,
    );
    if (choisi != null) {
      _codeFournisseurCtrl.text = choisi.nom;
      _fournisseurChoisi = choisi;
    }
  }
}
```

Puis, dans `_save()` (dégustateur ~L358, chef ~L187) :
- Change la signature en `Future<void> _save() async {`.
- Juste après le bloc `if (!_isValid) { ...; return; }` et **avant** `Navigator.pop(context)`,
  ajoute :

```dart
await _verifierFournisseur();
if (!mounted) return;
```

Le reste de `_save()` (construction des `Echantillon`, appel à `onSaveMultiple`) ne change
pas. Vérifie que le bouton qui appelle `_save` (`onPressed: _save` dans les actions du
dialogue) compile toujours tel quel — c'est le même motif que le collecteur, qui compile
déjà avec un `_save` async à cet endroit.

---

## Ce que tu ne fais pas

- Tu ne touches à rien côté serveur (`backend_new/`) : l'endpoint et les permissions sont
  déjà corrects.
- Tu ne modifies pas `champ_autocomplete.dart`, `fournisseur_service.dart`,
  `dialog_doublon_fournisseur.dart`, ni le formulaire du collecteur : ils servent de
  référence, pas de cible.
- Tu ne touches pas au champ "Variété" ni à aucun autre champ de ces formulaires.
- Tu ne fusionnes pas les deux `formulaire_dialog.dart` (dégustateur / chef) en un seul
  fichier partagé, même si CLAUDE.md le suggérerait à terme — pas demandé ici, signale-le
  sous `## HORS PÉRIMÈTRE` si tu veux, sans y toucher.
- Tu ne touches pas au modèle `Echantillon` (`core/models/echantillon.dart`) :
  `fournisseurId` reste tel quel, `_fournisseurChoisi` sert uniquement au filet de sécurité
  local, pas à ce qui est envoyé au serveur (le serveur résout déjà le fournisseur à partir
  du nom tapé, comme pour le collecteur).

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport. Référence : 49 diagnostics/0 erreur,
108 tests (107 réussis + 1 échec déjà connu) avant cette tâche.

## RAPPORT

*Rapport rédigé par Claude : le processus Codex qui a écrit le code ci-dessous s'est bloqué
avant de pouvoir lancer ses vérifications (même symptôme que sur plusieurs tâches ce soir).
Le code, lui, était complet et correct : Claude l'a relu intégralement puis vérifié
lui-même plutôt que de relancer Codex sur un travail déjà fait.*

### Fait

- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : le champ
  "Nom / Code fournisseur" propose maintenant des suggestions pendant la frappe (les
  fournisseurs déjà connus), comme chez le collecteur. Ajout du filet de sécurité
  `_verifierFournisseur()` appelé avant l'enregistrement.
- `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` :
  identique.
- Aucun fichier partagé (`champ_autocomplete.dart`, `fournisseur_service.dart`,
  `dialog_doublon_fournisseur.dart`) ni le formulaire du collecteur n'a été modifié — utilisés
  tels quels, en lecture seule.
- Aucun changement côté serveur : l'endpoint et les permissions étaient déjà corrects.

### Vérifié

```bash
dart format lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
```
Sortie brute : `Formatted 2 files (2 changed) in 0.32 seconds.`

```bash
flutter analyze lib test
```
Sortie brute : `49 issues found.` — 0 erreur, conforme à la référence.

```bash
flutter test
```
Sortie brute : `108 tests`, **107 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.

### Non fait

Rien.

### HORS PÉRIMÈTRE

Rien de nouveau signalé. Le doublon `formulaire_dialog.dart` entre dégustateur et chef
(déjà pré-existant, hors périmètre de cette tâche) reste non fusionné, comme demandé.
