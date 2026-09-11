# Tâche 28 — Messagerie : règles de contacts par rôle, liste des contacts,
# compteur de non-lus (backend uniquement)

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Backend Django uniquement (`backend_new/`). Le frontend (les pages de conversation) est
une tâche séparée (29) qui viendra après celle-ci — ne touche à rien dans `lib/`.

---

## Contexte — décisions déjà tranchées par le propriétaire du projet

Décrites dans [`files/notifications/01_collecteur.md`](../notifications/01_collecteur.md)
§6.2 (Q2, Q3, Q4, Q5, Q10, Q11, Q12) — déjà tranché, ne redemande rien là-dessus :

- C'est une **messagerie générale** (page indépendante), **pas un fil par échantillon**.
- **Qui a une messagerie, et avec qui** :

  | Rôle | Messagerie ? | Contacts autorisés |
  |------|--------------|---------------------|
  | Chef dégustateur | ✅ oui | tous les **collecteurs** + tous les **direction** |
  | Collecteur | ✅ oui | tous les **chef dégustation** + tous les **direction** |
  | Direction (CEO) | ✅ oui | tous les **collecteurs** + tous les **chef dégustation** |
  | Dégustateur (simple) | ❌ non | — |
  | Laboratoire | ❌ non | — |

  « Maximum 2 chefs dégustateurs » dans le carnet signifie simplement qu'il n'y en a
  généralement que 1 ou 2 dans l'entreprise, pas une restriction à des individus
  précis — un collecteur peut écrire à **tous** les utilisateurs actifs du rôle
  `chef_degustation`, pas seulement certains.
- **Confidentialité (Q5)** : seuls les deux participants à un échange y ont accès. Le CEO
  ne peut pas lire une conversation collecteur ↔ chef à laquelle il ne participe pas, et
  inversement.
- **Notifications/non-lus (Q3)** : un badge doit pouvoir afficher le nombre de messages
  non lus (sur l'entrée « Messagerie » du Drawer, côté frontend — hors périmètre ici,
  mais l'API doit fournir ce chiffre).
- Le champ visible côté frontend s'appellera « Messagerie Direction » chez le collecteur
  (jamais « Messagerie CEO ») — c'est un détail de libellé frontend, pas un sujet de
  cette tâche, mais garde-le en tête si tu dois écrire des messages d'erreur.

## Contexte — état actuel vérifié dans le code

L'app `backend_new/messages_chat/` existe déjà et fonctionne, mais **sans aucune
restriction de contact** : n'importe quel utilisateur authentifié peut aujourd'hui
envoyer un message à n'importe quel autre (seul l'auto-envoi est refusé).

- [`messages_chat/models.py`](../../backend_new/messages_chat/models.py) : modèle
  `Message` simple (`expediteur`, `destinataire`, `contenu`, `lu`, `lu_le`,
  `date_envoi`). Ne change pas ce modèle.
