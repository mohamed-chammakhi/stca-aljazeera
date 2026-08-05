# Tâche 01 — Page Utilisateurs : le directeur consulte, le chef dégustateur gère

## CONSIGNE

### Pourquoi

Aujourd'hui la gestion des comptes appartient entièrement à la direction :
[utilisateurs_ceo_page.dart](../../lib/1_ceo/utilisateurs/widgets/utilisateurs_ceo_page.dart)
(1 048 lignes) permet de créer, activer, désactiver et supprimer un compte, et les cinq vues de
`backend_new/users/urls.py` sont toutes en `IsDirection`.

Le chef dégustateur n'a que « Membres du panel » — une liste en lecture seule.

Décision du propriétaire : **les rôles s'inversent sur cette page.**

| | Directeur | Chef dégustateur |
|---|---|---|
| Voir la liste et les détails | ✅ | ✅ |
| Créer un compte | ❌ *(à retirer)* | ✅ *(à ajouter)* |
| Activer / désactiver | ❌ *(à retirer)* | ✅ *(à ajouter)* |
| Supprimer | ❌ *(à retirer)* | ✅ *(à ajouter)* |

Les deux voient **la même page**, au thème et au tiroir de navigation près. Le directeur la voit
sans les boutons d'action.

---

### 1. Backend — inverser les permissions

Fichier : `backend_new/users/views.py`.
Les classes nécessaires existent déjà dans `backend_new/users/permissions.py` (`IsDirection`,
`IsChefDegustation`). N'en crée aucune.

| Vue | Aujourd'hui | Attendu |
|---|---|---|
| `UserListCreateView` | `IsDirection` | **GET** : `IsDirection \| IsChefDegustation` — **POST** : `IsChefDegustation` |
| `UserDetailView` | `IsDirection` | **GET** : `IsDirection \| IsChefDegustation` — **PUT/PATCH/DELETE** : `IsChefDegustation` |
| `UserToggleActiveView` | `IsDirection` | `IsChefDegustation` |
| `UserCreateView` | `IsDirection` | `IsChefDegustation` |

Sépare lecture et écriture avec `get_permissions()`. Le patron existe déjà dans
`backend_new/analyses/views.py:41-44` :

```python
def get_permissions(self):
    if self.request.method == 'POST':
        return [IsChefDegustation()]
    return [(IsDirection | IsChefDegustation)()]
```

**Garde-fou anti-verrouillage — obligatoire.** Si seul le chef peut créer des comptes et qu'il perd
le sien, plus personne ne peut en créer. Dans `UserToggleActiveView` et dans la suppression de
`UserDetailView` :

```python
if str(instance.id) == str(request.user.id):
    raise ValidationError({'detail': 'Vous ne pouvez pas désactiver ou supprimer votre propre compte.'})
```

Un chef **peut** en revanche désactiver ou supprimer un compte `direction` : c'est voulu, ne
l'empêche pas.

---

### 2. Une seule page, deux points d'entrée

La page fait 1 048 lignes. **Ne la duplique pas** — c'est la règle 1 du `CLAUDE.md`, et cette
duplication a déjà produit un bug réel entre `3_degustateur/` et `5_chef_degustateur/`.

Crée `lib/core/utilisateurs/` :

| Fichier | Contenu |
|---|---|
| `utilisateurs_page_body.dart` | Le corps actuel : recherche, filtres par rôle, liste, dialogues. Prend `peutGerer` en paramètre. |
| `utilisateurs_service.dart` | L'actuel `lib/1_ceo/utilisateurs/services/utilisateurs_ceo_service.dart`, déplacé tel quel — il est déjà propre (`avecSecours`, message de 403 déjà écrit). |
| `widgets/user_card.dart` | Déplacé depuis `1_ceo/utilisateurs/widgets/`. |
| `widgets/user_created_dialog.dart` | Idem. |

Un seul paramètre de capacité :

```dart
class UtilisateursPageBody extends StatefulWidget {
  /// Quand false, la page est en consultation : ni bouton d'ajout, ni bascule
  /// d'activation, ni suppression. Le serveur reste le vrai garde-fou.
  final bool peutGerer;
  ...
}
```

Ce que `peutGerer: false` masque, dans le fichier actuel :
- le `FloatingActionButton.extended` ligne 145 ;
- `_confirmToggleStatus` ligne 363 et `_confirmDelete` ligne 404, ainsi que les boutons qui les
  déclenchent dans `user_card.dart`.

Tout le reste — recherche, filtres, carte, détails — est identique pour les deux rôles.

**Nettoyage au passage :** ligne 31, `typedef AppUser = UserProfile;`. Deux noms pour la même chose.
Supprime l'alias, emploie `UserProfile` partout.

Crée ensuite **deux enveloppes minces**, qui fournissent le `Scaffold`, l'`AppBar`, le tiroir et le
thème de leur rôle :

- `lib/1_ceo/utilisateurs/utilisateurs_ceo_page.dart` → `UtilisateursPageBody(peutGerer: false)`,
  avec `CeoDrawer` et `CeoNavMixin`. **Garde le même chemin d'import qu'aujourd'hui** pour ne pas
  toucher aux appelants.
