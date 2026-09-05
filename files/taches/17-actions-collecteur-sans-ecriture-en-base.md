# Tâche 17 — Ajouter/modifier/supprimer un échantillon sans écrire en base, en mode démonstration

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Module concerné : `2_collecteur` uniquement.
Fichier : `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart`.

---

## Contexte

Le propriétaire veut pouvoir essayer toutes les actions du module collecteur (ajouter,
modifier, supprimer un échantillon) juste pour voir le résultat à l'écran, **sans qu'aucune
écriture ne parte vers le serveur réel**, **sans bouton ni interrupteur à activer**, et
**sans perdre les données de démonstration existantes**.

Le mécanisme qu'il faut est déjà à moitié là. L'application entre déjà automatiquement en
mode démonstration (bandeau orange "Données de démonstration — serveur injoignable",
`lib/core/widgets/bandeau_demonstration.dart`) dès que le serveur Django ne répond pas —
et seulement en dehors d'un build de production (`avecSecours()`,
`lib/core/services/resultat_service.dart`, rethrow si `kReleaseMode`). C'est ce bandeau
qui sert d'indication : pas besoin d'en ajouter une autre.

Le problème : une fois dans ce mode, les quatre méthodes d'écriture de
`EchantillonCollecteurService` **refusent** l'action au lieu de l'appliquer localement :

```dart
if (_usingMockData) {
  throw StateError('Création indisponible avec les données de démonstration.');
}
```

Present dans `createEchantillon` (~L174), `createEchantillonWithImage` (~L188),
`updateEchantillon` (~L213), `deleteEchantillon` (~L229).

---

## CONSIGNE

Dans ces quatre méthodes, quand `_usingMockData` est vrai, **n'envoie rien au serveur** et
simule un succès au lieu de lancer une exception :

1. `createEchantillon(e)` et `createEchantillonWithImage(e, ...)` : renvoie `e` tel quel
   (l'appelant, `mes_echantillons_page.dart`, construit déjà un objet complet côté client
   avant l'appel — regarde `formulaire_dialog.dart` `_save()` pour voir comment l'id et le
   numéro sont déjà générés localement). N'essaie pas d'envoyer l'image dans
   `createEchantillonWithImage` en mode démonstration : ignore `imageBytes`/`filename`,
   renvoie l'échantillon sans photo.
2. `updateEchantillon(e)` : renvoie `e` tel quel, sans appeler `_api.patch`.
3. `deleteEchantillon(id)` : ne fait rien (pas d'appel réseau), renvoie normalement.

Le résultat attendu : le collecteur ajoute/modifie/supprime un échantillon exactement comme
d'habitude, la carte apparaît/se met à jour/disparaît dans la liste comme avec un vrai
serveur, le bandeau orange reste affiché pour rappeler que rien n'est enregistré, et rien
n'est perdu au rechargement des données de démonstration (`mockEchantillons()` n'est pas
modifiée : elle reste la même liste de scénarios de départ à chaque redémarrage).

---

## Ce que tu ne fais pas

- Tu ne touches pas à `confirmerAchat()` : elle continue de refuser l'action en mode
  démonstration pour l'instant, ce n'est pas dans cette tâche.
- Tu ne changes rien au comportement quand le serveur répond normalement.
- Tu ne construis aucun interrupteur ni bouton "mode aperçu" : le comportement est
  automatique, déclenché par l'échec de connexion au serveur, comme aujourd'hui.
- Tu ne touches à aucun autre module que `2_collecteur`.
- Tu ne modifies pas `mockEchantillons()` ni les scénarios de démonstration existants.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport.

## RAPPORT

### Fait

- `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart` :
  en mode demonstration, le collecteur peut maintenant ajouter, modifier et supprimer un
  echantillon a l'ecran sans envoyer d'ecriture au serveur; les donnees de demonstration
  initiales restent intactes au rechargement.

### Verifie

