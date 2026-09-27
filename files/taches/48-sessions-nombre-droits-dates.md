# Tâche 48 — Sessions de dégustation : nombre d'échantillons, droits, dates passées

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`. Flutter + backend. Pas de migration sauf si c'est indispensable (alors
`## QUESTION`).

**Encodage** : fichiers en **UTF-8 sans BOM**, modifie avec `apply_patch`, jamais
`Set-Content`/`Out-File`. À la fin, aucun « Ã© », « Ã¨ » ou « â”€ » dans `lib` et
`backend_new` (hors `venv`).
**Ne laisse jamais un fichier à moitié modifié** : termine une partie avant la suivante.

Chaque correction s'applique au **dégustateur** (`lib/3_degustateur/sessions_degustation/`)
**et** au **chef** (`lib/5_chef_degustateur/sessions_degustation/`), ainsi qu'au code commun
(`lib/core/widgets/sessions_degustation/`, `lib/core/models/session_degustation.dart`).

## A — Nombre d'échantillons toujours à 0

Le formulaire envoie bien `nombre_echantillons_prevus`, mais la carte affiche
`nbEchantillons` (= `echantillonIds.length`, les échantillons liés, souvent 0).
- La carte et le détail affichent le **nombre prévu** saisi (`nombreEchantillonsPrevus`).
  S'il est vide : n'affiche pas la ligne (ou « Non précisé »).
- Vérifie par un test serveur que la valeur envoyée est bien enregistrée et renvoyée,
  et par un test Flutter que la carte affiche 6 quand on saisit 6.

## B — Visibilité des sessions

- Une session **en attente de validation** n'est visible que par **son créateur** et par
  **le chef dégustateur**.
- Une fois **approuvée** (planifiée / en cours / terminée), elle est visible par les
  **membres concernés** : ses participants, ou **tous les dégustateurs et le chef** si
  la session n'a **aucun participant**. Le créateur la voit toujours.
- Une session **refusée** reste visible par son créateur seulement, avec le statut « Refusée ».
- Le chef voit toutes les sessions sauf les refusées (comme aujourd'hui).
- À faire côté serveur (`get_queryset` de la liste **et** du détail) ; tests serveur.

## C — Modifier / supprimer : créateur seulement

- Seul **le créateur** d'une session peut la modifier ou la supprimer (y compris le chef :
  le chef ne modifie/supprime que les sessions **qu'il a créées** ; il garde
  approuver / refuser pour les autres). Serveur : 403 sinon. Application : les boutons
  Modifier / Supprimer n'apparaissent que pour le créateur.
- Si un **dégustateur** modifie la **date ou l'heure** d'une session **déjà approuvée**,
  elle repasse **« en attente de validation »** (le chef doit la réapprouver). Changer
  seulement titre, lieu, notes, nombre ou participants ne change pas le statut.
- Une session créée par le chef reste planifiée après modification (pas de validation).

## D — Notifications

Utilise le système de notifications existant (`backend_new/notifications`). Les
« membres concernés » = participants, ou tous les dégustateurs et le chef actifs non
supprimés si aucun participant. On ne notifie jamais l'auteur de l'action.
- **Approbation** par le chef → les membres concernés sont notifiés (« Nouvelle session :
  <titre> le JJ/MM/AAAA à HH:MM »), plus le créateur (« Votre session a été approuvée »).
- **Refus** → le créateur est notifié.
- **Modification** d'une session approuvée → membres concernés notifiés du changement.
  Si elle repasse en attente (date/heure changée) → membres notifiés que la session
  **n'est plus prévue** pour l'instant, et le chef notifié qu'une session attend sa validation.
- **Suppression** d'une session approuvée → membres concernés notifiés (« Session
  annulée : <titre> »).
- Session en attente modifiée / supprimée → seul le chef est notifié.
- Tests serveur pour chaque cas (qui reçoit, qui ne reçoit pas).

## E — Dates passées

- **Création / modification** : refuser une date + heure **déjà passées** (heure locale du
  serveur, `Africa/Tunis`) — ex. le 27/09 à 10 h, 08 h le même jour est refusé.
  Serveur (400 avec message clair) **et** application (le sélecteur n'offre pas les jours
  passés ; message « La date et l'heure doivent être dans le futur »).
- **Confirmer sa présence** (bouton ✓) : refusé si la session est **déjà passée**
  (date + heure < maintenant). Serveur 400 ; application : le bouton ✓ n'apparaît pas
  (ou est désactivé) pour une session passée.
- Une session passée s'affiche comme **« Terminée »** (calculé à l'affichage ou côté
  serveur, sans tâche planifiée).