- `lib/5_chef_degustateur/utilisateurs/utilisateurs_chef_page.dart` →
  `UtilisateursPageBody(peutGerer: true)`, avec l'`AppDrawer` du chef et `ChefNavMixin`.

Respecte le système de design du `CLAUDE.md` : `AppBar` à `toolbarHeight: 65`, fond `_headerBg`,
titre en `GoogleFonts.domine`.

---

### 3. Entrée dans le tiroir du chef

`lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` expose déjà 9 rappels. Ajoute
`onUtilisateurs`, libellé **« Utilisateurs »**, juste après « Membres du panel ».

Ce tiroir est instancié dans **chaque page** du module chef : ajoute le rappel partout où
`AppDrawer(` apparaît sous `lib/5_chef_degustateur/`. Si tu en oublies un, la compilation échoue —
c'est voulu, aucune page ne peut être manquée.

- **Ne touche pas au tiroir du directeur.** Son entrée « Utilisateurs » existe déjà et pointera
  désormais vers la page en consultation.
- **Ne supprime pas « Membres du panel ».** Les deux pages coexistent : l'une suit la présence et
  l'activité du panel, l'autre gère les comptes.

---

### 4. Ce que voit le directeur

La page en consultation ne doit pas ressembler à une page cassée. Sous le titre, une ligne
discrète :

> *Consultation seule — la gestion des comptes appartient au chef dégustation.*

Sans elle, le directeur cherchera le bouton disparu.

---

### 5. Tests

