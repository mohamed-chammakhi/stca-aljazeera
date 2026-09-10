# CEO / Direction — Notifications & Idées

> Décisions tranchées le 2026-09-10 (voir §6) — pas encore codées, sauf ce qui est marqué
> « déjà existant ».
> ⚠️ Dans le Drawer des autres rôles, on dit **« Messagerie Direction »**, jamais « Messagerie CEO ».

**Rappel de droits (tranché dans [`01_collecteur.md`](01_collecteur.md) §6.1) :**
le CEO ne peut **ni modifier, ni ajouter, ni supprimer** un échantillon. Il consulte.
En revanche il **agit** sur la négociation et la validation d'achat — ce ne sont pas des
données de l'échantillon.

---

## 1. Notifications REÇUES par le CEO

### 1.1 — Ce qui existe DÉJÀ dans le code
Vérifié dans [`lib/1_ceo/notifications/services/notification_ceo_service.dart`](../../lib/1_ceo/notifications/services/notification_ceo_service.dart)
— 7 types de notifications sont déjà implémentés (en mock) :

| `type` | Titre | Section | Émetteur réel |
|--------|-------|---------|---------------|
| `echantillon_enregistre` | Nouvel échantillon enregistré | ECHANTILLONS | Collecteur |
| `echantillon_recu` | Échantillon reçu physiquement | ECHANTILLONS | Dégustateur / Chef dég. |
| `evaluation_soumise` | Évaluation soumise | EVALUATIONS | Dégustateur |
| `evaluation_urgente` | Évaluation urgente requise | EVALUATIONS | système (délai dépassé) |
| `analyse_soumise` | Analyse laboratoire disponible | ANALYSES | Laboratoire |
| `proposition_achat_attente` | Proposition d'achat en attente | ACHATS_VALIDATION | Collecteur |
| `achat_confirme` | Achat confirmé | ACHATS | Collecteur |
| `stock_arrive` | Stock arrivé | ACHATS | Collecteur |

→ **Ton point 1 (« il reçoit les nouveaux échantillons du collecteur ») existe déjà**
(`echantillon_enregistre`).

---

### 1.2 — Ce qui MANQUE (tes points 4 + relecture)

| Manque | Détail |
|--------|--------|
| **Date de livraison du stock** annoncée par le collecteur | notification quand le collecteur **fixe** la date |
| **Date de livraison de l'échantillon** annoncée par le collecteur | idem |
| ⚠️ **Changement d'une date déjà annoncée** | le plus important : une date qui bouge doit re-notifier (lien D3 §1.1 collecteur) |
| **Réponse du collecteur à une négociation** | aujourd'hui le CEO envoie les détails, mais rien ne remonte |
| **Message non lu dans la messagerie** | le CEO a une messagerie (collecteurs + chefs dég.) → badge + notif |
| **Échantillon refusé / négociation relancée** | dépend du §3 ci-dessous |

