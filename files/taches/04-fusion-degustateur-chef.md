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

**Ce que ça change concrètement pour toi : tu t'arrêtes à des points précis, pas après
chaque étape.** Les étapes 1 à 3 sont faites et déjà relues. **Fais l'étape 4 en entier
sans t'arrêter entre ses fichiers**, vérifie, écris ton rapport, puis **arrête-toi avant
l'étape 5**. L'étape 5 est la plus grosse et la plus risqué — les différences de droits
et de boutons visibles y sont les plus nombreuses — elle garde sa propre pause.

C'est cette découpe qui donne la sécurité recherchée : si une fusion casse quelque chose, on
revient en arrière sans avoir à démêler l'étape 4 de l'étape 5.

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

### Étape 2 — petits éléments d'affichage

#### Fait

- **Créé — `lib/core/widgets/filtre_chip.dart`** : les deux rôles affichent désormais le même bouton de filtre, avec exactement le même vert, les mêmes espacements et les mêmes états sélectionné/non sélectionné.
- **Modifié — `lib/core/widgets/search_filter_bar.dart`** : la barre de recherche partagée utilise le chip commun ; aucun changement visuel pour le dégustateur.
- **Modifié — `lib/5_chef_degustateur/gestion_echantillons/widgets/search_filter_bar.dart`** : la barre chef utilise le chip commun ; aucun changement visuel, car `chefGreen` et le vert partagé valent tous deux `0xFF38835A`.
- **Supprimé — `lib/3_degustateur/gestion_echantillons/widgets/filtre_chip.dart`** : la copie du rôle est remplacée par le widget partagé.
- **Supprimé — `lib/5_chef_degustateur/gestion_echantillons/widgets/filtre_chip.dart`** : la copie du rôle est remplacée par le widget partagé ; son ancien `withOpacity(0.2)` est remplacé par le `withValues(alpha: 0.2)` commun, sans changement visuel attendu.

