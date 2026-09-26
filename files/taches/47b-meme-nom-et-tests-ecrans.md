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

### Fait

- `lib/core/models/echantillon.dart` : le numéro affichable d'échantillon s'appelle maintenant `numero` et lit/écrit la clé serveur `numero`.
- `lib/core/services/gestion_echantillons_service.dart` : le mapping API vers gestion utilise la clé interne `numero`, plus `ref`.
- `lib/core/models/mock_echantillons_gestion.dart` : les données de démonstration de gestion utilisent `numero`.
- `lib/core/widgets/gestion_echantillons/echantillon_card.dart` : les cartes de gestion affichent le numéro via `numero`.
- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : la recherche/suppression utilise `numero` et le service est injectable pour les tests.
- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : la création/modification alimente `numero` côté modèle, sans changer le formulaire visible.
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : même correction que dégustateur, avec service injectable.
- `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : même correction de création/modification que dégustateur.
- `lib/core/models/echantillon_evaluation.dart` : la référence bouteille s'appelle `referenceBouteille`; les dates s'appellent `dateAjout`, `dateArriveeEchantillon`, `dateReceptionEchantillon`.
- `lib/core/services/evaluation_service.dart` : le mapping d'évaluation envoie `reference_bouteille` et `date_arrivee_echantillon`, sans clé interne `ref` ni `date_arrivee`.
- `lib/core/models/mock_echantillons_evaluation.dart` : les données de démonstration d'évaluation suivent les noms uniques.
- `lib/core/widgets/evaluation_echantillons/echantillon_card.dart` : les cartes d'évaluation affichent la référence bouteille via `referenceBouteille`.
- `lib/3_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` : la recherche et l'ouverture du formulaire utilisent les nouveaux noms.
- `lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` : même correction que dégustateur.
- `lib/core/analyses/ligne_analyse_labo.dart` : les dates de ligne d'analyse utilisent `dateAjout`, `dateArriveeEchantillon`, `dateReceptionEchantillon`.
- `lib/core/analyses/ligne_analyse_labo_service.dart` : la consultation labo lit `numero`, `date_arrivee_echantillon`, `date_reception_echantillon`, sans fallback `ref`/`date_arrivee`.
- `lib/4_laboratoire/echantillons_labo/models/echantillon_labo.dart` : le numéro d'échantillon labo s'appelle `numero` et lit la clé serveur `numero`.
- `lib/4_laboratoire/echantillons_labo/models/mock_echantillons_labo.dart` : les données labo de démonstration utilisent `numero`.
- `lib/4_laboratoire/echantillons_labo/widgets/echantillon_labo_card.dart` : les cartes labo affichent `numero`.
- `lib/4_laboratoire/echantillons_labo/echantillons_labo_page.dart` : la recherche labo utilise `numero` et les services sont injectables.
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` : les services collecteur/notifications sont injectables pour tester l'écran sans API.
- `lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart` : le service des sessions est injectable.
- `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart` : le service des sessions chef est injectable.
- `lib/1_ceo/echantillons/echantillons_ceo_page.dart` : le service Direction est injectable pour tester l'écran sans API.
- `lib/1_ceo/tableau_de_bord/models/dashboard_models.dart` : les décisions urgentes utilisent `numero`, plus `ref`.
- `lib/1_ceo/tableau_de_bord/widgets/urgent_panel.dart` : le panneau urgent affiche `numero`.
- `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` : la date de réception physique suit le nom `dateReceptionEchantillon`.
- `lib/core/utils/date_filter_utils.dart` : les filtres par date lisent les noms unifiés.
- `lib/core/widgets/messagerie/conversation_page.dart` : la référence d'échantillon jointe aux messages utilise `numero`.
- `test/cablage_api_test.dart` : le test de cablage lit les champs renommés.
- `test/date_filter_utils_test.dart` : les tests de filtre par dates utilisent les noms unifiés.
- `test/echantillon_classification_vide_test.dart` : le test de classification utilise `numero`.
- `test/evaluation_urgente_navigation_test.dart` : le test d'urgence utilise `referenceBouteille`.
- `test/ecrans_principaux_sans_uuid_test.dart` : nouveau fichier de tests widget, un test pour collecteur, dégustateur gestion, dégustateur évaluation, dégustateur sessions, chef gestion, chef évaluation, chef sessions, labo échantillons et direction échantillons; les tests injectent les fixtures API, fixent la largeur à 360 px et vérifient les `Text` contre UUID et dates ISO.
- Aucune migration créée ou appliquée. Aucun changement serveur.

