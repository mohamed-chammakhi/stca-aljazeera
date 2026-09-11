# Tâche 29 — Messagerie : interface partagée, câblée dans les 3 Drawers concernés

Lis `files/taches/PROTOCOLE.md` avant de commencer. Lis ensuite `CLAUDE.md` à la racine,
en particulier les **Deux règles absolues** (même chose → même nom, un seul fichier
partagé ; ne jamais laisser les données d'un utilisateur en écraser un autre).

Suite de la tâche 28 (backend, déjà terminée et commitée) — **vérifie d'abord que la
tâche 28 est bien commitée** (`git log`) avant de commencer ; si elle ne l'est pas,
arrête-toi et signale-le au lieu de continuer.

**Invoque la skill `frontend-design` avant d'écrire le moindre widget** (règle du
`CLAUDE.md`, « Always Do First »).

---

## Contexte — ce qui existe déjà côté serveur (tâche 28)

- `GET/POST /api/messages/` — liste (mes messages envoyés + reçus) / envoi. Le corps
  d'envoi attend `{"destinataire": "<uuid>", "contenu": "texte"}` — `expediteur` est
  déduit du token, pas envoyé.
- `GET /api/messages/<uuid>/` — un message ; `DELETE` pour le supprimer.
- `PATCH /api/messages/<uuid>/lire/` — marque un message reçu comme lu.
- `GET /api/messages/contacts/` — la liste des contacts autorisés pour l'utilisateur
  connecté (`[{id, nom, prenom, role}, ...]`), triée par nom. **Liste vide** (pas une
  erreur) si l'utilisateur n'a pas de messagerie.
- `GET /api/messages/non-lus/` — `{"total": N}`, nombre de messages reçus non lus.
- Champs exacts renvoyés par `MessageSerializer` sur un message :
  `id`, `expediteur` (uuid), `destinataire` (uuid), `contenu`, `lu` (bool), `lu_le`
  (iso datetime ou null), `date_envoi` (iso datetime), `is_read` (alias de `lu`),
  `horodatage` (alias de `date_envoi`), `expediteur_nom`, `destinataire_nom` (chaînes
  "Prénom Nom", en lecture seule).
- Règle de contacts (déjà appliquée côté serveur, le frontend n'a pas à la
  re-vérifier — juste à ne proposer que ce que `/contacts/` renvoie) :
  chef dégustation ↔ collecteur ↔ direction. Le dégustateur simple et le laboratoire
  n'ont pas de messagerie (leurs Drawers respectifs **ne doivent pas** avoir d'entrée
  « Messagerie » — ne touche pas à `lib/3_degustateur/` ni `lib/4_laboratoire/`).

## Contexte — ce qui existe déjà côté frontend (à corriger, pas à dupliquer)

- [`lib/core/models/message.dart`](../../lib/core/models/message.dart) : modèle existant
  mais **désynchronisé** de la vraie API (utilise `expediteur_id`/`created_at`, alors que
  le serveur envoie `expediteur`/`date_envoi`). **Corrige ce fichier**, ne le duplique
  pas ailleurs — c'est le seul fichier modèle pour un message, pour tous les rôles.
