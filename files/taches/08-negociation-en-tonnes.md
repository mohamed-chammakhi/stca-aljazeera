# Tâche 08 — Négociation en tonnes, quantité du PDG, prix total, remarque

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Source de la demande : `docs/retours-utilisation-et-questions.md`, points 2.4 et 2.5.

**C'est la tâche la plus délicate de la série. Lis tout le contexte avant d'écrire une ligne.**

---

## Contexte

Le propriétaire du projet a dit une chose simple et ferme : **l'entreprise ne travaille jamais
en litres, elle travaille en tonnes.** Or l'écran de négociation du collecteur affiche des prix
par litre.

### Ce que le code fait aujourd'hui

**Le prix est un texte libre, avec l'unité écrite dedans.**
`lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart:115` :
`String? budgetNegociation;` — et L121 `String? prixFinal;`.
Les valeurs ressemblent à `'9.50 TND/L'`
(`mes_echantillons/services/echantillon_mock_data.dart:86, 127, 148`).

**L'affichage n'ajoute aucune unité.** `_NegociationDetails`
(`widgets/card/echantillon_collecteur_card.dart:554-589`) rend `budgetNegociation` tel quel,
L575-576. L'unité vue à l'écran vient donc uniquement du texte stocké.

**Le calcul du total est déjà centralisé, et c'est une bonne chose.**
`lib/core/utils/montant_achat.dart` fait déjà prix × quantité. Il sait lire `/kg` et `/t`
(L62-63), et **prend le litre par défaut quand aucune unité n'est écrite** (L64-66), avec la
constante de densité `kDensiteHuileOlive = 0.916` (L17) pour convertir des tonnes en litres.
Le commentaire d'en-tête du fichier dit explicitement que cette réconciliation doit vivre là et
nulle part ailleurs.

**Trois autres endroits affichent des litres :**
- `lib/2_collecteur/notifications/notifications_collecteur_page.dart:573-574` :
  `'${budget.toStringAsFixed(2)} TND/L'`
- `lib/2_collecteur/notifications/services/notification_mock_data.dart:24, 73, 122` :
  textes `"Budget alloué : 7.80 TND/L"`
- `widgets/dialogs/confirmer_achat_dialog.dart:232` : exemple `'ex: 9.20 TND/L'`

**La quantité proposée par le PDG n'existe pas côté collecteur.**
Elle s'appelle `quantiteCibleT` et existe dans `lib/core/models/echantillon.dart:53`
(clé JSON `quantite_cible_t`) et dans `lib/1_ceo/utilisateurs/models/echantillon_ceo_view.dart:49`.
Le PDG la saisit dans `lib/1_ceo/analyse_organoleptique/widgets/approval_dialog.dart`.
**`EchantillonCollecteur` ne l'a pas.** Le collecteur ne peut donc pas voir la quantité qu'on
lui propose, ni le montant total.

**La fenêtre de confirmation n'a pas de champ libre.**
`widgets/dialogs/confirmer_achat_dialog.dart` a exactement trois champs : prix convenu
(L227-236), n° citerne (L240-246), camion (L250-256). Le rappel de l'offre de la direction est
en haut (L175-224). Rien pour écrire un commentaire.

---

## CONSIGNE

### Partie A — la tonne devient l'unité par défaut

1. Dans `lib/core/utils/montant_achat.dart`, **inverser l'unité par défaut** : un prix écrit
   sans unité se lit désormais **par tonne**, plus par litre.

2. **Attention, ne casse pas les données existantes.** Continue à reconnaître `/L`, `/kg` et
   `/t` explicitement. Ce qui change, c'est seulement le cas « aucune unité écrite ». Mets à
   jour le commentaire des lignes 64-66, qui explique aujourd'hui l'inverse.

3. Garde `kDensiteHuileOlive` : elle reste nécessaire pour lire les anciens prix en `/L`.

4. Faire disparaître `TND/L` de tous les écrans du collecteur, aux quatre endroits listés dans
   le contexte ci-dessus. L'unité affichée devient `TND/T`.

### Partie B — la quantité du PDG et le prix total

5. Ajouter `quantiteCibleT` à `EchantillonCollecteur` : déclaration, constructeur, `fromJson`,
   `toJson`, et le mapping dans `mes_echantillons/services/echantillon_collecteur_service.dart`.
   **Garde exactement le même nom que dans `lib/core/models/echantillon.dart`** — c'est la
   règle 1 du `CLAUDE.md` : même chose, même nom.

