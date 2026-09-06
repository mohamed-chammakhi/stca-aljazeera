# État des tâches

Ce fichier est le tableau de bord. **Claude le tient à jour, personne d'autre.**
Il répond à une seule question : où en est-on, et qui attend quoi.

Dernière mise à jour : 06/09/2026, après le commit de la tâche 12. Toutes les tâches écrites
sont terminées.

---

## Où en est chaque tâche

| # | Tâche | État | Qui doit agir |
|---|---|---|---|
| 05 | Texte d'aide de la recherche | **Terminée et commitée** (`8dd2e9c`) | personne |
| 06 | Photo et remarque par bouteille | **Terminée et commitée** (`370ff0a`) | à vérifier à l'écran |
| 07 | Référence bouteille automatique | **Terminée et commitée** | personne |
| 08 | Négociation en tonnes | **Terminée et commitée**, migration 0011 comprise | à vérifier à l'écran |
| 09 | Filtre par dates unifié (+ reprise 3 : libellé "Livraison du stock", indications sous chaque choix, 4ᵉ type pour le collecteur) | **Terminée et commitée** (`b058ea4`) | à vérifier à l'écran |
| 10 | Carte analyses laboratoire | **Terminée et commitée** (sauf le filtre par dates, qui attend la 09) | à vérifier à l'écran |
| 11 | Supprimer l'historique | **Terminée et commitée**, migration 0012 comprise | personne |
| 12 | Notifications | **Terminée et commitée** (`7e3b0b0`) | à vérifier à l'écran |
| 14 | Référence bouteille : indication dans le champ + mise à jour continue (collecteur) | **Terminée et commitée** (`a9deb01`) | à vérifier à l'écran |
| 15 | Retirer le compteur d'échantillons, remplacer par une phrase de contexte (collecteur) | **Terminée et commitée** (`361be23`) | à vérifier à l'écran |
| 16 | `getList()` doit ramener toutes les pages, pas seulement la première | **Terminée et commitée** (`37c9342`) | personne |
| 17 | Ajouter/modifier/supprimer un échantillon sans écriture en base, en mode démonstration (collecteur) | **Terminée et commitée** (`ab6a382`) | à vérifier à l'écran |
| 18 | Retirer complètement la carte géographique (collecteur, + vérification côté CEO) | **Terminée et commitée** (`70b4731`) | à vérifier à l'écran |
| 19 | Champ "lieu précis" hors liste gouvernorat/délégation (collecteur, dégustateur, chef dégustateur) | **Terminée et commitée** (`1edbfe0`) | à vérifier à l'écran |

Toutes les tâches numérotées sont faites et commitées, plus aucune question ouverte.

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
| Photo par bouteille | Un bouton photo dans chaque carte de bouteille, avec Galerie / Appareil photo / Annuler. Plus de question « à quelle bouteille ? » |
| Tests sur les écrans du collecteur | Abandonnés. Ces écrans vont chercher des données à l'ouverture et ne se stabilisent jamais dans un test. Vérification à l'écran |
| Comment tester malgré tout | Sortir la logique dans une **fonction pure** de `lib/core/utils/` et la tester là. C'est ce qui a marché en tâche 07 |
| Évaluation urgente — qui la reçoit | Tous les dégustateurs actifs, et le chef dégustateur aussi. Déjà le comportement du serveur, aucun changement de code |

---

## Ce qui attend encore une réponse de l'entreprise

Ces points ne doivent être codés par personne tant qu'ils ne sont pas tranchés.
Ils sont détaillés dans `docs/retours-utilisation-et-questions.md`, section 7.

- Comment le collecteur note-t-il neuf citernes pour un seul fournisseur ?
- La proposition du PDG porte-t-elle sur une citerne, sur toutes, ou sur l'échantillon ?
- La date d'arrivée de l'échantillon : réelle ou prévue ?
- Qui confirme que le stock est arrivé ?
- Le dégustateur envoie-t-il parfois une notification à la direction ?

---

## Défauts connus, non corrigés

| Où | Quoi |
|---|---|
| `test/widget_test.dart` | Test modèle de Flutter, teste un compteur inexistant. Échoue depuis toujours |
| `lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart:517` | Débordement d'affichage signalé par Codex, hors périmètre de la tâche 05 |

`chef.tests.ChefDashboardApiTests.test_delai_alignement_and_classifications_use_submitted_evaluations`
ne se reproduit plus depuis la tâche 12 (163 tests Django, 0 échec) — probablement réglé en
effet de bord par la tâche 13 (séparation des dates prévue/réelle). Retiré de la liste.
