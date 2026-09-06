# Tâche 15 — Retirer le compteur d'échantillons, page du collecteur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Module concerné : `2_collecteur` uniquement. Fichier :
`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`.

---

## Contexte

Sous les onglets de statut (Tous / Enregistré / Négociation / Achat conclu), la bande de
stats (~L906-950) affiche aujourd'hui une icône et "`$_totalFiltered` échantillon(s)". Le
propriétaire ne veut plus voir ce nombre. Il veut à la place une phrase courte qui dit ce
que cet onglet montre.

Le petit encart qui montre la période de dates sélectionnée (`_dateFilterActive`, ~L925-947)
n'est **pas concerné** : il reste tel quel.

---

## CONSIGNE

Remplace l'icône + le texte "`$_totalFiltered échantillon(s)`" par une phrase fixe, choisie
selon `_filtreStatut` :

| `_filtreStatut` | Phrase à afficher |
|---|---|
| `null` (onglet "Tous") | Tous vos échantillons, quel que soit leur état. |
| `StatutCollecteur.receptionne` (onglet "Enregistré") | Échantillons enregistrés, en attente de négociation. |
| `StatutCollecteur.enNegociation` (onglet "Négociation") | Échantillons en cours de négociation avec le fournisseur. |
| `StatutCollecteur.achatConfirme` (onglet "Achat conclu") | Échantillons dont l'achat est confirmé. |

Garde le même style visuel (taille, couleur grise, icône si tu veux en garder une — mais pas
le chiffre). Le texte de dates (`_dateFilterActive`) continue de s'afficher à la suite, comme
aujourd'hui.

---

## Ce que tu ne fais pas

- Tu ne touches pas à l'encart de dates sélectionnées.
- Tu ne touches à aucun autre module que `2_collecteur`.
- Tu n'inventes pas d'autre texte que celui du tableau ci-dessus.

## RAPPORT

### Fait

- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` : le nombre d'échantillons
  affiché sous les onglets de statut a été remplacé par `_descriptionFiltreStatut`, une phrase
  fixe selon `_filtreStatut` — exactement les quatre phrases demandées. Le texte est enveloppé
  dans un `Flexible` avec ellipsis pour ne jamais déborder. L'encart de dates sélectionnées
  n'a pas été touché.

### Vérifié

Codex a écrit ce correctif puis son processus s'est interrompu (redémarrage de session côté
Claude) avant d'écrire ce rapport. Claude a relu le diff — conforme au tableau demandé, aucun
autre fichier touché — et exécuté lui-même :

```bash
dart format lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart
```
Sortie brute : `Formatted 1 file (1 changed) in 0.10 seconds.`

```bash
flutter analyze lib test
```
Sortie brute : `49 issues found. (ran in 6.5s)` — 0 erreur, conforme à la référence.

```bash
flutter test
```
Sortie brute : `103 tests`, **102 réussis**, 1 échec déjà connu
(`test/widget_test.dart: Counter increments smoke test`). Aucune régression.

### Non fait

Rien.

### HORS PÉRIMÈTRE

Rien.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport.
