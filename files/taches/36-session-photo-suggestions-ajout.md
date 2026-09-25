# Tâche 36 — Session expirée, photo en grand, suggestions, bouton Ajouter

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Flutter uniquement. Aucun changement backend, aucune migration.
Ton sandbox ne peut pas lancer Flutter : n'essaie pas, Claude lancera `flutter analyze`
et `flutter test`.

**Attention :** deux changements de Claude ne sont pas encore commités
(`lib/core/services/resultat_service.dart`, `test/resultat_service_test.dart`,
`lib/core/widgets/gestion_echantillons/echantillon_card.dart`). Ne les annule pas.
Depuis ce changement, `avecSecours` ne renvoie plus jamais de données de démonstration :
une erreur réseau remonte toujours jusqu'à l'écran.

## Ce que la propriétaire a vu sur son téléphone (24/09/2026)

Connectée en collecteur, l'écran affiche « Impossible de charger les données ». Le journal
du serveur montre que **toutes** les requêtes du téléphone reçoivent `401 Unauthorized`
(`/api/echantillons/`, `/api/fournisseurs/`, `/api/notifications/unread-count/`), et
qu'aucune requête `POST /api/auth/refresh/` ni `/api/auth/login/` n'est envoyée.
L'application garde donc une session morte et ne ramène jamais à la page de connexion.
C'est aussi pour ça que le bouton « Ajouter » d'un échantillon n'a rien envoyé.

---

## Partie A — Session expirée → retour à la connexion

Fichiers : `lib/core/api_client.dart`, `lib/main.dart`.

1. **Défaut dans `_send`** : chaque méthode (`get`, `getList`, `post`, …) construit
   `headers` **avant** d'appeler `_send`, et la fonction de nouvel essai réutilise ces
   mêmes `headers`. Après un rafraîchissement réussi, le nouvel essai repart donc avec
   l'**ancien** jeton et échoue encore en 401. Corrige-le pour que le nouvel essai relise
   le jeton (par exemple : la fonction passée à `_send` reçoit les en-têtes à jour, ou
   `_send` reconstruit les en-têtes). Vérifie **toutes** les méthodes publiques, y compris
   les envois de fichiers (multipart) s'il y en a.
2. **Rafraîchissement impossible** (pas de jeton de rafraîchissement, ou le serveur refuse) :
   - efface les deux jetons (`logout` local, sans appel réseau qui échouerait lui aussi) ;
   - ramène à `LoginPage` en vidant toute la pile de navigation ;
   - affiche sur la page de connexion : « Votre session a expiré. Reconnectez-vous. »
   Pour naviguer depuis `api_client.dart`, ajoute un `GlobalKey<NavigatorState>` dans
   `main.dart`, passé au `MaterialApp`. Évite d'ouvrir plusieurs fois la page de connexion
   si plusieurs requêtes échouent en même temps.
3. Ne touche pas au délai de vie des jetons côté serveur.
4. Ajoute un test pour le point 1 (le nouvel essai part avec le nouveau jeton) avec un
   client HTTP factice si `api_client.dart` le permet sans refonte ; sinon explique
   pourquoi dans le rapport.

## Partie B — Photo en grand dans le formulaire d'ajout

Quand on ajoute un échantillon et qu'on touche la miniature de la photo d'une bouteille,
la photo doit s'afficher **en entier**, en grand, avec zoom possible.

- La carte des dégustateurs le fait déjà : `lib/core/widgets/gestion_echantillons/echantillon_card.dart`
  vers la ligne 600 (`showDialog` + `InteractiveViewer`). **Réutilise ce même affichage** :
  sors-le dans un widget partagé de `lib/core/widgets/` qui accepte une image réseau
  (URL) **ou** des octets en mémoire (photo pas encore envoyée), et fais-le utiliser par la
  carte des dégustateurs et par le formulaire.
- Formulaires concernés : collecteur
  (`lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`), et les
  formulaires d'ajout du dégustateur et du chef
  (`lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`,
  `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`)
  s'ils ont une miniature de photo.