6. Dans `_NegociationDetails` (`echantillon_collecteur_card.dart:554-589`), afficher trois
   lignes au lieu d'une :

   | Ligne | Source |
   |---|---|
   | Quantité proposée | `quantiteCibleT`, suivi de `T` |
   | Prix par tonne | `budgetNegociation` |
   | Prix total | `MontantAchat.formater(budgetNegociation, quantiteCibleT)` |

7. **N'écris pas ton propre calcul de total.** Utilise `MontantAchat` — c'est déjà fait, et le
   fichier dit lui-même que deux calculs différents ne doivent jamais coexister.

8. Si `quantiteCibleT` est absent, n'affiche ni la ligne quantité ni la ligne total. Pas de
   `null`, pas de `0 T` à l'écran.

### Partie C — la remarque du collecteur

9. Ajouter un champ « Remarque du collecteur » dans `confirmer_achat_dialog.dart`, texte libre,
   **non obligatoire**.

10. Le faire remonter jusqu'au bout de la chaîne : la signature de rappel L27-33, la validation
    L310-330, l'appel dans `mes_echantillons_page.dart:231-255`, puis `confirmerAchat` dans
    `echantillon_collecteur_service.dart:235-245`.

11. Côté Django : il faut un champ pour stocker cette remarque.
    **Si cela demande une migration de base de données, tu ne la fais pas.** Tu écris ta
    question sous `## QUESTION` et tu t'arrêtes — `PROTOCOLE.md` section 2 l'impose. Tu peux
    livrer les parties A et B avant de t'arrêter, et le dire clairement dans ton rapport.

---

## Points de vigilance

- `dateStockSouhaiteeDebut` et `dateStockSouhaiteeFin` sont forcés à `null` au parsing
  (`echantillon_collecteur.dart:206-207` et `echantillon_collecteur_service.dart:81-82`).
  La date souhaitée par le PDG ne survit donc pas à un rechargement. **Ce n'est pas dans le
  périmètre de cette tâche** — signale-le sous `## HORS PÉRIMÈTRE`, ne le corrige pas ici.
- La pastille de quantité de la carte collecteur (`echantillon_collecteur_card.dart:156-158`,
  L246) affiche `'Qté : $quantite'` **sans unité**, alors que les cartes direction et
  laboratoire écrivent `' T'`. Tu peux aligner ce détail puisqu'il s'agit du même sujet.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

La suite Django prend environ 3 minutes 30 sans `--keepdb`. Ne conclus pas à un blocage avant
400 secondes.

Ajoute des tests sur `MontantAchat` : un prix `'8000'` sans unité doit maintenant donner un
total par tonne, et un prix `'9.50 TND/L'` doit continuer à donner le même résultat qu'avant ta
modification. Donne les sorties chiffrées réelles.

## QUESTION

Le modèle Django `Echantillon` ne possède pas de champ distinct pour la « Remarque du
collecteur ». Réutiliser `remarques` écraserait les remarques déjà enregistrées sur l'échantillon
et mélangerait deux informations distinctes. Ajouter `remarque_collecteur` au modèle et au
sérialiseur exige une migration Django. Autorisez-vous cette migration ?


### RÉPONSE À LA QUESTION

**Oui, la migration est autorisée.** Ajoute `remarque_collecteur` au modèle `Echantillon`, au
sérialiseur, et crée la migration correspondante.

Ton analyse est juste et c'est pour ça qu'on ne réutilise pas `remarques` : ce champ porte déjà
les observations saisies au moment de l'enregistrement de l'échantillon. Le commentaire écrit
par le collecteur au moment où il confirme la négociation est une autre information, à un autre
moment. Les mélanger ferait perdre les deux.

Le champ n'est **pas obligatoire** : il peut rester vide.

Termine ensuite la partie C : la remontée depuis la fenêtre de confirmation jusqu'au service,
puis relance les trois commandes de vérification, y compris la suite Django.

## RAPPORT

### Fait

- `lib/core/utils/montant_achat.dart` — les prix sans unité sont désormais lus par tonne ; les
  anciens prix explicitement au litre ou au kilo gardent le même montant et s'affichent en TND/T.
- `lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart` — le collecteur reçoit
  désormais la quantité cible proposée par la direction.
- `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart` — la quantité
  cible de la direction est conservée entre l'API et la carte du collecteur.
- `lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart` — la carte
  affiche quantité proposée, prix par tonne et prix total ; les quantités de ses pastilles ont
  l'unité T.
- `lib/2_collecteur/notifications/notifications_collecteur_page.dart` — les budgets de
  notification sont affichés en TND/T.