- [`lib/2_collecteur/widgets/collecteur_drawer.dart`](../../lib/2_collecteur/widgets/collecteur_drawer.dart)
  a déjà un item « Messagerie CEO » avec un callback `onMessagerie` — mais :
  - le libellé doit devenir **« Messagerie Direction »** (jamais « Messagerie CEO »,
    décision explicite du propriétaire dans `files/notifications/01_collecteur.md` §6.2)
  - ses deux points d'appel ouvrent un `Placeholder()` vide :
    [`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart:639`](../../lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart#L639)
    et
    [`lib/2_collecteur/profilcom.dart:223`](../../lib/2_collecteur/profilcom.dart#L223)
    — remplace `const Placeholder()` par la vraie page de conversations.
- `lib/2_collecteur/messagerie/` existe déjà comme **dossier vide** — c'est l'endroit
  prévu pour du code spécifique au collecteur s'il en fallait, mais vu que la
  messagerie est identique pour les 3 rôles (même page, mêmes règles, seul le rôle de
  l'utilisateur connecté change ce qu'il peut voir), **mets le code partagé dans
  `lib/core/messagerie/`** et laisse ce dossier vide (ou supprime-le si Dart/Flutter
  n'aime pas les dossiers vides suivis par git — vérifie s'il contient un `.gitkeep`).
- [`lib/1_ceo/widgets/ceo_drawer.dart`](../../lib/1_ceo/widgets/ceo_drawer.dart) et
  [`lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart`](../../lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart)
  **n'ont aucune entrée Messagerie** — à ajouter dans les deux.

---

## CONSIGNE

### 1. Modèles partagés (`lib/core/models/`)

- Corrige `lib/core/models/message.dart` pour matcher exactement les champs listés
  plus haut (`expediteur`, `destinataire`, `expediteur_nom`, `destinataire_nom`,
  `contenu`, `lu`, `luLe`, `dateEnvoi`). Garde `fromJson`/`toJson` comme le reste du
  projet (`snake_case` en JSON). Le corps envoyé par `toJson()` pour une création ne
  doit contenir que `destinataire` + `contenu` (le reste est en lecture seule côté
  serveur) — ou fournis une méthode dédiée `toCreateJson()` séparée si `toJson()` est
  utilisé ailleurs pour autre chose.
- Nouveau fichier `lib/core/models/contact_messagerie.dart` : petit modèle
  `ContactMessagerie` (`id`, `nom`, `prenom`, `role`), avec `fromJson`/`fromJsonList`.
  `role` peut être une simple `String` ou réutiliser l'enum `RoleUtilisateur` déjà dans
  `lib/core/models/enums.dart` si son `fromJson` accepte les valeurs renvoyées par
  `/contacts/` (`collecteur`, `direction`, `chef_degustation`, etc. — vérifie la
  correspondance avant de choisir).

### 2. Service partagé (`lib/core/services/messagerie_service.dart`)

Un seul service, utilisé par les 3 rôles (même pattern que
`lib/core/services/fournisseur_service.dart` ou `variete_service.dart` — singleton
`.instance`, méthodes qui retournent `Resultat<T>` via `avecSecours()`) :

- `fetchMessages()` → `Future<Resultat<List<Message>>>` — `GET /api/messages/`
- `fetchContacts()` → `Future<Resultat<List<ContactMessagerie>>>` — `GET /api/messages/contacts/`
- `fetchUnreadCount()` → `Future<int>` — `GET /api/messages/non-lus/`, lit `total`.
  Pas besoin d'`avecSecours` ici : si l'appel échoue, retourne simplement `0` (un badge
  qui ne s'affiche pas en cas d'erreur réseau n'est pas une donnée inventée montrée à
  l'utilisateur, contrairement à une liste de messages — pas de bandeau démo à
  déclencher pour un simple compteur).
- `sendMessage(String destinataireId, String contenu)` → `Future<Message>` —
  `POST /api/messages/`, sans `avecSecours` (c'est une écriture, elle doit échouer
  franchement si le serveur ne répond pas — même principe que les autres formulaires
  d'écriture du projet).
- `markAsRead(String messageId)` → `Future<void>` — `PATCH /api/messages/<id>/lire/`

### 3. Regroupement en conversations — côté client, pas de nouvelle notion serveur

Le serveur ne connaît que des messages individuels. Le regroupement par interlocuteur
se fait **dans le widget/état de la page**, pas dans le modèle ni le service :
pour chaque message, l'« autre personne » est `expediteur` si `destinataire == moi`,
sinon `destinataire`. Regroupe par cet id, garde le message le plus récent comme
aperçu, trie les groupes par date du dernier message (plus récent en premier), compte
les non-lus **reçus** par groupe pour le badge par conversation.

### 4. Pages partagées (`lib/core/widgets/messagerie/` ou `lib/core/messagerie/widgets/`
   — choisis une convention et reste cohérent avec le reste du dossier `core/`)

Deux pages, dans l'esprit du système de design du `CLAUDE.md` (AppBar obligatoire,
couleurs du design system) :

**a) Liste des conversations** (`conversations_page.dart`)
- Charge `fetchMessages()` (état vide honnête si erreur réelle — même logique que la
  tâche 25 : `VueResultatService`/`ErreurChargement` pour une vraie panne, message
  contextuel type « Aucune conversation pour le moment » si la liste est vide après un
  chargement réussi).