- [`messages_chat/views.py`](../../backend_new/messages_chat/views.py) :
  `MessageListCreateView` (liste = mes messages envoyés/reçus, création),
  `MessageDetailView` (lecture/suppression d'UN message), `MessageMarkReadView`
  (marquer lu). Pas de notion de « conversation » — c'est voulu, le frontend regroupera
  par interlocuteur côté client.
- [`messages_chat/serializers.py`](../../backend_new/messages_chat/serializers.py) :
  `validate_destinataire()` ne vérifie que « existe, actif, pas soi-même ». **C'est ici
  qu'il faut ajouter la règle de contact.**
- [`messages_chat/urls.py`](../../backend_new/messages_chat/urls.py) : routes actuelles
  `''` (liste/création), `<uuid:pk>/lire/`, `<uuid:pk>/`.
- ⚠️ **Test existant à corriger** :
  [`messages_chat/tests.py:36`](../../backend_new/messages_chat/tests.py#L36)
  `test_user_can_send_message_and_sender_is_forced_from_token` fait envoyer un message
  par un utilisateur `DEGUSTATEUR` — **ce test va casser une fois la règle posée**,
  puisque le dégustateur simple n'a pas de messagerie. Change ce test pour utiliser un
  expéditeur `COLLECTEUR` ou `CHEF_DEGUSTATION` (rôles qui ont le droit), et ajoute un
  test séparé qui vérifie qu'un `DEGUSTATEUR` ou un `LABORATOIRE` qui tente d'envoyer un
  message se fait refuser.
- `User.Role` (`backend_new/users/models.py` ~ligne 24) :
  `DIRECTION`, `COLLECTEUR`, `DEGUSTATEUR`, `LABORATOIRE`, `CHEF_DEGUSTATION`,
  `RESPONSABLE_FINANCIER`. Le rôle `RESPONSABLE_FINANCIER` n'est mentionné nulle part
  dans le carnet de notifications — traite-le comme les rôles sans messagerie
  (`DEGUSTATEUR`/`LABORATOIRE`) par prudence, sans en faire une hypothèse cachée : note-le
  explicitement dans ton rapport comme une décision que tu as prise faute de préciser
  ailleurs.

---

## CONSIGNE

### 1. Fonction/mapping des contacts autorisés

Dans `messages_chat/` (nouveau fichier `permissions.py` ou directement dans
`serializers.py`/`views.py` selon ce qui te semble le plus propre, mais **une seule
fonction, réutilisée partout où la règle est nécessaire** — ne duplique pas cette table
trois fois) :

```python
CONTACTS_AUTORISES = {
    User.Role.CHEF_DEGUSTATION: [User.Role.COLLECTEUR, User.Role.DIRECTION],
    User.Role.COLLECTEUR:       [User.Role.CHEF_DEGUSTATION, User.Role.DIRECTION],
    User.Role.DIRECTION:        [User.Role.COLLECTEUR, User.Role.CHEF_DEGUSTATION],
}
```

Un rôle absent de ce mapping (dégustateur, laboratoire, responsable financier) n'a
**aucun** contact — ni envoi, ni réception dans les faits (personne n'est autorisé à
leur écrire non plus, puisqu'aucun rôle ne les liste comme contact).

### 2. `validate_destinataire()` — appliquer la règle

Dans `messages_chat/serializers.py`, en plus des vérifications déjà en place, vérifie
que le rôle du destinataire figure dans `CONTACTS_AUTORISES[expediteur.role]` — sinon
lève une `ValidationError` claire (« Vous ne pouvez pas écrire à ce contact. »).
Vérifie aussi que le rôle de l'expéditeur (l'utilisateur connecté) a une entrée dans
`CONTACTS_AUTORISES` du tout — sinon (dégustateur/labo/responsable financier), refuse
également, avec un message clair (« Vous n'avez pas de messagerie. »).

### 3. Nouvel endpoint — liste des contacts

`GET /api/messages/contacts/` — retourne les utilisateurs actifs dont le rôle est
autorisé comme contact pour l'utilisateur connecté (selon `CONTACTS_AUTORISES`), triés
par nom. Si l'utilisateur connecté n'a pas de messagerie, retourne une liste vide (pas
une erreur — c'est un état normal, pas un échec).

Champs utiles par contact : `id`, `nom`, `prenom`, `role`. Un serializer léger dédié
(`ContactSerializer` dans `messages_chat/serializers.py`) suffit — pas besoin de
réutiliser un serializer utilisateur existant s'il expose plus que nécessaire.

### 4. Nouvel endpoint — compteur de non-lus

`GET /api/messages/non-lus/` — retourne `{"total": N}`, le nombre de messages où
`destinataire = utilisateur connecté` et `lu = False`. Sert au badge du Drawer côté
frontend (tâche 29).

### 5. URLs

Ajoute les deux nouvelles routes dans `messages_chat/urls.py`, **avant** la route
`<uuid:pk>/` existante (sinon Django essaiera de parser `contacts` ou `non-lus` comme un
UUID et échouera) :
```python
path('contacts/', ...),
path('non-lus/', ...),
path('<uuid:pk>/lire/', ...),
path('<uuid:pk>/', ...),
```

### 6. Corriger le test cassé + ajouter les nouveaux

- Corrige `test_user_can_send_message_and_sender_is_forced_from_token` (voir plus haut).
- Ajoute des tests couvrant : un collecteur peut écrire à un chef et à la direction ;
  un chef peut écrire à un collecteur et à la direction ; la direction peut écrire aux
  deux ; un dégustateur ne peut pas envoyer (403 ou 400 selon ce que tu choisis, sois
  cohérent) ; un collecteur ne peut pas écrire à un autre collecteur (rôle non autorisé) ;
  `GET /api/messages/contacts/` renvoie la bonne liste pour un collecteur et une liste
  vide pour un dégustateur ; `GET /api/messages/non-lus/` renvoie le bon compte et ne
  compte pas les messages déjà lus ni ceux envoyés (pas reçus) par l'utilisateur.

---

## Ce que tu ne fais pas

- Tu ne touches à rien dans `lib/` (Flutter) — c'est la tâche 29.
- Tu ne crées pas de notion de « conversation »/« thread » côté modèle — le frontend
  regroupera par interlocuteur à partir de la liste plate de messages.
- Tu n'ajoutes pas les pièces jointes (D27, encore ouvert dans le carnet — hors
  périmètre).
- Tu ne touches pas aux notifications existantes (`notifications_chat` app, tâches 26/27)
  — sujet différent, pas de lien de code entre les deux.
- Tu ne changes pas le modèle `Message` existant.

---

## Vérification à exécuter

```bash
cd backend_new
python manage.py test messages_chat
python manage.py test
```

Donne les résultats chiffrés réels des deux commandes (la suite complète, pas seulement
`messages_chat`, pour confirmer l'absence de régression ailleurs — référence avant cette
tâche : 80 tests sur `notifications echantillons analyses` seuls, le total complet de
l'app est plus grand, donne le vrai chiffre).

## RAPPORT

### Fait (par Codex, revu et vérifié par Claude)

- `backend_new/messages_chat/permissions.py` (nouveau) : table `CONTACTS_AUTORISES`
  (chef dégustation ↔ collecteur + direction, collecteur ↔ chef + direction,
  direction ↔ collecteur + chef) et la fonction `roles_contacts_autorises(user)`,
  réutilisée à la fois par `validate_destinataire()` (serializers.py) et par
  `MessageContactsView` (views.py) — une seule source de vérité.
- `RESPONSABLE_FINANCIER` : absent de `CONTACTS_AUTORISES`, retombe donc naturellement
  sur `roles_contacts_autorises() == []` — traité comme le dégustateur et le
  laboratoire (aucune messagerie), par défaut du `.get(role, [])`, sans cas spécial
  écrit. Conforme à la décision prise dans la consigne.
- `messages_chat/serializers.py` : `validate_destinataire()` refuse maintenant un
  expéditeur sans rôle autorisé (« Vous n'avez pas de messagerie. ») et un destinataire
  dont le rôle n'est pas dans la liste autorisée (« Vous ne pouvez pas écrire à ce
  contact. »). Nouveau `ContactSerializer` (`id`, `nom`, `prenom`, `role`).
- `messages_chat/views.py` : `MessageContactsView` (`GET /api/messages/contacts/`,
  liste vide si pas de messagerie, triée par nom/prénom) et `MessageUnreadCountView`
  (`GET /api/messages/non-lus/`, `{"total": N}`, ne compte que les messages reçus non
  lus).
- `messages_chat/urls.py` : `contacts/` et `non-lus/` ajoutées **avant**
  `<uuid:pk>/lire/` et `<uuid:pk>/`, dans cet ordre — évite que Django tente de parser
  ces mots comme un UUID.
- `messages_chat/tests.py` : le test cassé (`test_user_can_send_message_and_sender_is_forced_from_token`)
  corrigé pour utiliser un expéditeur `COLLECTEUR`. Nouveaux tests : matrice complète
  des envois autorisés (chef/collecteur/direction dans les deux sens), refus pour
  dégustateur et laboratoire (avec message d'erreur exact vérifié), refus
  collecteur→collecteur, `/contacts/` correct pour un collecteur et vide pour un
  dégustateur (utilisateur inactif exclu), `/non-lus/` ne compte que les messages
  reçus et non lus.

### Vérifié

Codex a lancé `manage.py test` (suite complète) en parallèle de la vérification de
Claude — les deux tournant en même temps sur la même base SQLite de test, le process
Codex a été arrêté pour éviter une collision, après relecture complète et validation du
diff (correct et conforme à la consigne).

```bash
cd backend_new
python manage.py test
```
Résultat (exécuté par Claude) : **179 tests, 0 échec** (1225.5s / ~20 minutes). Aucune
régression sur le reste de l'app.

### Conclusion

Les règles de contacts, la liste de contacts et le compteur de non-lus sont en place et
testés côté serveur. Le frontend (tâche 29) peut maintenant construire l'interface par
dessus cette API.
