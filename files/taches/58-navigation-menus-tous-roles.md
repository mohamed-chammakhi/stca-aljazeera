# Tâche 58 — Menus : chaque entrée doit ouvrir la bonne page, pour tous les rôles

Écrit le 03/10/2026 par Claude. Exécutant : GitHub Copilot. Claude vérifie et commite.

## Constat

Chef dégustateur, page « Évaluation des échantillons » : menu → « Accueil » ne ramène pas au
tableau de bord. Cause : dans
`lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` (~293)
`onaccueil: () => Navigator.pop(context)` — ça ferme seulement le menu.
Chaque page reconstruit elle-même son `AppDrawer(...)` avec ses propres fonctions, donc
d'autres pages ont sûrement des entrées qui ne mènent nulle part ou au mauvais endroit.

## À faire

1. Pour **chaque rôle**, un seul endroit qui sait aller vers chaque page du menu :
   - dégustateur : `lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart` ;
   - chef : `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` ;
   - direction : `lib/1_ceo/widgets/ceo_drawer.dart` (+ `ceo_nav_mixin.dart`) ;
   - collecteur : `lib/2_collecteur/widgets/collecteur_drawer.dart` ;
   - laboratoire : `lib/4_laboratoire/labo_drawer.dart`.
   Créer (ou réutiliser s'il existe, comme `ceo_nav_mixin.dart`) une navigation commune par rôle :
   le menu reçoit la page courante et fait lui-même la navigation, au lieu que chaque page passe
   ses fonctions. Toutes les pages du rôle utilisent ce menu commun.
2. Règles de navigation :
   - « Accueil » ouvre **toujours** le tableau de bord du rôle, depuis n'importe quelle page, en
     vidant la pile (`Navigator.pushAndRemoveUntil(…, (r) => false)` ou équivalent déjà utilisé
     dans le projet), sans revenir à l'écran de connexion ;
   - une autre entrée : fermer le menu puis remplacer la page courante par la page choisie
     (`pushReplacement`) — pas d'empilement infini ;
   - toucher l'entrée de la page où l'on est déjà : ferme seulement le menu ;
   - l'entrée de la page courante est mise en évidence ;
   - « Déconnexion » : inchangé (retour à la connexion, pile vidée) ;
   - bouton retour Android sur une page autre que l'accueil : revient au tableau de bord.
3. Vérifier **chaque entrée de chaque menu depuis chaque page** des 5 rôles. Aucune entrée vide
   (`() {}`), aucun `Navigator.pop` utilisé comme « Accueil ».
4. Tableaux de bord : les raccourcis / cartes cliquables qui ouvrent une page (ex. « voir tout »)
   doivent aussi mener à la bonne page.

## Rapport

Dans le rapport, un tableau par rôle : page de départ × entrée du menu → page obtenue (✓ / corrigé).

## Tests

- Test widget par rôle (au moins chef et dégustateur) : depuis la page « Évaluation des
  échantillons », ouvrir le menu, toucher « Accueil » → le tableau de bord est affiché. Si les
  pages appellent le serveur au démarrage, utiliser les mêmes faux clients / fixtures que les
  tests existants (`test/fixtures/api/…`), ou tester la fonction de navigation commune
  directement.

## Règles

Voir `files/taches/PROTOCOLE.md`. Interdit : `git commit`, `git push`, ML Kit, fausses données.
Même comportement pour tous les rôles. Encodage UTF-8 sans BOM, garder les fins de ligne.
Lancer `flutter analyze` (zéro ligne « error - ») et `flutter test` avant le rapport.
