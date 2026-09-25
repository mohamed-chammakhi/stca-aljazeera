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
