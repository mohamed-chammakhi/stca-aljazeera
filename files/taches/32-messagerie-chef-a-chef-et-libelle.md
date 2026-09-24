# Tâche 32 — Messagerie : chef dégustateur ↔ chef dégustateur, et correction
# du libellé chez le collecteur

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Backend Django + un seul fichier Flutter. Suite des tâches 28-31 (déjà terminées et
commitées — vérifie `git log` avant de commencer).

Demande du propriétaire du projet, mot pour mot : « messagerie for collector is not to
be called messagerie direction just messageire the people he is allowed to talk to are
only directeur and chef degustateur, so if another chef degustateur gets the app a new
chat box is gonna be open to him with that name, in this case the direction will have a
messagerie too (with collecteurs all but separately and chef degustateur) and the chef
degustateur is gonna have a messagerie too (with direction, collecteur all but
separately, chef degustateur (in case there is more than one chef)) ».

---

## Ce qui est déjà correct — ne pas y toucher

- Collecteur ↔ direction et collecteur ↔ chef dégustateur : **déjà en place**, rien à
  changer.
- Direction ↔ collecteurs et direction ↔ chefs dégustateurs : **déjà en place**, rien à
  changer.
- Une conversation par personne, pas par rôle — **déjà en place** (le modèle `Message`
  n'a qu'un `expediteur`/`destinataire` individuels ; la liste de contacts renvoie des
  personnes, pas des groupes ; `ConversationsPage` regroupe déjà côté client par id de
  contact individuel). Si un deuxième chef dégustateur rejoint l'entreprise, il apparaît
  déjà comme une entrée séparée dans `/api/messages/contacts/` et ouvre déjà sa propre
  conversation distincte — **c'est déjà le comportement actuel, ne rien reconstruire
  ici.**

## Ce qui manque réellement — le seul vrai changement de règle

**Un chef dégustateur ne peut aujourd'hui pas écrire à un autre chef dégustateur.**
Vérifié dans
[`backend_new/messages_chat/permissions.py`](../../backend_new/messages_chat/permissions.py) :

```python
CONTACTS_AUTORISES = {
    User.Role.CHEF_DEGUSTATION: [User.Role.COLLECTEUR, User.Role.DIRECTION],
    User.Role.COLLECTEUR: [User.Role.CHEF_DEGUSTATION, User.Role.DIRECTION],
    User.Role.DIRECTION: [User.Role.COLLECTEUR, User.Role.CHEF_DEGUSTATION],
}
```

Le propriétaire veut qu'un chef dégustateur puisse aussi écrire aux **autres** chefs
dégustateurs (utile s'il y en a plusieurs dans l'entreprise). Collecteur et direction,
eux, ne gagnent **aucun** nouveau contact — seul le chef dégustateur obtient son propre
rôle dans sa liste de contacts autorisés.

## CONSIGNE

### 1. Ajouter le chef dégustateur à sa propre liste de contacts

Dans `CONTACTS_AUTORISES`, ajoute `User.Role.CHEF_DEGUSTATION` à la liste déjà associée
à `User.Role.CHEF_DEGUSTATION` :

```python
CONTACTS_AUTORISES = {
    User.Role.CHEF_DEGUSTATION: [
        User.Role.COLLECTEUR,
        User.Role.DIRECTION,
        User.Role.CHEF_DEGUSTATION,
    ],
    User.Role.COLLECTEUR: [User.Role.CHEF_DEGUSTATION, User.Role.DIRECTION],
    User.Role.DIRECTION: [User.Role.COLLECTEUR, User.Role.CHEF_DEGUSTATION],
}
```

L'envoi d'un message à soi-même reste refusé par la vérification déjà en place dans
`MessageSerializer.validate_destinataire()` (`value == request.user`) — ne la touche
pas, elle suffit pour ce cas.

### 2. ⚠️ Bug révélé par ce changement — corrige-le dans la même tâche

`MessageContactsView.get_queryset()`
([`backend_new/messages_chat/views.py`](../../backend_new/messages_chat/views.py)) ne
s'excluait jamais lui-même de la liste, parce que jusqu'ici aucun rôle n'apparaissait
dans sa propre liste de contacts autorisés — ce n'était donc jamais visible. **Ça le
devient avec ce changement** : sans correction, un chef dégustateur se verrait
lui-même dans `GET /api/messages/contacts/`, et pourrait tenter de s'auto-sélectionner
comme contact (l'envoi serait refusé ensuite, mais l'entrée n'a rien à faire dans la
liste).

Corrige `get_queryset()` pour exclure l'utilisateur connecté de sa propre liste de
contacts, quel que soit son rôle :

```python
return User.objects.filter(
    is_active=True,
    role__in=roles_autorises,
).exclude(id=self.request.user.id).order_by('nom', 'prenom')
```

### 3. Tests

- Un chef dégustateur peut envoyer un message à un **autre** chef dégustateur (201).
- Un chef dégustateur ne peut toujours pas s'envoyer un message **à lui-même** (400,
  comportement déjà existant — juste confirmer qu'il tient toujours après le
  changement).
- `GET /api/messages/contacts/` pour un chef dégustateur inclut les **autres** chefs
  dégustateurs actifs, mais **jamais lui-même** — c'est le test qui couvre la
  correction du point 2.
- Confirme qu'un collecteur et un utilisateur direction ne voient toujours **pas**
  d'autres collecteurs / autres direction dans leur liste de contacts (pas de
  changement pour ces deux rôles — non-régression).

### 4. Libellé chez le collecteur

Dans
[`lib/2_collecteur/widgets/collecteur_drawer.dart`](../../lib/2_collecteur/widgets/collecteur_drawer.dart),
renomme l'item du Drawer `'Messagerie Direction'` → `'Messagerie'` (retour à un libellé
neutre, cohérent avec les items « Messagerie » des Drawers CEO et chef qui n'ont jamais
porté de nom de rôle). Ne touche à rien d'autre dans ce fichier.

---

## Ce que tu ne fais pas

- Tu n'ajoutes **aucun** nouveau contact pour le collecteur ni pour la direction — seul
  le chef dégustateur gagne un contact (lui-même, hors sa propre personne).
- Tu ne construis pas de messagerie de groupe — chaque chef supplémentaire reste une
  conversation individuelle séparée, exactement comme aujourd'hui pour les autres
  rôles.
- Tu ne touches à rien côté `ConversationsPage`/`ConversationPage`/`MessagerieBadge` —
  ces pages fonctionnent déjà correctement une fois la règle serveur et la liste de
  contacts corrigées, il n'y a rien à changer côté regroupement/affichage.
- Tu ne renommes aucun autre libellé « Messagerie » (CEO, chef) — seul celui du
  collecteur était erroné.

---

## Vérification à exécuter

```bash
cd backend_new
python manage.py test messages_chat
python manage.py test
```

```bash
dart format lib/2_collecteur/widgets/collecteur_drawer.dart
flutter analyze lib test
flutter test
```

⚠️ **Ne lance jamais `dart format` sur un dossier entier** — un seul fichier est
modifié dans cette tâche, formate-le seul, par son chemin exact.

Donne les sorties chiffrées réelles. Référence avant cette tâche : suite Django
complète à 187 tests (0 échec) ; Flutter : 55 diagnostics/0 erreur, 108 tests
(107 réussis + 1 échec déjà connu).

## RAPPORT

Complète cette section : le changement exact dans `CONTACTS_AUTORISES`, la correction
du `get_queryset()` et pourquoi elle était nécessaire, le résultat des tests ajoutés,
les résultats chiffrés réels des vérifications, et tout écart avec cette consigne.