## F — Message d'erreur du bouton ✓

Aujourd'hui l'application affiche toujours « L'action n'a pas pu être enregistrée. » et
cache la vraie raison. Affiche le **message `detail` du serveur** quand il existe
(ex. « Cette session n'est pas encore approuvée par le chef. », « Cette session est déjà
passée. », « Vous ne faites pas partie des participants de cette session. »), en
français correct avec accents. Le bouton ✓ n'apparaît que si l'action est possible
(session approuvée, non passée, l'utilisateur est concerné).

## Vérification

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Lance les tests Django
`sessions_degustation notifications` et `makemigrations --check --dry-run`. Claude lancera
Flutter.

## RAPPORT

### Fait

- `backend_new/sessions_degustation/serializers.py` : l'API refuse les créations/modifications avec une date + heure passées, renvoie les sessions passées comme `terminee`, conserve et renvoie `nombre_echantillons_prevus`, et expose les droits `can_modifier`, `can_supprimer`, `can_confirmer_presence` pour que l'application masque les actions impossibles.
- `backend_new/sessions_degustation/views.py` : la liste et le détail appliquent les règles de visibilité par créateur, chef, participants et sessions ouvertes ; seuls les créateurs peuvent modifier/supprimer ; une modification date/heure par un dégustateur remet une session approuvée en attente ; la présence est refusée sur session non approuvée, passée ou hors participants ; les notifications de session sont envoyées aux bons destinataires.
- `backend_new/notifications/signals.py` : les destinataires de notifications existants excluent aussi les comptes supprimés.
- `backend_new/sessions_degustation/tests.py` : ajout des tests serveur pour le nombre prévu, la visibilité liste/détail, les droits de modification/suppression, les transitions de statut, les dates passées, la présence et les notifications de session.
- `backend_new/notifications/tests.py` : dates de test de session mises hors du passé pour rester compatibles avec la nouvelle validation.
- `lib/core/models/enums.dart` : le statut `refusee` est reconnu et affiché comme `Refusée`.
- `lib/core/models/session_degustation.dart` : le modèle lit les droits `can_*`, reconnaît une session passée côté app, et distingue le nombre prévu du nombre d'échantillons liés.
- `lib/core/services/sessions_service.dart` : les champs calculés `can_*` ne sont pas renvoyés dans les payloads de création/modification.
- `lib/core/widgets/sessions_degustation/session_card.dart` : la carte affiche le nombre d'échantillons prévu, masque le bouton de présence quand l'action est impossible, et laisse les boutons modifier/supprimer dépendre des droits fournis par la page/API.
- `lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart` : les boutons modifier/supprimer/présence suivent les droits de la session, les sessions passées ne proposent plus la présence, et les erreurs serveur `detail` sont affichées.
- `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart` : mêmes règles de droits/actions et affichage du vrai message serveur côté chef.
- `lib/3_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart` : le calendrier commence à aujourd'hui et l'enregistrement refuse une date + heure passées avec le message demandé.
- `lib/5_chef_degustateur/sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart` : même validation locale côté chef.
- `test/session_presence_card_test.dart` : ajout du test Flutter de carte qui vérifie qu'une session prévue à 6 échantillons affiche `6 échantillons` même sans échantillon lié.

### Vérifié

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test sessions_degustation notifications
```

Sortie :

```text
Found 42 test(s).
System check identified no issues (1 silenced).
Ran 42 tests in 431.259s
OK
```

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run
```

Sortie :

```text
No changes detected
```

Après une petite correction sur les destinataires de suppression :

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test sessions_degustation
```

Sortie :

```text
Found 21 test(s).
System check identified no issues (1 silenced).
Ran 21 tests in 158.248s
OK
```

Contrôle encodage demandé :

```bash
$patterns = @("ÃƒÂ©","ÃƒÂ¨","Ã¢â€â‚¬"); Get-ChildItem -Recurse lib,backend_new -File | Where-Object { $_.FullName -notmatch "\\venv\\" } | Select-String -SimpleMatch -Pattern $patterns -List | ForEach-Object { $_.Path }
```

Sortie : aucune ligne.

### Non fait

- Flutter non lancé, conformément à la consigne de la tâche. Le test Flutter a été ajouté mais pas exécuté ici.
- Aucune migration créée ni appliquée : `makemigrations --check --dry-run` indique `No changes detected`.

### HORS PÉRIMÈTRE

- L'arbre contenait déjà des éléments non liés avant intervention : `files/taches/FILE-ATTENTE.md`, `backend_new/backup_propre.json`, `backend_new/media/`, `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json`, `files/taches/CONTROLE-MANUEL.md`. Je ne les ai pas modifiés.
