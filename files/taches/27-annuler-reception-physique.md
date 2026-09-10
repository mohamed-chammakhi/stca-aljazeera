# Tâche 27 — Permettre d'annuler une réception physique confirmée, avec
# notification dans les deux sens

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Backend Django (`backend_new/`) + frontend Flutter (dégustateur, chef dégustateur).
**Le propriétaire du projet a explicitement confirmé qu'il veut cette capacité** — ce
n'est pas une supposition : « oui je veux permettre d'annuler une réception physique
confirmée (et notifier dans les deux sens) ».

---

## Contexte — état actuel vérifié dans le code

Aujourd'hui, cocher « reçu physiquement » (dégustateur ou chef dégustateur, page
« Gestion des échantillons ») fonctionne et notifie déjà (voir tâche 26, qui ajoute le
collecteur et le laboratoire comme destinataires de cette coche). **Mais décocher est
bloqué en dur, des deux côtés, par du code dupliqué identique :**

- [`lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`](../../lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart)
  `_onToggleRecu` (~ligne 210) :
  ```dart
  if (e.recuPhysiquement) {
    _showError('Une réception confirmée ne peut pas être annulée.');
    return false;
  }
  ```
- [`lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`](../../lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart)
  `_onToggleRecu` (~ligne 231) : exactement le même bloc.

Le dialogue de confirmation ([`echantillon_card.dart`](../../lib/core/widgets/gestion_echantillons/echantillon_card.dart),
`_RecuConfirmDialog`) gère déjà visuellement les deux sens (`isConfirming: willBeReceived`)
— seul le traitement après confirmation refuse le sens inverse.

Côté serveur, [`backend_new/echantillons/views.py`](../../backend_new/echantillons/views.py)
(~ligne 201) n'a qu'une action `confirmer_reception` (alias `confirmer-reception`),
`permission_classes=[IsDegustateur | IsChefDegustation]`, qui met `recu_physiquement` à
`True` et pose `date_reception_echantillon`. **Aucune action inverse n'existe.**