- **Créé — `lib/core/widgets/dialogs/suppression_session_dialog.dart`** : le même dialogue de confirmation de suppression de session est utilisé par les deux rôles, avec les textes et actions existants inchangés.
- **Modifié — `lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart`** : la page ouvre désormais le dialogue partagé, sans changement du parcours de suppression.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart`** : la page chef ouvre désormais le même dialogue partagé, sans changement du parcours de suppression.
- **Supprimé — `lib/3_degustateur/sessions_degustation/widgets/dialogs/suppression_session_dialog.dart`** : la copie locale est remplacée par le dialogue partagé.
- **Supprimé — `lib/5_chef_degustateur/sessions_degustation/widgets/dialogs/suppression_session_dialog.dart`** : la copie locale est remplacée par le dialogue partagé ; l'import inutilisé de `chef_colors.dart` disparaît avec elle.

- **Créé — `lib/core/widgets/dialogs/suppression_dialog.dart`** : le dialogue de suppression d'échantillon est centralisé en conservant la même question, la même référence fournisseur et les mêmes boutons.
- **Supprimé — `lib/3_degustateur/gestion_echantillons/widgets/dialogs/suppression_dialog.dart`** : la copie locale est remplacée par la source partagée.
- **Supprimé — `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/suppression_dialog.dart`** : la copie locale est remplacée par la source partagée ; les couleurs chef avaient les mêmes valeurs que les constantes conservées.
- **Modifié — `files/taches/04-fusion-degustateur-chef.md`** : le présent compte rendu documente l'étape 2 ; ce fichier ne change pas l'application.

La recherche globale n'a trouvé aucun import ni appel actuel de `showSuppressionDialog` en dehors des deux anciennes définitions. Le dialogue partagé a été conservé, et non supprimé, puisque sa fusion est explicitement demandée et que les pages seront traitées à l'étape 5.

#### Vérifié

Après **chacun des trois fichiers fusionnés**, les commandes réellement exécutées ont été :

```powershell
$env:CI='true'; flutter analyze lib test --no-pub
$env:CI='true'; flutter test --no-pub
```

| Fichier fusionné | `flutter analyze lib test --no-pub` | `flutter test --no-pub` |
|---|---:|---:|
| `filtre_chip.dart` | 50 diagnostics, **0 error** | **95 réussis, 1 échec** |
| `suppression_session_dialog.dart` | 50 diagnostics, **0 error** | **95 réussis, 1 échec** |
| `suppression_dialog.dart` | 50 diagnostics, **0 error** | **95 réussis, 1 échec** |

Le passage de 51 à 50 diagnostics vient de la suppression du `withOpacity` déprécié présent uniquement dans l'ancienne copie chef du chip. L'échec est identique aux trois passages et reste le test connu :

```text
test/widget_test.dart: Counter increments smoke test
Expected: exactly one matching candidate
Actual: _TextWidgetFinder:<Found 0 widgets with text "0": []>
```

La première commande combinant formatage et analyse du chip n'a produit aucune sortie pendant environ une minute et a été interrompue ; ce silence n'a pas été compté comme un résultat. Le formatage avait entre-temps reformatté toute la barre de recherche chef, qui ne fait pas partie des fichiers fusionnés à cette étape. Cette réécriture a été intégralement retirée avant la validation : son diff final est exactement `1 insertion, 1 suppression`, correspondant uniquement au nouvel import.

Contrôles finaux réellement exécutés :

```powershell
$oldPaths | ForEach-Object { "$_ = $(Test-Path -LiteralPath $_)" }
rg -n "core/widgets/filtre_chip\.dart|core/widgets/dialogs/suppression_session_dialog\.dart|core/widgets/dialogs/suppression_dialog\.dart|import 'filtre_chip\.dart'" lib test
git diff --check
git diff --cached --name-only
```

Résultats :

- les **6 anciens chemins** ont chacun renvoyé `False` ;
- les consommateurs actifs du chip et du dialogue de session pointent vers `lib/core/` ;
- aucun consommateur actuel du dialogue de suppression d'échantillon n'existe ;
- `git diff --check = OK` ;
- `git diff --cached --name-only` n'a rien renvoyé : aucun fichier indexé.

La suite Django n'a pas été exécutée : aucune route ni aucun serializer n'a été modifié.

#### Non fait

- Les étapes 3 à 5 n'ont pas été commencées, conformément au découpage imposant un arrêt pour relecture après chaque étape.
- Les tests manuels sous les deux rôles n'ont pas été effectués ; ils sont réservés au propriétaire après les cinq étapes.
- Aucun commit, push ou changement de remote n'a été effectué.

#### HORS PÉRIMÈTRE

- `test/widget_test.dart` reste le seul test Flutter en échec et n'a pas été modifié.
- Les 50 diagnostics restants de l'analyse sont extérieurs aux trois composants fusionnés et n'ont pas été corrigés.
- La décoche de « reçu physiquement » sans notification et la décision T5 restent inchangées, conformément à la section hors périmètre de la tâche.

## QUESTION

1. Les deux services de tableau de bord ont été lus intégralement et leurs contrats sont structurellement différents :
   - le dégustateur appelle `/api/degustateur/dashboard/` et reçoit notamment `DelaiSummary` avec son délai personnel, ses points et une moyenne agrégée du panel ;
   - le chef appelle `/api/chef/dashboard/` et reçoit des modèles de supervision distincts (`DelaiPanelData` nominatif, `AlignementPanelData`, sessions en attente, urgences CEO et activité chef) ;
   - même les méthodes de même nom ont parfois des retours incompatibles (`PipelineData`/`PipelineChefData`, `PresenceData`/`PresenceChefData`, `DelaiSummary`/`DelaiPanelData`, types d’activité différents).

   Les réunir dans un service paramétré par rôle introduirait une branche susceptible d’exposer au dégustateur les données nominatives du panel, en contradiction avec la règle 2 du `CLAUDE.md`. Dois-je donc **laisser définitivement ces deux services séparés**, considérer cette ligne de l’étape 4 comme vérifiée mais non fusionnable, puis reprendre avec la dernière paire de services de notifications ?

   Au moment de cet arrêt, les quatre premières paires de l’étape 4 ont été fusionnées et validées après chacune (`flutter analyze lib test` : 50 diagnostics, 0 erreur ; `flutter test` : 95 réussis et l’unique échec connu de `test/widget_test.dart`). Les services de tableau de bord et de notifications n’ont pas été modifiés.

### RÉPONSE À LA QUESTION 1 (tableaux de bord)

Bonne analyse, et bon réflexe de t'arrêter. Confirmé de mon côté sur les routes serveur :
`/api/degustateur/dashboard/*` contre `/api/chef/dashboard/*` sont deux jeux d'adresses
différents, avec des méthodes qui n'existent que côté chef
(`fetchSessionsEnAttente`, `fetchAlignement`, `fetchUrgentesCeo`). Ce n'est pas une
dérive à corriger, ce sont deux fonctionnalités différentes qui partagent un nom de
dossier.

**Oui : laisse ces deux services définitivement séparés.** Note dans ton rapport cette
ligne du tableau comme « vérifiée, non fusionnable — contrats structurellement
différents », puis termine l'étape 4 avec la dernière paire, les services de
notifications (§4 ci-dessus, la décision T1 s'applique).

### Étape 3 — cartes

#### Fait

- **Créé — `lib/core/widgets/gestion_echantillons/echantillon_card.dart`** : la carte de gestion d’échantillon devient commune. La version la plus complète a été conservée, notamment la miniature de bouteille avec cache et repli visuel, l’historique des modifications et la protection contre le faux succès lors du changement de réception physique. Le chef bénéficie désormais aussi de la miniature lorsqu’une photo est disponible ; ses droits ne changent pas, car les actions restent conditionnées aux callbacks que sa page ne transmet pas.
- **Modifié — `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`** : l’import de la carte locale est remplacé par celui de la carte commune.
- **Modifié — `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`** : l’import de la carte locale est remplacé par celui de la carte commune ; aucune action d’édition ou de suppression n’est ajoutée.
- **Supprimé — `lib/3_degustateur/gestion_echantillons/widgets/echantillon_card.dart`** : la copie locale est remplacée par la source commune.
- **Supprimé — `lib/5_chef_degustateur/gestion_echantillons/widgets/echantillon_card.dart`** : la copie locale moins complète est remplacée par la source commune.

- **Créé — `lib/core/widgets/evaluation_echantillons/echantillon_card.dart`** : la carte de navigation vers une évaluation devient commune et conserve le paramètre `isHighlighted` utilisé par la navigation depuis une notification urgente.
- **Modifié — `lib/3_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart`** : la page utilise la carte d’évaluation commune.
- **Modifié — `lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart`** : la page chef utilise la même carte d’évaluation commune.
- **Modifié — `test/evaluation_urgente_navigation_test.dart`** : les deux scénarios de navigation continuent d’être vérifiés, mais ciblent désormais l’unique type `EchantillonCard` partagé.
- **Supprimé — `lib/3_degustateur/evaluation_echantillons/navigation/widgets/echantillon_card.dart`** : la copie locale est remplacée par la source commune.
- **Supprimé — `lib/5_chef_degustateur/evaluation_echantillons/navigation/widgets/echantillon_card.dart`** : la copie locale est remplacée par la source commune.

- **Créé — `lib/core/widgets/membres_panel/membre_card.dart`** : la carte membre, dont les deux copies ne différaient que par des constantes de couleur équivalentes, devient une source unique.
- **Modifié — `lib/3_degustateur/membres_panel/membres_panel_page.dart`** : la page utilise la carte membre commune.
- **Modifié — `lib/5_chef_degustateur/membres_panel/membres_panel_page.dart`** : la page chef utilise la carte membre commune.
- **Supprimé — `lib/3_degustateur/membres_panel/widgets/membre_card.dart`** : la copie locale est remplacée par la source commune.
- **Supprimé — `lib/5_chef_degustateur/membres_panel/widgets/membre_card.dart`** : la copie locale est remplacée par la source commune.

- **Créé — `lib/core/widgets/sessions_degustation/session_card.dart`** : la carte de session commune conserve le sur-ensemble chef avec les callbacks optionnels `onApprouver` et `onRefuser`. La correction de présence est préservée exactement : attente de la réponse, retour sans cocher en cas d’échec, puis mise à jour et minuterie seulement après succès. La ligne d’approbation n’apparaît que lorsque les callbacks chef sont fournis.
- **Modifié — `lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart`** : la page utilise la carte commune sans lui transmettre d’action d’approbation ou de refus.
- **Modifié — `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart`** : la page chef utilise la carte commune et conserve ses actions d’approbation/refus et ses restrictions d’édition.
- **Modifié — `test/session_presence_card_test.dart`** : les deux cas utilisateur continuent de vérifier qu’un échec serveur ne coche pas la présence et n’affiche pas le message de confirmation, via le widget partagé.
- **Supprimé — `lib/3_degustateur/sessions_degustation/widgets/session_card.dart`** : la copie locale est remplacée par la source commune.
- **Supprimé — `lib/5_chef_degustateur/sessions_degustation/widgets/session_card.dart`** : la copie locale est remplacée par la source commune ; ses capacités supplémentaires ont été conservées dans le widget partagé.

- **Créé — `lib/core/widgets/analyse_labo/analyse_card.dart`** : la carte d’analyse laboratoire devient commune. L’affichage du rapport signé, du classement, des tableaux, des notes et de l’état « Analyse non encore soumise » reste inchangé. Les paramètres du bouton urgent (`onUrgentLabo`, `isUrgentLabo`) sont conservés sans modification de comportement.
- **Modifié — `lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart`** : la page utilise la carte d’analyse commune ; son bouton de relance laboratoire reste branché comme avant.
- **Modifié — `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart`** : la page chef utilise la même carte ; son bouton de relance laboratoire reste également inchangé.
- **Supprimé — `lib/3_degustateur/analyse_labo/widgets/analyse_card.dart`** : la copie locale est remplacée par la source commune.
- **Supprimé — `lib/5_chef_degustateur/analyse_labo/widgets/analyse_card.dart`** : la copie locale est remplacée par la source commune.

- **Modifié — `files/taches/04-fusion-degustateur-chef.md`** : le présent compte rendu documente uniquement l’étape 3 ; ce fichier ne change pas l’application.

#### Vérifié

Après **chacun des cinq fichiers fusionnés**, les commandes suivantes ont réellement été exécutées :

```powershell
flutter analyze lib test
flutter test
```

| Fichier fusionné | `flutter analyze lib test` | `flutter test` |
|---|---:|---:|
| `gestion_echantillons/widgets/echantillon_card.dart` | 50 diagnostics, **0 erreur** | **95 réussis, 1 échec** |
| `evaluation_echantillons/navigation/widgets/echantillon_card.dart` | 50 diagnostics, **0 erreur** | **95 réussis, 1 échec** |
| `membres_panel/widgets/membre_card.dart` | 50 diagnostics, **0 erreur** | **95 réussis, 1 échec** |
| `sessions_degustation/widgets/session_card.dart` | 50 diagnostics, **0 erreur** | **95 réussis, 1 échec** |
| `analyse_labo/widgets/analyse_card.dart` | 50 diagnostics, **0 erreur** | **95 réussis, 1 échec** |

L’échec est identique aux cinq passages et reste le test connu :

```text
test/widget_test.dart: Counter increments smoke test
Expected: exactly one matching candidate
Actual: _TextWidgetFinder:<Found 0 widgets with text "0": []>
```

Contrôles finaux réellement exécutés :

```powershell
$oldPaths | ForEach-Object { "$(Test-Path -LiteralPath $_) $_" }
rg -n "core/widgets/(gestion_echantillons|evaluation_echantillons|membres_panel|sessions_degustation|analyse_labo)" lib test
rg -n "(3_degustateur|5_chef_degustateur)/.*(echantillon_card|membre_card|session_card|analyse_card)\.dart|import 'widgets/(echantillon_card|membre_card|session_card|analyse_card)\.dart'" lib test
git diff --check
git diff --cached --name-only
```

Résultats :

- les **10 anciens chemins** ont chacun renvoyé `False` ;
- les dix pages consommatrices et les deux tests concernés pointent vers les widgets de `lib/core/` ;
- aucune référence résiduelle vers les cinq paires supprimées n’a été trouvée ;
- `git diff --check = OK` ;
- `git diff --cached --name-only` n’a rien renvoyé : aucun fichier indexé.

La suite Django n’a pas été exécutée : aucune route ni aucun serializer n’a été modifié.

#### Non fait

- Les étapes 4 et 5 n’ont pas été commencées, conformément à la consigne d’arrêt après l’étape 3 pour relecture et commits fichier par fichier par Claude.
- Les fichiers de notifications et leurs types réservés au chef n’ont pas été touchés ; ils appartiennent à l’étape 4.
- Les gros formulaires et les pages prévus à l’étape 5 n’ont pas été modifiés.
- Les tests manuels sous les deux rôles n’ont pas été effectués ; ils sont réservés au propriétaire après les cinq étapes.
- Aucun commit, push ou changement de remote n’a été effectué.

#### HORS PÉRIMÈTRE

- `test/widget_test.dart` reste le seul test Flutter en échec et n’a pas été modifié.
- Les 50 diagnostics restants de l’analyse sont extérieurs aux cinq cartes fusionnées et n’ont pas été corrigés.
- La décoche de « reçu physiquement » sans notification et la décision T5 restent inchangées, conformément à la section hors périmètre de la tâche.
