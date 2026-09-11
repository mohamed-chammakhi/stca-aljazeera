# Tâche 31 — Messagerie : bouton photo, référence à un échantillon,
# modifier/supprimer un message (frontend)

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la
racine, en particulier les **Deux règles absolues**.

**Invoque la skill `frontend-design` avant d'écrire le moindre widget.**

Suite de la tâche 30 (backend, déjà terminée et commitée — vérifie `git log` avant de
commencer). Construit par-dessus les tâches 28/29 (règles de contact + interface de
messagerie déjà en place et fonctionnelles).

---

## Contexte — ce que le backend expose déjà (tâche 30, vérifié)

`Message` (`MessageSerializer`) porte maintenant, en plus des champs déjà utilisés en
tâche 29 :
- `photo_url` (string, lecture seule, vide si pas de photo)
- `echantillon` (UUID, optionnel, écrit à la création uniquement)
- `echantillon_numero`, `echantillon_reference_bouteille` (strings, lecture seule,
  `null` si pas de référence — évite un second appel réseau pour afficher la
  référence)
- `modifie` (bool), `modifie_le` (datetime ISO ou `null`)

**Créer un message avec photo** : `POST /api/messages/` en `multipart/form-data`,
champ fichier nommé `image` (même convention que la photo de bouteille du collecteur),
plus les champs habituels (`destinataire`, `contenu`, `echantillon` en option). Un
message peut avoir seulement du texte, seulement une photo, ou les deux — mais pas
aucun des deux (refusé par le serveur avec une erreur explicite sur `contenu`).

**Modifier un message** : `PATCH /api/messages/<id>/`, uniquement `{"contenu": "..."}`
— refusé (403) si l'utilisateur connecté n'est pas l'expéditeur. `destinataire` et
`echantillon` ne peuvent pas être changés après l'envoi (400 si tenté).

**Supprimer un message** : `DELETE /api/messages/<id>/`, désormais réservé à
l'expéditeur (le destinataire recevra un 404 — c'était un bug de sécurité, corrigé en
tâche 30 : **ne construis pas de bouton « Supprimer » sur un message reçu**, l'API le
refuserait de toute façon).

## Contexte — ce qui existe déjà côté frontend, à réutiliser telles quelles

