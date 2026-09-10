# Tâche 25 — Vérifier que chaque page distingue bien « pas encore de données »
# de « échec de chargement », dans tout l'app

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Cette tâche touche potentiellement les 5 modules de rôle. C'est un **audit d'abord, correction
ensuite** : beaucoup de pages font déjà ça bien, ne change que ce qui manque réellement.

---

## Contexte

Le propriétaire a vu la page "Sessions de dégustation" afficher "Impossible de charger les
données" et a cru que l'app traitait "aucune session" comme une erreur. En vérité ce n'était
pas le cas : cette page a déjà un message correct ("Aucune session trouvée") pour la liste
vide, et l'erreur affichée était un vrai échec réseau à cet instant précis (le serveur de
développement était indisponible). Le code de cette page était déjà correct.

Le propriétaire demande maintenant de vérifier **toutes les pages** de la même façon : que
partout, une liste vide après un chargement réussi affiche une phrase adaptée au contexte de
la page (pas un écran blanc, pas le message d'erreur), pendant qu'un vrai échec réseau
continue d'afficher clairement l'erreur.

**Ce que tu ne dois surtout pas faire : ne touche à rien dans `VueResultatService`
(`lib/core/widgets/bandeau_demonstration.dart`), `ErreurChargement`, ni `avecSecours()`
(`lib/core/services/resultat_service.dart`).** Cette séparation entre erreur et vide doit
rester intacte et honnête : un vrai échec de chargement doit continuer à être annoncé comme
tel. Le but de cette tâche est uniquement de vérifier que le contenu affiché **quand il n'y a
pas d'erreur** gère bien le cas "liste vide" avec un message clair, pas de masquer de vraies
pannes.

### Les deux bons exemples déjà dans le code — imite l'un des deux, selon ce qui existe déjà
dans la page

1. `lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart` (~L475-495) : un
   `Center` avec icône + texte ("Aucune session trouvée") directement dans le `Column` quand
   `items.isEmpty`.
2. `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : utilise le widget
   partagé `EmptyState` (`lib/core/widgets/empty_state.dart`), qui prend un `message` et une
   `icon` personnalisables (par défaut : "Aucun échantillon trouvé").

Les deux approches sont valables. Ne remplace pas l'une par l'autre si elle fonctionne déjà —
seulement complète ce qui manque.

---

## CONSIGNE

### 1. Audit

Ces 32 fichiers utilisent tous `VueResultatService` (trouvés par
`grep -rl VueResultatService lib/`) :

```
lib/4_laboratoire/echantillons_labo/echantillons_labo_page.dart
lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart
lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart
lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart
lib/5_chef_degustateur/notifications/notifications_degustateur_page.dart
lib/3_degustateur/notifications/notifications_degustateur_page.dart
lib/core/utilisateurs/utilisateurs_page_body.dart
lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart
lib/4_laboratoire/notifications/notifications_labo_page.dart
lib/5_chef_degustateur/formulaire_evaluation.dart
lib/5_chef_degustateur/membres_panel/membres_panel_page.dart
lib/3_degustateur/tableau_de_bord/homepage_page.dart
lib/3_degustateur/membres_panel/membres_panel_page.dart
lib/3_degustateur/evaluation_echantillons/formulaire_evaluation.dart
lib/1_ceo/notifications/notifications_ceo_page.dart
lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart
lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart
lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart
lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart
lib/3_degustateur/tableau_de_bord/widgets/home_body.dart
lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart
lib/3_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart
lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart
lib/1_ceo/validation_achats/validation_achats_ceo_page.dart
lib/1_ceo/tableau_de_bord/tableau_de_bord.dart
lib/1_ceo/echantillons/echantillons_ceo_page.dart
lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart
lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart
lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart
lib/2_collecteur/notifications/notifications_collecteur_page.dart
```

Pour chacun, regarde ce que `VueResultatService.child` affiche quand la liste chargée est
vide (`items.isEmpty`, `_liste.isEmpty`, etc. selon le nom local) **et qu'il n'y a pas
d'erreur**. Trois cas possibles :

- **Déjà bon** : un message contextuel s'affiche déjà (comme les deux exemples ci-dessus).
  Ne touche à rien, note-le comme "déjà bon" dans le rapport.
- **Manquant** : la liste vide affiche un espace blanc, ou rien de particulier. Ajoute un
  message, avec la méthode qui correspond au style déjà en place dans ce fichier précis (voir
  point 2).
- **Hors sujet** : le fichier n'affiche pas de liste dynamique qui peut être vide au sens
  propre (ex. un tableau de bord avec des cartes de chiffres fixes qui existent toujours, un
  formulaire). Note-le comme "hors sujet" et n'y touche pas.

Deux fichiers à regarder en particulier avant de conclure "hors sujet" trop vite :
- `lib/3_degustateur/tableau_de_bord/homepage_page.dart` et
  `lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart` n'ont pas de `ListView` visible
  directement dedans — regarde si `VueResultatService.child` délègue à `HomeBody(...)`
  (`widgets/home_body.dart` du même module), qui lui a peut-être des sous-listes (ex. un
  panneau "urgent", une liste d'activité récente) à vérifier séparément.

### 2. Si un message manque, écris-le

- Reprends le style déjà utilisé dans ce fichier précis pour les autres messages (widget
  `EmptyState` s'il est déjà importé dans ce fichier ou dans un fichier très proche du même
  module, sinon un `Center`/`Column` avec icône + texte comme les sessions).
- Le texte doit correspondre au contenu réel de la page, pas une formule générique copiée
  partout. Exemples de ton à viser (adapte, n'invente pas au hasard) :
  - Notifications vides → "Aucune notification pour le moment"
  - Membres du panel vides → "Aucun membre dans le panel pour le moment"
  - Évaluations vides → "Aucune évaluation pour le moment"
  - Achats confirmés vides (CEO) → "Aucun achat confirmé pour le moment"
  - Utilisateurs vides → "Aucun utilisateur pour le moment"
- Une icône simple et cohérente avec le contenu (`Icons.notifications_none`,
  `Icons.people_outline`, etc.) — pas obligatoire d'inventer une icône originale à chaque
  fois, regarde ce que `EmptyState`/les pages voisines utilisent déjà comme famille d'icônes.

---

## Ce que tu ne fais pas

- **Tu ne touches pas** à `VueResultatService`, `ErreurChargement`, `BandeauDemonstration`,
  ni `avecSecours()` — la distinction erreur/vide doit rester exactement ce qu'elle est
  aujourd'hui, seul le contenu affiché en cas de succès-mais-vide peut changer.
- Tu ne changes pas la logique de chargement, les filtres, ni quoi que ce soit d'autre sur
  ces pages — uniquement ce qui s'affiche quand la liste chargée est vide.
- Tu ne touches pas aux fichiers "hors sujet" (tableaux de bord à cartes fixes, formulaires).
- Tu ne changes rien côté serveur.
- Tu ne remplaces pas un message déjà bon par un autre juste pour uniformiser le style — s'il
  fonctionne, laisse-le.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles dans ton rapport. Référence : 49 diagnostics/0 erreur,
108 tests (107 réussis + 1 échec déjà connu) avant cette tâche.

Dans le rapport, sous **Fait**, donne la liste des 32 fichiers avec pour chacun : déjà bon /
corrigé (et avec quel message) / hors sujet. C'est le seul moyen de vérifier que l'audit a
vraiment couvert les 32 fichiers et pas seulement quelques-uns.

## RAPPORT

### Fait

Fichiers modifiés :

- `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart` : le panneau "Activité récente" du dashboard dégustateur affiche maintenant `Aucune activité récente` quand le chargement réussit mais ne renvoie aucune activité.
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_activite_section.dart` : le panneau "Activité récente" du dashboard chef affiche maintenant `Aucune activité récente` quand le chargement réussit mais ne renvoie aucune activité.
- `files/taches/25-audit-etats-vides-toutes-pages.md` : ajout du présent rapport.

Audit des fichiers `VueResultatService` :

- `lib/4_laboratoire/echantillons_labo/echantillons_labo_page.dart` : déjà bon, message `Aucun échantillon trouvé`.
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : déjà bon, `EmptyState`.
- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : déjà bon, `EmptyState`.
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` : déjà bon, message `Aucun échantillon trouvé`.
- `lib/5_chef_degustateur/notifications/notifications_degustateur_page.dart` : déjà bon, message `Aucune notification`.
- `lib/3_degustateur/notifications/notifications_degustateur_page.dart` : déjà bon, message `Aucune notification`.
- `lib/core/utilisateurs/utilisateurs_page_body.dart` : déjà bon, message `Aucun utilisateur trouvé`.
- `lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart` : hors sujet direct, page conteneur; elle délègue à `widgets/home_body.dart`.
- `lib/4_laboratoire/notifications/notifications_labo_page.dart` : déjà bon, message `Aucune notification`.
- `lib/5_chef_degustateur/formulaire_evaluation.dart` : hors sujet, formulaire sans liste dynamique vide.
- `lib/5_chef_degustateur/membres_panel/membres_panel_page.dart` : déjà bon, message `Aucun membre trouvé`.
- `lib/3_degustateur/tableau_de_bord/homepage_page.dart` : hors sujet direct, page conteneur; elle délègue à `widgets/home_body.dart`.
- `lib/3_degustateur/membres_panel/membres_panel_page.dart` : déjà bon, message `Aucun membre trouvé`.
- `lib/3_degustateur/evaluation_echantillons/formulaire_evaluation.dart` : hors sujet, formulaire sans liste dynamique vide.
- `lib/1_ceo/notifications/notifications_ceo_page.dart` : déjà bon, message `Aucune notification`.
- `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` : déjà bon, message `Aucun échantillon trouvé`.
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart` : corrigé via la section appelée `home_activite_section.dart`, message `Aucune activité récente`; les autres sous-zones vides affichaient déjà `Aucune donnée` ou sont des cartes KPI fixes.
- `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart` : déjà bon, message `Aucune session trouvée`.
- `lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` : déjà bon, `EmptyState`.
- `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart` : déjà bon, message `Aucune analyse trouvée`.
- `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart` : corrigé, message `Aucune activité récente`; les autres sous-zones vides affichaient déjà `Aucune donnée` ou sont des cartes KPI fixes.
- `lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart` : déjà bon, message `Aucune session trouvée`.
- `lib/3_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` : déjà bon, `EmptyState`.
- `lib/3_degustateur/analyse_labo/analyse_laboratoire_page.dart` : déjà bon, message `Aucune analyse trouvée`.
- `lib/1_ceo/validation_achats/validation_achats_ceo_page.dart` : déjà bon, messages `Aucune proposition à valider`, `Aucune décision enregistrée` ou `Aucune proposition`.
- `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` : hors sujet, dashboard à cartes et sections fixes sans liste dynamique vide à corriger.
- `lib/1_ceo/echantillons/echantillons_ceo_page.dart` : déjà bon, message `Aucun échantillon trouvé`.
- `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart` : déjà bon, message `Aucun échantillon trouvé`; les cartes sans évaluations affichent aussi `Aucune évaluation soumise`.
- `lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart` : déjà bon, message `Aucun échantillon trouvé`.
- `lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart` : déjà bon, message `Aucun achat confirmé`.
- `lib/2_collecteur/notifications/notifications_collecteur_page.dart` : déjà bon, message `Aucune notification`.
- `lib/core/widgets/bandeau_demonstration.dart` : hors sujet et explicitement exclu par la consigne; `rg -l VueResultatService lib` le compte comme 32e fichier réel, mais il contient `VueResultatService` / `BandeauDemonstration`, que la tâche interdit de modifier.

### Vérifié

Commande de comptage utilisée pour contrôler le décalage entre la liste de la tâche et le dépôt :

```bash
rg -l "VueResultatService" lib | Sort-Object
```

Résultat brut : 32 fichiers, dont `lib/core/widgets/bandeau_demonstration.dart`. La liste markdown de la consigne contient 31 chemins; le 32e résultat réel est le fichier explicitement interdit.

Commandes demandées :

```bash
flutter analyze lib test
```

Résultat : timeout après 900.1 s, aucune sortie chiffrée produite par la commande. Des processus `dart` / `dartvm` restaient actifs après le timeout et ont été arrêtés.

```bash
flutter test
```

Résultat : timeout après 900.1 s, aucune sortie chiffrée produite par la commande. Des processus `dart` / `dartvm` restaient actifs après le timeout et ont été arrêtés.

Vérification complémentaire exécutée :

```bash
git diff --check
```

Résultat : exit code 0. Sortie brute utile : avertissements CRLF/LF uniquement pour `files/taches/ETAT.md`, `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart`, `lib/5_chef_degustateur/tableau_de_bord/widgets/home_activite_section.dart`; aucune erreur de whitespace.

Tentative de formatage :

```bash
dart format 'lib/3_degustateur/tableau_de_bord/widgets/home_body.dart' 'lib/5_chef_degustateur/tableau_de_bord/widgets/home_activite_section.dart'
```

Résultat : timeout après 120.1 s, aucune sortie produite. Des processus Dart restaient actifs après le timeout et ont été arrêtés.

### Non fait

- Les chiffres finaux de `flutter analyze lib test` et `flutter test` n'ont pas été obtenus par Codex, car les deux commandes se sont bloquées sans sortie jusqu'au timeout de 15 minutes.

### Vérification par Claude (les commandes de Codex avaient bloqué)

```bash
dart format lib/3_degustateur/tableau_de_bord/widgets/home_body.dart lib/5_chef_degustateur/tableau_de_bord/widgets/home_activite_section.dart
```

Résultat : `Formatted 2 files (2 changed) in 0.11 seconds.` Dans `home_activite_section.dart`,
le formatage a aussi remis en forme un tableau `mois` existant qui n'avait jamais été passé
par le formateur actuel (une ligne → une entrée par ligne) — contenu identique, vérifié par
lecture du diff, sans rapport avec le correctif de cette tâche.

```bash
flutter analyze lib test
```

Résultat : **49 diagnostics, 0 erreur** — identique à la référence d'avant cette tâche.

```bash
flutter test
```

Résultat : **108 tests, 107 réussis, 1 échec** (`test/widget_test.dart: Counter increments
smoke test`, l'échec déjà connu et sans rapport) — identique à la référence d'avant cette
tâche. Aucune régression.

### Conclusion

Audit couvrant les 32 fichiers réels utilisant `VueResultatService` (31 listés dans la
consigne + `bandeau_demonstration.dart`, le 32ᵉ, explicitement hors périmètre). 2 vrais
manques trouvés et corrigés (dashboards dégustateur et chef dégustateur, panneau "Activité
récente"). Les 30 autres étaient déjà corrects ou hors sujet. `VueResultatService`,
`ErreurChargement`, `BandeauDemonstration` et `avecSecours()` n'ont pas été touchés.

### HORS PÉRIMÈTRE

- `files/taches/ETAT.md`, `backend_new/backup_propre.json` et `files/taches/codex_22.txt` étaient déjà modifiés ou non suivis avant cette tâche et n'ont pas été touchés.