⚠️ **Les mêmes notifications de dates doivent aussi partir vers les dégustateurs**
(ton point 4 : « c'est la même chose pour les tasters »). Ils doivent savoir quand un
échantillon arrive pour s'organiser.

---

### 1.3 — Notifications potentiellement manquantes (✅ tranché — C7)

- ✅ **Analyse labo hors normes** — acidité anormale, échantillon non conforme → alerte
  distincte de `analyse_soumise`. **Retenue**, la donnée `parametres_hors_normes` existe
  déjà côté labo (voir [`05_laboratoire.md`](05_laboratoire.md) §3.2)
- ✅ **Aucune évaluation depuis X jours sur un échantillon reçu** — pendant symétrique de
  `evaluation_urgente`, côté réception. **Retenue, secondaire**
- ✅ **Stock en retard** — la date de livraison annoncée est dépassée et rien n'est arrivé.
  **Retenue, secondaire**
- ❌ **Nouveau fournisseur créé** par un collecteur — **écartée pour l'instant**
- ❌ **Proposition d'achat expirée** — **écartée pour l'instant**

---

## 2. Notifications ÉMISES par le CEO

### 2.1 — Détails de négociation → collecteur
Le CEO saisit les détails de négociation, le collecteur est notifié.

✅ **Comportement demandé :** la notification est **cliquable** → elle amène le collecteur
**directement sur la page de l'échantillon concerné, avec les détails de négociation**.

📌 Le modèle `NotificationCeo` porte déjà `echantillonId` + `echantillonReference` →
la mécanique de navigation depuis une notification existe côté données, il faut la même
chose côté collecteur.

⚠️ Rappel du problème §2.1 de [`01_collecteur.md`](01_collecteur.md) : aujourd'hui le
collecteur ne reçoit que le **nom de l'échantillon** + « détails de négociation », sans le
contenu. Le clic vers la page résout en partie ce problème.

---

### 2.2 — Mise à jour de négociation → collecteur
❓ Fonctionnalité **à créer** (D5) : le CEO doit pouvoir **mettre à jour** une négociation
existante, pas seulement la créer. Notification associée.

---

### 2.3 — Marquer une évaluation « Urgent » → tous les dégustateurs
✅ **DÉJÀ IMPLÉMENTÉ** — vérifié dans
[`lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart`](../../lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart) :

- bouton « Urgent » dans `panel_section.dart`
- popup de confirmation : « Tous les dégustateurs recevront une notification urgente pour
  soumettre leur évaluation de {ref} en priorité »
- appel `sendUrgentDegustation(id, reference)`
- le bouton passe en état `isUrgent` après envoi et **ne peut pas être renvoyé**
  (`if (_urgentSent.contains(e.id)) return;`)

→ **Rien à faire**, sauf si tu veux modifier le comportement.

✅ Tranché (C4, C5) :
- le **chef dégustateur** reçoit aussi cette notification urgente, comme les dégustateurs
  simples
- on **ne peut pas** annuler un « urgent » envoyé par erreur — reste définitif

---

## 3. ⚠️ Refus d'achat — le problème du « tout ou rien »

**Problème soulevé :** aujourd'hui, quand le CEO refuse une proposition d'achat, le stock
est **complètement refusé**. Or un refus veut souvent dire « le prix ne me va pas »,
pas « je ne veux pas de ce stock ».

**État actuel du code** ([`validation_achats_ceo_page.dart:145`](../../lib/1_ceo/validation_achats/validation_achats_ceo_page.dart#L145)) :
`_refuser()` ouvre un `RefusDecisionDialog`, demande une **raison**, puis passe le statut à
`StatutCeo.refuse` et stocke `raisonRefus`. C'est un **cul-de-sac** : rien ne permet de
relancer.

✅ **SOLUTION RETENUE — séparer refus du prix et refus du stock**

Deux décisions distinctes remplacent le refus unique :

| Décision | Sens | Effet |
|----------|------|-------|
| **Refus définitif** | le stock ne m'intéresse pas | statut `refusé`, fin du parcours (comportement actuel) |
| **Renvoi en négociation** | le prix / les conditions ne vont pas | retour au collecteur avec un **contre-prix ou une fourchette**, l'échantillon **reste vivant** |

**Principe :** le CEO refuse **un prix**, pas **un stock**. Un désaccord commercial ne doit
pas tuer un stock intéressant.

💡 Ce chemin rejoint directement la **mise à jour de négociation** (§2.2) et
l'**intervalle de prix** (§4) : renvoyer en négociation = reproposer une fourchette.
Les trois se conçoivent ensemble, pas séparément.

**Notification associée :** le collecteur reçoit « négociation à revoir » avec le
contre-prix, cliquable vers la page de l'échantillon (même mécanique que §2.1).

---

#### ❓ Reste à trancher sur ce point

#### ✅ C1 — TRANCHÉ : un seul bouton « Refuser », le choix se fait dans le dialog

Pas de troisième bouton dans la carte. Le dialog de refus **existant** est enrichi :

```
┌─────────────────────────────────────────┐
│  Refuser — CHEMLALI-K7                  │
│                                         │
│  ○ Renvoyer en négociation              │
│    → contre-prix / fourchette : [____]  │
│                                         │
│  ○ Refus définitif                      │
│                                         │
│  Raison : [__________________________]  │
│                                         │
│            [ Annuler ]  [ Valider ]     │
└─────────────────────────────────────────┘
```

La carte garde ses deux boutons actuels (`Confirmer` / `Refuser`). Le CEO est obligé de
choisir explicitement → pas de refus définitif par réflexe.

---

#### ✅ C2 — TRANCHÉ : PAS DE PLAFOND

Le nombre de renégociations est **illimité**. L'app ne bloque jamais le CEO et ne refuse
jamais un échantillon toute seule — la décision de refuser reste **toujours** humaine.

**Conséquence :** rien ne signale « ça tourne en rond » à part le marqueur du C3. Le
compteur de tours devient donc le **seul garde-fou** — il porte cette responsabilité à lui
seul (voir le design ci-dessous).

---

#### ✅ C3 — TRANCHÉ : pas de nouveau statut, mais un MARQUEUR sur l'échantillon

On **réutilise le statut `En négociation`** existant — pas de statut supplémentaire.

En revanche l'échantillon concerné porte un **marqueur visuel** signalant qu'il est passé
par un refus de prix : une pastille / un badge sur la carte, visible dans les listes.

**Pourquoi c'est mieux qu'un statut :** ça n'ajoute pas un état au cycle de vie (donc
aucun filtre, aucune logique de statut à refaire), tout en rendant le problème **visible
d'un coup d'œil** dans la liste.

---

#### 🎨 Design du marqueur — spécification

**Principe directeur : le marqueur ne doit jamais être lu comme un statut.**
Le statut reste `En négociation`. Si le marqueur ressemble à une pastille de statut, on
recrée visuellement le statut qu'on a justement refusé de créer. Il se distingue donc par
la **forme**, pas seulement par la couleur.

| | Chip de statut | Marqueur « renégocié » |
|---|---|---|
| Forme | pastille **pleine** | pastille **contournée** (bordure 1.2px, fond très clair) |
| Contenu | texte seul | **icône + texte + compteur** |
| Rôle | *où en est l'échantillon* | *ce qui lui est arrivé en chemin* |

**Couleur — famille « négociation », pas rouge**
On réutilise l'orange déjà attribué à `En négociation` dans le `CLAUDE.md` :
`0xFFD07B2F` (trait/texte) sur `0xFFFEF3E8` (fond).
⚠️ **Pas de rouge** : le rouge est la couleur du refus. Un marqueur rouge ferait lire
« refusé » un échantillon qui est justement **toujours vivant**.

**Icône :** `Icons.replay` — la flèche circulaire dit « c'est reparti pour un tour »,
exactement le sens voulu. Taille 13, même couleur que le texte.

**Texte :** `Renégocié ×2` — Alegreya 11px, `w600`, `letterSpacing 0.2`.
Le `×N` n'est pas décoratif : sans plafond (C2), **c'est le seul indicateur qu'un dossier
s'enlise**.

**Placement :** sur la même ligne que le chip de statut, juste après.
```
┌────────────────────────────────────────────────┐
│  CHEMLALI-K7                          40 T     │
│  Henchir Errouss · Sfax                        │
│                                                │
│  ( En négociation )  [↺ Renégocié ×2]          │
│    ▲ pastille pleine   ▲ pastille contournée   │
└────────────────────────────────────────────────┘
```

**🔸 Le parti pris : le marqueur s'intensifie avec les tours**
Puisqu'il n'y a pas de plafond, le marqueur porte seul l'alerte. Il monte donc en
intensité au lieu de rester figé :

| Tours | Rendu |
|-------|-------|
| **×1** | pastille contournée, orange sur fond crème — discret, factuel |
| **×2** | idem |
| **×3 et +** | pastille **pleine** `0xFFD07B2F`, texte blanc — impossible à manquer en balayant la liste |

C'est le **seul** effet visuel appuyé de la carte. Tout le reste (typo, espacements,
chips) suit le design system à la lettre.

**Qui le voit :** CEO **et** collecteur, à l'identique. C'est le collecteur qui doit agir
dessus — le lui cacher n'aurait aucun sens.

**Ce que le marqueur ne fait pas :** il ne raconte pas l'historique. Le détail des tours
(dates, prix proposés, raisons) vit dans la **page de détails** de l'échantillon. Le
marqueur signale, la fiche explique.

---

## 4. Intervalle de prix dans les détails de négociation

**Reporté depuis [`01_collecteur.md`](01_collecteur.md) §3.3 — c'est une action CEO.**

Le CEO doit pouvoir exprimer la négociation sous forme d'**intervalle** (en option, pas
obligatoire). Aujourd'hui il ne peut saisir que des nombres, et la façon d'écrire un
intervalle est compliquée.