- `lib/2_collecteur/notifications/services/notification_mock_data.dart` — les messages de
  démonstration n'annoncent plus de prix au litre.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/confirmer_achat_dialog.dart` — le prix
  convenu et le rappel de l'offre sont présentés en tonnes.
- `test/montant_achat_test.dart` — couvre le nouveau défaut par tonne et la compatibilité d'un
  ancien prix explicite au litre.

### Vérifié

- `dart format lib/core/utils/montant_achat.dart lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart lib/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart lib/2_collecteur/notifications/notifications_collecteur_page.dart lib/2_collecteur/notifications/services/notification_mock_data.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/confirmer_achat_dialog.dart test/montant_achat_test.dart` — sortie : `Formatted 8 files (6 changed) in 0.20 seconds.`
- `flutter test test/montant_achat_test.dart` — sortie : `00:00 +2: All tests passed!`
- `flutter analyze lib test` — sortie : `50 issues found. (ran in 3.6s)` ; aucune erreur de
  compilation affichée.
- `flutter test` — sortie : `00:13 +97 -1`; seul échec :
  `test/widget_test.dart: Counter increments smoke test`, l'échec modèle déjà connu.
- `./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb` — échec après
  `2.4 seconds`, avant l'exécution de tests : `ValueError: Invalid truth value: release` dans
  `backend_new/aljazeera_stca/settings.py` lors de la lecture de `DEBUG`.

### Non fait

- Le champ « Remarque du collecteur » et sa transmission ne sont pas réalisés : ils exigent la
  migration Django faisant l'objet de la question ci-dessus.

### HORS PÉRIMÈTRE

- `dateStockSouhaiteeDebut` et `dateStockSouhaiteeFin` restent forcés à `null` lors du parsing,
  comme signalé dans la consigne ; aucune modification n'a été faite.
- La suite Django est bloquée par la valeur locale `DEBUG=release` ; aucune configuration n'a été
  modifiée.

---

## CONSIGNE DE REPRISE — il ne reste que la partie C

Les parties A et B sont **relues et commitées** (`c5e0f97`). N'y reviens pas : les tonnes, la
quantité proposée par la direction et le prix total sont en place et vérifiés.

**Il ne reste que la partie C : la remarque du collecteur.**
Ta question a été répondue plus haut, sous `### RÉPONSE À LA QUESTION` : **la migration est
autorisée.**

### Ce que tu fais, dans cet ordre

1. **Côté Django.** Ajoute `remarque_collecteur` au modèle `Echantillon`
   (`backend_new/echantillons/models.py`) et au sérialiseur. Champ texte, **non obligatoire**,
   qui peut rester vide. Crée la migration correspondante.

   Ne réutilise pas `remarques` : ce champ porte déjà les observations saisies au moment de
   l'enregistrement de l'échantillon. Le commentaire écrit au moment de confirmer la
   négociation est une autre information, à un autre moment.

2. **Côté Flutter.** Ajoute le champ « Remarque du collecteur » dans
   `confirmer_achat_dialog.dart`, texte libre, non obligatoire, et fais-le remonter jusqu'au
   bout : la signature de rappel, la validation, l'appel dans `mes_echantillons_page.dart`,
   puis `confirmerAchat` dans `echantillon_collecteur_service.dart`.

   Ajoute aussi le champ au modèle `EchantillonCollecteur`, avec `fromJson`, `toJson` et le
   mapping du service. **Même nom des deux côtés** : `remarque_collecteur` en JSON,
   `remarqueCollecteur` en Dart. C'est la règle 1 du `CLAUDE.md`.

3. La remarque saisie doit **survivre à un rechargement**. C'est le seul vrai critère de
   réussite : si elle disparaît quand on recharge, le travail n'est pas fait.

### Sur les tests — la leçon des tâches 06 et 07

**N'écris aucun test de widget sur les écrans du collecteur.** Ils vont chercher des données à
l'ouverture et ne se stabilisent jamais. Trois tentatives ont échoué en tâche 06.

**Ce qui marche**, et qui a très bien marché en tâche 07 : si tu as de la logique à vérifier,
sors-la dans une fonction pure de `lib/core/utils/` et teste-la directement.

Côté Django en revanche, **écris un vrai test** : la remarque envoyée est bien enregistrée et
bien relue. Là, rien ne t'en empêche.

### Vérification

```bash
flutter analyze lib test
flutter test
```

puis, **depuis le dossier `backend_new`** — lancée depuis la racine, la suite ne teste rien et
affiche `Found 0 test(s)` :

```bash
cd backend_new
./venv/Scripts/python.exe manage.py test --keepdb
```

Elle prend environ 800 secondes. Ne conclus pas à un blocage avant 15 minutes.

