# Plan de correction — brief d'exécution

> Document autonome. Tu n'as besoin d'aucun historique de conversation pour l'exécuter.
> Lis-le en entier avant de toucher un fichier.

---

## 0. Où tu es

| | |
|---|---|
| Racine du dépôt | `c:\Users\takwa\Desktop\flash5\more\flutterpfe` |
| Application Flutter | `project3/` |
| Backend Django | `project3/backend_new/` |
| Python du backend | `project3/backend_new/venv/Scripts/python.exe` (jamais le python global) |
| Base de données | PostgreSQL 18.4, base `mobileapp` |
| Langue de l'interface | **français** — libellés, messages, commentaires |
| Plateforme | Windows 11, PowerShell |

**Lis `project3/CLAUDE.md` avant tout.** Ses règles priment sur ce document.

Le projet : application multi-rôles de collecte et d'évaluation d'huile d'olive pour
**Al Jazeera STCA** (Tunisie). Cinq rôles : direction (`1_ceo/`), collecteur (`2_collecteur/`),
dégustateur (`3_degustateur/`), laboratoire (`4_laboratoire/`), chef dégustateur
(`5_chef_degustateur/`).

**Nous ne sommes pas en phase de déploiement.** On répare l'application en local. La sécurité et
le polissage viendront après, dans cet ordre.

---

## 1. Les deux règles qui ne se négocient pas

Elles viennent du propriétaire du projet et sont écrites dans `CLAUDE.md`.

### Règle 1 — même chose = même nom, un seul fichier

Si deux variables, champs, classes ou fichiers servent le **même but dans le même contexte**, ils
portent le **même nom** et vivent, si possible, dans **un seul fichier partagé**.

Le code dupliqué diverge, et la divergence est silencieuse. Ça a déjà causé un vrai bug sur ce
projet : le modèle d'échantillon d'évaluation copié de `3_degustateur/` vers `5_chef_degustateur/`,
l'original corrigé plus tard, la copie oubliée — et toutes les évaluations soumises s'affichaient
« En attente » chez le chef dégustateur.

**Avant toute fusion ou renommage, vérifier deux choses :**
- l'opération ne change pas **dans quelle table** une valeur est écrite ;
- elle ne croise pas **les données de deux utilisateurs** (règle 2).

Le code d'affichage pur se fusionne sans demander. Tout ce qui est sur un chemin d'écriture se
vérifie d'abord.

### Règle 2 — jamais les données d'un utilisateur chez un autre

Deux échecs à éviter :
- un **statut appartenant à A affiché chez B** ;
- le **travail de A écrasé par B**.

Vérification pratique : tout code qui regroupe des enregistrements par identifiant d'échantillon ne
doit pas garder un seul enregistrement par échantillon quand plusieurs utilisateurs ont chacun le
leur. Vérifier que l'API filtre déjà par utilisateur connecté avant de supposer que le client doit
le faire.

### Contraintes techniques du projet

- **État : `StatefulWidget` + `setState()` uniquement.** Pas de Provider, Riverpod, BLoC, GetX.
- **Navigation : `Navigator.push()` / `pushReplacement()` + `MaterialPageRoute`.** Pas de routes nommées.
- Tous les identifiants sont des `String` (UUID), jamais des `int`.
- Les clés JSON sont en `snake_case`.
- Tout modèle implémente `fromJson()` et `toJson()`.
- Tout accès aux données passe par une classe de service — jamais depuis un widget.
- L'URL de base vit uniquement dans `lib/config.dart`.
- Le linter autorise `unused_element`, `unused_import`, `unused_local_variable` : **le code mort
  n'est jamais signalé**. Ne pas s'y fier.
- Le système de design (couleurs, AppBar obligatoire, structure de page) est décrit dans `CLAUDE.md`.
  Le respecter.

---

## 2. Ce qui a été vérifié et fonctionne — ne pas y toucher

Ces points ont été audités. Ne les « corrige » pas.

- **L'authentification est réelle et correcte.** JWT, jetons dans `flutter_secure_storage`,
  renouvellement automatique sur 401 avec rejeu de la requête, déconnexion qui invalide le jeton
  côté serveur. Fichier : `lib/core/api_client.dart`.
  ⚠️ Le commentaire `// TODO: add token refresh logic` en ligne 116 est **périmé** — le code sous
  le commentaire fonctionne. Supprimer le commentaire, pas le code.
- **L'isolation des données côté serveur est correcte.** Le collecteur ne voit que ses échantillons,
  le laboratoire que les échantillons reçus physiquement, le dégustateur que ses propres
  évaluations. Voir `backend_new/echantillons/views.py:104-119` et
  `backend_new/evaluations/views.py:25-34`.