**Contraintes posées :**
- il faut un séparateur clair (`/` ou autre) indiquant l'intervalle
- ❌ **pas** deux sélecteurs côte à côte type calendrier → trop lourd, trop chargé

✅ **Tranché (D6/C8).** Même logique que le masque de saisie de date (§3.2 collecteur) : un
champ unique, format `1200-1500`, séparateur auto, pas de sélecteurs côte à côte.

---

## 5. Page « Validation achats » — corrections UI

### 5.1 — Popup de confirmation sur « Confirmer »

✅ **RE-VÉRIFIÉ LE 2026-09-10 — CE N'EST PLUS UN PROBLÈME, DÉJÀ CORRIGÉ.**

Le code a changé depuis la première rédaction de cette note. `_confirmer()`
([`validation_achats_ceo_page.dart:182`](../../lib/1_ceo/validation_achats/validation_achats_ceo_page.dart#L182))
ouvre bien `ConfirmerAchatDialog`
([`decision_dialog.dart`](../../lib/1_ceo/validation_achats/widgets/decision_dialog.dart)),
qui rappelle la référence, le budget négocié et la quantité, et n'appelle le serveur que si
`confirme == true`. Symétrique avec « Refuser ». **Rien à faire.**

---

### 5.2 — Ordre des filtres de statut — ✅ AUCUN CHANGEMENT

Après vérification du code puis arbitrage : **l'ordre actuel est conservé.**

**`À valider` → `Décidées` → `Tout`**
(lignes [311](../../lib/1_ceo/validation_achats/validation_achats_ceo_page.dart#L311),
[320](../../lib/1_ceo/validation_achats/validation_achats_ceo_page.dart#L320),
[327](../../lib/1_ceo/validation_achats/validation_achats_ceo_page.dart#L327)),
filtre actif par défaut : `a_valider`.

**Raison :** le CEO arrive directement sur ce qu'il doit traiter. Mettre `Tout` en premier
l'obligerait à filtrer avant d'agir.

ℹ️ **Écart assumé avec le `CLAUDE.md`**, qui pose « Tous » comme premier chip sur les
autres pages. Ici la page est une **file de travail**, pas une liste de consultation —
l'écart est justifié. À ne pas « corriger » par erreur plus tard.

→ **Rien à coder sur ce point.**

---

## 6. Récapitulatif des décisions

| # | Question ouverte | Impact |
|---|------------------|--------|
| ~~C1~~ | ~~Deux boutons ou dialog ?~~ → ✅ **dialog enrichi**, un seul bouton « Refuser » | résolu |
| ~~C2~~ | ~~Cycles plafonnés ?~~ → ✅ **non — aucun plafond**, l'app ne refuse jamais toute seule | résolu |
| ~~C3~~ | ~~Nouveau statut ?~~ → ✅ **non — marqueur visuel** sur l'échantillon, statut inchangé | résolu |
| ~~C11~~ | ~~Design du marqueur ?~~ → ✅ **spécifié** : pastille contournée orange + `↺ Renégocié ×N`, pleine à partir de ×3 | résolu |
| ~~C4~~ | ~~Le chef dégustateur reçoit-il la notification « Urgent » ?~~ → ✅ **oui**, il supervise le panel | résolu |
| ~~C5~~ | ~~Peut-on annuler un « Urgent » envoyé par erreur ?~~ → ✅ **non**, pas prioritaire | résolu |
| ~~C7~~ | ~~Valider ou écarter les 5 notifications proposées en §1.3~~ → ✅ **analyse hors normes : oui** (donnée déjà disponible côté labo) ; **aucune évaluation depuis X jours** et **stock en retard : oui, secondaire** ; **nouveau fournisseur créé** et **proposition expirée : non pour l'instant** | résolu |
| ~~C8~~ | ~~Solution UI pour l'intervalle de prix (= D6)~~ → ✅ résolu dans [`01_collecteur.md`](01_collecteur.md) D6 : un seul champ, format `1200-1500` | résolu |

**Déjà tranché / déjà existant :**
- ✅ **Principe du refus scindé** (refus définitif ≠ renvoi en négociation) : **retenu** (§3)
- ✅ Urgent → dégustateurs : **déjà implémenté**, rien à faire (§2.3)
- ✅ Notification « nouvel échantillon » : **déjà implémentée** (§1.1)
- ✅ Popup de confirmation sur **« Confirmer »** : **existe déjà**, re-vérifié 2026-09-10
  (§5.1)
- ~~C6~~ ✅ Ordre des filtres : **inchangé**, `À valider → Décidées → Tout` conservé (§5.2)

---

## 7. Pistes envisagées puis écartées

> Trace des options étudiées et rejetées. **La décision finale reste celle des sections
> ci-dessus** — ce tableau ne sert qu'à justifier les choix (utile pour le rapport).

| Piste écartée | Pourquoi | Décision retenue |
|---------------|----------|------------------|
| Réordonner les filtres en `Tout → À valider → Décidées` | La page est une **file de travail** : le CEO doit atterrir sur ce qu'il a à traiter, pas filtrer avant d'agir | Ordre inchangé `À valider → Décidées → Tout` (§5.2) |
| **Deux boutons** `Refuser` + `Renégocier` dans la carte | 3ᵉ bouton dans une carte déjà chargée ; invite au clic réflexe | Un seul bouton `Refuser` → choix dans le dialog (§3, C1) |
| **Plafonner** les cycles de renégociation (2 ou 3 tours) | L'app déciderait à la place du CEO ; un stock encore négociable serait tué automatiquement | Aucun plafond — la décision de refuser reste humaine (§3, C2) |
| Créer un statut **`En renégociation`** | Ajouterait un état au cycle de vie → filtres et logique de statut à refaire partout | Statut inchangé + **marqueur visuel** sur la carte (§3, C3) |
| Marqueur « renégocié » en **rouge** | Le rouge est la couleur du refus — ferait lire « refusé » un échantillon qui est toujours vivant | Orange `0xFFD07B2F`, famille « négociation » (§3, design) |
| Marqueur en **pastille pleine** dès ×1 | Serait confondu avec un chip de statut — recréerait visuellement le statut qu'on a refusé de créer | Pastille **contournée**, pleine seulement à partir de ×3 (§3, design) |

---

## 8. À compléter
_(à enrichir au fil des idées)_
