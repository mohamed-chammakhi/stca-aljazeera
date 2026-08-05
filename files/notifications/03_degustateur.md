# Dégustateur — Notifications & Idées

> Carnet d'idées brut, organisé. Non validé, non implémenté.

**Rappel de droits (tranché dans [`01_collecteur.md`](01_collecteur.md) §6.1) :**
le dégustateur simple **peut modifier** un échantillon après réception physique, avec
historisation (ancienne + nouvelle valeur) — comme le chef dégustateur. Il **n'a pas** de
messagerie (D21, résolu : ❌ non).

**Pourquoi ce fichier compte plus que les autres en ce moment :** `3_degustateur/` et
`5_chef_degustateur/` sont deux copies du même module (33 fichiers dupliqués), en cours de
fusion (B4 du plan de correction). Ce carnet doit donc aussi signaler les endroits où les
deux copies se sont **déjà mises à diverger** en silence — c'est exactement le genre de
dérive que la fusion doit corriger, pas figer.

---

## 1. Notifications ÉMISES par le dégustateur

| Événement | Destinataire | Détail |
|-----------|--------------|--------|
| **Coche « reçu physiquement »** (page Gestion des échantillons) | Chef dégustateur + CEO | même mécanique que §1.4/§2 de [`04_chef_degustateur.md`](04_chef_degustateur.md) — le dégustateur simple a le même bouton |
| **Décoche « reçu physiquement »** | Chef dégustateur + CEO | notification inverse — ⚠️ n'existe nulle part aujourd'hui (même lacune que côté chef) |
| **Évaluation soumise** | CEO (`evaluation_soumise`, ✅ déjà listé dans [`02_ceo.md`](02_ceo.md) §1.1) | 📌 vérifié dans le code : `lib/3_degustateur/evaluation_echantillons/services/evaluation_service.dart:90` — `soumettre()` appelle déjà `POST /api/evaluations/{id}/soumettre/`. Le déclenchement de la notification est côté serveur, pas encore vérifié. |
| **Confirmation de présence à une séance** (coche sur `session_card.dart`) | ✅ Le créateur de la séance | tranché (T3) — à construire, n'existe pas encore |
| **Bouton urgent labo** (page Analyse laboratoire, cloche rouge) | Laboratoire | ✅ déjà décrit dans [`05_laboratoire.md`](05_laboratoire.md) (`ANALYSE_URGENTE`, "existe déjà") ; bouton verrouillé après envoi, pour la session. 📌 Vérifié : `lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart:263` et `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart:219` appellent **le même** `LigneAnalyseLaboService.sendUrgentAnalyseLabo()` — déjà partagé, aucune dérive ici. |
| **Nouvel échantillon ajouté** (le dégustateur peut créer un échantillon manqué par le collecteur, `role_degustateur.md`) | ❓ Collecteur concerné ? CEO ? | pas encore posé nulle part |

---

## 2. Notifications REÇUES par le dégustateur

### 2.1 — Déjà tranché ailleurs, s'applique tel quel
- ✅ **Échantillon reçu physiquement** — `echantillon_recu`, émetteur "Dégustateur / Chef
  dég." dans le tableau CEO ([`02_ceo.md`](02_ceo.md) §1.1) — un dégustateur qui reçoit la
  coche d'un collègue doit le savoir aussi, pour que l'échantillon apparaisse dans sa page
  Évaluation.
- ✅ **« Urgent » envoyé par le CEO** — §2.3 de [`02_ceo.md`](02_ceo.md), déjà implémenté
  côté déclenchement (`sendUrgentDegustation`), déjà reçu côté mock dans
  `notification_degustateur_service.dart` (type `evaluation_urgente`).
- ✅ **Invitation à une séance de dégustation** — `role_degustateur.md` : « Only selected
  participants receive notification » ; texte déjà présent dans le dialogue de création
  (`formulaire_session_dialog.dart:514`) : *« Si aucun participant n'est sélectionné, tous
  les membres du panel seront notifiés. »*

### 2.2 — ⚠️ Dérive trouvée entre les deux copies du module

En comparant `lib/3_degustateur/notifications/` et `lib/5_chef_degustateur/notifications/` :

