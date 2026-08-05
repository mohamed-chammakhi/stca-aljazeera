# Tâche 03 — Le changement de mot de passe doit marcher pour de vrai

## CONSIGNE

### Le problème

Les cinq pages Profil ont un bouton « Changer le mot de passe ». Il ouvre un dialogue, vérifie
les champs sur le téléphone, puis affiche **« Mot de passe changé avec succès »**.

Rien ne change. Aucune requête n'est envoyée.

Exemple : `lib/3_degustateur/profil/profil_page.dart`, bouton ligne 365, dialogue ligne 529,
message de succès ligne 640 — sans aucun appel de service entre les deux.

Et côté serveur, il n'existe **aucune** adresse pour changer un mot de passe. Le serializer de
mise à jour du profil rejette explicitement le champ `password`
(`backend_new/users/serializers.py`, vers les lignes 92 à 106).

**Décision du propriétaire :** le faire marcher pour de vrai.

---

### 1. Côté serveur — une nouvelle adresse

Crée `POST /api/users/me/changer-mot-de-passe/`, ouverte à **tout utilisateur connecté**
(`IsAuthenticated`), qui reçoit :

```json
{ "ancien_mot_de_passe": "...", "nouveau_mot_de_passe": "..." }
```

**Le serveur doit vérifier l'ancien mot de passe avant d'accepter.** C'est le point le plus
important de cette tâche. Sans cette vérification, quelqu'un qui trouve un téléphone déverrouillé
peut changer le mot de passe et prendre le compte. Utilise `user.check_password()` — le patron
existe déjà dans `users/serializers.py` vers la ligne 132.

Réponses attendues :

| Cas | Code | Message |
|---|---|---|
| Tout va bien | 200 | — |
| Ancien mot de passe faux | 400 | `{'code': 'password_incorrect', 'detail': 'Mot de passe actuel incorrect.'}` |
| Nouveau mot de passe trop faible | 400 | message expliquant la règle non respectée |
| Nouveau identique à l'ancien | 400 | `'Le nouveau mot de passe doit être différent de l'ancien.'` |

**Les règles du nouveau mot de passe doivent être exactement celles déjà appliquées à l'écran de
connexion** (`lib/main.dart`, fonction `_validatePassword`) : au moins 6 caractères, au moins un
chiffre, au moins un caractère spécial. Deux jeux de règles différents produiraient un mot de
passe accepté ici et refusé à la connexion.

**Ne déconnecte pas l'utilisateur après le changement.** Son jeton de connexion doit rester
valable — sinon il se retrouve à l'écran de connexion sans comprendre pourquoi, juste après avoir
réussi son changement.

---

### 2. Côté application — un service partagé

**Un seul endroit**, pas cinq. `lib/core/services/profile_service.dart` existe déjà et parle
correctement à l'API (`currentProfile`, `updateCurrentProfile`, `messageFor`). Ajoute-lui une
méthode :

```dart
Future<void> changerMotDePasse({
  required String ancien,
  required String nouveau,
});
```

Et complète `messageFor()` pour traduire le code `password_incorrect` en français clair :
**« Mot de passe actuel incorrect. »**

---

### 3. Côté application — les cinq pages Profil

Fichiers :
- `lib/1_ceo/profil_ceo_page.dart`
- `lib/2_collecteur/profilcom.dart`
- `lib/3_degustateur/profil/profil_page.dart`
- `lib/4_laboratoire/profil_labo_page.dart`
- `lib/5_chef_degustateur/profil.dart`

Dans chacune :

- le dialogue appelle `profileService.changerMotDePasse(...)` et **attend la réponse** ;
- le message « Mot de passe changé avec succès » ne s'affiche **qu'après** une réponse réussie ;
- en cas d'échec, le message d'erreur du serveur s'affiche à la place ;
- pendant l'attente, le bouton de validation est désactivé, pour éviter deux envois.

Les cinq dialogues sont aujourd'hui cinq copies du même code. **Si tu peux les remplacer par un
seul dialogue partagé** dans `lib/core/widgets/`, fais-le : c'est la règle 1 du `CLAUDE.md`, et
cinq copies dériveront tôt ou tard. Si les cinq versions ont des différences réelles que tu ne
sais pas trancher, écris une `## QUESTION` et ne fusionne pas.

---

### 4. Tests

**Django**, dans `backend_new/users/tests.py` :

1. changement avec le bon ancien mot de passe → 200, et l'utilisateur peut se connecter avec le
   nouveau ;
2. changement avec un mauvais ancien mot de passe → 400, et **l'ancien mot de passe fonctionne
   toujours** ;
3. nouveau mot de passe trop faible → 400 ;
4. nouveau mot de passe identique à l'ancien → 400 ;
5. utilisateur non connecté → 401.

**Flutter** : un test qui vérifie que le message de succès n'apparaît pas quand le service lève
une erreur.

---

### 5. Vérification

```bash
cd project3
flutter analyze lib test
flutter test
./backend_new/venv/Scripts/python.exe backend_new/manage.py test --keepdb
```

Repères à ne pas faire baisser : **139 tests Django au vert**, `flutter test` vert sauf
`widget_test.dart`.