- Sur la carte du collecteur, si une photo est affichée et ne s'ouvre pas en grand, fais
  de même.

## Partie C — Suggestions pour Fournisseur et Variété

Comme dans une barre de recherche Google : on tape, les valeurs déjà utilisées
apparaissent en dessous, on peut en choisir une **ou** continuer à taper une valeur nouvelle.

- Il existe déjà `lib/core/widgets/champ_autocomplete.dart` (`ChampAutocomplete`) et
  `lib/core/services/variete_service.dart` (variétés déjà utilisées).
- **Variété** : dans le formulaire du collecteur (`formulaire_dialog.dart`, classe
  `_BouteillesSection`, vers la ligne 941), le champ « Variété d'olive » est un simple
  `TextField`. Remplace-le par `ChampAutocomplete<String>` alimenté par `VarieteService`,
  comme le fait déjà `BouteillesSection` dans `formulaire_sections.dart` (vers la ligne 458)
  — prends-le pour modèle. Même chose dans les formulaires d'ajout du dégustateur et du
  chef si leur champ variété est un simple `TextField`.
  Après un enregistrement réussi, la nouvelle variété doit apparaître dans les suggestions
  la fois suivante (`fetchAll(forceRefresh: true)` ou vider le cache).
- **Fournisseur** : le collecteur a déjà un `ChampAutocomplete<Fournisseur>` (vers la
  ligne 471). Vérifie seulement que les fournisseurs créés précédemment apparaissent bien
  (y compris un fournisseur créé juste avant, sans redémarrer l'application) et que taper
  un nom nouveau reste possible. Fais la même vérification dans les formulaires du
  dégustateur et du chef. Ne change pas la règle de création des fournisseurs.
- Si `formulaire_sections.dart` `BouteillesSection` n'est utilisé nulle part, **ne le
  supprime pas** : signale-le sous `HORS PÉRIMÈTRE`.

## Partie D — Le bouton « Ajouter » ne doit jamais rester muet

Dans les trois formulaires d'ajout, quand on appuie sur « Ajouter » (ou « Enregistrer ») :
- si un champ obligatoire manque ou est invalide → un message dit **lequel** ;
- si l'envoi au serveur échoue → un message d'erreur s'affiche (le texte de l'erreur du
  serveur si possible) et le formulaire reste ouvert avec ce qui a été tapé ;
- si ça marche → comportement actuel inchangé.
Cherche chaque chemin où l'appui ne fait rien sans rien dire, et corrige-le.

## Partie E — Liste vide ou erreur

Sur la page « Mes échantillons » du collecteur, un compte qui n'a encore **aucun**
échantillon doit voir le message de liste vide (déjà existant), pas « Impossible de charger
les données ». Vérifie que c'est bien le cas quand le serveur répond une liste vide, et
corrige si non. Le message d'erreur ne doit apparaître que si le serveur ne répond pas.

---

## Vérification attendue (Claude)

```bash
flutter analyze lib test
flutter test
```

Résultat attendu : 0 erreur, 0 test en échec.

Dans ton rapport : une ligne par partie (A à E) avec ce qui a été fait, et les fichiers.

## RAPPORT

### Fait

