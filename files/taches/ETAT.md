# État des tâches

Ce fichier est le tableau de bord. **Claude le tient à jour, personne d'autre.**
Il répond à une seule question : où en est-on, et qui attend quoi.

Dernière mise à jour : 27/08/2026, après le commit `b1a137a`.

---

## Où en est chaque tâche

| # | Tâche | État | Qui doit agir |
|---|---|---|---|
| 05 | Texte d'aide de la recherche | **Terminée et commitée** (`8dd2e9c`) | personne |
| 06 | Photo et remarque par bouteille | Question répondue, **à relancer** | Codex |
| 07 | Référence bouteille automatique | Attend la 06 | Codex, après la 06 |
| 08 | Négociation en tonnes | Parties A et B commitées (`c5e0f97`). **Partie C à relancer**, migration autorisée | Codex |
| 09 | Filtre par dates unifié | **Jamais lancée** | Codex |
| 10 | Carte analyses laboratoire | Attend la 09 | Codex, après la 09 |
| 11 | Supprimer l'historique | Flutter et Django commités (`37488cc`). **Migration à relancer**, autorisée | Codex |
| 12 | Notifications | **Jamais lancée** | Codex |

Ordre conseillé : 06, 07, 08, 11, 09, 10, 12.
Les seules contraintes réelles sont **06 avant 07** et **09 avant 10**.

---

## Décisions déjà prises, à ne plus rediscuter

| Sujet | Décision |
|---|---|
| Remarques du collecteur | Une seule remarque, portée par la bouteille. La case globale disparaît. Aucune migration. |
| Remarque de confirmation d'achat | Champ `remarque_collecteur` ajouté au modèle Django, migration autorisée |
| `edit_history` | Supprimé du modèle Django, migration de suppression autorisée |
| Unité de prix | La tonne. Un prix sans unité se lit par tonne |
| Une citerne | Une bouteille d'échantillon |
| Quantité du fournisseur | Donnée dès le dépôt, pas après la dégustation |
| Réception physique | Reste au dégustateur, le laboratoire n'intervient pas |
| Test de la page « Mes échantillons » | Abandonné : il aurait fallu changer le constructeur de la page |

---

## Ce qui attend encore une réponse de l'entreprise

Ces points ne doivent être codés par personne tant qu'ils ne sont pas tranchés.
Ils sont détaillés dans `docs/retours-utilisation-et-questions.md`, section 7.

- Comment le collecteur note-t-il neuf citernes pour un seul fournisseur ?
- La proposition du PDG porte-t-elle sur une citerne, sur toutes, ou sur l'échantillon ?
- La date d'arrivée de l'échantillon : réelle ou prévue ?
- Qui confirme que le stock est arrivé ?
- Le dégustateur envoie-t-il parfois une notification à la direction ?
- L'évaluation urgente va-t-elle à un seul dégustateur ou à tous ?

---

## Deux défauts connus, non corrigés

| Où | Quoi |
|---|---|
| `test/widget_test.dart` | Test modèle de Flutter, teste un compteur inexistant. Échoue depuis toujours |
| `chef.tests.ChefDashboardApiTests.test_delai_alignement_and_classifications_use_submitted_evaluations` | Attend 3 échantillons « extra vierge », en trouve 1. Vérifié comme préexistant en remisant toutes les modifications |
| `lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart:517` | Débordement d'affichage signalé par Codex, hors périmètre de la tâche 05 |
