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

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport.
