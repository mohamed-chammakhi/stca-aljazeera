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

### Fait

- `backend_new/core/tests_parcours.py` cree un test Django de parcours API bout en bout : comptes par role, creation d'un echantillon par collecteur avec photo, reception degustateur, session creee/approuvee/presence confirmee, evaluations degustateur + chef soumises, analyse labo soumise, validation/achat Direction + collecteur, puis message lie a l'echantillon. Pour l'utilisateur, cela prouve que les roles voient le meme dossier au bon moment et qu'un deuxieme collecteur ne voit pas les donnees du premier.
- `test/fixtures/api/` contient 567 reponses JSON generees par le test, rangees par role et etape. Pour l'utilisateur, ces fichiers donnent une trace relisible de ce que l'application recoit vraiment a chaque phase du parcours.
- `test/cablage_api_test.dart` ajoute le test Flutter de lecture des fixtures par les vrais modeles/parsers disponibles (`EchantillonCollecteur`, `Echantillon` gestion, `EchantillonLabo`, `LigneAnalyseLaboService.ligneFromApi`, `RapportLabo`, `SessionDegustation`, notifications, messages, profils, dashboard CEO). Pour l'utilisateur, il doit detecter les UUID ou dates ISO brutes dans les champs destines a l'affichage.
- `lib/core/services/gestion_echantillons_service.dart` expose `echantillonApiToGestionFlutterMap()` et reutilise cette meme fonction dans le service. Pour l'utilisateur, aucun comportement ne change ; le mapping backend -> modele Flutter devient testable.
- Aucune migration n'a ete creee ni appliquee sur la vraie base.

Table "meme chose = meme nom" releve pendant l'audit :

| Idee | Serveur | Noms Flutter vus |
|---|---|---|
| Numero d'echantillon | `numero` | `numero`, `ref`, `id` dans certaines vues CEO d'affichage |
| Reference bouteille | `reference_bouteille` | `referenceBouteille`, `reference_bouteille`, `echantillon_ref`, `echantillonReferenceBouteille` |
| Fournisseur | `fournisseur`, `fournisseur_nom`, `code_fournisseur` | `fournisseurId`, `fournisseurNom`, `codeFournisseur`, `fournisseurAffichage`, `fournisseur` |
| Collecteur | `collecteur`, `collecteur_nom` | `collecteurId`, `collecteurNom`, `collecteur` |
| Date annoncee d'arrivee echantillon | `date_arrivee_echantillon` | `dateArriveeEchantillon`, `date_arrivee`, `dateLivraisonEchantillon` |
| Date reception physique | `date_reception_echantillon` | `dateReceptionEchantillon`, `dateReceptionPhysique` |
| Date enregistrement | `date_ajout` | `dateAjout`, `dateEnregistrement` |
| Date livraison stock | `date_livraison_stock`, `date_livraison_stock_fin` | `dateLivraisonStock`, `dateStockSouhaiteeDebut`, `dateStockSouhaiteeFin` |
| Statut collecteur | `statut_collecteur` | `statutCollecteur`, `statut`, `achatConfirme` |
| Statut degustateur/evaluation | `statut_degustateur`, evaluation `statut` | `statutDegustateur`, `statut`, `status` local dans service evaluation |
| Statut labo | `statut_labo`, analyse `statut` | `statutLabo`, `statutAnalyse`, `statut` |
| Statut Direction | `statut_ceo` | `statutCeo`, `statut` |

Pages / routes auditees avec la regle de visibilite :

| Role | Pages/routes couvertes | Regle verifiee |
|---|---|---|
| Direction | echantillons, evaluations, analyses, analyses/echantillons, dashboard, utilisateurs, panel, notifications, messagerie | voit le dossier complet et les donnees agregees ; routes GET a 200 |
| Collecteur proprietaire | echantillons, carte collecteur, notifications, messagerie | voit seulement ses echantillons ; achat confirme apres negociation |
| Autre collecteur | echantillons, carte collecteur, notifications, messagerie | ne voit pas l'echantillon du premier collecteur |
| Degustateur | gestion echantillons, filtre recus, evaluations, analyses en lecture, sessions, membres panel, dashboard, notifications, messagerie | voit les echantillons ; le filtre recu reste vide avant reception puis contient l'echantillon apres reception |
| Chef degustateur | gestion echantillons, evaluations, vue ensemble chef, analyses en lecture, sessions, utilisateurs, membres panel, dashboard chef, notifications, messagerie | voit le dossier panel et les agregats chef ; ses evaluations restent separees de celles du degustateur |
| Laboratoire | echantillons, analyses, analyses/echantillons, notifications, messagerie | ne voit que les echantillons recus physiquement |

### Verifie

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test core.tests_parcours -v 2
```

Sortie chiffree : `Found 1 test(s)` ; `Ran 1 test in 6.246s` ; `OK`.

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run
```

Sortie : `No changes detected`.

```bash
cd backend_new
.\venv\Scripts\python.exe -m py_compile core\tests_parcours.py
```

Sortie : aucune ; code retour 0.

```bash
Get-ChildItem -Recurse test\fixtures\api -Filter *.json | Measure-Object
```

Sortie chiffree : `Count : 567`.

```bash
dart format lib\core\services\gestion_echantillons_service.dart test\cablage_api_test.dart
```

Commande interrompue apres environ 60 secondes sans sortie ; code retour 1 apres interruption. Je ne la compte pas comme reussie.

### Non fait

- Je n'ai pas lance `flutter analyze lib test` ni `flutter test` : la consigne de cette tache dit que le sandbox ne peut pas lancer Flutter et demande de ne pas essayer.
- Le test Flutter `test/cablage_api_test.dart` est ajoute mais non execute dans ce sandbox.
- Je n'ai pas ajoute un test widget par ecran principal : sans execution Flutter et avec les ecrans qui chargent leurs donnees a l'ouverture, cela reste a faire cote relecture/outillage Flutter.
- Je n'ai pas fait le renommage mecanique complet de tous les noms Flutter divergents (`ref`, `date_arrivee`, `dateLivraisonEchantillon`, etc.). J'ai seulement rendu testable le mapping central de gestion des echantillons utilise par degustateur/chef.
- Je n'ai pas liste les champs serveur jamais utilises de facon exhaustive. Le tableau ci-dessus liste les doublons/noms divergents observes dans les flux audites.
- Je n'ai pas lance la suite Django complete `manage.py test --keepdb`; seul le parcours cible de cette tache a ete execute.

### HORS PERIMETRE

- `files/backend_sprint_plan.md` est demande par les consignes projet mais absent du depot.
- Des fichiers non suivis existaient deja avant cette tache et n'ont pas ete modifies volontairement : `backend_new/backup_propre.json`, `backend_new/media/`, `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json`, `files/taches/CONTROLE-MANUEL.md`.
