# Tâche 04 — Réunir les modules dégustateur et chef dégustateur

## CONSIGNE

### Le problème

`lib/3_degustateur/` et `lib/5_chef_degustateur/` sont deux copies du même module. **33
fichiers ont exactement le même chemin relatif dans les deux dossiers.** Un bug déjà réel
est passé par là : le modèle d'évaluation a été appris à lire les statuts en minuscules
d'un seul côté, et la copie oubliée a affiché « En attente » pendant des semaines pour des
évaluations pourtant soumises. C'est la règle 1 du `CLAUDE.md` — même chose, même nom, un
seul fichier — qui doit s'appliquer ici.

Le carnet [`files/notifications/03_degustateur.md`](../notifications/03_degustateur.md) a
déjà trouvé une deuxième dérive, plus récente : les fichiers de notifications ont divergé
sans que personne ne le décide. Cette tâche est l'occasion de la corriger.

---

### Règle absolue

**Avant de fusionner un fichier, lis les deux versions en entier.** Elles ont vécu
séparément pendant des mois. Certaines différences sont des corrections reçues d'un seul
côté — les perdre ferait revenir un bug déjà réparé. D'autres sont des différences de
comportement voulues (le chef n'a pas les boutons de décision, par exemple) — celles-là
doivent devenir un paramètre du widget partagé (comme `peutGerer` sur la page Utilisateurs),
pas disparaître.

**Tu ne commites pas.** La règle du `PROTOCOLE.md` s'applique sans exception ici aussi :
Claude relit et commite lui-même, un commit par fichier fusionné. La phrase « un commit par
fichier » décrit **son** travail de relecture, pas le tien — c'est une consigne mal formulée
au départ, corrigée ici.

**Ce que ça change concrètement pour toi : tu travailles étape par étape.** Tu fais **une
seule étape** (parmi les 5 ci-dessous), tu la vérifies, tu écris ton rapport, et tu
t'arrêtes. Tu ne commences pas l'étape suivante. Claude relit, commite fichier par fichier,
puis te relance pour l'étape d'après.

C'est cette découpe qui donne la sécurité recherchée : si une fusion casse quelque chose, on
revient en arrière sur ce fichier-là sans perdre le reste.

**Destination :** `lib/core/`, dans un sous-dossier qui reflète la fonction (`models/`,
`widgets/`, `services/`), à l'image de ce qui existe déjà pour `lib/core/utilisateurs/` et
`lib/core/widgets/change_password_dialog.dart`. Les deux pages qui restent spécifiques à
chaque rôle (import, thème, drawer) appellent le composant partagé — exactement comme
`lib/1_ceo/utilisateurs/utilisateurs_ceo_page.dart` et
`lib/5_chef_degustateur/utilisateurs/utilisateurs_chef_page.dart` le font aujourd'hui.

---

### Ordre — du plus sûr au plus risqué

**Étape 1 — modèles et données statiques.** Aucune logique, aucun affichage, le risque est
minimal.

- `sessions_degustation/models/mock_sessions.dart`
- `sessions_degustation/models/session_degustation.dart`
- `gestion_echantillons/models/mock_echantillons.dart`
- `evaluation_echantillons/navigation/models/mock_echantillons.dart`
- `membres_panel/models/membre_panel.dart`
- `notifications/models/notification_degustateur.dart` — ⚠️ voir §4 (Notifications)
  ci-dessous avant de toucher ce fichier précis, ce n'est pas un simple copier-coller.

**Étape 2 — petits éléments d'affichage.**

- `gestion_echantillons/widgets/filtre_chip.dart`
- `sessions_degustation/widgets/dialogs/suppression_session_dialog.dart`
- `gestion_echantillons/widgets/dialogs/suppression_dialog.dart`

**Étape 3 — cartes.**

- `gestion_echantillons/widgets/echantillon_card.dart`
- `evaluation_echantillons/navigation/widgets/echantillon_card.dart`
- `membres_panel/widgets/membre_card.dart`
- `sessions_degustation/widgets/session_card.dart`
- `analyse_labo/widgets/analyse_card.dart`

**Étape 4 — services.** Ici les deux copies n'ont **pas le même nom** — vérifie toi-même
qu'il s'agit bien de la même fonction avant de fusionner :

| Dégustateur | Chef | Même fonction ? |
|---|---|---|
| `gestion_echantillons/services/gestion_echantillons_service.dart` | `gestion_echantillons/services/gestion_echantillons_chef_service.dart` | à vérifier |
| `membres_panel/services/membres_panel_service.dart` | `membres_panel/services/membres_panel_chef_service.dart` | à vérifier |
| `sessions_degustation/services/sessions_service.dart` | `sessions_degustation/services/sessions_chef_service.dart` | à vérifier |
| `evaluation_echantillons/services/evaluation_service.dart` | `evaluation_echantillons/services/evaluation_echantillons_chef_service.dart` | à vérifier |
| `tableau_de_bord/services/dashboard_degustateur_service.dart` | `tableau_de_bord/services/dashboard_chef_degustateur_service.dart` | ❓ probablement pas la même — le chef a un tableau de bord différent (supervision de panel). Si les données renvoyées diffèrent structurellement, **ne fusionne pas**, écris `## QUESTION`. |
| `notifications/services/notification_degustateur_service.dart` | `notifications/services/notification_degustateur_service.dart` (même chemin) | voir §4 — décision déjà prise ci-dessous |

**Étape 5 — pages et formulaires, en dernier.** Les plus gros fichiers, où les différences
de comportement (droits, boutons visibles) sont les plus nombreuses :

- `gestion_echantillons/gestion_echantillons_page.dart`
- `evaluation_echantillons/evaluation_echantillons_page.dart`
- `sessions_degustation/sessions_degustation_page.dart`
- `sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart`
- `gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`
- `membres_panel/membres_panel_page.dart`
- `analyse_labo/analyse_laboratoire_page.dart`
- `tableau_de_bord/homepage_page.dart` + tout `tableau_de_bord/widgets/home_*.dart`
- `tableau_de_bord/widgets/app_drawer.dart` — ⚠️ le drawer du chef a déjà été réordonné
  récemment (section « Comptes », commit `585c553`). Vérifie que la fusion ne fait pas
  revenir l'ancien ordre.
- `notifications/notifications_degustateur_page.dart` — après §4.

**Ce qui reste séparé, volontairement :** `evaluation_echantillons/formulaire_evaluation.dart`
(dégustateur) et le formulaire équivalent côté chef n'ont pas le même chemin ni le même
rôle exact (le chef consulte via `vue_ensemble_evaluations/`, sans bouton de décision — déjà
tranché dans [`04_chef_degustateur.md`](../notifications/04_chef_degustateur.md) §1.2). Ne
fusionne pas ces deux-là sans poser de question.

---

### 4. Le cas des notifications — décision prise, à appliquer

Le carnet [`03_degustateur.md`](../notifications/03_degustateur.md) §2.2 documente une
dérive entre les deux copies : le fichier du **chef** a deux types de notification
(`EVALUATION_SOUMISE`, `TOUTES_EVALUATIONS`) que celui du **dégustateur simple** n'a pas,
avec une fonction `isSuperTasterOnly(type)` qui les filtre.

**Décision du propriétaire (T1) : retire ces deux types.** Le fichier fusionné ne garde que
les types communs aux deux copies — le chef reçoit exactement les mêmes notifications que
le dégustateur simple, rien de plus. Retire aussi `isSuperTasterOnly()`, qui n'a plus
d'usage une fois ces deux types absents.

Le constructeur injectable (`NotificationDegustateurService({ApiClient? api})`, présent
côté dégustateur) est la version conservée — c'est elle qui permet de tester le service.

⚠️ **Ce qui n'est PAS une dérive, ne cherche pas à le "réparer" :** le bouton qui relance le
laboratoire en urgence (page Analyse laboratoire, cloche rouge) appelle déjà, côté
dégustateur **et** côté chef, le **même** service partagé
`LigneAnalyseLaboService.sendUrgentAnalyseLabo()`. Il n'y a aucun manque de ce côté — vérifié
dans les deux fichiers `analyse_laboratoire_page.dart`. Ne confonds pas cette méthode avec
`sendUrgentDegustation()` du service de notifications : celle-ci sert au CEO à relancer tous
les dégustateurs, appelée directement depuis `lib/1_ceo/analyse_organoleptique/`. Elle
n'a rien à voir avec le laboratoire ; laisse-la telle quelle.

**T2 et T3 sont tranchées, mais rien à fusionner ici :** les notifications de date
(T2 — vont vers le dégustateur simple **et** le chef) et la confirmation de présence à une
séance (T3 — notifie le créateur) n'existent pas encore dans le code, ni d'un côté ni de
l'autre. Si un fichier que tu fusionnes touche par hasard à l'un de ces deux sujets, c'est la
réponse ci-dessus qu'il faut suivre — pas une supposition, et pas un `## QUESTION` puisque
c'est déjà tranché.

---

### 5. Tests

Après **chaque** fichier fusionné, avant de passer au suivant :

```bash
cd project3
flutter analyze lib test
flutter test
```

Si un fichier casse quelque chose, répare-le avant de continuer — ne laisse pas s'accumuler
plusieurs fusions cassées dans la même étape, elles deviennent impossibles à démêler.

À la fin de l'étape, lance en plus la suite Django si tu as touché des routes ou des
serializers (normalement non, cette tâche est côté Flutter) :

```bash
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Repères à ne pas faire baisser : **157 tests Django au vert**, `flutter test` **95 réussis**
(le seul échec connu, `widget_test.dart`, est hors périmètre — ne le corrige pas ici),
`flutter analyze lib test` **0 erreur**.

**À la main, avec le backend lancé** — c'est le propriétaire du projet qui le fera, pas toi,
une fois les 5 étapes terminées : ouvrir chaque écran fusionné sous les deux rôles
(dégustateur simple, puis chef dégustateur) et vérifier que rien ne manque à l'écran. Un
champ vide qui ne plantait aucun test serait le signe d'une fusion qui a supprimé une
différence de comportement au lieu de la rendre paramétrable.

---

### 6. Hors périmètre — à signaler, pas à corriger

- La décoche de « reçu physiquement » qui ne notifie personne (§1 de
  [`03_degustateur.md`](../notifications/03_degustateur.md)) — lacune déjà connue, pas de
  cette tâche.
- T5 du carnet dégustateur — seule question encore ouverte (qui prévenir quand un
  dégustateur ajoute lui-même un échantillon manqué par le collecteur). T1 à T4 sont
  tranchées, voir §4 et le carnet.
- Tout défaut trouvé en dehors des 33 fichiers listés — signale-le, n'y touche pas.

---

## RÉPONSE À LA QUESTION 1 (contradiction Git)

Tu avais raison de t'arrêter : les deux consignes se contredisaient bien. C'était une erreur
de rédaction de la tâche, pas une exception voulue.

**C'est le `PROTOCOLE.md` qui prévaut : tu ne commites jamais.** La section « Règle absolue »
ci-dessus a été corrigée en conséquence, et te dit désormais de travailler **une étape à la
fois** puis de t'arrêter pour relecture.

Tu peux reprendre à l'**étape 1**.

---

## RAPPORT

### Étape 1 — modèles et données statiques

#### Fait

- **Créé — `lib/core/models/mock_sessions.dart`** : les données de secours des sessions sont maintenant centralisées, avec une liste propre à chaque rôle afin de conserver exactement les séances que chacun voyait avant la fusion.
- **Modifié — `lib/3_degustateur/sessions_degustation/services/sessions_service.dart`** : le dégustateur utilise la liste de secours partagée, sans changement de séances affichées.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/services/sessions_chef_service.dart`** : le chef utilise sa liste de secours dans le fichier partagé, sans changement de séances affichées.
- **Supprimé — `lib/3_degustateur/sessions_degustation/models/mock_sessions.dart`** : la copie locale est remplacée par la source partagée.
- **Supprimé — `lib/5_chef_degustateur/sessions_degustation/models/mock_sessions.dart`** : la copie locale est remplacée par la source partagée.

- **Modifié — `lib/core/models/session_degustation.dart`** : le modèle commun réexporte désormais `StatutSession` et son extension ; les écrans conservent ainsi la même API et les mêmes libellés de statut.
- **Modifié — `lib/3_degustateur/sessions_degustation/services/sessions_service.dart`** : le service lit directement le modèle commun, sans changement réseau ou métier.
- **Modifié — `lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart`** : la page utilise le modèle commun, sans changement visuel.
- **Modifié — `lib/3_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart`** : le formulaire utilise le modèle commun, sans changement de champs ni de validation.
- **Modifié — `lib/3_degustateur/sessions_degustation/widgets/dialogs/suppression_session_dialog.dart`** : le dialogue utilise le modèle commun, sans changement de confirmation.
- **Modifié — `lib/3_degustateur/sessions_degustation/widgets/session_card.dart`** : la carte utilise le modèle commun, sans changement affiché.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/services/sessions_chef_service.dart`** : le service chef lit directement le modèle commun, sans changement réseau ou métier.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart`** : la page chef utilise le modèle commun, sans changement visuel.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart`** : le formulaire chef utilise le modèle commun, sans changement de champs ni de validation.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/widgets/dialogs/suppression_session_dialog.dart`** : le dialogue chef utilise le modèle commun, sans changement de confirmation.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/widgets/session_card.dart`** : la carte chef utilise le modèle commun, sans changement affiché.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/widgets/statut_session_badge.dart`** : le badge utilise le modèle et les statuts réexportés par la source commune, sans changement de couleur ou de texte.
- **Modifié — `test/session_presence_card_test.dart`** : l'import direct des enums, devenu redondant, est retiré ; les assertions utilisateur ne changent pas.
- **Supprimé — `lib/3_degustateur/sessions_degustation/models/session_degustation.dart`** : le petit fichier relais du rôle est remplacé par l'import direct du modèle commun.
- **Supprimé — `lib/5_chef_degustateur/sessions_degustation/models/session_degustation.dart`** : le petit fichier relais du rôle est remplacé par l'import direct du modèle commun.

- **Créé — `lib/core/models/mock_echantillons_gestion.dart`** : les données de secours de gestion d'échantillons, identiques dans les deux rôles, ont une source unique ; leur contenu est inchangé.
- **Modifié — `lib/3_degustateur/gestion_echantillons/services/gestion_echantillons_service.dart`** : le service utilise les données de secours communes, sans changement des échantillons affichés.
- **Modifié — `lib/5_chef_degustateur/gestion_echantillons/services/gestion_echantillons_chef_service.dart`** : le service chef utilise les mêmes données de secours communes, sans changement des échantillons affichés.
- **Supprimé — `lib/3_degustateur/gestion_echantillons/models/mock_echantillons.dart`** : la copie locale identique est remplacée par la source partagée.
- **Supprimé — `lib/5_chef_degustateur/gestion_echantillons/models/mock_echantillons.dart`** : la copie locale identique est remplacée par la source partagée.

- **Créé — `lib/core/models/mock_echantillons_evaluation.dart`** : les huit échantillons de secours de la navigation d'évaluation ont une source unique ; les références, régions et statuts sont inchangés.
- **Modifié — `lib/3_degustateur/evaluation_echantillons/services/evaluation_service.dart`** : le service d'évaluation utilise la source de secours commune, sans changement visible.
- **Modifié — `lib/5_chef_degustateur/evaluation_echantillons/services/evaluation_echantillons_chef_service.dart`** : le service chef utilise la source de secours commune, sans changement visible.
- **Supprimé — `lib/3_degustateur/evaluation_echantillons/navigation/models/mock_echantillons.dart`** : la copie locale identique est remplacée par la source partagée.
- **Supprimé — `lib/5_chef_degustateur/evaluation_echantillons/navigation/models/mock_echantillons.dart`** : la copie locale identique est remplacée par la source partagée.

- **Créé — `lib/core/models/membre_panel.dart`** : le modèle de membre du panel devient unique et conserve l'API la plus complète, notamment `fromJsonList`, afin de ne perdre aucune capacité de lecture côté dégustateur.
- **Modifié — `lib/3_degustateur/membres_panel/membres_panel_page.dart`** : la page utilise le modèle partagé, sans changement de membres affichés.
- **Modifié — `lib/3_degustateur/membres_panel/services/membres_panel_service.dart`** : le service utilise le modèle partagé, sans changement réseau.
- **Modifié — `lib/3_degustateur/membres_panel/widgets/membre_card.dart`** : la carte utilise le modèle partagé, sans changement visuel.
- **Modifié — `lib/3_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart`** : la sélection des membres utilise aussi le modèle partagé, sans changement des choix proposés.
- **Modifié — `lib/5_chef_degustateur/membres_panel/membres_panel_page.dart`** : la page chef utilise le modèle partagé, sans changement de membres affichés.
- **Modifié — `lib/5_chef_degustateur/membres_panel/services/membres_panel_chef_service.dart`** : le service chef utilise le modèle partagé, sans changement réseau.
- **Modifié — `lib/5_chef_degustateur/membres_panel/widgets/membre_card.dart`** : la carte chef utilise le modèle partagé, sans changement visuel.
- **Modifié — `lib/5_chef_degustateur/membres_panel/models/mock_membres.dart`** : les données de secours chef référencent le modèle partagé ; leur contenu reste inchangé.
- **Supprimé — `lib/3_degustateur/membres_panel/models/membre_panel.dart`** : la copie locale est remplacée par la source partagée.
- **Supprimé — `lib/5_chef_degustateur/membres_panel/models/membre_panel.dart`** : la copie locale est remplacée par la source partagée.

- **Créé — `lib/core/models/notification_degustateur.dart`** : le modèle commun correspond à la version partagée par les deux rôles et ne contient plus `isSuperTasterOnly()` ni de logique réservée au chef.
- **Modifié — `lib/3_degustateur/notifications/notifications_degustateur_page.dart`** : la page utilise le modèle commun, sans changement d'affichage à cette étape.
- **Modifié — `lib/3_degustateur/notifications/services/notification_degustateur_service.dart`** : le service utilise le modèle commun, sans changement d'appel réseau à cette étape.
- **Modifié — `lib/3_degustateur/tableau_de_bord/homepage_page.dart`** : la navigation depuis le tableau de bord utilise le modèle commun, sans changement de destination.
- **Modifié — `lib/5_chef_degustateur/notifications/notifications_degustateur_page.dart`** : la page chef utilise le modèle commun, sans changement d'affichage à cette étape.
- **Modifié — `lib/5_chef_degustateur/notifications/services/notification_degustateur_service.dart`** : le service chef utilise le modèle commun, sans changement d'appel réseau à cette étape.
- **Modifié — `lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart`** : la navigation chef utilise le modèle commun, sans changement de destination.
- **Supprimé — `lib/3_degustateur/notifications/models/notification_degustateur.dart`** : la copie locale est remplacée par la source partagée.
- **Supprimé — `lib/5_chef_degustateur/notifications/models/notification_degustateur.dart`** : la copie locale et sa méthode `isSuperTasterOnly()` sont remplacées par la source commune décidée en T1.

- **Modifié — `files/taches/04-fusion-degustateur-chef.md`** : le présent rapport documente l'étape 1 ; aucun comportement utilisateur n'est modifié par ce fichier.

#### Vérifié

Après **chacun des six fichiers fusionnés**, les commandes réellement exécutées ont été :

```powershell
$env:CI='true'; flutter analyze lib test --no-pub
$env:CI='true'; flutter test --no-pub
```

Résultat final après chaque fusion :

| Fichier fusionné | `flutter analyze lib test --no-pub` | `flutter test --no-pub` |
|---|---:|---:|
| `mock_sessions.dart` | 51 diagnostics, **0 error** | **95 réussis, 1 échec** |
| `session_degustation.dart` | 51 diagnostics, **0 error** | **95 réussis, 1 échec** |
| `mock_echantillons.dart` (gestion) | 51 diagnostics, **0 error** | **95 réussis, 1 échec** |
| `mock_echantillons.dart` (évaluation) | 51 diagnostics, **0 error** | **95 réussis, 1 échec** |
| `membre_panel.dart` | 51 diagnostics, **0 error** | **95 réussis, 1 échec** |
| `notification_degustateur.dart` | 51 diagnostics, **0 error** | **95 réussis, 1 échec** |

L'échec est identique aux six passages et correspond au test déjà connu :

```text
test/widget_test.dart: Counter increments smoke test
Expected: exactly one matching candidate
Actual: _TextWidgetFinder:<Found 0 widgets with text "0": []>
```

Lors de la première fusion, une première analyse a dépassé le délai initial de 184,1 s ; les processus Flutter/Dart restés actifs ont été arrêtés, puis la commande a été relancée avec un délai de 400 s. La première sortie exploitable a révélé 8 erreurs d'import liées à `StatutSession` après suppression des fichiers relais. Le modèle commun a alors été corrigé pour réexporter les enums, puis **la validation complète a été relancée avec le résultat final de 51 diagnostics et 0 error avant de passer au fichier suivant**.

Contrôles finaux réellement exécutés :

```powershell
git diff --check
```

Sortie : `git diff --check = OK` (aucune erreur d'espacement ; seulement les avertissements Git de conversion LF vers CRLF sur la copie de travail).

```powershell
$oldPaths | ForEach-Object { "$_ = $(Test-Path -LiteralPath $_)" }
rg -n 'models/(mock_sessions|session_degustation|mock_echantillons|membre_panel|notification_degustateur)\.dart' lib test
```

Sortie brute utile : les **12 anciens chemins** ont chacun renvoyé `False`. Les imports trouvés pointent vers `core/models/` ; aucune référence compilée ne cible une copie supprimée.

La suite Django n'a pas été exécutée : l'étape 1 ne modifie ni route ni serializer, conformément à la condition de la consigne.

#### Non fait

- Les étapes 2 à 5 n'ont pas été commencées, conformément à la demande de s'arrêter après l'étape 1 pour relecture et commits fichier par fichier par Claude.
- Les occurrences de `EVALUATION_SOUMISE` et `TOUTES_EVALUATIONS` encore présentes dans le faux service et la présentation des notifications chef n'ont pas été retirées maintenant : ces fichiers appartiennent respectivement aux étapes 4 et 5. Seule la méthode `isSuperTasterOnly()` du modèle fusionné a été retirée à cette étape.
- Le test manuel sous les deux rôles n'a pas été effectué : la consigne le réserve au propriétaire après les cinq étapes.
- Aucun commit, push ou changement de remote n'a été effectué.

#### HORS PÉRIMÈTRE

- La décoche de « reçu physiquement » ne notifie toujours personne ; défaut déjà connu et explicitement hors périmètre.
- T5 reste ouvert : le destinataire d'une notification lorsqu'un dégustateur ajoute un échantillon manqué par le collecteur n'est pas décidé.
- `test/widget_test.dart` reste le seul test Flutter en échec : il cherche le texte de compteur `"0"` absent de l'application actuelle. Il n'a pas été modifié.
- Les 51 diagnostics de l'analyse (warnings et infos, sans erreur) sont antérieurs ou extérieurs aux six modèles fusionnés ; ils n'ont pas été corrigés.