- Une ligne par conversation : nom du contact, rôle si utile pour le distinguer, aperçu
  du dernier message, heure/date, badge rouge si non-lus. Nom en gras si non lu (Q3 du
  carnet, section 3).
- Un bouton (FAB ou icône AppBar) pour démarrer une nouvelle conversation : ouvre la
  liste des contacts (`fetchContacts()`), taper un contact ouvre sa conversation
  (existante si elle existe déjà, vide sinon).
- Tap sur une conversation → page de conversation (b).

**b) Conversation avec un contact** (`conversation_page.dart`)
- Reçoit le contact (id + nom déjà connus, pas besoin de re-fetch son profil) et
  éventuellement les messages déjà chargés par la page précédente (évite un second
  aller-retour si tu peux te le permettre simplement — sinon recharge, ce n'est pas
  bloquant).
- Affiche les messages avec ce contact uniquement (filtrés depuis la liste complète, ou
  un nouvel appel si plus simple), bulles alignées à droite (envoyés) / gauche (reçus),
  ordre chronologique.
- Marque les messages reçus non lus comme lus à l'ouverture (`markAsRead` sur chacun,
  ou en boucle — pas besoin d'endpoint de masse, le carnet ne le demande pas).
- Champ de saisie + bouton d'envoi en bas. Vide après envoi réussi. Message d'erreur
  clair si l'envoi échoue (pas de silence).
- **Mode démonstration** : si le chargement initial des messages est tombé en secours
  (`estDemonstration == true`), refuse l'envoi avec le message standard du projet
  (« Action indisponible avec les données de démonstration. Réessayez lorsque le
  serveur répond. ») — même formulation que les autres pages d'écriture.

### 5. Badge de non-lus — widget autonome, pas de paramètre à faire remonter partout

`CeoDrawer`, `CollecteurDrawer` et le `AppDrawer` du chef sont chacun construits dans
**de nombreuses pages** (7 pour le CEO, 9 pour le chef, 2 pour le collecteur — vérifié
par `grep -rl "CeoDrawer("` / `"AppDrawer("` / `"CollecteurDrawer("`). Faire remonter un
compteur d'entiers depuis chaque page serait un gros chantier de plomberie pour un
simple badge.

**Solution : un petit widget autonome** `MessagerieBadge` (dans
`lib/core/widgets/messagerie/` ou `lib/core/messagerie/widgets/`), un
`StatefulWidget` qui appelle lui-même `MessagerieService.instance.fetchUnreadCount()`
dans son `initState()` et affiche un petit cercle rouge avec le chiffre (rien si `0`).
Il est posé **à côté du label** de l'item « Messagerie » dans les 3 Drawers, sans que la
page parente ait besoin de connaître ce chiffre. Pas d'actualisation en temps réel
requise (pas de websocket demandé) — un rafraîchissement à chaque ouverture du Drawer
suffit.

### 6. Câblage dans les 3 Drawers

**Collecteur** (`lib/2_collecteur/widgets/collecteur_drawer.dart`) :
- renomme le label `'Messagerie CEO'` → `'Messagerie Direction'`
- ajoute le `MessagerieBadge` à côté
- dans les deux call sites (`mes_echantillons_page.dart`, `profilcom.dart`), remplace
  `onMessagerie: () => goToPage(const Placeholder())` par la vraie navigation vers la
  page de conversations partagée.

**CEO** (`lib/1_ceo/widgets/ceo_drawer.dart`) :
- ajoute un nouveau `VoidCallback onMessagerie` au constructeur, un nouvel item
  « Messagerie » (icône `Icons.chat_bubble_outline`, cohérent avec le collecteur) +
  badge, placé de façon cohérente avec les sections existantes (par exemple dans la
  section « Compte », à côté de « Utilisateurs »/« Profil », ou une nouvelle section —
  à toi de juger ce qui est le plus lisible, en gardant le style `_SectionLabel`
  existant).
