# Transverse — Version web (tous les rôles)

> Décisions tranchées le 2026-09-10 (voir §6) — pas encore codées, sauf ce qui est marqué
> « déjà existant ». Reste ouvert : W7 (messagerie sur le web).

**Pourquoi un fichier commun :** ce sujet a été soulevé depuis le laboratoire
([`05_laboratoire.md`](05_laboratoire.md) §2) mais concerne **les 5 rôles**.
Conformément à la convention du [`README.md`](README.md) — *« les idées transverses sont
notées dans le fichier de l'acteur où elles ont été soulevées, puis remontées dans un
fichier commun si elles concernent plusieurs rôles »* — il est remonté ici.

---

## 1. Le problème posé

> *« J'aimerais ajouter toute une version web pour chaque département de l'entreprise,
> mais le problème c'est que ça représenterait beaucoup de travail — il faut trouver une
> solution dès maintenant. »*

L'inquiétude est justifiée, mais elle porte sur le mauvais coût.

---

## 2. ✅ TRANCHÉ (W1) — **un seul web, plusieurs points d'accès**

Il n'y a **pas** une version web par département. Il y a **une seule application web**,
un seul déploiement, une seule URL — et le **rôle de l'utilisateur connecté** détermine
ce qu'il voit.

C'est **exactement le fonctionnement actuel du mobile** :
[`lib/main.dart`](../../lib/main.dart) → login → rôle → Drawer et pages du rôle.

| ❌ Ce qu'on ne fait pas | ✅ Ce qu'on fait |
|------------------------|------------------|
| 5 applications web | **1** application web |
| 5 déploiements, 5 URLs | 1 déploiement, 1 URL |
| 5 systèmes de design à maintenir | celui du `CLAUDE.md`, déjà écrit |
| 5 × le travail | le travail d'une seule |

→ **Le rôle est un point d'entrée, pas un produit séparé.**

---

## 3. ✅ TRANCHÉ (W2) — le vrai coût n'est pas de construire le web plus tard,
### c'est de le **rattraper** plus tard

C'est le cœur de la réponse à *« il faut trouver une solution dès maintenant »*.

**On ne construit pas le web maintenant.** On rend simplement le code **incapable de le
bloquer**. La différence est énorme :

| | Conventions adoptées **maintenant** | Rattrapage **plus tard** |
|---|---|---|
| Coût par nouvelle page | ≈ 0 | — |
| Coût du jour où on veut le web | reprise de **mise en page** | reprise **page par page** : chasse aux `dart:io`, aux largeurs figées, aux `Platform.is…` éparpillés |
| Risque | faible | ⚠️ élevé — c'est là que « beaucoup de travail » devient vrai |

**Les 3 règles à appliquer dès aujourd'hui, sur chaque nouvelle page :**

1. **Pas de largeur figée « taille téléphone »** — utiliser `LayoutBuilder` /
   `MediaQuery` et des points de rupture, pas des constantes en dur.
2. **Pas d'accès plateforme direct dans les widgets** — caméra, fichiers, stockage
   passent par une **interface de service** (cohérent avec la règle existante du
   `CLAUDE.md` : *« tout accès aux données passe par une classe de service, jamais dans
   les widgets »*). C'est la même règle, étendue à la plateforme.
3. **Aucun `import 'dart:io'` dans le code d'UI** — il casse la compilation web.

📌 `flutter build web` **fonctionne déjà** et le dossier [`web/`](../../web/) existe.
Le blocage n'est pas l'outillage, c'est la discipline de mise en page.

---

## 4. ⚠️ Conséquence de sécurité — à ne pas manquer

Sur le web, **les 5 modules de rôle sont livrés dans le même bundle JavaScript**.
N'importe qui peut le lire.

→ **Le filtrage par rôle côté Flutter n'est qu'un confort d'affichage, jamais une
sécurité.** Le seul périmètre de sécurité réel est le **backend Django**.

