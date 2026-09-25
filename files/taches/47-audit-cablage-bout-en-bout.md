# Tâche 47 — Audit du câblage de bout en bout (serveur ↔ application ↔ rôles)

Lis `files/taches/PROTOCOLE.md`, puis `CLAUDE.md`, et la règle de mémoire du projet :
**même chose = même nom ; les données d'un utilisateur ne fuient jamais vers un autre.**

**Priorité : cette tâche passe AVANT les tâches 43 à 46.** Elle vérifie la base sur
laquelle elles s'appuient.

## Pourquoi

La propriétaire teste l'application comme en vrai, avec un compte par rôle, et elle a
l'impression que les pages de rôles différents ne sont pas reliées entre elles. Voici ce
que Claude a trouvé en une soirée, chacun corrigé à la main :
- la classification vide `''` faisait échouer toute la liste des échantillons ;
- la page Gestion des échantillons du dégustateur ne montrait que les échantillons reçus,
  alors que c'est là qu'on confirme la réception : elle restait vide pour toujours ;
- une carte de session affichait l'UUID de la session et celui de l'organisateur ;
- la carte d'évaluation affichait l'UUID au lieu du numéro, et la date brute ;
- la même idée porte des noms différents : `ref` = numéro (`gestion_echantillons_service`)
  **ou** référence bouteille (`evaluation_service`) ; `date_arrivee` /
  `date_arrivee_echantillon` / `dateLivraisonEchantillon` ; `fournisseur` / `fournisseur_nom`
  / `code_fournisseur`…
- la déconnexion laissait les pages de l'ancien compte en vie (voir tâche 46 A).

On arrête de corriger au cas par cas : cette tâche **prouve** que tout est relié.

## A — Un parcours réel, de bout en bout, sur le serveur

Test Django (ex. `backend_new/core/tests_parcours.py`) qui crée des comptes de chaque rôle
puis déroule le vrai parcours d'un échantillon **avec les vraies routes de l'API** (pas en
écrivant directement en base) :
collecteur crée l'échantillon (avec photo si possible) → dégustateur / chef le voit et
confirme la réception → session de dégustation créée, approuvée, présence confirmée →
évaluations soumises → labo saisit l'analyse → direction valide / conclut l'achat →
collecteur confirme l'achat ; notifications et messagerie au passage.

À **chaque étape**, pour **chaque rôle**, le test appelle toutes les routes GET que
l'application utilise pour ce rôle (liste dans `lib/` : grep `'/api/`) et vérifie :
1. code 200 (ou 403 seulement si l'écran n'est jamais montré à ce rôle — liste explicite) ;
2. l'échantillon apparaît là où ce rôle doit le voir, et **n'apparaît pas** là où il ne doit
   pas (un collecteur ne voit pas les échantillons d'un autre collecteur, le labo ne voit
   que les reçus…) ;
3. aucune erreur serveur.

Le test **enregistre** chaque réponse JSON dans `test/fixtures/api/<role>/<etape>/<route>.json`
(données de test, pas la vraie base).

## B — L'application lit chaque réponse sans se tromper

Test Flutter (ex. `test/cablage_api_test.dart`) qui prend **chaque** fichier de
`test/fixtures/api/` et le fait passer par le **vrai** code de lecture de l'écran concerné
(service + modèle : `_toFlutterMap`, `fromJson`, `EchantillonCeoView`, `EchantillonLabo`,
`EchantillonCollecteur`, `SessionDegustation`, évaluations, analyses, notifications,
messages, tableaux de bord de chaque rôle…). Pour cela, rends les fonctions de conversion
testables (publiques ou `@visibleForTesting`) sans changer leur comportement.

Vérifie pour chaque objet lu :
- aucune exception (valeurs vides, `null`, énumérations inconnues) ;
- **aucun UUID affiché** : les champs destinés à l'écran (numéro, nom de fournisseur,
  nom de collecteur, organisateur…) ne ressemblent jamais à un UUID ;
- **dates** : toute date destinée à l'écran passe par un formateur (`JJ/MM/AAAA`, avec
  l'heure si utile) ; aucune chaîne ISO brute (`2026-09-25T…`) ne s'affiche.

Complète par un test widget par écran principal de chaque rôle, nourri avec ces fichiers,
qui cherche à l'écran un motif d'UUID ou de date ISO : **zéro** occurrence.

## C — Même chose = même nom

1. Écris dans ton rapport un tableau : pour chaque idée (numéro d'échantillon, référence
   bouteille, fournisseur, collecteur, date annoncée, date de réception, date
   d'enregistrement, date de livraison du stock, statut de chaque rôle…), le nom côté
   serveur et **tous** les noms utilisés côté Flutter.
2. Côté Flutter, unifie : un seul nom par idée dans tous les modèles et services
   (ex. `numero` pour 2026/0001, `referenceBouteille` pour la référence, `fournisseurNom`,
   `dateArriveeEchantillon`…). Plus jamais `ref` pour deux choses différentes.
   Renommage mécanique, sans changer le comportement.
3. Côté serveur : **ne renomme et ne supprime rien** dans cette tâche. Liste les champs
   envoyés que l'application n'utilise jamais, et les doublons (même valeur sous deux
   noms). La propriétaire décidera.

## D — Pages vides ou en erreur

Pour chaque rôle, vérifie avec les données du parcours A qu'aucune page n'est vide « par
erreur » (filtre trop strict, mauvais champ, mauvais rôle, route refusée) : Gestion des
échantillons, Évaluation des échantillons, Analyse labo, Sessions, Vue d'ensemble,
tableaux de bord. Une page vide doit l'être **seulement** parce qu'il n'y a rien à montrer
pour ce rôle (et elle affiche alors le message « système tout neuf » ou « aucun résultat »).
Liste dans le rapport chaque page, par rôle, avec : ce qu'elle montre, et la règle
(ex. « labo : seulement les échantillons reçus »).

Si une règle métier n'est pas claire (qui doit voir quoi), ne devine pas : `## QUESTION`.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera les tests Flutter et
Django. Le test du parcours A doit pouvoir tourner seul
(`manage.py test core.tests_parcours`).

## RAPPORT