- **Le backend est plus avancé que le client** : 126 tests, documentation Swagger sur `/api/docs/`,
  historique des modifications après réception, upload de photos.
- **Les 5 pages Profil sont correctement branchées** : elles appellent l'API, affichent les vraies
  erreurs, ne fabriquent rien. (Sauf l'avatar — voir lot 1b.)
- `lib/main.dart:156` porte aussi un `// TODO: replace with real API call` **périmé** : la connexion
  juste en dessous est réelle.

---

## 3. Les lots, dans l'ordre

**L'ordre compte.** Le lot 0 protège tous les autres. Ne pas le sauter.

Après chaque lot terminé : `flutter analyze`, `flutter test`, puis un commit.

---

### Lot 0 — Le filet (≈ 1 heure) — **COMMENCER PAR LÀ**

Il n'existe **aucun dépôt Git**. Pas un commit, pas de `.gitignore`. Des mois de travail dans un
dossier du Bureau, sans aucun moyen de revenir en arrière. Les lots 2 et 3 suppriment et déplacent
des milliers de lignes : sans dépôt, une erreur est définitive.

```bash
cd c:/Users/takwa/Desktop/flash5/more/flutterpfe
git init
```

Écrire un `.gitignore` à la racine excluant au minimum :

```
build/
.dart_tool/
.flutter-plugins*
backend_new/venv/
backend_new/*.log
backend_new/backend_new.zip
__pycache__/
*.pyc
db.sqlite3
.env
android/local.properties
ios/Pods/
```

Vérifier que rien de sensible ni de volumineux n'entre :

```bash
git add -A
git status --short | wc -l        # doit être quelques centaines, pas des dizaines de milliers
git count-objects -vH             # si ça dépasse ~200 Mo, le .gitignore est incomplet
```

Puis :

```bash
git commit -m "État du projet avant la phase de correction"
```

**Dépôt local uniquement.** Pas de `git remote add`, pas de push. Rien ne part sur internet sans
accord explicite du propriétaire.

Ensuite : **un commit par lot terminé**, message en français décrivant ce qui a été fait.

---

### Lot 1 — L'application ne ment plus (≈ 2 à 3 jours)

#### 1a. Encadrer les données de démonstration

Une vingtaine de services suivent ce schéma :

```dart
try   { return await apiClient.getList('/api/...'); }
catch (_) { return _mockAnalyses(); }        // ← silence total
```

`catch (_)` n'attrape pas seulement « pas de réseau ». Il attrape **tout** : jeton expiré, erreur
500, champ absent, mauvaise URL, faute de frappe dans le chemin. Dans chacun de ces cas, l'écran se
remplit de valeurs fabriquées et **rien ne le signale**. Déployé, un directeur pourrait lire un
tableau de bord entièrement inventé et le croire.

**Décision du propriétaire :** on garde les données de démonstration — elles servent à parcourir les
scénarios sans backend — mais elles ne seront plus jamais silencieuses, et elles seront **coupées en
build de production**.

Créer `lib/core/services/resultat_service.dart` :

```dart
import 'package:flutter/foundation.dart' show kReleaseMode;

/// Ce qu'un service renvoie : la donnée, et d'où elle vient.
class Resultat<T> {
  final T donnees;
  final bool estDemonstration;   // vrai = le serveur n'a pas répondu
  final String? messageErreur;
  const Resultat(this.donnees, {this.estDemonstration = false, this.messageErreur});
}

/// Enveloppe un appel réseau.
///
/// En développement, si le serveur ne répond pas, on renvoie les données de
/// démonstration en le signalant. En production (kReleaseMode), le secours est
/// désactivé : l'erreur remonte et l'écran affiche « Réessayer ». Une valeur
/// inventée ne doit jamais atteindre un utilisateur réel.
Future<Resultat<T>> avecSecours<T>(
  Future<T> Function() appel,
  T Function() secours,
) async {
  try {
    return Resultat(await appel());
  } catch (e) {
    if (kReleaseMode) rethrow;
    return Resultat(secours(), estDemonstration: true, messageErreur: e.toString());
  }
}
```

Créer `lib/core/widgets/bandeau_demonstration.dart` — un bandeau orange d'une ligne :
**« Données de démonstration — serveur injoignable »**, avec un bouton *Réessayer*. Respecter le
système de design de `CLAUDE.md`.

Puis convertir les services concernés. Les repérer ainsi :

```bash
cd project3
grep -rn "catch (_)" lib --include="*.dart" | grep services
```

Chaque page qui consomme un service converti affiche le bandeau quand `estDemonstration` est vrai,
et gère l'exception en production par un écran d'erreur avec *Réessayer*.

Comportement visé :

| | Développement | Production (`flutter build apk --release`) |
|---|---|---|
| Serveur répond | vraies données | vraies données |
| Serveur muet | démonstration **+ bandeau orange** | écran d'erreur + *Réessayer*, **jamais d'inventions** |

#### 1b. Supprimer les faux succès

Actions qui annoncent une réussite sans rien enregistrer :

- **`lib/main.dart:212`** (`_forgotPassword`) — affiche « Password reset link sent! », en anglais,
  dans une application française. Aucun mot de passe n'est réinitialisé, aucun message n'est envoyé.
  → Soit brancher une vraie réinitialisation (**la route n'existe pas côté serveur, il faut la
  créer**), soit remplacer le message par « Contactez votre administrateur ».
  **Ne pas laisser un message qui affirme qu'un mail est parti.**
- **Les 5 pages Profil** (`profil_ceo_page.dart`, `profilcom.dart`, `profil_labo_page.dart`,
  `3_degustateur/profil/profil_page.dart`, `5_chef_degustateur/profil.dart`) — l'avatar affiche
  « Galerie - disponible avec image_picker » et « Photo supprimée » sans rien faire. Le paquet
  `image_picker` est **déjà installé** dans `pubspec.yaml`. → Écrire la sélection et l'upload, ou
  retirer les boutons. Pas d'entre-deux.
- Passer en revue les **114** appels à `showSnackBar` / `_showSuccess` du projet :

  ```bash
  grep -rn "showSnackBar\|_showSuccess" lib --include="*.dart"
  ```

  **Règle : un message de succès ne s'affiche qu'après un `await` réussi sur un service.**
  Signaler au propriétaire tout cas ambigu plutôt que de deviner.

---

### Lot 2 — Encaisser le backend déjà écrit (≈ 1 jour)

Le meilleur rapport effort/résultat du projet. Trois services ne font **aucun appel réseau** alors
que les routes existent et fonctionnent côté serveur.

| Fichier client | À brancher sur |
|---|---|
| `lib/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart` | les **10 routes** de `backend_new/chef/urls.py`, sous `/api/chef/dashboard/` |
| `lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart` | `/api/degustateur/dashboard/delai/` et `/api/degustateur/activite/` |
| `lib/4_laboratoire/notifications/services/notification_labo_service.dart` | `/api/notifications/` |

Notes :

- Pour les **notifications du laboratoire**, les 4 autres rôles utilisent déjà cette API. Recopier le
  service du dégustateur (`lib/3_degustateur/notifications/services/notification_degustateur_service.dart`),
  qui est branché et fonctionne.
- Pour le **tableau de bord du dégustateur**, seules 2 routes existent. Les blocs *pipeline*,
  *classifications* et *présence* n'ont pas d'équivalent côté serveur pour ce rôle — alors que le chef
  les a. Deux options : réutiliser les vues du chef avec un filtre sur l'utilisateur connecté, ou
  créer les vues manquantes. **Demander au propriétaire avant de choisir** : c'est un arbitrage de
  périmètre, pas un détail technique. Et attention à la règle 2 — un dégustateur ne doit pas voir
  les chiffres d'un autre.
- Appliquer le modèle du lot 1 : `avecSecours(...)`, données de démonstration conservées sous bandeau.

Contrôle de fin de lot — plus aucun `0` en tête de liste :

```bash
cd project3
for f in $(find lib -path '*/services/*.dart'); do echo "$(grep -c apiClient $f)  $f"; done | sort -n
```

(`geo_service.dart` et les fichiers `*mock_data*.dart` sont des exceptions légitimes : ils ne
parlent à aucun serveur par nature.)

---

### Lot 3 — Fusionner les deux modules de dégustation (≈ 1 à 2 semaines)

> ⚠️ **Vérifier d'abord qu'aucun autre travail n'est en cours sur `analyse_labo/`.** Un plan séparé
> (rapport de laboratoire partagé entre direction, dégustateur et chef dégustateur) touche
> `3_degustateur/analyse_labo/` et `5_chef_degustateur/analyse_labo/`. S'il n'est pas terminé,
> commencer ce lot par les autres dossiers.

`3_degustateur/` (14 510 lignes) et `5_chef_degustateur/` (16 484 lignes) représentent **48 % de
l'application**. **33 fichiers portent le même chemin dans les deux modules — et les 33 ont divergé.**

Exemples :

| Fichier | dégustateur | chef |
|---|---|---|
| `tableau_de_bord/widgets/home_body.dart` | 1 800 | 2 035 |
| `gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` | 1 265 | 1 153 |
| `sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart` | 956 | 976 |
| `tableau_de_bord/widgets/home_delai_section.dart` | 324 | 142 |

Pour lister les 33 et voir lesquels ont divergé :

```bash
cd project3/lib
for f in $(cd 3_degustateur && find . -name '*.dart' | sort); do
  if [ -f "5_chef_degustateur/${f#./}" ]; then
    diff -q "3_degustateur/${f#./}" "5_chef_degustateur/${f#./}" >/dev/null 2>&1 \
      && echo "IDENTIQUE ${f#./}" || echo "diverge   ${f#./}"
  fi
done
```

**Ne pas tout fusionner d'un coup.** Un fichier à la fois, du moins risqué au plus risqué :

1. **Modèles et données de démonstration** (7 fichiers) — `membre_panel.dart`,
   `notification_degustateur.dart`, `session_degustation.dart`, les `mock_*.dart`.
   Aucun risque : personne n'écrit dedans.
2. **Petits widgets d'affichage** (5 fichiers) — `filtre_chip.dart`, `membre_card.dart`,
   `suppression_dialog.dart`, `suppression_session_dialog.dart`, `empty_state.dart`.
3. **Cartes et sections** (10 fichiers) — `echantillon_card.dart`, `session_card.dart`, les
   `home_*_section.dart`. Paramétrer les couleurs au lieu de dupliquer : `deg_colors.dart` et
   `chef_colors.dart` deviennent un objet de thème passé en argument.
4. **Services** (5 fichiers) — ⚠️ **chemin d'écriture.** Avant chaque fusion, vérifier les deux
   règles de la section 1 : (a) l'appel n'écrit pas dans une autre table, (b) il ne croise pas les
   données de deux utilisateurs. Vérifier le filtrage **endpoint par endpoint** côté serveur, avant
   la fusion, pas après.
5. **Gros formulaires** (2 fichiers, ~2 400 lignes) — `formulaire_dialog.dart`,
   `formulaire_session_dialog.dart`. En dernier, quand tout le reste est stable.
6. **Les pages restent séparées.** Elles diffèrent par le tiroir de navigation et le thème : c'est
   une vraie différence, pas une copie.

Destination : `lib/core/` pour ce qui est réellement commun.

> **Avant de fusionner un fichier, lire les DEUX versions en entier et noter les écarts.**
> Elles ont divergé pendant des mois. Certains écarts sont des corrections que seul un côté a
> reçues ; d'autres sont des différences voulues. Fusionner sans lire ferait réapparaître des bugs
> déjà corrigés d'un côté. En cas de doute sur un écart, **demander** plutôt que de trancher.

**Après chaque fichier fusionné :** `flutter analyze`, `flutter test`, un commit.
**Jamais deux fichiers dans le même commit** — c'est ce qui rend une erreur annulable.

---

### Lot 4 — Les tests disent la vérité (≈ 2 jours)

- **`project3/test/widget_test.dart`** — le test « Counter increments smoke test » livré par défaut
  avec Flutter, cassé depuis la création du projet, qui échoue à chaque exécution. Il apprend à
  ignorer les échecs. **Le supprimer** et le remplacer par un test qui ouvre l'écran de connexion.
- **`backend_new/degustateur/tests.py` : 0 test** — alors que le lot 2 branche le client dessus.
- **`backend_new/planifications/tests.py` : 0 test** — arrivages et livraisons de stock, sans
  aucune couverture.
- **Aucun test Dart sur les services.** Écrire au moins un test par service converti au lot 1 :
  serveur muet → `estDemonstration == true` ; serveur qui répond → données réelles, pas de bandeau.

Cible : `flutter test` **entièrement vert**. Un échec toléré en cache dix vrais.

---

### Lot 5 — Sécurité et finitions (≈ 3 jours, après les lots 1 à 4)

- **Retirer les 4 boutons de connexion de debug** de `lib/main.dart` (lignes ~471-487). Ils entrent
  dans n'importe quel rôle sans mot de passe. À faire **quand la vraie connexion est confortable**
  pour les 5 comptes de test — pas avant, sinon on ne peut plus rien tester.
- Supprimer les commentaires `TODO` périmés qui décrivent du code déjà écrit
  (`api_client.dart:116`, `main.dart:156`) : ils font douter de code qui fonctionne.
- Relire les messages d'erreur : l'écran de connexion mélange français et anglais.
- Vérifier `kApiBaseUrl` dans `lib/config.dart` — une adresse IP locale figée ne doit pas partir en
  production.

---

### Lot 6 — Mode hors ligne du collecteur (**reporté — ne pas commencer**)

Décision prise par le propriétaire : après les lots 0 à 5.

Pour information : `CLAUDE.md` dit que le collecteur travaille parfois hors réseau. Aujourd'hui il
n'y a **aucun stockage local** — ni `sqflite`, ni `hive`, ni `shared_preferences` dans `pubspec.yaml`.
Un échantillon saisi sans réseau est perdu à la fermeture de l'application. C'est un chantier à part
entière (file d'attente locale, synchronisation, conflits, indicateur « en attente d'envoi »), à
planifier séparément.

---

### Lot 7 — Non construit, **hors périmètre**

Ne pas commencer sans demande explicite : messagerie Direction ↔ chef et Direction ↔ collecteurs
(l'app Django `messages_chat` existe déjà, le client ne l'utilise pas) ; notifications push ;
verrouillage de l'échantillon après évaluation soumise ; adaptation web.

---

## 4. Comment vérifier

Après chaque lot :

```bash
cd c:/Users/takwa/Desktop/flash5/more/flutterpfe/project3
flutter analyze lib test
flutter test
./backend_new/venv/Scripts/python.exe backend_new/manage.py test
cd .. && git add -A && git commit -m "lot N — <ce qui a été fait>"
```

Repères actuels, à ne pas faire régresser :
- `flutter analyze` : **0 erreur**
- `manage.py test` : **126 tests au vert**
- `flutter test` : tout au vert **sauf** `widget_test.dart` (cassé avant ce chantier, supprimé au lot 4)

**Après le lot 1**, la vérification qui compte se fait à la main, backend lancé :

1. Ouvrir chaque écran des 5 rôles. **Aucun bandeau orange ne doit apparaître.** S'il apparaît, cet
   écran n'a jamais parlé au serveur — c'est exactement ce qu'on cherche à découvrir.
2. Couper le backend, recharger : le bandeau apparaît partout, les données de démonstration
   s'affichent, l'application ne plante pas.
3. `flutter build apk --release` avec le backend coupé : **aucune donnée de démonstration**, un écran
   d'erreur avec *Réessayer*.

**Après le lot 3**, sur le téléphone : parcourir les deux rôles de dégustation écran par écran. Ils
doivent afficher la même chose aux couleurs près. Tout écart restant est soit un bug d'un côté, soit
une différence à documenter.

---

## 5. Ce que tu ne fais pas

- **Pas de `git push`, pas de remote, pas de dépôt distant.** Le dépôt reste local.
- **Pas de nouvelle bibliothèque d'état** (Provider, Riverpod, BLoC, GetX). `setState` uniquement.
- **Pas de refactoring hors sujet.** Si tu vois un problème en dehors du lot en cours, note-le et
  signale-le à la fin ; ne le corrige pas au passage.
- **Pas de suppression d'un fichier « inutilisé » sans preuve.** Le linter du projet autorise
  `unused_element` et `unused_import` : il ne signale jamais le code mort. Vérifier avec `grep` que
  personne n'importe le fichier avant de le supprimer.
- **Pas de retrait des boutons de debug avant le lot 5.**
- **Pas de « ça marche » sans l'avoir exécuté.** Si un test échoue, le dire avec sa sortie. Si une
  étape est sautée, le dire.

## 6. Quand t'arrêter et demander

- Un écart entre les deux modules de dégustation dont tu ne sais pas s'il est une correction ou une
  différence voulue (lot 3).
- Le choix entre réutiliser les vues du chef ou créer des vues serveur pour le tableau de bord du
  dégustateur (lot 2).
- Tout ce qui touche les décisions métier ouvertes des carnets `files/notifications/` (D1 à D30,
  C4/C5/C7/C8, W3 à W7, L6 à L9). Ce sont des questions du propriétaire, pas des tiens.
- Toute suppression de fonctionnalité visible par l'utilisateur.

---

## 7. Deux remarques utiles

- **`files/notifications/03_degustateur.md` n'existe pas.** C'est le seul rôle sans carnet de
  décisions, alors qu'il pèse 48 % du code avec le chef. Ce n'est pas ton travail de l'écrire, mais
  ça explique pourquoi ce module est le moins cadré.
- **Le rapport d'analyse de laboratoire compte 28 valeurs**, définies une seule fois dans
  `lib/core/analyses/normes_coi.dart` avec son miroir Python `backend_new/analyses/normes_coi.py`.
  Si tu croises une liste de seuils COI recopiée ailleurs, c'est un bug de duplication (règle 1) —
  signale-le.
