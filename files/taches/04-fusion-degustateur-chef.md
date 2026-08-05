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

**Un commit par fichier fusionné. Jamais deux à la fois.** Si un commit casse quelque chose,
on doit pouvoir revenir en arrière sans perdre le reste.

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

Après **chaque** fichier fusionné :

```bash
cd project3
flutter analyze lib test
flutter test
```

Après le dernier fichier de chaque étape (1 à 5), lance en plus la suite Django si tu as
touché des routes ou des serializers (normalement non, cette tâche est côté Flutter) :

```bash
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Repères à ne pas faire baisser : **157 tests Django au vert**, `flutter test` **95 réussis**
(le seul échec connu, `widget_test.dart`, est hors périmètre — ne le corrige pas ici),
`flutter analyze lib test` **0 erreur**.

**À la main, avec le backend lancé, après l'étape 5 complète :** ouvrir chaque écran fusionné
sous les deux rôles (dégustateur simple, puis chef dégustateur) et vérifier que rien ne
manque à l'écran — un champ vide qui ne plantait aucun test serait le signe d'une fusion qui
a supprimé une différence de comportement au lieu de la rendre paramétrable.

---

### 6. Hors périmètre — à signaler, pas à corriger

- La décoche de « reçu physiquement » qui ne notifie personne (§1 de
  [`03_degustateur.md`](../notifications/03_degustateur.md)) — lacune déjà connue, pas de
  cette tâche.
- T2, T3, T4, T5 du carnet dégustateur — questions ouvertes, non résolues ici.
- Tout défaut trouvé en dehors des 33 fichiers listés — signale-le, n'y touche pas.

---

## RAPPORT

_(à compléter par l'exécuteur, une entrée par fichier fusionné)_