```bash
dart format lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart
```

Sortie reelle :

```text
Exit code: 124
command timed out after 120142 milliseconds
```

Relance :

```bash
dart format lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart
```

Sortie reelle :

```text
Exit code: 124
command timed out after 300108 milliseconds
```

Controle local du diff applique :

```bash
rg -n -C 2 "if \(_usingMockData\)|return e;|return;|confirmerAchat|Confirmation indisponible" lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart
```

Sortie reelle :

```text
175-    EchantillonCollecteur e,
176-  ) async {
177:    if (_usingMockData) {
178:      return e;
179-    }
180-    final response = await _api.post('/api/echantillons/', _toDjangoMap(e));
--
189-    required String filename,
190-  }) async {
191:    if (_usingMockData) {
192:      return e;
193-    }
194-    final dj = _toDjangoMap(e);
--
210-    EchantillonCollecteur e,
211-  ) async {
212:    if (_usingMockData) {
213:      return e;
214-    }
215-    final response = await _api.patch(
--
222-  /// Deletes an echantillon by ID.
223-  Future<void> deleteEchantillon(String id) async {
224:    if (_usingMockData) {
225:      return;
226-    }
227-    await _api.delete('/api/echantillons/$id/');
--
232-  /// Calls `PATCH /api/echantillons/<id>/confirmer_achat/` with optional
233-  /// [prixFinal], [camionLivraison], and [remarqueCollecteur] values.
234:  Future<EchantillonCollecteur> confirmerAchat(
235-    String id, {
236-    String? prixFinal,
--
238-    String? remarqueCollecteur,
239-  }) async {
240:    if (_usingMockData) {
241-      throw StateError(
242:        'Confirmation indisponible avec les données de démonstration.',
243-      );
244-    }
```

```bash
flutter analyze lib test
```

Sortie reelle :

```text
Exit code: 124
command timed out after 900126 milliseconds
```

Relance sans resolution de paquets :

```bash
flutter analyze --no-pub lib test
```

Sortie reelle :

```text
Exit code: 124
command timed out after 900133 milliseconds
```

Controle de l'outillage Flutter :

```bash
flutter --version
```

Sortie reelle :

```text
Exit code: 124
command timed out after 60130 milliseconds
```

Controle de l'outillage Dart :

```bash
dart --version
```

Sortie reelle :

```text
Exit code: 124
command timed out after 60170 milliseconds
```

```bash
flutter test
```

Sortie reelle :

```text
Exit code: 124
command timed out after 900141 milliseconds
```

### Non fait

- Sorties chiffrees completes de `flutter analyze lib test` et `flutter test` non obtenues :
  les commandes Flutter/Dart se bloquent dans cet environnement avant d'afficher leurs
  diagnostics, y compris `flutter --version` et `dart --version`.

### HORS PERIMETRE

- L'outillage Flutter/Dart local semble bloque ou deja occupe par un processus Dart du SDK
  (`C:\Users\takwa\Documents\flutter\bin\cache\dart-sdk\bin\dart.exe`). Je ne l'ai pas corrige,
  car la tache demandait uniquement le comportement du service collecteur.

### Complément — vérification par Claude

Diagnostic confirmé : Claude faisait tourner `flutter clean` puis `flutter run -d windows`
en parallèle pendant que Codex travaillait, ce qui a saturé le même verrou du SDK Flutter.
Une fois ces commandes terminées, Claude a relu le diff (conforme à la consigne — les 4
méthodes changées, `confirmerAchat` inchangée, aucun autre fichier touché) et exécuté :

```bash
dart format lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart
```
Sortie brute : `Formatted 1 file (1 changed) in 0.02 seconds.`

```bash
flutter analyze lib test
```
Sortie brute : `50 issues found. (ran in 3.2s)` — 0 erreur, conforme à la référence.

```bash
flutter test
```
Sortie brute : `103 tests`, **102 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.
