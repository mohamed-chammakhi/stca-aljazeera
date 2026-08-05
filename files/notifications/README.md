# Notifications — Idées & Scénarios (brut, en cours)

Espace de collecte des idées de notifications entre les 5 acteurs.
Rien ici n'est validé ni implémenté — c'est un carnet d'idées organisé, à trier ensuite.

## Fichiers par acteur

| Acteur | Fichier | Statut |
|--------|---------|--------|
| Collecteur | [`01_collecteur.md`](01_collecteur.md) | 🟡 en cours de collecte |
| CEO / Directeur | [`02_ceo.md`](02_ceo.md) | 🟡 en cours de collecte |
| Dégustateur | [`03_degustateur.md`](03_degustateur.md) | 🟡 en cours de collecte |
| Chef Dégustateur | [`04_chef_degustateur.md`](04_chef_degustateur.md) | 🟡 en cours de collecte |
| Laboratoire | [`05_laboratoire.md`](05_laboratoire.md) | 🟡 en cours de collecte |

## Fichiers transverses

Sujets qui concernent plusieurs rôles, remontés depuis le fichier d'acteur où ils ont
été soulevés (voir la note en bas de page).

| Sujet | Fichier | Statut | Soulevé depuis |
|-------|---------|--------|----------------|
| Version web | [`00_transverse_web.md`](00_transverse_web.md) | 🟡 en cours de collecte | Laboratoire |

## Convention d'écriture

Chaque fichier acteur contient :

1. **Notifications émises** — ce que cet acteur déclenche, et qui le reçoit
2. **Notifications reçues** — ce qui arrive à cet acteur, et de qui
3. **Problèmes ouverts** — les blocages / incohérences relevés (⚠️)
4. **Récapitulatif des décisions** — tranchées (✅ barrées) et ouvertes (❓)
5. **Pistes envisagées puis écartées** — l'option rejetée, sa raison, et la décision retenue

**Règle de lecture :** la **décision finale** est celle des sections numérotées.
Le tableau des pistes écartées ne sert qu'à **justifier** les choix — il ne contient
aucune décision active.

**Conventions de marquage :**
- ✅ tranché · ❓ ouvert · ⚠️ problème ou conflit · 💡 idée · 📌 info utile
- une décision tranchée est ~~barrée~~ dans le récap, avec sa réponse à la suite
- toute vérification faite dans le code est signalée et **liée au fichier source**

**Numérotation des décisions** — un préfixe par fichier, pour que les renvois croisés
entre fichiers restent lisibles :

| Préfixe | Fichier |
|---------|---------|
| `D…` | Collecteur |
| `C…` | CEO |
| `T…` | Dégustateur |
| `CD…` | Chef dégustateur |
| `L…` | Laboratoire |
| `W…` | Transverse — version web |

**Ce qui n'a PAS sa place ici :** les sujets purement techniques ou d'infrastructure
(cache, hébergement, CI/CD, sauvegardes) vont dans
[`docs/production-and-deployment-guide.md`](../../docs/production-and-deployment-guide.md),
pas dans ce dossier. Ici on ne note que de la **logique métier**.

Les idées transverses (calendrier, format des dates, intervalles) sont notées
dans le fichier de l'acteur où elles ont été soulevées, puis remontées plus tard
dans un fichier commun si elles concernent plusieurs rôles.
