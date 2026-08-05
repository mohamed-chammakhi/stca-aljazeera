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
| **Confirmation de présence à une séance** (coche sur `session_card.dart`) | ❓ le chef dégustateur qui a créé la séance ? | rien ne le dit aujourd'hui — voir T3 |
| **Bouton urgent labo** (page Analyse laboratoire, cloche rouge) | Laboratoire | ✅ déjà décrit dans [`05_laboratoire.md`](05_laboratoire.md) (`ANALYSE_URGENTE`, "existe déjà") ; bouton verrouillé après envoi, pour la session |
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
  `isSuperTasterOnly(type)` qui les marque comme réservés au chef.
- le service du **dégustateur** contient une méthode que celui du **chef n'a pas** :
  `sendUrgentDegustation()` (l'appel réel vers `/api/notifications/evaluation-urgente/`) —
  le chef ne peut donc pas relancer un labo en urgence dans le code actuel, alors que
  [`04_chef_degustateur.md`](04_chef_degustateur.md) §1.4 dit que le chef réutilise le même
  bouton que le dégustateur.
- le service du **dégustateur** construit son client HTTP de façon testable
  (`NotificationDegustateurService({ApiClient? api})`), celui du **chef** appelle
  directement le singleton global `apiClient` — différence purement technique, sans impact
  métier, mais à unifier pendant la fusion.

→ Ce ne sont **pas des choix faits exprès** : c'est la dérive silencieuse que la règle 1 du
`CLAUDE.md` (même chose → même nom, même fichier) est censée empêcher. Voir T1 ci-dessous.

### 2.3 — ❓ Pas encore posé
- Date d'arrivée de stock / d'échantillon annoncée ou modifiée par le collecteur — voir T2.
- Analyse labo disponible pour un échantillon que ce dégustateur doit évaluer (le CEO la
  reçoit déjà via `analyse_soumise`, [`02_ceo.md`](02_ceo.md) §1.1).
- Accès en lecture au fil de messagerie chef dégustateur ↔ collecteur — c'est **la même
  question que D17** dans [`01_collecteur.md`](01_collecteur.md), posée ici parce qu'elle
  concerne directement ce rôle.

---

## 3. Récapitulatif des décisions

| # | Question ouverte | Impact |
|---|-------------------|--------|
| T1 | Le chef dégustateur reçoit-il, en plus des notifications de base du dégustateur simple, `EVALUATION_SOUMISE` et `TOUTES_EVALUATIONS` ? (= le code actuel du chef le fait, mais ce n'est tranché nulle part — recoupe CD3 de [`04_chef_degustateur.md`](04_chef_degustateur.md) §3) | fusion des notifications (B4) |
| T2 | Les notifications de date (arrivée stock / échantillon) doivent-elles aussi partir vers le dégustateur simple, ou seulement vers le chef ? (`02_ceo.md` §1.2 dit « les dégustateurs » sans préciser lequel) | notif |
| T3 | La confirmation de présence à une séance notifie-t-elle en retour le créateur de la séance ? | notif |
| T4 | Accès en lecture du dégustateur au fil de messagerie chef ↔ collecteur ? (= D17) | droits |
| T5 | Un dégustateur qui ajoute lui-même un échantillon manqué par le collecteur — qui est prévenu ? | notif |

**Déjà tranché / déjà existant :**
- ✅ Droit de modification après réception, avec historique — même règle que le chef
  (§6.1 de `01_collecteur.md`)
- ✅ Pas de messagerie pour le dégustateur simple (D21)
- ✅ Bouton urgent labo — existe et fonctionne (§1 ci-dessus)
- ✅ Invitation de séance ciblée aux participants sélectionnés — texte déjà en place

---

## 4. À compléter