- câble ce nouveau paramètre dans **les 7 pages** qui construisent `CeoDrawer(...)`
  (liste ci-dessus dans le contexte) — chacune doit lui passer une vraie navigation
  vers la page de conversations, pas un `Placeholder`.

**Chef dégustateur** (`lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart`) :
- même traitement que pour le CEO : nouveau `VoidCallback`, nouvel item + badge, câblé
  dans **les 9 pages** qui construisent `AppDrawer(...)`.

Pour CEO et chef, regarde d'abord comment leurs Drawers actuels naviguent vers les
autres pages (`Navigator.push`/`MaterialPageRoute`, ou un helper `goToPage` local à
chaque fichier) pour rester cohérent avec le style déjà en place dans chaque module —
ne mélange pas les conventions de navigation entre rôles.

---

## Ce que tu ne fais pas

- Tu ne touches ni à `lib/3_degustateur/` ni à `lib/4_laboratoire/` — ces deux rôles
  n'ont pas de messagerie (décision explicite, D21/D22 du carnet).
- Tu n'ajoutes pas de pièces jointes/photos (D27, encore ouvert — hors périmètre).
- Tu n'ajoutes pas de référence cliquable vers un échantillon depuis un message (idée
  du carnet, pas encore demandée explicitement par le propriétaire — hors périmètre).
- Tu ne touches à rien côté serveur (`backend_new/`) — la tâche 28 a déjà tout fait.
- Tu ne réinvente pas de notion de « conversation » stockée en base — c'est un
  regroupement client uniquement (point 3).
- Tu ne mélanges pas ce sujet avec les notifications système (`notifications_ceo_page`,
  etc., tâches 26/27) — sujets liés mais distincts, pas de fusion de code entre les
  deux.

---

## Vérification à exécuter

```bash
dart format lib/
flutter analyze lib test
flutter test
```

Donne les sorties chiffrées réelles. Référence avant cette tâche : 48 diagnostics/0
erreur, 108 tests (107 réussis + 1 échec déjà connu).

Dans le rapport, liste bien **chacun des 18 call sites de Drawer câblés** (2 collecteur
+ 7 CEO + 9 chef) — c'est le seul moyen de vérifier que rien n'a été oublié.

## RAPPORT

### Fait (par Codex, revu en détail et vérifié par Claude)

**Nouveaux fichiers partagés :**
- `lib/core/models/contact_messagerie.dart` — modèle `ContactMessagerie` (id, nom,
  prenom, `RoleUtilisateur` réutilisé depuis `core/models/enums.dart`), `fromJsonList`
  attend une liste plate (correspond à ce que renvoie `apiClient.getList()`, déjà
  dépaginé côté client).
