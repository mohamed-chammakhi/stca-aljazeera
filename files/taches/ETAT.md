# État des tâches

Ce fichier est le tableau de bord. **Claude le tient à jour, personne d'autre.**
Il répond à une seule question : où en est-on, et qui attend quoi.

Dernière mise à jour : 24/09/2026, tâche 32 terminée — le chef dégustateur peut
maintenant écrire aux autres chefs dégustateurs (conversation individuelle, pas de
groupe), et le libellé du collecteur est redevenu "Messagerie" (au lieu de "Messagerie
Direction"). Bug latent corrigé au passage : un utilisateur se voyait lui-même dans sa
propre liste de contacts, jamais visible avant puisqu'aucun rôle n'apparaissait dans sa
propre liste jusqu'ici.

Précédente mise à jour (11/09/2026), tâches 30 et 31 terminées. Le propriétaire avait
demandé trois ajouts à la messagerie : joindre une photo (galerie ou appareil photo),
référencer un échantillon dans un message (cliquable, ouvre la page adaptée au rôle de
celui qui clique), et pouvoir modifier/supprimer ses propres messages. En creusant le
code de suppression existant, un vrai bug de permission a été trouvé et corrigé au
passage : le destinataire d'un message pouvait déjà le supprimer, pas seulement
l'expéditeur. Un incident mineur pendant la tâche 31 : Codex a livré un diff correct
mais avec des accents mal encodés dans 12 chaînes de caractères (double encodage
UTF-8/Latin-1) — repéré et corrigé avant le commit, et le processus Codex s'est arrêté
sans écrire de RAPPORT, complété par Claude après revue complète du diff.

Ancienne mise à jour (11/09/2026), tâches 28 et 29 terminées — la messagerie
collecteur ↔ chef dégustateur ↔ direction est fonctionnelle de bout en bout (décrite
dans `files/notifications/01_collecteur.md` §6.2). Backend : règles de contact par
rôle, liste des contacts, compteur de non-lus. Frontend : une seule interface partagée
(pas 3 copies), câblée dans les 19 points d'entrée réels des 3 Drawers concernés (le
bouton "Messagerie" du collecteur ouvrait un `Placeholder()` vide, rien n'existait chez
le chef ni le CEO). Le dégustateur simple et le laboratoire n'ont toujours pas de
messagerie (décision du propriétaire).

Ancienne mise à jour (10/09/2026), tâches 26 et 27 terminées. Le propriétaire a demandé
de « s'occuper des notifications » : le carnet `files/notifications/` (6 fichiers) a été
relu entièrement, toutes ses questions ouvertes tranchées, puis recoupé avec le vrai
code — bien plus construit que le carnet ne le disait (négociation/refus, urgents, dates
de livraison stock — tout existe et est testé). La tâche 26 a corrigé les 4 vrais manques
trouvés (collecteur non notifié de la réception, labo non notifié d'un nouvel
échantillon, CEO qui propose/met à jour une négociation ne notifiait personne, clic sur
une notification collecteur sans effet). En creusant, un point est apparu plus gros
qu'une notification manquante : la "décoche" de réception physique était bloquée en dur
côté code. Le propriétaire a explicitement confirmé vouloir permettre cette annulation,
avec notification dans les deux sens — tâche 27, faite : nouvelle action serveur
`annuler-reception`, notifie collecteur + Direction + Chef, et le laboratoire seulement
si son analyse est déjà en cours.

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
| 27 | Permettre d'annuler une réception physique confirmée, avec notification dans les deux sens | **Terminée et commitée** (`39d7a35`) | à vérifier à l'écran |
| 28 | Messagerie — backend : règles de contacts par rôle, liste des contacts, compteur de non-lus | **Terminée et commitée** (`5f9c4c6`) | personne |
| 29 | Messagerie — frontend : pages de conversation partagées, câblage dans les 3 Drawers concernés | **Terminée et commitée** (`9d6c81f`) | à vérifier à l'écran |
| 30 | Messagerie — backend : photo jointe, référence à un échantillon, modifier/supprimer un message (+ correction d'un bug de permission de suppression) | **Terminée et commitée** (`c9a4dda`) | personne |
| 31 | Messagerie — frontend : bouton photo, sélecteur d'échantillon, menu modifier/supprimer, navigation au clic sur une référence | **Terminée et commitée** (`67ff348`) | à vérifier à l'écran |
| 32 | Messagerie — chef dégustateur ↔ chef dégustateur, libellé "Messagerie" chez le collecteur (au lieu de "Messagerie Direction") | **Terminée et commitée** (`8198c6f`) | à vérifier à l'écran |
| 33 | Les deux petits défauts connus : suppression de `test/widget_test.dart`, débordement de l'en-tête négociation sur la carte collecteur (+ test 360 px) | **Terminée et commitée** | personne |
| 35 | Mise à jour des écrans : tirer vers le bas + rechargement automatique toutes les 30 s | **Terminée et commitée** | à vérifier à l'écran (téléphone) |
| 36 | Session expirée → retour à la connexion, photo en grand, suggestions variété, bouton Ajouter qui affiche l'erreur ; + dates de livraison sur la carte dégustateur/chef, suppression des données de démonstration | **Terminée et commitée** | à vérifier à l'écran (téléphone) |
| 37 | Les formulaires ne se ferment plus en touchant à côté ; retour Android demande confirmation ; + écran rouge du filtre « Jour exact » (collecteur) ; + rester connecté 8 h sans utilisation | **Terminée et commitée** | à vérifier à l'écran (téléphone) |

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

Aucun. Les deux défauts connus (`test/widget_test.dart`, débordement de la carte collecteur)
ont été corrigés par la tâche 33.

`chef.tests.ChefDashboardApiTests.test_delai_alignement_and_classifications_use_submitted_evaluations`
ne se reproduit plus depuis la tâche 12 (163 tests Django, 0 échec) — probablement réglé en
effet de bord par la tâche 13 (séparation des dates prévue/réelle). Retiré de la liste.