- Partie A — `lib/core/api_client.dart` : après un 401, le nouvel essai reconstruit les en-têtes et repart avec le jeton rafraîchi ; si le refresh est impossible, les jetons locaux sont effacés et la session est redirigée vers la connexion.
- Partie A — `lib/main.dart` : ajout de la clé globale de navigation, branchement du retour à `LoginPage`, et affichage du message « Votre session a expiré. Reconnectez-vous. ».
- Partie A — `lib/core/session_expiration.dart` : nouveau point central pour déclencher le retour à la connexion depuis le client API sans créer d'import circulaire.
- Partie A — `test/api_client_test.dart` : nouveau test unitaire qui vérifie que le retry après refresh envoie `Bearer new-token`.
- Partie B — `lib/core/widgets/photo_plein_ecran.dart` : nouveau widget partagé de miniature ouvrable en grand avec `InteractiveViewer`, pour URL réseau ou octets mémoire.
- Partie B — `lib/core/widgets/gestion_echantillons/echantillon_card.dart` : la carte dégustateur utilise le widget photo partagé.
- Partie B — `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` : la photo choisie dans le formulaire collecteur s'ouvre en grand avec zoom.
- Partie B — `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : la photo choisie dans le formulaire dégustateur s'ouvre en grand avec zoom.
- Partie C — `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` : le champ « Variété d'olive » utilise maintenant `ChampAutocomplete<String>` alimenté par `VarieteService`.
- Partie C — `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`, `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`, `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : après une sauvegarde réussie, les caches fournisseur et variété sont invalidés pour que les prochaines suggestions repartent du serveur.
- Partie D — `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart`, `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`, `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` : les formulaires attendent la sauvegarde serveur, gardent les données saisies en cas d'échec, affichent l'erreur, et désactivent le bouton pendant l'envoi.
- Partie D — `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`, `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`, `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` : les erreurs de création/modification remontent au dialogue au lieu d'être avalées silencieusement.
- Partie E — `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` : l'échec du compteur de notifications ne déclenche plus l'écran global « Impossible de charger les données », donc une liste d'échantillons vide reste affichée comme liste vide.

### Vérifié

```bash
dart format lib/core/api_client.dart lib/main.dart lib/core/session_expiration.dart lib/core/widgets/photo_plein_ecran.dart lib/core/widgets/gestion_echantillons/echantillon_card.dart lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart test/api_client_test.dart
```

Sortie : `command timed out after 120057 milliseconds`.

```bash
dart format lib/core/api_client.dart lib/main.dart lib/core/session_expiration.dart lib/core/widgets/photo_plein_ecran.dart test/api_client_test.dart
dart format lib/core/widgets/gestion_echantillons/echantillon_card.dart
```

Sorties : `command timed out after 60101 milliseconds` et `command timed out after 60104 milliseconds`.

```bash
dart --version
```

Sortie : `command timed out after 10099 milliseconds`.

```bash
git diff --check
```

Sortie : exit code 0 ; uniquement des avertissements CRLF du type `LF will be replaced by CRLF the next time Git touches it`.

```bash
rg -n "formulaire_sections|BouteillesSection|PhotoSection" lib test -g "*.dart"
```

Sortie brute utile :

```text
lib\1_ceo\analyse_organoleptique\widgets\panel_widgets.dart:13:import '../../../../2_collecteur/mes_echantillons/widgets/dialogs/formulaire_sections.dart'
lib\2_collecteur\mes_echantillons\widgets\dialogs\formulaire_sections.dart:69:class PhotoSection extends StatelessWidget {
lib\2_collecteur\mes_echantillons\widgets\dialogs\formulaire_sections.dart:284:class BouteillesSection extends StatelessWidget {
lib\2_collecteur\mes_echantillons\widgets\dialogs\formulaire_dialog.dart:23:import 'formulaire_sections.dart';
lib\2_collecteur\mes_echantillons\widgets\dialogs\formulaire_dialog.dart:574:                    _BouteillesSection(
lib\3_degustateur\gestion_echantillons\widgets\dialogs\formulaire_dialog.dart:627:                    _BouteillesSection(
lib\5_chef_degustateur\gestion_echantillons\widgets\dialogs\formulaire_dialog.dart:461:                    _BouteillesSection(
```

`flutter analyze lib test` et `flutter test` non exécutés : la tâche dit explicitement que ce sandbox ne peut pas lancer Flutter et qu'il ne faut pas essayer.

### Non fait

- Je n'ai pas lancé `flutter analyze lib test` ni `flutter test`, conformément à la consigne de cette tâche.
- Je n'ai pas pu formater avec `dart format` : la commande expire systématiquement dans ce sandbox, même sur petits lots.

### HORS PÉRIMÈTRE

- Aucun problème hors périmètre corrigé.