- le fichier du **chef** contient deux types que celui du **dégustateur simple n'a pas** :
  `EVALUATION_SOUMISE` et `TOUTES_EVALUATIONS`, avec une fonction
  `isSuperTasterOnly(type)` qui les marque comme réservés au chef. ✅ **Tranché (T1) :** ces
  deux types sont **retirés pour l'instant** — le chef reçoit les mêmes notifications que le
  dégustateur simple, rien de plus.
- le service du **dégustateur** construit son client HTTP de façon testable
  (`NotificationDegustateurService({ApiClient? api})`), celui du **chef** appelle
  directement le singleton global `apiClient` — différence purement technique, sans impact
  métier, à unifier pendant la fusion.

📌 **Correction d'une erreur de ma part :** j'avais initialement noté ici que
`sendUrgentDegustation()` (le bouton « urgent » qui relance le laboratoire) manquait côté
chef. **C'est faux, vérifié après coup.** Les deux pages `analyse_laboratoire_page.dart`
(dégustateur ligne 263, chef ligne 219) appellent **le même** service partagé
`LigneAnalyseLaboService.sendUrgentAnalyseLabo()` — cette fonctionnalité marche déjà
identiquement pour les deux rôles, aucune dérive. `sendUrgentDegustation()` est une méthode
différente, sans rapport avec le laboratoire : elle sert au **CEO** à relancer tous les
dégustateurs (`lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart:330`
l'appelle directement depuis le module dégustateur). Ce n'est pas une dérive chef/dégustateur
— tout au plus une question d'architecture (le CEO importe un service d'un module de rôle
qui n'est pas le sien), à noter mais qui ne bloque pas la fusion.

→ La seule dérive réelle ici est la première : la règle 1 du `CLAUDE.md` (même chose → même
nom, même fichier) est censée l'empêcher.

### 2.3 — ✅ Tranché
- **Date d'arrivée de stock / d'échantillon** annoncée ou modifiée par le collecteur (T2) :
  le dégustateur simple **et** le chef dégustateur la reçoivent tous les deux — comme le
  CEO. Cette notification n'existe pas encore dans le code (elle manque aussi côté CEO, voir
  [`02_ceo.md`](02_ceo.md) §1.2) ; c'est à construire, pas à corriger.
- **Accès en lecture au fil de messagerie** chef dégustateur ↔ collecteur (T4) : **aucun
  accès**. Principe posé par le propriétaire du projet : une conversation reste strictement
  entre les deux personnes qui échangent, comme sur Messenger — personne d'autre ne la lit,
  y compris le CEO (résout aussi D17 dans [`01_collecteur.md`](01_collecteur.md)).

### 2.4 — ❓ Pas encore posé
- Analyse labo disponible pour un échantillon que ce dégustateur doit évaluer (le CEO la
  reçoit déjà via `analyse_soumise`, [`02_ceo.md`](02_ceo.md) §1.1).

---

## 3. Récapitulatif des décisions

| # | Question ouverte | Impact |
|---|-------------------|--------|
| T5 | Un dégustateur qui ajoute lui-même un échantillon manqué par le collecteur — qui est prévenu ? | notif |

**Tranché :**
- ~~T1~~ — Le chef dégustateur reçoit-il en plus `EVALUATION_SOUMISE` et
  `TOUTES_EVALUATIONS` ? → ✅ **non, retirés** — le chef reçoit exactement les mêmes
  notifications que le dégustateur simple (§2.2)
- ~~T2~~ — Notifications de date (arrivée stock / échantillon) ? → ✅ **le dégustateur
  simple et le chef, les deux** (§2.3)
- ~~T3~~ — La confirmation de présence notifie-t-elle le créateur de la séance ? → ✅ **oui**
  (§1)
- ~~T4~~ — Accès en lecture du dégustateur au fil de messagerie chef ↔ collecteur ? (= D17)
  → ✅ **aucun accès** — une conversation reste entre les deux personnes qui échangent,
  comme Messenger (§2.3)

**Déjà tranché / déjà existant :**
- ✅ Droit de modification après réception, avec historique — même règle que le chef
  (§6.1 de `01_collecteur.md`)
- ✅ Pas de messagerie pour le dégustateur simple (D21)
- ✅ Bouton urgent labo — existe et fonctionne, partagé avec le chef (§1 ci-dessus)
- ✅ Invitation de séance ciblée aux participants sélectionnés — texte déjà en place

---

## 4. À compléter