Cela renforce directement un point déjà présent dans
[`docs/production-and-deployment-guide.md`](../../docs/production-and-deployment-guide.md) §7 :
> « Check who can do what per role (who can confirm a purchase, refuse a sample, etc.) —
> real business consequences. »

Sur mobile ce point était important. **Sur le web il devient obligatoire.**

⚠️ Rappel lié : les **4 boutons de login de debug** de `main.dart` doivent disparaître
avant toute mise en ligne — sur le web, ils seraient accessibles publiquement.

---

## 5. Qui a réellement besoin du web ?

Le mobile reste le support principal. Le web n'est pas un doublon : il sert là où le
téléphone est mauvais — **beaucoup de lignes, fichiers, clavier, grand écran**.

| Rôle | Besoin web | Pourquoi |
|------|------------|----------|
| **Laboratoire** | ✅ **fort** | import / export de fichiers, tableaux de valeurs, traitement par lot ([`05_laboratoire.md`](05_laboratoire.md) §2) |
| **CEO / Direction** | ✅ probable | tableaux de bord, comparaisons, lecture sur grand écran |
| **Chef dégustateur** | ❓ moyen | supervise un panel — vue d'ensemble confortable sur grand écran |
| **Collecteur** | ❌ faible | il est **sur la route**, souvent hors ligne. Le mobile *est* son outil |
| **Dégustateur** | ❌ faible | il évalue physiquement devant l'échantillon |

✅ **Tranché (W3) :** ordre confirmé — **Laboratoire → CEO → Chef dégustateur → reste**
(collecteur et dégustateur restent des outils mobiles en priorité).

ℹ️ **Le collecteur n'est pas exclu.** Comme il n'y a qu'une application (W1), il aura
accès au web s'il se connecte. Simplement, aucune page ne sera *conçue pour* lui en
priorité.

---

## 6. Questions — décisions

- ~~W3~~ — Ordre de priorité des rôles pour l'adaptation web → ✅ **Laboratoire → CEO →
  Chef dégustateur → reste** (§5)
- ~~W4~~ — Points de rupture (mobile / tablette / bureau) → ✅ **standard Material** :
  mobile `< 600px`, tablette `600–1024px`, bureau `> 1024px`
- ~~W5~~ — Le web est-il public ou réservé au réseau de l'entreprise ? → ✅ **public**,
  accessible avec identifiants depuis n'importe où — ⚠️ exige une vraie rigueur côté
  Django (rate limiting, permissions par rôle vérifiées serveur, jamais côté Flutter
  seul — voir §4 ci-dessus)
- ~~W6~~ — Notifications push sur le web → ✅ **reporté**, pas prioritaire avant un vrai
  déploiement web (sujet push aussi ouvert dans [`ideas.md`](../ideas.md))
- W7 — La messagerie ([`01_collecteur.md`](01_collecteur.md) §6.2) doit-elle être adaptée
  au web dès le départ ? → 📌 **laissé ouvert**, dépend de la construction de la
  messagerie elle-même, non commencée

---

## 7. Pistes envisagées puis écartées

| Piste écartée | Pourquoi | Décision retenue |
|---------------|----------|------------------|
| **Une application web par département** | 5 codebases, 5 déploiements, 5 systèmes de design à synchroniser pour toujours | **Une seule app web**, rôle décidé au login (§2) |
| **Application web séparée** (React / Vue) sur la même API Django | Meilleure ergonomie bureau, mais double la maintenance — disproportionné ici | Même codebase Flutter (§2) |
| **Web pour le laboratoire uniquement, et on s'arrête là** | Rouvre la question à la première demande de tableau de bord du CEO | Une app pour tous, **priorisation** de l'adaptation (§5) |
| **Construire le web maintenant** | Effort important pour un besoin non encore exprimé sur la plupart des rôles | Conventions maintenant, construction plus tard (§3) |
| **Ne rien faire et rattraper plus tard** | ⚠️ C'est précisément ce qui rend le chantier coûteux : reprise page par page | 3 règles appliquées dès aujourd'hui (§3) |

---

## 8. À compléter