Champs présents dans `test/fixtures/api/` mais non lus par un littéral de clé dans `lib/` d'après le relevé automatique :

`badge`, `criteres`, `date_arrivee`, `date_modification`, `date_reception_physique`, `days_waiting`, `degustateur_id`, `delegations`, `divergence_details`, `is_complete`, `nb_echantillons`, `parametres_hors_normes`, `previous`, `receptionnes`, `ref`, `refuses`, `submitted_count`, `technicien`, `total_count`.

Clés d'enveloppe de fixture également absentes de `lib/` mais non métier : `data`, `route`, `status_code`.

### Vérifié

```bash
Get-ChildItem -Recurse -Path lib,test -File -Include *.dart | Select-String -Pattern '\.ref\b','\bref:','''ref''','"ref"'
```

Sortie chiffrée : `Count : 0`.

```bash
Get-ChildItem -Recurse -Path lib,test -File -Include *.dart | Select-String -Pattern 'dateLivraisonEchantillon','dateReceptionPhysique','dateEnregistrement','''date_arrivee''','"date_arrivee"','''date_livraison_echantillon''','"date_livraison_echantillon"','''date_reception_physique''','"date_reception_physique"','''date_enregistrement''','"date_enregistrement"'
```

Sortie chiffrée : `Count : 0`.

```bash
Get-ChildItem -Recurse test\fixtures\api -Filter *.json | Measure-Object
```

Sortie chiffrée : `Count : 567`.

```bash
# relevé des clés fixtures absentes des lectures littérales de lib/
Fixture key count: 244
Unused in lib count: 22
badge
criteres
data
date_arrivee
date_modification
date_reception_physique
days_waiting
degustateur_id
delegations
divergence_details
is_complete
nb_echantillons
parametres_hors_normes
previous
receptionnes
ref
refuses
route
status_code
submitted_count
technicien
total_count
```

```bash
git diff --check
```

Sortie : code retour 0 ; uniquement des avertissements CRLF/LF, aucun whitespace error.

```bash
dart format lib test
```

Commande interrompue après environ 90 secondes sans sortie ; code retour 1 après interruption.

```bash
dart format lib\core\models\echantillon.dart lib\core\models\echantillon_evaluation.dart lib\core\services\evaluation_service.dart lib\core\services\gestion_echantillons_service.dart lib\core\utils\date_filter_utils.dart lib\core\analyses\ligne_analyse_labo.dart lib\core\analyses\ligne_analyse_labo_service.dart lib\4_laboratoire\echantillons_labo\models\echantillon_labo.dart test\ecrans_principaux_sans_uuid_test.dart
```

Commande interrompue après environ 30 secondes sans sortie ; code retour 1 après interruption.

### Non fait

- Je n'ai pas lancé `flutter analyze lib test` ni `flutter test` : la tâche dit explicitement que ce sandbox ne peut pas lancer Flutter et demande de ne pas essayer.
- Les nouveaux tests widget n'ont donc pas été exécutés dans ce sandbox.
- Je n'ai appliqué aucune migration et je n'ai pas lancé Django, conformément à la consigne Flutter seulement.

### HORS PÉRIMÈTRE

- Le skill `frontend-design` demandé par `CLAUDE.md` n'est pas disponible dans cette session.
- Fichiers non suivis déjà présents et laissés intacts : `backend_new/backup_propre.json`, `backend_new/media/`, `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json`, `files/taches/CONTROLE-MANUEL.md`.