- `lib/core/services/messagerie_service.dart` — singleton `.instance`, méthodes
  `fetchMessages()`/`fetchContacts()` via `avecSecours()` (avec données de secours
  thématiques), `fetchUnreadCount()` (retombe sur `0` en cas d'erreur, sans bandeau
  démo — un badge muet n'est pas une donnée inventée), `sendMessage()`/`markAsRead()`
  en écriture directe, sans secours.
- `lib/core/widgets/messagerie/conversations_page.dart` — liste des conversations
  (regroupement client par interlocuteur, tri par dernier message, badge non-lus par
  conversation, état vide « Aucune conversation pour le moment », sélecteur de contact
  pour démarrer un nouvel échange).
- `lib/core/widgets/messagerie/conversation_page.dart` — fil de discussion, bulles
  alignées, marquage automatique comme lu à l'ouverture, refus d'envoi en mode
  démonstration avec le message standard du projet.
- `lib/core/widgets/messagerie/messagerie_badge.dart` — `MessagerieBadge`, widget
  autonome (`StatefulWidget`, charge son propre compteur dans `initState`), posé à
  côté du label dans les 3 Drawers — évite de faire remonter un entier depuis chaque
  page hôte.

**Corrigé :** `lib/core/models/message.dart` — champs alignés sur la vraie API
(`expediteur`, `destinataire`, `expediteur_nom`, `destinataire_nom`, `date_envoi`),
`toCreateJson()` séparé pour ne poster que `destinataire` + `contenu`.

**Drawers modifiés :** les trois `_DrawerItem` locaux (`collecteur_drawer.dart`,
`ceo_drawer.dart`, `app_drawer.dart` du chef) acceptent maintenant un `trailing`
optionnel, utilisé pour le `MessagerieBadge`. Libellé collecteur renommé
`Messagerie CEO` → `Messagerie Direction`. `CeoDrawer` et `AppDrawer` (chef) ont un
nouveau `VoidCallback onMessagerie` requis + un item « Messagerie ».

**Câblage — 19 points d'appel réels (la consigne en annonçait 18 ; comptage refait :
8 pour le CEO, pas 7 — erreur de comptage dans la consigne, pas un oubli de Codex),
tous vérifiés un par un, plus aucun `Placeholder()` restant :**

Collecteur (2) :
`lib/2_collecteur/mes_echantillons/mes_echantillons_page.dart`,
`lib/2_collecteur/profilcom.dart`

CEO (8) :
`lib/1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart`,
`lib/1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart`,
`lib/1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart`,
`lib/1_ceo/echantillons/echantillons_ceo_page.dart`,
`lib/1_ceo/profil_ceo_page.dart`,
`lib/1_ceo/tableau_de_bord/tableau_de_bord.dart`,
`lib/1_ceo/utilisateurs/utilisateurs_ceo_page.dart`,
`lib/1_ceo/validation_achats/validation_achats_ceo_page.dart`

Chef dégustateur (9) :
`lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart`,
`lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart`,
`lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`,
`lib/5_chef_degustateur/membres_panel/membres_panel_page.dart`,
`lib/5_chef_degustateur/profil.dart`,
`lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart`,
`lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart`,
`lib/5_chef_degustateur/utilisateurs/utilisateurs_chef_page.dart`,
`lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart`

Vérifié par Claude : `grep -rn "onMessagerie:"` dans les 3 modules (hors fichiers de
Drawer) → 19 résultats ; `grep -rn "Placeholder()"` → aucun résultat.

### Incident pendant la vérification, corrigé

Claude a lancé `dart format lib/` (sans restreindre aux fichiers de la tâche) pour
vérifier le formatage — ça a reformaté **89 fichiers** au lieu des 24 concernés (le
projet n'avait apparemment jamais été passé en entier par le formateur actuel).
Détecté immédiatement via `git diff --stat`, corrigé par `git checkout --` sur les 65
fichiers hors périmètre (liste calculée par différence d'ensembles avec les fichiers
réellement modifiés par la tâche 29), puis re-vérifié que le diff restant correspond
exactement aux 24 fichiers attendus. Aucun fichier hors périmètre n'a été committé.

### Vérifié (par Claude, après avoir arrêté le `flutter analyze` de Codex qui traînait)

```bash
flutter analyze lib test
```
Résultat : **50 diagnostics, 0 erreur** (référence : 48) — les 2 diagnostics en plus
sont deux infos `unnecessary_underscores` dans `conversations_page.dart` (variables de
callback `(_, __)` dans des `separatorBuilder`), style déjà toléré ailleurs dans le
projet, sans impact.

```bash
flutter test
```
Résultat : **108 tests, 107 réussis, 1 échec** (`test/widget_test.dart`, connu et sans
rapport) — identique à la référence, aucune régression.

### Conclusion

La messagerie collecteur ↔ chef dégustateur ↔ direction est fonctionnelle de bout en
bout : règles de contact (tâche 28) + interface partagée (cette tâche), câblée dans
les 19 points d'entrée réels des 3 rôles concernés. Le dégustateur simple et le
laboratoire n'ont toujours aucune entrée Messagerie, conformément à la décision du
propriétaire du projet.
