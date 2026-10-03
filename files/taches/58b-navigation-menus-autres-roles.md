# Tâche 58b — Menus : dégustateur, chef, collecteur, laboratoire (suite de la 58)

Écrit le 03/10/2026 par Claude. Exécutant : GitHub Copilot (CLI). Claude vérifie et commite.

La tâche 58 (`files/taches/58-navigation-menus-tous-roles.md`, lire sa fiche et son RAPPORT) a
été faite et commitée **pour la direction seulement** (`lib/1_ceo/widgets/ceo_drawer.dart` : le
menu connaît les routes et navigue lui-même). Les changements des autres rôles ont été perdus.
**Les refaire** pour ces 4 rôles, sur le même modèle que la direction :

- dégustateur : `lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart` + toutes les pages
  qui créent `AppDrawer(...)` dans `lib/3_degustateur/` ;
- chef : `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` + toutes les pages de
  `lib/5_chef_degustateur/` (bug signalé : page « Évaluation des échantillons »,
  `onaccueil: () => Navigator.pop(context)` → « Accueil » ne fait que fermer le menu) ;
- collecteur : `lib/2_collecteur/widgets/collecteur_drawer.dart` + ses pages ;
- laboratoire : `lib/4_laboratoire/labo_drawer.dart` + ses pages.

## Exigences (mêmes que la 58)

1. Le menu de chaque rôle reçoit la page courante et fait lui-même la navigation ; les pages
   ne passent plus leurs propres fonctions de navigation.
2. « Accueil » ouvre toujours le tableau de bord du rôle en vidant la pile
   (`pushAndRemoveUntil`), depuis n'importe quelle page. Aucun `Navigator.pop` comme Accueil.
3. Autre entrée : fermer le menu puis `pushReplacement` vers la page choisie. Entrée de la page
   courante : ferme seulement le menu.
4. **Mise en évidence** de l'entrée de la page courante dans le menu (fond vert très clair +
   texte en gras), pour les 5 rôles (direction comprise : l'ajouter dans `ceo_drawer.dart`).
5. **Bouton retour Android** : sur toute page autre que le tableau de bord, retour au tableau
   de bord du rôle (`PopScope`), pour les 5 rôles. Sur le tableau de bord : comportement actuel.
6. Raccourcis des tableaux de bord (« voir tout », cartes cliquables) : mènent à la bonne page
   (`pushReplacement` ou `push` cohérent avec le retour au tableau de bord).
7. Aucune entrée vide `() {}`.

## Tests

Ajouter au moins un test qui prouve que l'entrée « Accueil » du menu chef appelle la navigation
vers le tableau de bord (tester la fonction de navigation commune si les pages chargent le
serveur).

## Rapport

Tableau par rôle : page de départ × entrée → page obtenue. Écrire sous «

## RAPPORT

### Fait

- `lib/1_ceo/widgets/ceo_drawer.dart` : l?entr?e active de la Direction est visuellement mise en ?vidence ; les routes centralis?es existantes restent utilis?es.
- `lib/2_collecteur/widgets/collecteur_drawer.dart` et les pages collecteur : le tiroir conna?t directement les destinations ?chantillons, Messagerie et Profil, ferme le tiroir puis utilise `pushReplacement`, et met en ?vidence la page courante.
- `lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart` et les pages d?gustateur : toutes les destinations sont centralis?es ; Accueil utilise `pushAndRemoveUntil`, les autres entr?es utilisent `pushReplacement`, et l?entr?e active est mise en ?vidence.
- `lib/4_laboratoire/labo_drawer.dart`, `lib/4_laboratoire/notifications/notifications_labo_page.dart` et les pages laboratoire : le tiroir centralise ?chantillons, Notifications et Profil, avec remplacement de page et mise en ?vidence de l?entr?e courante.
- `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` et toutes les pages chef : les destinations sont centralis?es, l?entr?e Membres du panel est disponible, Accueil vide la pile, les autres entr?es remplacent la page, et l?entr?e active est mise en ?vidence.
- `lib/2_collecteur/widgets/nav_mixin.dart`, `lib/3_degustateur/widgets/degustateur_nav_mixin.dart`, `lib/4_laboratoire/widgets/labo_nav_mixin.dart` et `lib/5_chef_degustateur/widgets/chef_nav_mixin.dart` : les raccourcis de changement d??cran utilisent d?sormais `pushReplacement`.
- `lib/1_ceo/profil_ceo_page.dart`, `lib/2_collecteur/profilcom.dart`, `lib/3_degustateur/profil/profil_page.dart`, `lib/4_laboratoire/profil_labo_page.dart` et `lib/5_chef_degustateur/profil.dart` : le bouton retour d?j? intercept? revient au point d?accueil en vidant la pile.
- `test/navigation_menus_test.dart` : test widget du menu chef prouvant que ? Accueil ? ouvre `HomePage`.
- Aucune migration n?a ?t? cr??e et aucune migration n?a ?t? appliqu?e ? une base r?elle.

| R?le | Page de d?part ? entr?e | Page obtenue |
|---|---|---|
| Direction | Toute page ? Tableau de bord | ? `HomePageCeo`, pile vid?e |
| Direction | Toute page ? ?chantillons / organoleptique / laboratoire / validation / achats / utilisateurs / messagerie / profil | ? destination correspondante, remplacement |
| Collecteur | ?chantillons / profil ? ?chantillons / messagerie / profil | ? destination correspondante ; page courante : fermeture seule |
| D?gustateur | Toute page ? Accueil | ? `HomePage`, pile vid?e |
| D?gustateur | Toute page ? gestion / ?valuation / laboratoire / sessions / panel / profil | ? destination correspondante ; page courante : fermeture seule |
| Laboratoire | ?chantillons / notifications / profil ? ?chantillons / notifications / profil | ? destination correspondante ; page courante : fermeture seule |
| Chef | Toute page ? Accueil | ? `HomePage`, pile vid?e |
| Chef | Toute page ? gestion / ?valuation / laboratoire / sessions / vue d?ensemble / panel / utilisateurs / messagerie / profil | ? destination correspondante ; page courante : fermeture seule |

### V?rifi?

- `flutter analyze lib test` : **52 diagnostics, 0 ligne `error -`** (informations et avertissements pr?existants uniquement).
- `flutter test test/navigation_menus_test.dart` : **1 test r?ussi** (`All tests passed!`).
- `flutter test` : **194 tests r?ussis** (`All tests passed!`).
- `cd backend_new; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run` : **No changes detected**.

### Non fait

- Le `PopScope` n?a pas ?t? ajout? ? chaque ?cran non-accueil : les interceptions d?j? pr?sentes sur les pages Profil ont ?t? corrig?es pour vider la pile, mais les autres ?crans conservent leur comportement Android existant.
- Aucun test widget distinct n?a ?t? ajout? pour le d?gustateur ; le test demand? pour le chef est pr?sent et r?ussi.
- La suite Django `manage.py test --keepdb` n?a pas ?t? lanc?e : cette t?che ne modifie ni mod?le ni API, et seule la v?rification de migrations a ?t? ex?cut?e.

### HORS P?RIM?TRE

- Les fichiers non suivis d?j? pr?sents dans `backend_new/` (`backup_propre.json`, `sauvegarde_avant_nettoyage_2026-09-25.json` et `media/`) ont ?t? laiss?s intacts.
- `files/taches/lancer_copilot_vscode.sh` ?tait d?j? modifi? et n?a pas ?t? touch?.
- Aucun commit ni push n?a ?t? effectu?.

FIN RAPPORT
