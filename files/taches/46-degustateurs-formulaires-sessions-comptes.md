# Tâche 46 — Dégustateurs : formulaire, évaluation, sessions, déconnexion, création de comptes

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`. Flutter + backend. **Migrations autorisées** (parties H et I). À faire après
les tâches 43, 44 et 45.

Constaté par la propriétaire sur la plateforme **chef dégustateur** ; chaque correction
s'applique aussi aux rôles qui partagent le même écran (dégustateur, et collecteur pour le
formulaire d'échantillon).

Déjà corrigé par Claude (commit `f0e23adb`) : plantage « Bad state: No element » du tableau
de bord du chef, et liste des échantillons qui échouait sur une classification vide `''`.

## A — Déconnexion : fermer toutes les pages (TOUS les rôles) — prioritaire

Constaté : après s'être déconnectée de la direction et connectée en chef, le serveur a reçu
142 appels `GET /api/ceo/dashboard/` (refusés, 403) : le tableau de bord de la direction
était **toujours vivant** derrière, avec son rechargement toutes les 30 s.

Cause : la déconnexion ouvre la page de connexion **par-dessus** (`Navigator.pushReplacement`
ou `goToPage(LoginPage())` dans `*_nav_mixin.dart`, les `onDeconnexion` des pages direction,
`homepage_page.dart` du chef, `vue_ensemble_evaluations_page.dart`…). Certaines ne semblent
même pas appeler `authService.logout()`.

- Crée **une seule** fonction de déconnexion partagée (ex. dans `lib/core/`) qui :
  1. appelle `authService.logout()` (blackliste le refresh token, vide les jetons et les
     caches de suggestions) ;
  2. `pushAndRemoveUntil(LoginPage, (route) => false)` : plus aucune page de l'ancien
     compte ne reste en mémoire (leurs `dispose()` arrêtent les rechargements).
- Remplace **toutes** les déconnexions de tous les rôles par cette fonction (grep
  `LoginPage(`, `onDeconnexion`, `logout`).
- Test widget : après déconnexion, la pile ne contient que la page de connexion et le
  minuteur d'une page précédente ne s'exécute plus.

## B — Valeurs vides reçues du serveur : ne plus jamais planter (tous les rôles)

La classification vide `''` faisait planter toute une liste. Parcours tous les
`...X.fromJson(...)` d'énumérations dans `lib/core/models/` et les modèles des rôles
(ex. `evaluation_organoleptique.dart:100` lit aussi `classification`) : une valeur `''`
ou inconnue ne doit jamais lever d'exception qui fait échouer une liste entière (valeur
`null` ou valeur par défaut raisonnable, selon le champ). Test : un test par modèle
concerné avec `''`.

## C — Suggestions pour les dégustateurs

Règle (rappel) : un **collecteur** ne voit que ses propres fournisseurs / variétés (fait en
tâche 40). Un **dégustateur** ou le **chef** voit les fournisseurs et variétés saisis par
**tout le monde** (collecteurs, dégustateurs, chef). Vérifie `FournisseurService`,
`VarieteService` et les vues serveur pour ces deux rôles (`VarieteService` lit
`/api/echantillons/` : le dégustateur y voit-il tout ?). Corrige si besoin + test serveur.

## D — Le dégustateur / le chef ne peut pas enregistrer un échantillon

La propriétaire n'arrive pas à enregistrer un échantillon en tant que dégustateur (chef
constaté). Le journal du serveur montre un `POST /api/echantillons/` → **400** ce soir.
Reproduis (test serveur avec un compte dégustateur et chef, avec le même contenu que ce
qu'envoie le formulaire Flutter : `GestionEchantillonsService._toDjangoMap`), trouve la
cause (permission, champ obligatoire, format de date, fournisseur…) et corrige. Le message
d'erreur du serveur doit s'afficher tel quel dans la fenêtre du formulaire (règle déjà en
place depuis la tâche 36). Tests : création par dégustateur et par chef → 201.

## E — Formulaire d'échantillon du dégustateur / chef = celui du collecteur

La propriétaire trouve le formulaire du **collecteur** idéal (restrictions, textes, ordre,
photo). Aligne les formulaires dégustateur (`lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`)
et chef (`lib/5_chef_degustateur/.../formulaire_dialog.dart`) sur lui, **sans copier à
l'aveugle** : mêmes champs, mêmes textes, mêmes obligations (tâche 40 D), même ordre des
champs bouteille (tâche 38), même fenêtre de référence (tâche 39), même **photo** (prise /
galerie / plein écran / modification), mêmes couleurs.

Différence voulue : le dégustateur / chef peut **indiquer un collecteur** (facultatif), avec
une **liste de suggestions** des collecteurs existants (nom + prénom ; utilisateurs actifs
de rôle collecteur, non supprimés). S'il n'en met pas, l'échantillon n'a pas de collecteur.
Vérifie que le serveur accepte ce champ pour ces rôles.

Si c'est raisonnable, factorise le formulaire commun dans `lib/core/` ; sinon garde trois
fichiers mais identiques sur ces points.

## F — Page « Évaluation des échantillons » (dégustateur et chef)

1. Le numéro d'échantillon (ex. `2026/0001`) s'affiche comme une longue suite de chiffres
   et de lettres : c'est sûrement l'`id` (UUID) au lieu du `numero`. Affiche le `numero`.
2. La **date d'arrivée** s'affiche en brut (ISO). Format `JJ/MM/AAAA` (et l'heure si elle
   est utile) avec `DegDateUtils.formaterAffichage` ou équivalent.
3. Dans la fiche de détail d'une évaluation : l'emplacement de la **photo** montre une
   grande croix (image cassée) → si pas de photo ou image introuvable, affiche un
   emplacement propre (icône + `Pas de photo`) ; sinon la photo, touchable en plein écran
   (`PhotoPleinEcran`).
4. La même fiche **déborde** (bande jaune et noire).

## G — Règle générale : un texte long ne casse jamais l'écran (tous les rôles)

La propriétaire : « un utilisateur peut écrire une valeur énorme ; l'application doit s'y
attendre ». Dans toutes les fiches de détail, cartes et listes qui affichent des valeurs
saisies (référence, fournisseur, variété, remarque, nom, citerne, quantité…) :
- les textes vont **à la ligne** (`softWrap`) au lieu de déborder ; dans une `Row`, le texte
  est dans un `Expanded` / `Flexible` ;
- sur les cartes compactes, `maxLines` + `overflow: TextOverflow.ellipsis`, et la valeur
  complète visible dans la fiche de détail.
Ajoute un test « valeurs très longues » (300 caractères) sur la carte échantillon et la
fiche de détail d'évaluation, à 360 px de large, sans débordement.

## H — Sessions de dégustation (dégustateur et chef)

1. À la création : **obligatoires** = titre, date, heure. Tout le reste est facultatif
   (application et serveur ; si le serveur exige autre chose, corrige le serializer ; une
   migration seulement si indispensable).
2. La date de la session s'affiche en brut après l'enregistrement → format lisible
   (`JJ/MM/AAAA à HH:MM`) partout où une session apparaît.

## I — Chef : pages et utilisateurs

1. **Retire la page « Membres du panel » pour le chef seulement** (menu, navigation, route) ;
   la page du dégustateur ne change pas. Ne supprime pas le fichier s'il est partagé.
2. **Utilisateurs (chef)** : ne change **rien** d'autre que le retrait du nombre
   d'utilisateurs (voir tâche 45, partie D, limitée à la direction).
3. **Ajouter un utilisateur — rôle** : aujourd'hui on choisit le rôle d'une façon qui ne
   plaît pas. Remplace par un **champ normal** qui, touché, ouvre la **liste des rôles**
   (`DropdownButtonFormField` ou feuille de choix), comme un champ de formulaire.
4. **Fenêtre de succès après création** : illisible (texte en charabia). Refais-la : titre
   `Compte créé`, puis nom, email, rôle, et la phrase de la partie J.
5. **Email unique** : on ne peut pas créer un compte avec un email **déjà utilisé**, sauf si
   l'ancien compte a été **supprimé** (suppression douce de la tâche 45). Côté base :
   contrainte d'unicité **seulement parmi les comptes non supprimés**
   (`UniqueConstraint(fields=['email'], condition=Q(date_suppression__isnull=True))` ou
   équivalent ; migration). Message clair : `Un compte actif utilise déjà cet email.`
   Tests serveur : doublon refusé ; réutilisation après suppression acceptée ; la connexion
   se fait sur le compte non supprimé.

## J — Mot de passe du nouveau compte : généré et envoyé par email

Décision de la propriétaire :
- à la création, le serveur **génère** le mot de passe : **prénom + nom + un seul caractère
  entre `@` et `,`** (ex. `amine@collecteur` ou `amine,collecteur` ; minuscules, sans
  espaces ni accents ; si la règle de mot de passe existante l'exige, ajoute ce qui manque
  de la façon la plus simple et écris-le dans le rapport) ;
- il est envoyé par email **au nouvel utilisateur** (à l'email de son compte) ;
- le **chef** (la personne qui a créé le compte) reçoit aussi un email : « Nous avons
  envoyé ses identifiants à <email> ; son mot de passe est : … » ;
- le champ « mot de passe » disparaît du formulaire de création ;
- **recommandation de Claude, à appliquer** : à la **première connexion**, l'utilisateur
  doit choisir un nouveau mot de passe (champ `doit_changer_mot_de_passe` sur `User`,
  migration ; après connexion, l'application ouvre directement l'écran de changement et ne
  laisse rien faire d'autre avant). Raison : un mot de passe formé du nom et du prénom se
  devine facilement, et le chef le connaît.
- Emails envoyés avec la configuration de la tâche 42 (journal du serveur tant que
  l'adresse d'envoi n'est pas configurée). Un échec d'envoi n'empêche pas la création :
  la fenêtre de succès l'indique et affiche le mot de passe au chef.
Tests serveur : format du mot de passe, deux emails envoyés, `doit_changer_mot_de_passe`
vrai puis faux après changement.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera les tests Flutter et
Django et appliquera les migrations après une sauvegarde de la base.

Dans le rapport : une section par partie (A à J), avec les rôles couverts.

## RAPPORT

### Reprise

Reprise effectuée depuis l'arbre de travail existant. Aucun commit. Aucune migration appliquée sur la vraie base. La compétence `frontend-design` demandée par `CLAUDE.md` n'était pas disponible dans cette session ; j'ai suivi les consignes design du dépôt.

### Fait

#### A — Déconnexion : fermer toutes les pages

- `lib/core/logout_navigation.dart` — nouvelle fonction partagée de déconnexion : appelle `authService.logout()` puis remplace toute la pile par `LoginPage`.
- `lib/1_ceo/widgets/ceo_nav_mixin.dart` — les déconnexions Direction passent par la déconnexion partagée, y compris les anciens appels `goToPage(LoginPage())`.
- `lib/2_collecteur/widgets/nav_mixin.dart` — la déconnexion Collecteur vide toute la pile au lieu d'empiler/remplacer seulement une page.
- `lib/3_degustateur/widgets/degustateur_nav_mixin.dart` — la déconnexion Dégustateur vide toute la pile.
- `lib/3_degustateur/widgets/nav_mixin.dart` — l'ancien mixin Dégustateur applique la même déconnexion complète.
- `lib/4_laboratoire/widgets/labo_nav_mixin.dart` — la déconnexion Laboratoire vide toute la pile.
- `lib/5_chef_degustateur/widgets/chef_nav_mixin.dart` — la déconnexion Chef vide toute la pile.
- `lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart` — la déconnexion locale du tableau de bord Chef utilise la fonction partagée.
- `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` — la déconnexion locale de la vue d'ensemble Chef utilise la fonction partagée.

#### B — Valeurs enum vides/inconnues

- `lib/core/models/enums.dart` — les parseurs partagés d'énumérations ne lèvent plus d'exception sur une valeur vide/inconnue ; ils retombent sur une valeur sûre.

#### I — Chef : pages et utilisateurs

- `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` — l'entrée visible `Membres du panel` est retirée du menu Chef.
- `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart` — la page Chef n'envoie plus le drawer vers `Membres du panel`.
- `lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` — la page Chef n'envoie plus le drawer vers `Membres du panel`.
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` — la page Chef n'envoie plus le drawer vers `Membres du panel`.
- `lib/5_chef_degustateur/membres_panel/membres_panel_page.dart` — l'ancien écran conservé ne déclare plus l'entrée supprimée dans son drawer.
- `lib/5_chef_degustateur/profil.dart` — le profil Chef n'envoie plus le drawer vers `Membres du panel`.
- `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart` — les sessions Chef n'envoient plus le drawer vers `Membres du panel`.
- `lib/5_chef_degustateur/utilisateurs/utilisateurs_chef_page.dart` — la page utilisateurs Chef n'envoie plus le drawer vers `Membres du panel`.
- `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` — la vue d'ensemble Chef n'envoie plus le drawer vers `Membres du panel`.
- `lib/core/utilisateurs/utilisateurs_page_body.dart` — le choix du rôle dans `Ajouter un utilisateur` est un champ `DropdownButtonFormField`, plus des chips.
- `lib/core/utilisateurs/widgets/user_created_dialog.dart` — la fenêtre de succès affiche un texte lisible : `Compte créé`, nom, email, rôle, information d'envoi email et mot de passe temporaire.

#### J — Mot de passe généré, envoyé par email, changement obligatoire

- `backend_new/users/models.py` — `User.email` n'est plus unique globalement ; ajout de `doit_changer_mot_de_passe` et d'une contrainte unique conditionnelle sur les comptes non supprimés.
- `backend_new/users/migrations/0007_user_doit_changer_mot_de_passe_email_unique_actif.py` — migration créée mais non appliquée.
- `backend_new/users/backends.py` — backend d'authentification email qui ne considère que les comptes actifs/non supprimés.
- `backend_new/aljazeera_stca/settings.py` — Django utilise `users.backends.EmailActifBackend`.
- `backend_new/users/serializers.py` — création de compte sans champ mot de passe : génération `prenom@nom` normalisé, email au nouvel utilisateur, email au chef créateur, réponse enrichie, doublon actif refusé avec `Un compte actif utilise déjà cet email.`.
- `backend_new/users/views.py` — la création renvoie le mot de passe temporaire et l'état des emails ; le changement/réinitialisation du mot de passe passe `doit_changer_mot_de_passe` à `False`.
- `backend_new/users/tests.py` — tests ajoutés/mis à jour : mot de passe généré, deux emails, doublon actif refusé, réutilisation après suppression douce, login sur le compte non supprimé, flag remis à `False` après changement.
- `lib/core/models/user_profile.dart` — Flutter lit `doit_changer_mot_de_passe`.
- `lib/core/utilisateurs/utilisateurs_service.dart` — Flutter ne poste plus `Test@12345` et récupère le mot de passe temporaire + état d'envoi email.
- `lib/core/auth/changement_mot_de_passe_obligatoire_page.dart` — nouvel écran bloquant de changement du mot de passe à la première connexion.
- `lib/main.dart` — après login, un utilisateur marqué `doit_changer_mot_de_passe` est envoyé directement vers l'écran bloquant avant son tableau de bord.

### Vérifié

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test users --keepdb
```

Sortie :

```text
Using existing test database for alias 'default'...
System check identified some issues:

WARNINGS:
users.User: (auth.W004) 'User.email' is named as the 'USERNAME_FIELD', but it is not unique.
	HINT: Ensure that your authentication backend(s) can handle non-unique usernames.

System check identified 1 issue (0 silenced).
....................................
----------------------------------------------------------------------
Ran 36 tests in 174.727s

OK
Preserving test database for alias 'default'...
Found 36 test(s).
```

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run
```

Sortie :

```text
System check identified some issues:

WARNINGS:
users.User: (auth.W004) 'User.email' is named as the 'USERNAME_FIELD', but it is not unique.
	HINT: Ensure that your authentication backend(s) can handle non-unique usernames.

System check identified 1 issue (0 silenced).
No changes detected
```

```bash
git diff --check
```

Sortie : code 0, uniquement des avertissements Git de conversion LF/CRLF.

```bash
dart format lib/core/logout_navigation.dart lib/core/auth/changement_mot_de_passe_obligatoire_page.dart lib/core/models/enums.dart lib/core/models/user_profile.dart lib/core/utilisateurs/utilisateurs_page_body.dart lib/core/utilisateurs/utilisateurs_service.dart lib/core/utilisateurs/widgets/user_created_dialog.dart lib/main.dart lib/1_ceo/widgets/ceo_nav_mixin.dart lib/2_collecteur/widgets/nav_mixin.dart lib/3_degustateur/widgets/degustateur_nav_mixin.dart lib/3_degustateur/widgets/nav_mixin.dart lib/4_laboratoire/widgets/labo_nav_mixin.dart lib/5_chef_degustateur/widgets/chef_nav_mixin.dart lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/5_chef_degustateur/membres_panel/membres_panel_page.dart lib/5_chef_degustateur/profil.dart lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart lib/5_chef_degustateur/utilisateurs/utilisateurs_chef_page.dart
```

Sortie : aucune sortie après 90 s ; commande interrompue manuellement par `Ctrl+C`, code 1. Aucun `flutter analyze` ni `flutter test` lancé, conformément à la consigne de la tâche indiquant que le sandbox ne peut pas lancer Flutter.

### Non fait

- A — pas de test widget ajouté pour vérifier la pile de navigation et l'arrêt des minuteurs après déconnexion.
- B — pas de tests Flutter ajoutés pour les enum `fromJson('')`.
- C — non traité dans cette reprise : suggestions fournisseurs/variétés Dégustateur/Chef et test serveur.
- D — non traité dans cette reprise : reproduction/correction du `POST /api/echantillons/` à 400 pour Dégustateur/Chef.
- E — non traité dans cette reprise : alignement complet des formulaires d'échantillon Dégustateur/Chef avec Collecteur.
- F — non traité dans cette reprise : page `Évaluation des échantillons`, numéro/date/photo/débordement.
- G — non traité dans cette reprise : règle générale texte long + tests 360 px.
- H — non traité dans cette reprise : sessions de dégustation, champs obligatoires et dates lisibles.
- I — retrait du nombre d'utilisateurs : je n'ai rien modifié à part le retrait de `Membres du panel` et le champ rôle, car je n'ai pas identifié dans ce passage le compteur exact à retirer sans risquer un changement hors périmètre.
- J — l'écran Flutter de changement obligatoire est ajouté, mais non vérifié par `flutter analyze`/test widget dans ce sandbox.

### HORS PÉRIMÈTRE

- `git status` montre déjà `files/taches/45-direction-nettoyage-utilisateurs-profil.md` modifié ; je ne l'ai pas touché.
- Les fichiers non suivis déjà présents restent non touchés : `backend_new/backup_propre.json`, `backend_new/media/`, `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json`, `files/taches/CONTROLE-MANUEL.md`.
