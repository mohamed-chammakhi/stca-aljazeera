# Tâche 30 — Messagerie : photos, référence à un échantillon, modifier/supprimer
# un message (backend uniquement)

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine.

Backend Django uniquement (`backend_new/`). Le frontend (bouton photo, sélecteur
d'échantillon, menu modifier/supprimer, navigation au clic sur une référence) est une
tâche séparée (31) qui suit celle-ci — ne touche à rien dans `lib/`.

Suite des tâches 28 et 29 (déjà terminées et commitées, vérifie `git log` avant de
commencer). Demande du propriétaire du projet, mot pour mot : « the users can like use
the reference of a sample in a chat in a way like you can copy a link and put it in chat
and then when the sender or the receiver click on it they get directed to that sample in
the page designed to do, also they can send pics when they want to any pics from gallery
or camera of course they can delete or modify messages ».

---

## Contexte — conventions déjà en place dans le projet, à réutiliser telles quelles

**Photo — même mécanique que la photo de bouteille du collecteur**
([`echantillons/views.py:120-133`](../../backend_new/echantillons/views.py#L120)) :
champ multipart nommé `image`, sauvegardé sur le stockage média local
(`default_storage.save('echantillons/<uuid><ext>', ...)`), l'URL résultante stockée
comme simple `CharField` (`image_url`, **pas** un `ImageField` Django). Reproduis
exactement ce schéma pour la messagerie : dossier `messages/` au lieu de
`echantillons/`, champ `photo_url` (`CharField(max_length=500, blank=True)`) sur
`Message`.

**Référence à un échantillon** — le modèle `Notification`
([`notifications/models.py`](../../backend_new/notifications/models.py)) a déjà un FK
optionnel vers `echantillons.Echantillon` (`on_delete=models.SET_NULL, null=True,
blank=True`) sans aucune vérification de permission particulière au-delà de
« l'utilisateur est authentifié ». Fais pareil sur `Message` : un FK `echantillon`
nullable, sans règle de propriété supplémentaire — le frontend (tâche 31) ne proposera
de toute façon que des échantillons que l'utilisateur peut déjà voir dans sa propre
liste ; ce n'est pas à cette tâche de recréer ce filtrage côté serveur.

## Contexte — état actuel vérifié dans le code

- [`messages_chat/models.py`](../../backend_new/messages_chat/models.py) : `Message`
  n'a que `expediteur`, `destinataire`, `contenu`, `lu`, `lu_le`, `date_envoi`. Pas de
  photo, pas de lien vers un échantillon, pas de suivi de modification.
- [`messages_chat/views.py`](../../backend_new/messages_chat/views.py) :
  `MessageDetailView(generics.RetrieveDestroyAPIView)` — **son `get_queryset()` filtre
  sur `Q(expediteur=user) | Q(destinataire=user))`, donc aujourd'hui le destinataire
  peut aussi supprimer un message qu'il n'a pas écrit.** C'est un bug à corriger dans
  cette tâche : seul l'expéditeur doit pouvoir supprimer son propre message.
- Pas d'endpoint de modification (`PATCH`/`PUT`) du contenu d'un message aujourd'hui.

---

## CONSIGNE

### 1. Modèle (`messages_chat/models.py`)

Ajoute au modèle `Message` :
- `photo_url = models.CharField(max_length=500, blank=True)`
- `echantillon = models.ForeignKey('echantillons.Echantillon', on_delete=models.SET_NULL, null=True, blank=True, related_name='messages')`
- `modifie = models.BooleanField(default=False)`
- `modifie_le = models.DateTimeField(null=True, blank=True)`

Génère la migration.

**Décision prise pour toi, à respecter :** un message doit garder au moins une des
deux choses — texte ou photo. Un message avec `contenu` vide n'est autorisé que s'il a
une photo. Un message avec `contenu` ET une photo est valide. Applique cette règle dans
la validation du serializer, pas dans le modèle (cohérent avec le reste de l'app, qui
valide côté serializer).

### 2. Upload de la photo (`messages_chat/views.py`)

Dans `MessageListCreateView.perform_create()`, reproduis exactement
`_store_bottle_photo()` de `echantillons/views.py` (champ multipart `image`, dossier
`messages/`) et pose `photo_url` sur l'instance créée si un fichier est fourni.

### 3. Référence à un échantillon — accepter l'ID à l'envoi

`MessageSerializer` doit accepter un champ `echantillon` (UUID, optionnel) en écriture,
et exposer en lecture `echantillon` (id), `echantillon_numero` et
`echantillon_reference_bouteille` (`SerializerMethodField`, lisant
`obj.echantillon.numero` / `obj.echantillon.reference_bouteille` si `obj.echantillon`
existe, sinon `None`) — pour que le frontend puisse afficher la référence sans un
second appel réseau.

### 4. Modifier un message

Nouvelle vue `MessageUpdateView` (ou transforme `MessageDetailView` en
`RetrieveUpdateDestroyAPIView` si c'est plus simple — à toi de juger), avec :
- seul l'**expéditeur** peut modifier son propre message (`get_queryset` filtré sur
  `expediteur=user` pour la modification, distinct du filtre `sent-or-received` qui
  reste pour la lecture)
- seul le champ `contenu` (et potentiellement remplacer/retirer la photo si tu veux
  aller jusque-là — **optionnel, pas obligatoire** : la demande du propriétaire est
  « modifier les messages », le texte suffit à satisfaire ça si le reste te semble trop
  pour cette tâche) est modifiable — jamais `destinataire`, jamais `echantillon`
- pose `modifie = True` et `modifie_le = timezone.now()` à chaque modification
  effective du `contenu`
- refuse (403) si l'utilisateur connecté n'est pas l'expéditeur

### 5. Supprimer un message — corriger le bug de permission

`MessageDetailView` (ou son équivalent après le point 4) : le `get_queryset()` utilisé
pour **DELETE** doit être restreint à `expediteur=user` uniquement. Le **GET** (lecture
d'un message) peut rester ouvert à l'expéditeur et au destinataire comme aujourd'hui —
c'est bien la suppression seule qui doit être resserrée. Si tu dois distinguer les deux
comportements dans une même vue, surcharge `get_queryset()` selon la méthode HTTP
(`self.request.method`), ou sépare en deux vues si c'est plus clair — à toi de choisir,
explique ton choix dans le rapport.

### 6. Tests

Ajoute des tests couvrant : envoi d'un message avec photo (multipart, vérifie
`photo_url` non vide et contient `messages/`) ; envoi avec `echantillon` (vérifie
`echantillon_numero` dans la réponse) ; refus d'un message sans `contenu` ni photo ;
modification du contenu par l'expéditeur (200, `modifie` passe à `True`,
`modifie_le` posé) ; refus de modification par le destinataire (403 ou 404 selon ton
choix, sois cohérent avec le reste de l'app) ; refus de modification de `destinataire`
ou `echantillon` via l'endpoint de modification (ignoré silencieusement ou rejeté — à
toi de choisir, mais documente-le) ; suppression par l'expéditeur (204) ; **suppression
refusée pour le destinataire** (c'est le bug corrigé — le test le plus important de
cette tâche).

---

## Ce que tu ne fais pas

- Tu ne touches à rien dans `lib/` — c'est la tâche 31.
- Tu ne recrées pas de filtrage « quels échantillons cet utilisateur peut référencer » —
  voir le contexte plus haut, ce n'est pas nécessaire côté serveur pour cette tâche.
- Tu ne touches pas aux règles de contact de la tâche 28 (`CONTACTS_AUTORISES`).
- Tu ne construis pas de suppression « pour moi seulement » façon certaines
  messageries — un message supprimé est supprimé pour tout le monde, comme le reste de
  l'app (suppression simple, pas de état par-utilisateur). Si ça te semble discutable,
  note-le dans le rapport, mais implémente cette version simple.

---

## Vérification à exécuter

```bash
cd backend_new
python manage.py makemigrations messages_chat
python manage.py migrate
python manage.py test messages_chat
python manage.py test
```

Donne les résultats chiffrés réels. Référence avant cette tâche : 179 tests sur la
suite complète, 0 échec.

## RAPPORT

Complète cette section : les champs ajoutés, la structure retenue pour
modifier/supprimer (une vue ou deux), les décisions prises (modification de la photo
incluse ou non, code de statut pour un refus de modification), les résultats chiffrés
réels des vérifications, et tout écart avec cette consigne.
