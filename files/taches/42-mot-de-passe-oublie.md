# Tâche 42 — Mot de passe oublié : code à 6 chiffres par email

Lis `files/taches/PROTOCOLE.md`, puis `CLAUDE.md`. Backend + Flutter.
**Une migration est autorisée pour cette tâche** (nouvelle table des codes).

## Règles de la propriétaire

- Sur la page de connexion : lien `Mot de passe oublié ?`.
- La personne tape **l'email de son compte**. Le code est envoyé **uniquement** à cet email
  (celui enregistré sur le compte), jamais ailleurs.
- Elle reçoit un **code à 6 chiffres** (lisible sur PC ou téléphone, dans Gmail ou autre).
- Elle tape le code **dans l'application**, puis l'application l'amène à l'écran
  « Nouveau mot de passe ».
- Le code est valable **15 minutes**, une seule fois, avec **4 essais au maximum**. Après 4
  mauvais essais ou 15 minutes, le code ne marche plus : il faut en demander un nouveau.

## Backend (`backend_new/users/`)

1. Modèle `CodeReinitialisation` : utilisateur, **empreinte** du code (jamais le code en
   clair : `make_password` / `check_password`), date de création, date d'expiration
   (+15 min), nombre d'essais, utilisé (bool). Migration.
2. `POST /api/auth/mot-de-passe-oublie/` `{email}` :
   - si un compte actif a cet email : invalide ses anciens codes, crée un code
     (`secrets.randbelow`), envoie l'email avec `django.core.mail.send_mail` ;
   - **répond toujours pareil** (200, `Si un compte existe, un code a été envoyé.`), que
     l'email existe ou non — on ne révèle pas quels emails ont un compte ;
   - limite : pas plus de 3 demandes par email par heure (réponse identique au-delà).
3. `POST /api/auth/mot-de-passe-oublie/verifier/` `{email, code}` : vérifie (expiré, déjà
   utilisé, essais ≥ 4 → refus). Chaque mauvais code ajoute 1 essai. Si bon : renvoie un
   **jeton court** (signé, valable 10 min, lié à ce code) pour l'étape suivante.
   Messages : `Code incorrect. Il vous reste N essai(s).`,
   `Code expiré ou épuisé. Demandez un nouveau code.`
4. `POST /api/auth/mot-de-passe-oublie/nouveau/` `{jeton, nouveau_mot_de_passe}` :
   applique **les mêmes règles de mot de passe** que le changement de mot de passe existant
   (réutilise la même validation), marque le code utilisé, enregistre le mot de passe.
   Blackliste les refresh tokens existants de l'utilisateur (déconnexion des autres
   appareils) si c'est simple avec `token_blacklist` ; sinon, note-le dans le rapport.
5. Ces 3 routes sont accessibles **sans être connecté** (`AllowAny`).
6. Email : dans `settings.py`, lis la configuration depuis l'environnement
   (`EMAIL_BACKEND`, `EMAIL_HOST`, `EMAIL_PORT`, `EMAIL_HOST_USER`,
   `EMAIL_HOST_PASSWORD`, `EMAIL_USE_TLS`, `DEFAULT_FROM_EMAIL`) avec `config(...)` comme
   le reste du fichier. **Par défaut** : `django.core.mail.backends.console.EmailBackend`
   (l'email s'affiche dans le journal du serveur : c'est ainsi qu'on testera en attendant
   l'adresse d'envoi). N'écris aucun mot de passe dans le code.
   Texte de l'email (français, court) : objet `Votre code Al Jazeera STCA`, corps avec le
   code, « valable 15 minutes », « si vous n'avez rien demandé, ignorez ce message ».
7. Tests Django : email inconnu → même réponse et aucun email ; bon code → jeton ; 4
   mauvais essais → épuisé même avec le bon code ; code expiré ; nouveau mot de passe trop
   faible refusé ; mot de passe changé → connexion avec le nouveau OK.

## Flutter

- `lib/main.dart` (`LoginPage`) : lien `Mot de passe oublié ?` sous le champ mot de passe,
  même style que la page.
- Nouvel écran (ex. `lib/core/auth/mot_de_passe_oublie_page.dart`), 3 étapes :
  1. email → `Envoyer le code` ;
  2. code (6 chiffres, clavier numérique) → `Vérifier`, avec `Renvoyer un code` ;
  3. nouveau mot de passe + confirmation → `Enregistrer` ; puis retour à la connexion avec
     le message `Mot de passe modifié. Connectez-vous.` (réutilise `messageInitial`).
- Erreurs en **fenêtre** (`AlertDialog`), comme la tâche 41 B pour le changement de mot de
  passe ; réutilise la même fonction si elle existe déjà.
- Tests widget : l'enchaînement des 3 étapes avec un faux client HTTP.

## Vérification attendue

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera les tests Flutter et
Django, et appliquera la migration.

## RAPPORT