**Backend**, dans `backend_new/users/tests.py` (14 tests aujourd'hui ; plusieurs vont devoir changer
de rôle attendu — adapte-les, n'en supprime aucun) :

1. un chef dégustateur crée un compte → 201 ;
2. un directeur tente de créer un compte → **403** ;
3. un directeur liste les utilisateurs → 200 ;
4. un chef liste les utilisateurs → 200 ;
5. un dégustateur simple liste les utilisateurs → 403 ;
6. un chef bascule l'activation d'un autre compte → 200 ;
7. un directeur tente de basculer une activation → 403 ;
8. un chef tente de se désactiver lui-même → **400** ;
9. un chef tente de se supprimer lui-même → **400**.

**Flutter**, un test de widget : `UtilisateursPageBody(peutGerer: false)` n'affiche ni bouton
d'ajout, ni bascule, ni suppression ; avec `peutGerer: true`, les trois sont présents.

---

### 6. Vérification

```bash
cd project3
flutter analyze lib test
flutter test
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Repères actuels à ne pas faire régresser : **139 tests Django au vert**, `flutter test` vert sauf
`widget_test.dart` (cassé avant ce chantier, prévu au lot 4).

---

### 7. Hors périmètre — à signaler, pas à corriger

`lib/1_ceo/utilisateurs/services/utilisateurs_ceo_service.dart:30` envoie un mot de passe par défaut
codé en dur, `'Test@12345'`, à chaque création de compte. C'est un vrai problème de sécurité, mais il
relève du lot 5 de [`plan_correction.md`](../plan_correction.md). Mentionne-le dans ton rapport et
n'y touche pas.

---

## RAPPORT

### Fait

- `backend_new/users/views.py` — le directeur peut consulter les comptes mais seul le chef dégustation peut les créer, les modifier, les activer, les désactiver ou les supprimer ; un chef ne peut ni désactiver ni supprimer son propre compte.
- `backend_new/users/tests.py` — les droits de consultation et de gestion, l’interdiction d’auto-verrouillage et la suppression volontaire d’un compte direction par le chef sont protégés par des tests API.
- `lib/core/utilisateurs/utilisateurs_page_body.dart` — les deux rôles partagent désormais la même recherche, les mêmes filtres, le même compteur, la même liste et les mêmes dialogues ; le directeur voit le message de consultation seule et aucune action de gestion.
- `lib/core/utilisateurs/utilisateurs_service.dart` — les deux rôles chargent et gèrent les utilisateurs par le même service réseau, avec le même secours de démonstration et les mêmes messages d’erreur.
- `lib/core/utilisateurs/widgets/user_card.dart` — une carte affiche toujours le détail du compte, mais ne montre la bascule d’activation et la suppression que lorsque le rôle peut gérer.
- `lib/core/utilisateurs/widgets/user_created_dialog.dart` — le chef conserve le dialogue de confirmation après création d’un compte depuis le composant partagé.
- `lib/1_ceo/utilisateurs/utilisateurs_ceo_page.dart` — nouvelle enveloppe direction au bon emplacement, avec AppBar de 65 px, tiroir direction et page partagée en consultation seule.
- `lib/5_chef_degustateur/utilisateurs/utilisateurs_chef_page.dart` — nouvelle enveloppe chef, avec AppBar de 65 px, tiroir chef et page partagée avec les trois actions de gestion.
- `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart` — l’entrée « Utilisateurs » apparaît juste après « Membres du panel », sans retirer cette dernière.
- `lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart` — le chef peut ouvrir « Utilisateurs » depuis le tableau de bord.
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` — le chef peut ouvrir « Utilisateurs » depuis la gestion des échantillons.
- `lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart` — le chef peut ouvrir « Utilisateurs » depuis ses évaluations.
- `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart` — le chef peut ouvrir « Utilisateurs » depuis les analyses laboratoire.
- `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart` — le chef peut ouvrir « Utilisateurs » depuis les sessions.
- `lib/5_chef_degustateur/membres_panel/membres_panel_page.dart` — le chef peut ouvrir « Utilisateurs » depuis « Membres du panel » ; les deux pages continuent de coexister.
- `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart` — le chef peut ouvrir « Utilisateurs » depuis la vue d’ensemble.
- `lib/5_chef_degustateur/profil.dart` — le chef peut ouvrir « Utilisateurs » depuis son profil.
- `lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart` — l’entrée direction ouvre la page déplacée en consultation seule.
- `lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart` — l’entrée direction ouvre la page déplacée en consultation seule.
- `lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart` — l’entrée direction ouvre la page déplacée en consultation seule.
- `lib/1_ceo/echantillons/echantillons_ceo_page.dart` — l’entrée direction ouvre la page déplacée en consultation seule.
- `lib/1_ceo/profil_ceo_page.dart` — l’entrée direction ouvre la page déplacée en consultation seule.
- `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` — l’entrée direction ouvre la page déplacée en consultation seule.
- `lib/1_ceo/validation_achats/validation_achats_ceo_page.dart` — l’entrée direction ouvre la page déplacée en consultation seule.
- `test/utilisateurs_page_body_test.dart` — vérifie que le directeur ne voit aucune des trois actions et que le chef les voit toutes.
- `lib/1_ceo/utilisateurs/services/utilisateurs_ceo_service.dart` — supprimé après déplacement vers le service partagé ; aucun second chemin n’est conservé.
- `lib/1_ceo/utilisateurs/widgets/user_card.dart` — supprimé après déplacement vers les widgets partagés.
- `lib/1_ceo/utilisateurs/widgets/user_created_dialog.dart` — supprimé après déplacement vers les widgets partagés.
- `lib/1_ceo/utilisateurs/widgets/utilisateurs_ceo_page.dart` — supprimé après séparation entre corps partagé et enveloppe direction à la racine de `utilisateurs/` ; aucun fichier de compatibilité n’est conservé.

### Vérifié

- `flutter analyze lib test` — exécuté ; code de sortie 1, résultat brut final : `51 issues found. (ran in 108.4s)`. Il y a 11 avertissements et 40 informations préexistants, sans erreur de compilation. Les deux avertissements `undefined_shown_name` concernent `lib/1_ceo/analyse_organoleptique/widgets/panel_widgets.dart:14` ; les autres diagnostics sont détaillés dans la sortie de la commande et ne concernent pas les nouveaux fichiers utilisateurs.
- `flutter test test/utilisateurs_page_body_test.dart` — exécuté : `2` tests, `All tests passed!`.
- `flutter test` — exécuté : `90` tests réussis, `1` échec. Échec exact connu : `test/widget_test.dart:19`, `Expected: exactly one matching candidate`, `Actual: Found 0 widgets with text "0"`; récapitulatif : `Some tests failed.`
- `./venv/Scripts/python.exe manage.py test users --keepdb` depuis `backend_new/` — exécuté : `Found 20 test(s)`, `Ran 20 tests in 51.877s`, `OK`.
- `./venv/Scripts/python.exe manage.py test --keepdb` depuis `backend_new/` — exécuté : `Found 149 test(s)`, `Ran 149 tests in 309.916s`, `OK`.
- `git diff --check` — exécuté sans sortie : aucune erreur d’espace dans le diff.
- Comptage brut par recherche : `AppDrawer_pages=9`, `onUtilisateurs_files=9`, `old_paths_or_AppUser_files=0`. Commandes basées sur `rg -l "drawer: AppDrawer\\("`, `rg -l "onUtilisateurs:"` et `rg -l "utilisateurs/widgets/utilisateurs_ceo_page|utilisateurs/services/utilisateurs_ceo_service|typedef AppUser|\\bAppUser\\b"`.

### Non fait

- Aucun élément demandé dans la consigne n’a été sauté.
- Aucun commit ni push n’a été effectué, conformément au protocole.
- La compétence `frontend-design` n’a pas été invoquée parce qu’elle n’existe pas dans cette session ; après autorisation explicite, le système de design de `CLAUDE.md` et ses pages de référence ont été appliqués directement.
- `test/widget_test.dart` n’a pas été corrigé : son échec est antérieur et réservé au lot 4.

### HORS PÉRIMÈTRE

- `lib/core/utilisateurs/utilisateurs_service.dart` conserve volontairement le mot de passe par défaut codé en dur `Test@12345` lors d’une création. Le fichier a été déplacé, mais ce défaut de sécurité n’a pas été corrigé puisqu’il relève du lot 5.
- `flutter analyze lib test` signale 51 diagnostics antérieurs hors de cette tâche, notamment les deux imports `show` inexistants dans `lib/1_ceo/analyse_organoleptique/widgets/panel_widgets.dart:14`. Aucun de ces diagnostics n’a été corrigé.
