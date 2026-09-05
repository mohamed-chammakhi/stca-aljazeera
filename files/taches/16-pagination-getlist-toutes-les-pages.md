# Tâche 16 — `getList()` doit ramener toutes les pages, pas seulement la première

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.
La **règle 1** du `CLAUDE.md` s'applique : un seul endroit à corriger pour que ça se répare
partout.

Fichier concerné : `lib/core/api_client.dart`, méthode `getList()` (~L210-221).

---

## Contexte — défaut vérifié, pas une supposition

Le backend Django pagine ses listes par défaut :
`backend_new/aljazeera_stca/settings.py:172-173` fixe
`DEFAULT_PAGINATION_CLASS = PageNumberPagination` et `PAGE_SIZE = 50`.

`ApiClient.getList()` appelle l'URL une seule fois, lit `results` dans la réponse, et jette
`count` / `next`. Toute page au-delà de la première est donc **silencieusement invisible**
dans l'application — pour n'importe quel rôle, puisque `getList()` est la méthode partagée
utilisée par tous les services de liste.

Avec les données de démonstration actuelles (quelques échantillons par rôle) ça ne se voit
pas. Ça deviendra un vrai problème dès qu'un rôle dépassera 50 échantillons avec le vrai
serveur — ce qui arrivera en usage réel.

---

## CONSIGNE

Modifie `getList()` pour qu'elle ramène **la totalité** des résultats, pas seulement la
première page :

- Si la réponse est un objet paginé (`results` + `next`), suis `next` et concatène jusqu'à ce
  qu'il n'y ait plus de page suivante, puis renvoie la liste complète.
- Si la réponse est déjà une simple liste (cas non paginé, déjà géré), ne change rien.
- Aucun appelant de `getList()` ne doit changer : la méthode continue de renvoyer
  `Future<List<dynamic>>`, juste complet au lieu de tronqué à 50.

Ce n'est **pas** une demande de défilement infini ni de chargement page par page côté
interface — juste que la liste renvoyée soit complète. Si tu penses qu'un vrai système de
pagination à l'affichage serait nécessaire pour de très gros volumes, dis-le sous
`## HORS PÉRIMÈTRE`, mais ne le construis pas ici.

---

## Ce que tu ne fais pas

- Tu ne touches à aucun service appelant (`EchantillonCollecteurService` etc.) : seule
  `getList()` change.
- Tu ne changes pas le comportement de `post`, `put`, `delete`.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport.

## RAPPORT

### Note sur l'exécution

Codex a écrit le correctif ci-dessous puis son processus s'est interrompu (redémarrage de la
session Claude en cours de tâche) avant d'avoir pu lancer la vérification ni écrire ce
rapport. Claude a relu le code, jugé qu'il correspondait exactement à la consigne, et a
lui-même exécuté la vérification ci-dessous plutôt que de relancer Codex sur un travail déjà
fait.

### Fait

- `lib/core/api_client.dart` : `getList()` suit maintenant le champ `next` de la réponse
  paginée Django et concatène chaque page jusqu'à épuisement, au lieu de ne renvoyer que la
  première page. Ajout de `_uriFromPathOrUrl()` : `next` renvoyé par Django est une URL
  absolue, pas un chemin relatif, il ne faut donc pas lui recoller `baseUrl`. Le cas non
  paginé (liste brute) est inchangé. Aucun appelant n'a été modifié.

### Vérifié

```bash
dart format lib/core/api_client.dart
```
Sortie brute : `Formatted 1 file (0 changed) in 0.11 seconds.`

```bash
flutter analyze lib test
```
Sortie brute : `50 issues found. (ran in 144.6s)` — 0 erreur, conforme à la référence
(50 diagnostics, 0 erreur).

```bash
flutter test
```
Sortie brute : `103 tests` au total, **102 réussis**, 1 échec — le seul déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.

### Non fait

Rien.

### HORS PÉRIMÈTRE

Rien de nouveau au-delà de ce que la consigne signalait déjà (système de pagination à
l'affichage non construit ici, comme demandé).
