# Chef Dégustateur — Notifications & Idées

> Carnet d'idées brut, organisé. Non validé, non implémenté.

**Rappel de droits (tranché dans [`01_collecteur.md`](01_collecteur.md) §6.1) :**
le chef dégustateur **peut modifier** un échantillon après réception physique, avec
historisation (ancienne + nouvelle valeur). Il a une **messagerie** avec tous les
collecteurs et avec la Direction.

---

## 1. Page « Vue d'ensemble évaluations » — alignement sur la page CEO

**Demande :** cette page doit ressembler à la page **Analyse organoleptique du CEO**
([`analyse_organoleptique_ceo_page.dart`](../../lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart)),
**mais sans les boutons de décision**.

Fichier concerné :
[`lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart`](../../lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart)

### 1.1 — Ce qu'on reprend de la page CEO
La structure, la mise en page, la présentation des panels d'évaluation.

### 1.2 — Ce qu'on NE reprend PAS
❌ Les **boutons de décision** (approbation / refus). Le chef dégustateur consulte et
supervise les évaluations — il ne décide pas de l'achat, c'est le rôle du CEO.

❓ À préciser : le bouton **« Urgent »** de la page CEO (§2.3 de [`02_ceo.md`](02_ceo.md))
fait-il partie des « boutons de décision » à retirer, ou le chef dégustateur peut-il lui
aussi relancer ses dégustateurs ? *(à mon sens il devrait pouvoir — c'est lui qui pilote
le panel au quotidien, pas le CEO)*

---

### 1.3 — ✅ Le compteur « 3 / 4 » est conservé
Le compteur d'évaluations soumises sur le total **plaît et reste tel quel**.

Il existe déjà dans le code :
```dart
int get submitted => evaluations.where((e) => e.statut == 'Soumis').length;
int get total     => evaluations.length;
```
affiché en `'${g.submitted} / ${g.total}'`
([ligne 839](../../lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart#L839))
et `'${g.submitted} / ${g.total} soumises'`
([ligne 887](../../lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart#L887)).

→ **Rien à changer.**

---

### 1.4 — ⚠️ Le bouton check doit devenir ACTIONNABLE

**Problème :** aujourd'hui, le check « Réception physique » de cette page est un
**simple indicateur passif** — vérifié dans le code
([lignes 960-999](../../lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart#L960)) :
un cercle avec `Icons.check_circle` / `check_circle_outline` + le texte « Oui — date » ou
« Non ». **Aucun `onTap`** : on ne peut pas cliquer dessus.

**Demandé :** le même comportement que le check de la page **Gestion des échantillons du
dégustateur**
([`echantillon_card.dart`](../../lib/3_degustateur/gestion_echantillons/widgets/echantillon_card.dart)),
qui lui est **actionnable** :

| | Vue d'ensemble (chef) — actuel | Gestion échantillons (dégustateur) — cible |
|---|---|---|
| Nature | indicateur passif | **bouton cliquable** |
| Au clic | rien | ouvre `_RecuConfirmDialog` |
| Confirmation | — | « Confirmez-vous que cet échantillon est physiquement présent dans la société ? » |
| Action inverse | — | bouton **« Annuler réception »** (orange `0xFFD07B2F`) |
| Icône | `check_circle` / `check_circle_outline` | idem — même icône, mais elle bascule |

→ **Le widget existe déjà et fonctionne.** Il s'agit de le réutiliser, pas d'en écrire un
nouveau.

**Lien avec les notifications :** §2.4 de [`01_collecteur.md`](01_collecteur.md) — quand le
chef dégustateur coche, le collecteur reçoit une notification ; quand il **décoche**, le
collecteur est notifié aussi. Le dialog « Annuler réception » est donc le déclencheur de la
notification inverse.

---

## 2. Notifications ÉMISES par le chef dégustateur

| Événement | Destinataire | Détail |
|-----------|--------------|--------|
| **Coche réception physique** | Collecteur | + CEO (`echantillon_recu` existe déjà côté CEO) |
| **Décoche réception physique** | Collecteur | notification inverse — ⚠️ n'existe nulle part aujourd'hui |
| **Message dans la messagerie** | Collecteur ou CEO | badge non-lus, modèle Messenger |
| ❓ Relance « Urgent » | Dégustateurs | si on lui accorde ce bouton (voir §1.2) |

**Effet de bord de la coche** (déjà noté §2.4 collecteur) : quand un échantillon est reçu,
il **apparaît chez le laboratoire** et dans la **page d'évaluation** du dégustateur et du
chef dégustateur.

---

## 3. Notifications REÇUES par le chef dégustateur
_(à compléter — pas encore d'idées données)_

Pistes évidentes à valider :
- ❓ Nouvel échantillon enregistré par un collecteur
- ❓ Évaluation soumise par un de ses dégustateurs
- ❓ Analyse laboratoire disponible
- ❓ Dates de livraison annoncées / modifiées par le collecteur
  *(ton point 4 côté CEO : « c'est la même chose pour les tasters »)*
- ❓ Notification « Urgent » envoyée par le CEO — la reçoit-il aussi ? (= C4 dans
  [`02_ceo.md`](02_ceo.md))

---

## 4. Récapitulatif des décisions

| # | Question ouverte | Impact |
|---|------------------|--------|
| CD1 | Le chef dégustateur garde-t-il un bouton « Urgent » ? *(reco : oui)* | §1.2 |
| CD2 | Reçoit-il la notification « Urgent » du CEO ? (= C4) | notif |
| CD3 | Liste définitive de ses notifications reçues (§3) | notif |

**Déjà tranché / déjà existant :**
- ✅ Compteur `3 / 4` : **existe, conservé, rien à faire** (§1.3)
- ✅ Check actionnable : **le widget existe** dans le module dégustateur, à réutiliser (§1.4)
- ❌ Boutons de décision : **retirés** de la vue d'ensemble (§1.2)

---

## 5. À compléter