**À la main, avec le backend lancé :**
1. changer son mot de passe → message de succès ;
2. rester sur l'écran : on ne doit **pas** être déconnecté ;
3. se déconnecter, se reconnecter avec le **nouveau** mot de passe → ça marche ;
4. recommencer en tapant un mauvais ancien mot de passe → message d'erreur clair, et l'ancien
   mot de passe fonctionne toujours.

---

### 6. Hors périmètre — à signaler, pas à corriger

`backend_new/users/serializers.py` vers la ligne 164 : à la création d'un compte, le serveur
utilise `'Test@12345'` comme mot de passe par défaut. Tous les comptes créés partagent donc le
même mot de passe, écrit en clair dans le code. C'est prévu plus tard, avec le reste de la
sécurité. Mentionne-le dans ton rapport, n'y touche pas.

---

## RAPPORT

### Fait

- `backend_new/users/serializers.py` — le nouveau mot de passe est refusé s'il n'a pas 6 caractères, un chiffre et un caractère spécial.
- `backend_new/users/views.py` — tout utilisateur connecté peut changer son propre mot de passe après vérification de l'actuel; un mot de passe identique est refusé et le JWT courant n'est pas révoqué.
- `backend_new/users/urls.py` — ajout de `POST /api/users/me/changer-mot-de-passe/`.
- `backend_new/users/tests.py` — tests de l'authentification obligatoire, du bon/mauvais mot de passe actuel, des trois règles de robustesse, du mot de passe identique et de la validité du même JWT après changement.
- `lib/core/services/profile_service.dart` — ajout de l'appel partagé `changerMotDePasse()` et traduction du code `password_incorrect` en « Mot de passe actuel incorrect. ».
- `lib/core/password_validation.dart` — règles de mot de passe partagées par la connexion et le changement de mot de passe.
- `lib/core/widgets/change_password_dialog.dart` — dialogue unique pour les cinq rôles; il attend le serveur, désactive Annuler/Enregistrer pendant l'envoi, conserve le dialogue en cas d'erreur et ne renvoie un succès qu'après la réponse.
- `lib/main.dart` — l'écran de connexion utilise le validateur partagé, sans changer les règles acceptées.
- `lib/1_ceo/profil_ceo_page.dart` — le profil direction ouvre le dialogue partagé et n'annonce le succès qu'après son résultat positif.
- `lib/2_collecteur/profilcom.dart` — même comportement réel pour le collecteur.
- `lib/3_degustateur/profil/profil_page.dart` — même comportement réel pour le dégustateur.
- `lib/4_laboratoire/profil_labo_page.dart` — même comportement réel pour le laboratoire.
- `lib/5_chef_degustateur/profil.dart` — même comportement réel pour le chef dégustateur.
- `test/profile_password_service_test.dart` — tests du chemin et du corps HTTP, de l'attente réelle, du message d'ancien mot de passe incorrect, des règles partagées et de l'absence de faux succès lors d'une erreur serveur.

### Vérifié

- `flutter analyze lib test` : code 1, **51 diagnostics préexistants** (11 avertissements, 40 informations), aucun nouveau diagnostic B2/B3.
- `flutter test test/profile_password_service_test.dart test/echantillon_collecteur_service_test.dart` : **5 tests réussis**.
- `flutter test` : **95 réussis, 1 échec**. Échec unique connu : `test/widget_test.dart:19`, `Expected: exactly one matching candidate`, `Actual: Found 0 widgets with text "0"`.
- `./venv/Scripts/python.exe manage.py test users --keepdb -v 1` depuis `backend_new/` : **25 tests réussis en 62,076 s**, `OK`.
- `./venv/Scripts/python.exe manage.py test echantillons users --keepdb -v 1` depuis `backend_new/` : **48 tests réussis en 245,708 s**, `OK`.
- Le test `test_change_password_checks_old_password_and_keeps_jwt_valid` réutilise exactement le jeton d'accès émis avant le changement pour appeler ensuite `/api/users/me/`; réponse 200.
- Une exécution intermédiaire des 25 tests utilisateurs a d'abord signalé **2 échecs** parce que DRF enveloppait `code` et `detail` dans des listes; la vue a été corrigée pour renvoyer exactement les chaînes demandées, puis les 25 tests ont été relancés avec succès.
- `./venv/Scripts/python.exe manage.py test --keepdb -v 1` : une exécution globale antérieure a réussi **153 tests en 638,576 s**. Après les derniers ajustements et quatre tests supplémentaires, la tentative globale finale est restée sans sortie et a été interrompue après **2 381,5 s**; aucun résultat global final n'est donc revendiqué. Les 48 tests des deux applications modifiées passent sur l'état final.
- `git diff --check` : aucune erreur d'espace; uniquement les avertissements de conversion LF/CRLF existants.

### Non fait

- Les quatre vérifications manuelles sur téléphone (changer, rester connecté, se reconnecter avec le nouveau, essayer un mauvais ancien) n'ont pas été exécutées : aucune session applicative authentifiée ni appareil de test n'a été utilisé.

### HORS PÉRIMÈTRE

- `backend_new/users/serializers.py:177` conserve le mot de passe par défaut partagé `Test@12345` lors de la création d'un compte. Il n'a pas été modifié, conformément à la consigne; sa correction reste prévue au lot sécurité.