**Sélecteur photo Galerie/Appareil photo/Annuler** — motif déjà présent et à reproduire
à l'identique (mêmes libellés, mêmes icônes) :
[`lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart:131-170`](../../lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart#L131)
(`_choosePhotoSource`) + `_pickPhoto` juste au-dessus, avec `ImagePicker()` de
`package:image_picker/image_picker.dart` (déjà dans `pubspec.yaml`, déjà utilisé
ailleurs dans le projet — pas de nouvelle dépendance).

**Envoi multipart** — `apiClient.postMultipart(path, {bytes, filename, fileField,
fields})` existe déjà
([`lib/core/api_client.dart:262`](../../lib/core/api_client.dart#L262)), utilisé pour
la photo de bouteille
([`lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart:199`](../../lib/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart#L199)).
Réutilise-le tel quel pour l'envoi d'un message avec photo (`fileField: 'image'`,
`fields: {'destinataire': ..., 'contenu': ..., si présent 'echantillon': ...}`).

**Les pages de messagerie existantes** (tâche 29, à modifier, pas à dupliquer) :
- `lib/core/models/message.dart` — modèle à étendre (pas remplacer)
- `lib/core/services/messagerie_service.dart` — service à étendre
- `lib/core/widgets/messagerie/conversation_page.dart` — c'est ici que vivent le
  composeur (`_Composer`) et les bulles (`_MessageBubble`) à enrichir
- `lib/core/widgets/messagerie/conversations_page.dart` — liste des conversations,
  n'a normalement pas besoin de changer pour cette tâche

**Les 4 pages de liste d'échantillons, une par rôle concerné par la messagerie**
(+ CEO qui consulte, ne messagerie pas directement les échantillons mais doit pouvoir
recevoir une référence et y naviguer comme les autres) :
- `lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart` —
  `MesEchantillonsPage`
- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` —
  `GestionEchantillonsPage` (dégustateur — n'a pas de messagerie lui-même, mais la
  référence doit quand même fonctionner si un jour il en obtient une ; **laisse ce
  fichier de côté pour l'instant, seuls collecteur/chef/CEO ont une messagerie** —
  vérifie plutôt `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`)
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` —
  `GestionEchantillonsPage` (chef)
- `lib/1_ceo/echantillons/echantillons_ceo_page.dart` — `EchantillonsCeoPage`

Aucune de ces 4 classes n'accepte de paramètre au constructeur aujourd'hui
(`const XxxPage({super.key})`), et chacune a déjà un champ de recherche/filtre
(`TextEditingController` de recherche) utilisé pour filtrer la liste affichée.

---

## CONSIGNE

### 1. Modèle et service (`lib/core/models/message.dart`,
   `lib/core/services/messagerie_service.dart`)

- Étends `Message` avec `photoUrl` (`String?`), `echantillonId` (`String?`),
  `echantillonNumero` (`String?`), `echantillonReferenceBouteille` (`String?`),
  `modifie` (`bool`, défaut `false`), `modifieLe` (`String?`). Garde `fromJson` en
  `snake_case` côté JSON, cohérent avec le reste du modèle.
- `MessagerieService.sendMessage(...)` : fais-en une méthode qui accepte en plus,
  optionnellement, des `bytes`/`filename` de photo et un `echantillonId`. Si une photo
  est fournie, passe par `apiClient.postMultipart('/api/messages/', ...)` ; sinon garde
  l'appel JSON existant (`apiClient.post`). Les deux chemins doivent produire un
  `Message` correctement désérialisé en retour.
- Nouvelle méthode `editMessage(String id, String nouveauContenu)` →
  `apiClient.patch('/api/messages/$id/', {'contenu': nouveauContenu})` → `Message`.
- Nouvelle méthode `deleteMessage(String id)` → `apiClient.delete('/api/messages/$id/')`.

### 2. Composeur — bouton photo (`conversation_page.dart`, `_Composer`)

Ajoute un bouton icône (trombone ou appareil photo, à choisir selon ce qui rend le
mieux à côté du champ texte existant) qui ouvre le **même** sélecteur
Galerie/Appareil photo/Annuler que la photo de bouteille (reproduit, pas importé
directement — le composant du collecteur est privé à son fichier, mais le motif visuel
et les libellés doivent être identiques). Une fois une photo choisie, affiche un aperçu
miniature au-dessus du champ de texte, avec un moyen de l'annuler avant envoi. `_send()`
doit maintenant envoyer texte et/ou photo ensemble.

### 3. Composeur — référence à un échantillon

Ajoute un second bouton (trombone-échantillon, ou icône `Icons.inventory_2_outlined`)
qui ouvre un petit sélecteur d'échantillon : réutilise `apiClient.getList('/api/echantillons/')`
(déjà utilisé ailleurs dans le projet, pas besoin d'un nouveau service — vérifie s'il
existe déjà un modèle/service générique listant les échantillons visibles par
l'utilisateur connecté, et réutilise-le plutôt que d'en écrire un nouveau) pour
présenter une liste recherchable (numéro, référence bouteille, fournisseur). Sélectionner
un échantillon l'attache au message en préparation (affiché comme une petite carte
« pièce jointe » au-dessus du champ, avec un moyen de la retirer avant envoi) —
exactement le même traitement visuel que la pièce jointe photo, pas un second système.

### 4. Bulles de message — afficher photo et référence

Dans `_MessageBubble` :
- si `photoUrl` n'est pas vide : affiche l'image (`Image.network`, avec un espace
  réservé pendant le chargement et une icône d'erreur si l'URL échoue) ; tap → ouvre
  l'image en plein écran (une page simple avec `InteractiveViewer`, pas besoin d'un
  package supplémentaire).
- si `echantillonNumero` n'est pas nul : affiche une petite carte/chip cliquable dans
  la bulle (icône + numéro + référence bouteille), **avant** ou **après** le texte selon
  ce qui rend le mieux — au tap, appelle un callback `onOuvrirEchantillon(String id)`
  fourni par la page (voir point 6).
- si `modifie == true` : petit texte « modifié » à côté de l'heure, discret (même
  esprit que Messenger/WhatsApp).

### 5. Modifier / supprimer — menu sur ses propres messages

Sur un message **envoyé par l'utilisateur connecté** (`isSent == true`) uniquement —
**pas sur un message reçu**, l'API refuserait de toute façon (voir contexte) : ajoute
un geste (appui long, ou une petite icône qui apparaît au survol/tap selon ce qui est
cohérent avec le reste du design du projet) ouvrant un menu avec deux options :

- **Modifier** — ouvre un champ d'édition en place (ou une petite boîte de dialogue,
  à toi de choisir ce qui s'intègre le mieux visuellement) pré-rempli avec le texte
  actuel ; valide → `editMessage()` → remplace le message dans la liste locale avec la
  réponse du serveur (qui porte `modifie: true`).
- **Supprimer** — boîte de dialogue de confirmation (« Supprimer ce message ? », pas de
  retour possible) → `deleteMessage()` → retire le message de la liste locale en cas de
  succès.

Gère les erreurs des deux actions avec un message clair (pas de silence), même
formulation que le reste du projet pour les échecs réseau.

### 6. Navigation au clic sur une référence — un paramètre optionnel par page

Ajoute un paramètre constructeur optionnel à chacune des 3 pages concernées
(collecteur, chef, CEO — **pas** le dégustateur simple, voir contexte) :

```dart
const MesEchantillonsPage({super.key, this.referenceInitiale});
final String? referenceInitiale;
```

(même nom `referenceInitiale` dans les 3 fichiers — même chose, même nom, règle 1 du
`CLAUDE.md`). Dans `initState()` de chaque page, si `referenceInitiale != null`, pré-remplis
le contrôleur de recherche existant avec cette valeur avant le premier chargement/filtre
— la liste affichée atterrit donc déjà filtrée sur l'échantillon référencé, sans toucher
au mécanisme d'expansion des cartes existant.

Dans `conversation_page.dart`, le callback `onOuvrirEchantillon` (point 4) doit
naviguer vers la bonne page **selon le rôle de l'utilisateur qui clique** — pas le rôle
de qui a envoyé le message. `ConversationPage` doit donc connaître le rôle de
l'utilisateur connecté (vérifie si l'app a déjà un moyen simple d'y accéder localement
sans réseau — sinon appelle `authService.currentUser()` une fois et garde le résultat en
état local) pour choisir entre `MesEchantillonsPage`, `GestionEchantillonsPage` (chef)
ou `EchantillonsCeoPage`.