Côté service Flutter partagé,
[`lib/core/services/gestion_echantillons_service.dart:122`](../../lib/core/services/gestion_echantillons_service.dart#L122) :
```dart
Future<void> toggleRecuPhysiquement(String id, bool value) async {
  await apiClient.patch('/api/echantillons/$id/confirmer-reception/', {});
}
```
Le paramètre `value` est **ignoré** — l'appel est toujours le même, quel que soit son
contenu. C'est pour ça que décocher n'a jamais eu d'effet réel même si on retirait le
blocage frontend seul.

---

## CONSIGNE

### 1. Backend — nouvelle action pour annuler la réception

Dans `backend_new/echantillons/views.py`, ajoute une action symétrique à
`confirmer_reception`, par exemple `annuler_reception` (+ variante `annuler-reception`
avec tiret, même schéma que l'existante) :
- mêmes `permission_classes=[IsDegustateur | IsChefDegustation]`
- si `obj.recu_physiquement` est `True` : le remet à `False`. Laisse
  `date_reception_echantillon` tel quel ou remets-le à `None` — **choisis en cohérence
  avec l'usage qu'en fait `EchantillonCeoView`/`dateReceptionEchantillon` côté CEO (la
  carte CEO l'affiche comme "reçu le ...")** : si le champ reste rempli après une
  annulation, la carte CEO redirait "reçu le" pour un échantillon qui ne l'est plus tant
  que `recu_physiquement` est vrai à nouveau. Mets-le à `None` à l'annulation, c'est
  l'option cohérente.
- idempotent comme l'originale (si déjà `False`, ne fait rien de plus qu'un retour de
  l'objet tel quel)

Vérifie si l'échantillon est verrouillé ailleurs contre ce changement (par exemple un
statut déjà avancé en négociation/achat confirmé côté CEO) : si un tel garde-fou existe
déjà pour d'autres champs, applique le même raisonnement ici ; sinon n'en invente pas —
la demande du propriétaire est d'autoriser l'annulation, pas de la restreindre
davantage que ce qui est explicitement demandé.

### 2. Backend — notifications dans les deux sens (`backend_new/notifications/signals.py`)

Le signal `on_echantillon_saved` a déjà (après la tâche 26) une branche
`if old_recu is False and instance.recu_physiquement:` qui notifie Direction, Chef
dégustation, le collecteur et le laboratoire. Ajoute la branche symétrique :

```python
elif old_recu is True and not instance.recu_physiquement:
    ...
```

- ajoute un nouveau type `Notification.Type.RECEPTION_ANNULEE` dans
  `backend_new/notifications/models.py` (migration à générer)
- destinataires : **les mêmes rôles/personnes que la coche** — Direction, Chef
  dégustation, le collecteur (`instance.collecteur`, si non `None`)
- pour le laboratoire : notifie-le **seulement si une `AnalyseLabo` existe déjà pour cet
  échantillon et que son statut est `en_cours`**
  (`hasattr(instance, 'analyse') and instance.analyse.statut == AnalyseLabo.Statut.EN_COURS`
  — vérifie l'import nécessaire, `analyses.models.AnalyseLabo`, attention aux imports
  circulaires si besoin d'un import tardif dans la fonction). C'est la décision L9 du
  carnet [`files/notifications/05_laboratoire.md`](../notifications/05_laboratoire.md)
  §3.1 : pas de notification si l'analyse n'a pas commencé, oui si elle est en cours.
- message clair indiquant que la réception a été annulée, avec la référence de
  l'échantillon

### 3. Frontend — retirer le blocage, appeler le bon endpoint

Dans les deux fichiers `gestion_echantillons_page.dart` (dégustateur et chef
dégustateur), retire le bloc `if (e.recuPhysiquement) { _showError(...); return false; }`
dans `_onToggleRecu`. La fonction doit maintenant, selon `e.recuPhysiquement` :
- si `false` (on confirme) : comportement actuel inchangé
- si `true` (on annule) : appelle `_service.toggleRecuPhysiquement(e.id, false)`, message
  de succès du type `'Réception annulée'`, `setState(() => e.recuPhysiquement = false)`

Corrige les deux fichiers de façon identique — c'est le même bug dupliqué, pas deux bugs
différents (règle 1 du `CLAUDE.md`).

### 4. Frontend — le service doit vraiment tenir compte de `value`

Dans `lib/core/services/gestion_echantillons_service.dart`, `toggleRecuPhysiquement`
doit appeler `confirmer-reception` si `value == true`, et le nouvel endpoint
`annuler-reception` si `value == false`. Retire le commentaire qui dit que `value` est
ignoré — ce ne sera plus vrai.

---

## Ce que tu ne fais pas

- Tu ne touches pas à la tâche 26 (notifications collecteur/labo/négociation) — si elle
  n'est pas encore commitée au moment où tu commences, vérifie `git log`/`git status`
  d'abord et ne récris pas ce qu'elle a déjà fait.
- Tu n'ajoutes pas de garde-fou (statut avancé, évaluations déjà soumises, etc.) qui
  n'est pas explicitement demandé ici — voir point 1.
- Tu ne touches pas à la messagerie (hors périmètre, réservée).
- Tu ne changes rien côté CEO ni côté collecteur au-delà de ce que la notification exige
  (pas de nouveau bouton, pas de nouvelle page).

---

## Vérification à exécuter

Backend :
```bash
cd backend_new
python manage.py makemigrations notifications
python manage.py migrate
python manage.py test notifications echantillons analyses
```

Frontend :
```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles. Référence Flutter avant cette tâche : autour de
48-49 diagnostics/0 erreur, 108 tests (107 réussis + 1 échec déjà connu) — donne le vrai
chiffre au moment où tu termines, il peut avoir légèrement bougé avec la tâche 26.

## RAPPORT

### Fait

- `backend_new/echantillons/views.py` : nouvelle action `annuler_reception` (+ alias
  `annuler-reception`), mêmes permissions que `confirmer_reception`
  (`IsDegustateur | IsChefDegustation`). Remet `recu_physiquement` à `False` et
  `date_reception_echantillon` à `None`, idempotente.
- `backend_new/notifications/models.py` : nouveau type `RECEPTION_ANNULEE`
  (`'Reception physique annulee'`), migration `0008_alter_notification_type.py`.
- `backend_new/notifications/signals.py` : nouvelle branche
  `elif old_recu is True and not instance.recu_physiquement:` — notifie Direction, Chef
  dégustation et le collecteur (mêmes destinataires que la coche) ; notifie en plus le
  laboratoire **seulement si** une `AnalyseLabo` existe pour l'échantillon et que son
  statut est `en_cours` (message précisant que l'analyse doit être suspendue).
- `backend_new/echantillons/tests.py` : test de l'annulation par le dégustateur (statut,
  date remise à `None`, réponse API).
- `backend_new/notifications/tests.py` : deux tests — annulation avec analyse en cours
  (labo notifié) et sans analyse en cours / analyse déjà soumise (labo non notifié).
- `lib/core/services/gestion_echantillons_service.dart` : `toggleRecuPhysiquement`
  appelle vraiment `confirmer-reception` ou `annuler-reception` selon `value`.
- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` et
  `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` :
  `_onToggleRecu` retire le blocage, gère les deux sens avec le bon message de succès/erreur.

### Vérifié (par Codex puis par Claude, les commandes flutter de Codex ayant traîné)

```bash
cd backend_new
python manage.py makemigrations notifications
python manage.py migrate
python manage.py test notifications echantillons analyses
```
Résultat (exécuté par Claude après la fin de Codex) : **80 tests, 0 échec** (646.6s).

```bash
dart format lib/core/services/gestion_echantillons_service.dart lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart
```
Résultat : `Formatted 3 files (2 changed)`.

```bash
flutter analyze lib test
```
Résultat : **48 diagnostics, 0 erreur** (5.7s) — cohérent avec la référence.

```bash
flutter test
```
Résultat : **108 tests, 107 réussis, 1 échec** (`test/widget_test.dart`, échec connu et
sans rapport) — identique à la référence, aucune régression.

### Conclusion

L'annulation de réception physique est maintenant possible côté dégustateur et chef
dégustateur, avec notification symétrique à la coche (Direction, Chef, collecteur), et
une notification supplémentaire au laboratoire uniquement si son analyse est déjà en
cours — conforme à la décision explicite du propriétaire du projet.
