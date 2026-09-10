# État des tâches

Ce fichier est le tableau de bord. **Claude le tient à jour, personne d'autre.**
Il répond à une seule question : où en est-on, et qui attend quoi.

Dernière mise à jour : 10/09/2026, tâche 26 terminée, tâche 27 en cours. Le propriétaire
a demandé de « s'occuper des notifications » : le carnet `files/notifications/` (6
fichiers) a été relu entièrement, toutes ses questions ouvertes tranchées, puis recoupé
avec le vrai code — bien plus construit que le carnet ne le disait (négociation/refus,
urgents, dates de livraison stock — tout existe et est testé). La tâche 26 a corrigé les
4 vrais manques trouvés (collecteur non notifié de la réception, labo non notifié d'un
nouvel échantillon, CEO qui propose/met à jour une négociation ne notifiait personne,
clic sur une notification collecteur sans effet). En creusant, un point est apparu plus
gros qu'une notification manquante : la "décoche" de réception physique est bloquée en
dur côté code ("ne peut pas être annulée"), sans route serveur pour l'inverse. Le
propriétaire a explicitement confirmé vouloir permettre cette annulation, avec
notification dans les deux sens → tâche 27.

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
| 20 | Dégustateur et chef dégustateur peuvent enregistrer/modifier/supprimer des échantillons, page du collecteur réutilisée | **Terminée et commitée** (`d986f95`) | à vérifier à l'écran |
| 21 | Retirer (pas cacher) le tiroir/cloche/achat-livraison du collecteur pour dégustateur et chef | **Annulée par la tâche 22**, mauvaise approche selon le propriétaire | personne |
| 22 | Corriger : retirer la page réutilisée du collecteur, ajouter/modifier/supprimer directement sur la page "Gestion des échantillons" du dégustateur et du chef | **Terminée et commitée** | à vérifier à l'écran |
| 23 | Le filtre par date du dégustateur et du chef propose les mêmes 4 choix que celui du collecteur | **Terminée et commitée** | à vérifier à l'écran |
| 24 | Suggestions de fournisseur (façon Google) pour le dégustateur et le chef, comme le collecteur a déjà | **Terminée et commitée** | à vérifier à l'écran |
| 25 | Audit des 32 pages utilisant VueResultatService : message contextuel quand une liste est vide, sans toucher à la vraie gestion d'erreur | **Terminée et commitée** | à vérifier à l'écran |
| 26 | Notifications manquantes : collecteur (réception physique), laboratoire (nouvel échantillon), collecteur (négociation proposée/mise à jour), clic notification collecteur → page échantillon | **Terminée et commitée** (`9b3aca9`) | à vérifier à l'écran |
| 27 | Permettre d'annuler une réception physique confirmée, avec notification dans les deux sens | **En cours** | Codex |

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
| Suppression par dégustateur/chef | N'importe lequel des deux peut supprimer n'importe quel échantillon non enregistré par un collecteur — pas seulement ce que chacun a lui-même ajouté. Aucun champ « qui a enregistré » à ajouter |
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