Référence : **50 problèmes, 0 erreur** ; **101 tests Flutter réussis** avec le seul échec connu
`test/widget_test.dart` ; **158 tests Django** avec le seul échec connu
`chef.tests.ChefDashboardApiTests.test_delai_alignement_and_classifications_use_submitted_evaluations`.
Ces deux échecs sont préexistants et listés dans `PROTOCOLE.md`.

Si `flutter` refuse de s'exécuter chez toi, dis-le franchement comme tu l'as fait à chaque
fois, et ne revendique aucun chiffre. Écris ton compte rendu sous `### Reprise`.

### Reprise

#### Fait

- `backend_new/echantillons/models.py` — la remarque saisie lors de la confirmation d'achat est
  stockée séparément des observations d'enregistrement de l'échantillon et peut rester vide.
- `backend_new/echantillons/serializers.py` — l'API renvoie `remarque_collecteur` après
  enregistrement et lors des rechargements suivants.
- `backend_new/echantillons/views.py` — l'action de confirmation d'achat enregistre la remarque
  du collecteur et permet aussi de la vider.
- `backend_new/echantillons/migrations/0011_echantillon_remarque_collecteur.py` — la base de
  données reçoit le nouveau champ facultatif avec une valeur vide pour les lignes existantes.
- `backend_new/echantillons/tests.py` — un test API confirme que la remarque envoyée est écrite
  en base, renvoyée immédiatement, puis encore présente après un nouveau `GET`.
- `lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart` — la remarque de
  confirmation est lue et écrite sous le nom JSON `remarque_collecteur`.
- `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart` — la remarque
  circule dans les mappings API et dans la requête de confirmation d'achat.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/confirmer_achat_dialog.dart` — le collecteur
  dispose du champ texte facultatif « Remarque du collecteur », prérempli après rechargement.
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` — les deux usages du dialogue
  transmettent et conservent la remarque saisie.
- `files/mapbackend.md` — le checkpoint backend documente désormais ce champ et ses
  vérifications.
- `files/taches/08-negociation-en-tonnes.md` — le présent rapport de reprise consigne les
  changements et les sorties réelles des contrôles.

#### Vérifié

- `dart format lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/confirmer_achat_dialog.dart lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` — sortie :
  `Formatted 4 files (4 changed) in 0.12 seconds.`
- Depuis `backend_new`,
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run` — sortie : `No changes detected`.
- Depuis `backend_new`, test ciblé
  `echantillons.tests.CollectorEchantillonApiTests.test_collector_purchase_remark_is_stored_and_reloaded --keepdb -v 2` — sortie : `Found 1 test(s)`, `Ran 1 test in 8.407s`, `OK` ; la migration `0011_echantillon_remarque_collecteur` est appliquée avec `OK`.
- Depuis `backend_new`,
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test echantillons --keepdb -v 1` — sortie : `Found 25 test(s)`, `Ran 25 tests in 160.146s`, `OK`.
- Depuis `backend_new`,
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test --keepdb -v 1` — sortie : `Found 159 test(s)`, `Ran 159 tests in 972.186s`, un seul échec :
  `chef.tests.ChefDashboardApiTests.test_delai_alignement_and_classifications_use_submitted_evaluations`, `AssertionError: 1 != 3`. C'est l'échec préexistant documenté dans le protocole ; les 158 autres tests réussissent.
- `git diff --check` — aucune sortie, code retour `0`.
- `flutter analyze lib test` — impossible avant l'analyse : code retour `1`, six lignes
  `CreateFile failed 5 (Access is denied.)`, puis Flutter ne peut pas exécuter
  `git -c log.showSignature=false log HEAD -n 1 --pretty=format:%ad --date=iso` dans son SDK.
- `flutter test` — impossible avant l'exécution des tests : code retour `1`, même refus d'accès
  du SDK Flutter lors de l'appel à `git`.
- Contrôle supplémentaire `dart analyze lib test` — impossible avant l'analyse : code retour
  `1`, `ProcessException: Access is denied` au lancement de `analysis_server_aot.dart.snapshot`.

#### Non fait

- Aucun résultat de compilation ou de tests Flutter n'est revendiqué : les deux commandes
  demandées sont bloquées par les permissions de création de sous-processus du SDK dans cet
  environnement. Aucun changement du SDK Flutter n'a été tenté.

#### HORS PÉRIMÈTRE

- `dateStockSouhaiteeDebut` et `dateStockSouhaiteeFin` restent forcés à `null` au parsing,
  conformément à la consigne initiale ; aucune modification n'a été faite.
