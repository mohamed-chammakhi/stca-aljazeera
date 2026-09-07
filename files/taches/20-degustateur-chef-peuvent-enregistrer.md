# Tâche 20 — Le dégustateur et le chef dégustateur peuvent enregistrer, modifier et
# supprimer des échantillons, exactement comme le collecteur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Modules concernés : `3_degustateur`, `5_chef_degustateur` (frontend), `backend_new/echantillons`
(permissions serveur). Le module `2_collecteur` fournit le code réutilisé — **tu n'y dupliques
rien, tu l'importes tel quel.**

---

## Contexte

Décision du propriétaire : en période de forte activité, le dégustateur et le chef
dégustateur doivent pouvoir enregistrer eux-mêmes un nouvel échantillon — pas seulement le
collecteur. Ils doivent aussi pouvoir modifier et supprimer des échantillons, avec **une
restriction** : ils ne peuvent pas supprimer un échantillon enregistré par un collecteur (le
collecteur, lui, garde son droit de suppression habituel).

Exigence explicite du propriétaire : *« le formulaire doit ressembler et fonctionner
exactement comme celui que le collecteur a et utilise actuellement »*. Ce n'est pas une
suggestion de style — c'est la page entière (liste, carte, formulaire, FAB) qui doit être la
même, réutilisée, pas reconstruite.

### Ce qui existe déjà et qu'il ne faut PAS utiliser

`lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` et
`lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`
contiennent chacun une branche "ajout" jamais branchée à un bouton ni au serveur — du code
mort, sur un modèle de données différent (`lib/core/models/echantillon.dart`) de celui du
collecteur. **Ignore ces deux fichiers pour cette tâche.** Ne les supprime pas non plus, ils
servent à autre chose (modification depuis la page d'évaluation) — hors périmètre ici.

### Ce qu'il faut réutiliser tel quel

Le collecteur gère ses échantillons avec :
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` — la page entière (liste,
  filtres, FAB "Ajouter")
- `lib/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart` — le modèle
  `EchantillonCollecteur`
- `lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart` — le
  service, y compris `createEchantillon`, `updateEchantillon`, `deleteEchantillon`
- Tout `lib/2_collecteur/mes_echantillons/widgets/` (dialogues, cartes) que `mes_echantillons_page.dart`
  utilise déjà

### Comment le serveur distingue déjà "qui a enregistré"

`backend_new/echantillons/models.py` : le champ `collecteur` (ForeignKey) est **nullable**.
Aujourd'hui, `perform_create` (`backend_new/echantillons/views.py:135-150`) ne remplit
`collecteur=request.user` que si le rôle est `COLLECTEUR` — pour tout autre rôle, il reste
`null`. **C'est exactement le signal à utiliser** pour la règle de suppression : un
échantillon avec `collecteur` à `null` a été enregistré par un dégustateur ou un chef, pas par
un collecteur. Pas de nouveau champ, pas de migration.

---

## CONSIGNE

### 1. Backend — ouvrir les permissions (`backend_new/echantillons/views.py`)

`get_permissions()` (~L113-118) :

```python
def get_permissions(self):
    if self.action in ['create', 'bulk', 'destroy']:
        return [IsCollecteur()]
    if self.action in ['update', 'partial_update']:
        return [(IsCollecteur | IsDegustateur)()]
    return super().get_permissions()
```

Remplace par :
- `create` et `bulk` : autoriser `IsCollecteur | IsDegustateur | IsChefDegustation`.
- `update` / `partial_update` : autoriser `IsCollecteur | IsDegustateur | IsChefDegustation`
  (aujourd'hui le chef dégustateur en est exclu, alors que le propriétaire veut qu'il puisse
  modifier).
- `destroy` : autoriser `IsCollecteur | IsDegustateur | IsChefDegustation` **au niveau
  permission**. La restriction "pas les échantillons du collecteur" se fait en plus, au niveau
  objet — voir point 2.

### 2. Backend — la règle de suppression (`destroy()`, ~L166-182)

La méthode vérifie déjà deux règles (pas reçu physiquement, statut toujours "réceptionné").
Ajoute une troisième vérification, **avant** ces deux-là ou après, peu importe l'ordre tant
que les trois s'appliquent : si `request.user.role` est `DEGUSTATEUR` ou `CHEF_DEGUSTATION`
**et** `obj.collecteur is not None`, renvoie 403 avec un message clair, par exemple
`"Impossible de supprimer un échantillon enregistré par un collecteur."` — même format que
les deux réponses 403 déjà présentes dans cette méthode.

Le collecteur garde son comportement actuel, inchangé.

### 3. Backend — vérifie `perform_create` pour les deux nouveaux rôles

`perform_create` (~L135-150) laisse `statut_collecteur` non précisé quand le rôle n'est pas
`COLLECTEUR` — vérifie avec un test que le champ prend bien sa valeur par défaut du modèle
(`RECEPTIONNE`) dans ce cas, plutôt que de supposer que c'est le cas. Si ce n'est pas le cas,
corrige `perform_create` pour fixer `statut_collecteur=Echantillon.StatutCollecteur.RECEPTIONNE`
quand le créateur n'est pas collecteur non plus (uniquement le statut — ne touche pas
`collecteur`, qui doit rester `null`).

### 4. Frontend — donner accès à la page du collecteur, réutilisée

Dans `lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart` et
`lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart`, ajoute une entrée de menu
qui ouvre `MesEchantillonsPage` (importée depuis
`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`) — le même import direct
inter-module que le projet utilise déjà pour `GeoService` (voir
`lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart:16`, qui
importe déjà quelque chose depuis `2_collecteur`). Choisis un libellé de menu cohérent avec le
reste ("Mes échantillons", ou équivalent — regarde comment le collecteur nomme son entrée dans
`lib/2_collecteur/widgets/collecteur_drawer.dart` et reste cohérent).

Ne touche pas aux pages d'évaluation existantes (`gestion_echantillons_page.dart`,
`evaluation_echantillons_page.dart`) : cette nouvelle entrée est en plus, pas un remplacement.

### 5. Frontend — la restriction de suppression, côté affichage

`mes_echantillons_page.dart` doit maintenant s'ouvrir pour trois rôles différents. Le bouton
supprimer sur une carte d'échantillon doit être masqué quand : le rôle connecté est
dégustateur ou chef dégustateur **et** `echantillon.collecteurId` n'est pas vide/null — en
plus de la règle déjà existante (`canDelete`, basée sur le statut et la réception physique).
Les deux règles s'appliquent ensemble, aucune ne remplace l'autre.

Utilise `authService.currentUser()` (`lib/core/services/auth_service.dart`) pour connaître le
rôle connecté — `UserProfile.role` (`lib/core/models/user_profile.dart:14`). Regarde comment
une page existante du dégustateur ou du chef récupère déjà l'utilisateur connecté (s'il y en a
une) avant d'en ajouter un nouvel appel redondant.

### 6. Vérifie que la création fonctionne de bout en bout pour les deux nouveaux rôles

Un test (Flutter ou Django, à toi de choisir le plus adapté) doit prouver : un utilisateur
dégustateur peut créer un échantillon via `EchantillonCollecteurService`, il apparaît avec
`collecteur = null` côté serveur, et un dégustateur ne peut pas le supprimer si un collecteur
l'a créé mais peut supprimer le sien.

---

## Ce que tu ne fais pas

- Tu ne touches pas aux deux `formulaire_dialog.dart` morts du dégustateur/chef.
- Tu ne dupliques aucun fichier de `2_collecteur` : import direct, un seul fichier qui existe.
- Tu ne changes rien au comportement du collecteur lui-même.
- Tu ne touches pas à `evaluation_echantillons_page.dart` ni aux pages d'analyse.
- Si en cours de route tu trouves que la page du collecteur, une fois ouverte par un
  dégustateur/chef, affiche ou casse quelque chose de spécifique au collecteur (un texte, une
  action qui n'a pas de sens pour ce rôle), **note-le sous `## QUESTION` plutôt que de
  deviner** — ne modifie pas le comportement du collecteur pour "corriger" ça.

---

## Vérification à exécuter

```bash
flutter analyze lib test
flutter test
cd backend_new
./venv/Scripts/python.exe manage.py test --keepdb
```

Donne les sorties chiffrées réelles dans ton rapport.

## QUESTION

La page `MesEchantillonsPage` est bien reutilisee telle quelle, comme demande. En l'ouvrant
depuis Degustateur/Chef, elle embarque donc aussi des elements specifiques au collecteur :
le drawer `CollecteurDrawer`, la cloche `NotificationCollecteurService`, le profil collecteur,
et les actions d'achat/livraison qui peuvent apparaitre selon le statut mais restent refusees
cote serveur pour Degustateur/Chef. Faut-il, dans une tache separee, creer une enveloppe
role-aware autour de cette meme page pour masquer seulement ces destinations/actions non
pertinentes sans dupliquer le formulaire ni la liste ?

## RAPPORT

### Fait

- `backend_new/echantillons/views.py` : Degustateur et Chef de Degustation peuvent creer,
  creer en lot, modifier et appeler la suppression des echantillons; la suppression reste
  refusee si l'echantillon a ete enregistre par un collecteur.
- `backend_new/echantillons/tests.py` : les tests prouvent la creation Degustateur/Chef avec
  `collecteur = null`, le statut collecteur par defaut `receptionne`, la modification par le
  chef, le refus de suppression d'un echantillon collecteur par un degustateur, et la
  suppression autorisee d'un echantillon sans collecteur.
- `lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart` : le drawer Degustateur ajoute
  l'entree `Mes echantillons` qui ouvre directement la page collecteur reutilisee.
- `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` : le drawer Chef ajoute
  la meme entree `Mes echantillons` vers la page collecteur reutilisee.
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` : le bouton supprimer reste
  base sur `canDelete`, et il est masque en plus pour Degustateur/Chef quand `collecteurId`
  n'est pas vide.
- `files/mapbackend.md` : le checkpoint backend est mis a jour avec ce changement.

### Verifie

```bash
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test echantillons --keepdb -v 2
```

Sortie chiffree : `Found 31 test(s).` puis `Ran 31 tests in 125.389s` -> `OK`.

```bash
& 'C:\Users\takwa\Documents\flutter\bin\cache\dart-sdk\bin\dart.exe' format lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart lib/3_degustateur/tableau_de_bord/widgets/app_drawer.dart lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart
```

Sortie chiffree : `Formatted 3 files (2 changed) in 0.22 seconds.`

```bash
$env:FLUTTER_SUPPRESS_ANALYTICS='true'; flutter analyze lib test
```

Sortie chiffree : timeout apres `900122 ms`, aucune sortie Flutter produite.

```bash
$env:FLUTTER_SUPPRESS_ANALYTICS='true'; flutter test
```

Sortie chiffree : timeout apres `900114 ms`, aucune sortie Flutter produite.

```bash
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test --keepdb -v 1
```

Sortie chiffree : `Found 168 test(s).` puis `Ran 168 tests in 1061.398s` -> `OK`.

Commandes de diagnostic Flutter executees pendant le blocage :

```bash
dart --version
flutter --version
```

Sorties chiffrees : timeouts apres environ `30153 ms` et `30157 ms`, sans sortie.

```bash
& 'C:\Users\takwa\Documents\flutter\bin\cache\dart-sdk\bin\dart.exe' --version
```

Sortie chiffree : `Dart SDK version: 3.12.2 (stable)`.

```bash
$env:FLUTTER_SUPPRESS_ANALYTICS='true'; & 'C:\Users\takwa\Documents\flutter\bin\dart.bat' --version
$env:FLUTTER_SUPPRESS_ANALYTICS='true'; & 'C:\Users\takwa\Documents\flutter\bin\flutter.bat' --version
```

Sorties chiffrees : timeouts apres `60061 ms` pour les deux commandes, sans sortie.

```bash
$env:FLUTTER_SUPPRESS_ANALYTICS='true'; & 'C:\Users\takwa\Documents\flutter\bin\cache\dart-sdk\bin\dart.exe' 'C:\Users\takwa\Documents\flutter\packages\flutter_tools\bin\flutter_tools.dart' --version
```

Sortie chiffree : timeout apres `120119 ms`, aucune sortie Flutter produite.

### Non fait

- `flutter analyze lib test` et `flutter test` n'ont pas pu aboutir : l'outil Flutter/Dart
  reste muet jusqu'au timeout via les wrappers `dart.bat`/`flutter.bat`, et Flutter reste
  bloque meme via `flutter_tools.dart`.
- `files/backend_sprint_plan.md` n'a pas pu etre lu : le fichier est absent de ce checkout.

### HORS PERIMETRE

- Plusieurs processus Dart etaient deja presents pendant le diagnostic. Le sandbox a refuse
  `Get-CimInstance Win32_Process` avec `Access denied`, donc je n'ai pas pu identifier leur
  ligne de commande ni les nettoyer sans risquer de toucher a un processus utilisateur.
