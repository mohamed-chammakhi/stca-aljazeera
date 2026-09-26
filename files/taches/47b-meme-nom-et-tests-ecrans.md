# Tâche 47b — Suite de l'audit : un seul nom par idée, et un test par écran

Lis `files/taches/PROTOCOLE.md`, puis `CLAUDE.md`. Flutter seulement. Aucune migration,
aucun changement du serveur.

La partie 1 de la tâche 47 est **faite et commitée** (`9bd2140e`) : parcours serveur
`backend_new/core/tests_parcours.py`, 567 réponses dans `test/fixtures/api/`, et
`test/cablage_api_test.dart` qui lit chaque réponse sans plantage, UUID ni date brute
(0 défaut). Ne les casse pas : `test/cablage_api_test.dart` doit rester vert.

Relis le tableau « même chose = même nom » du `## RAPPORT` de
`files/taches/47-audit-cablage-bout-en-bout.md`.

## A — Un seul nom par idée côté Flutter (renommage mécanique)

Dans `lib/` et `test/`, pour les **modèles et services** (pas les textes affichés) :

| Idée | Nom unique à utiliser |
|---|---|
| Numéro d'échantillon (2026/0001) | `numero` |
| Référence bouteille | `referenceBouteille` |
| Nom du fournisseur | `fournisseurNom` |
| Nom du collecteur | `collecteurNom` |
| Date annoncée par le collecteur | `dateArriveeEchantillon` |
| Date de réception physique | `dateReceptionEchantillon` |
| Date d'enregistrement | `dateAjout` |

- En particulier, `ref` ne doit plus exister comme nom de champ : il veut dire « numéro »
  dans `core/models/echantillon.dart` et « référence bouteille » dans
  `core/models/echantillon_evaluation.dart`. Renomme selon ce qu'il contient vraiment.
  Même chose pour les clés internes des maps de conversion (`'ref'`, `'date_arrivee'`…) :
  utilise les noms du serveur (`numero`, `reference_bouteille`,
  `date_arrivee_echantillon`…).
- `dateLivraisonEchantillon` / `dateReceptionPhysique` / `dateEnregistrement` →
  noms ci-dessus.
- Renommage **sans changement de comportement**. Les données de démonstration / mocks
  suivent.
- Ne touche pas à `codeFournisseur` (il sera supprimé par la tâche 43).

## B — Un test par écran principal (pas d'UUID ni de date brute à l'écran)

Pour chaque rôle, un test widget de l'écran de liste principal, nourri avec les fichiers de
`test/fixtures/api/<role>/…` (injecte les données : si l'écran charge lui-même, ajoute un
paramètre de service injectable, sans changer le comportement par défaut) :
collecteur (Mes échantillons), dégustateur et chef (Gestion des échantillons, Évaluation
des échantillons, Sessions), labo (Échantillons), direction (Échantillons). Chaque test
parcourt tous les `Text` affichés et vérifie : **aucun** motif d'UUID, **aucune** date ISO
(`2026-09-25T…`). Largeur 360 px, sans débordement.

## C — Champs du serveur jamais utilisés

Liste dans le rapport (sans rien supprimer) les champs envoyés par le serveur dans
`test/fixtures/api/` qu'aucun code de `lib/` ne lit.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera `flutter analyze
lib test` et `flutter test`.

## RAPPORT