---

## Ce que tu ne fais pas

- Tu ne touches à rien côté serveur (`backend_new/`) — la tâche 30 a déjà tout fait.
- Tu ne construis pas de bouton « Supprimer »/« Modifier » sur un message reçu — l'API
  le refuse, l'UI ne doit même pas le proposer.
- Tu ne touches pas à `lib/3_degustateur/` ni `lib/4_laboratoire/` (pas de messagerie
  pour ces rôles, décision déjà actée en tâches 28/29).
- Tu ne remplaces pas le mécanisme d'expansion de carte existant sur les 3 pages de
  liste — tu te contentes de pré-remplir la recherche.
- Tu n'ajoutes pas de compression/redimensionnement d'image particulier au-delà de ce
  que fait déjà `ImagePicker` pour la photo de bouteille (`maxWidth: 2000,
  imageQuality: 90`) — réutilise les mêmes réglages, cohérence avec le reste du projet.

---

## Vérification à exécuter

```bash
dart format <uniquement les fichiers que tu as modifiés ou créés — jamais dart format lib/ ou lib/core/ en entier>
flutter analyze lib test
flutter test
```

⚠️ **Ne lance jamais `dart format` sur un dossier entier (`lib/`, `lib/core/`, etc.)** —
liste les fichiers un par un. Un lancement précédent sur ce projet a reformaté 89
fichiers hors périmètre par erreur ; corrigé, mais évite de reproduire l'incident.

Donne les sorties chiffrées réelles. Référence avant cette tâche : 50 diagnostics/0
erreur, 108 tests (107 réussis + 1 échec déjà connu).

## RAPPORT

Complète cette section : fichiers créés/modifiés, comment la photo et la référence sont
envoyées et affichées, comment modifier/supprimer sont exposés dans l'UI, la liste des
3 pages de liste modifiées avec leur nouveau paramètre, les résultats chiffrés réels
des vérifications, et tout écart avec cette consigne.
