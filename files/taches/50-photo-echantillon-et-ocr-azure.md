# Tâche 50 — Photo d'échantillon identique partout + OCR Azure prêt à activer

Lis `files/taches/PROTOCOLE.md` (dont « Même correction pour tous les rôles »), puis
`CLAUDE.md`. Flutter + backend. Pas de migration sauf nécessité (alors `## QUESTION`).

**Encodage** : UTF-8 sans BOM, modifie avec `apply_patch`, jamais `Set-Content`/`Out-File`.
Aucun « Ã© » / « â”€ » à la fin dans `lib` et `backend_new` (hors `venv`).
**Ne laisse jamais un fichier à moitié modifié** : termine une partie avant la suivante.

Formulaires concernés (bouton « Ajouter ») :
- collecteur : `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` (**référence**) ;
- dégustateur : `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` ;
- chef : `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart`.

## A — Photo : même fonctionnement que le collecteur

- Chez le collecteur, **chaque échantillon du formulaire a sa propre photo**. Le dégustateur et
  le chef doivent avoir **exactement le même bloc photo** (même emplacement, mêmes textes,
  même aperçu, possibilité de retirer / remplacer, une photo par échantillon).
- Le choix de la photo propose toujours **deux options** : **« Prendre une photo »**
  (appareil photo) et **« Importer depuis la galerie »**, dans les trois formulaires
  (y compris en modification).
- Factorise dans un widget commun sous `lib/core/widgets/` si ça évite trois copies ;
  les trois formulaires l'utilisent.
- La photo est bien envoyée au serveur à l'enregistrement (création **et** modification) pour
  les trois rôles, et s'affiche ensuite sur la carte / le détail.

## B — OCR de l'étiquette avec Azure, prêt à activer

La société utilisera **son propre compte Azure** plus tard ; il n'existe pas encore. Il faut
que tout soit prêt pour qu'il suffise de remplir le `.env` du serveur.

Historique utile : l'ancien OCR (local, easyocr) a été retiré au commit `f2b545e0`. Tu peux
lire `git show f2b545e0^:backend_new/core/ocr_service.py` et
`git show f2b545e0^:lib/2_collecteur/mes_echantillons/services/bottle_label_ocr_service.dart`,
et `git show 4882588b` (branchement retiré) pour reprendre la **logique d'extraction**
(quantité, citerne, fournisseur, rapprochement avec les fournisseurs connus). Ne remets
**pas** easyocr / paddleocr.

Serveur :
- Nouveau service `backend_new/core/ocr_azure.py` : appelle **Azure AI Vision — Read (Image
  Analysis 4.0, feature `read`)** en HTTP simple (`requests`, pas de SDK obligatoire),
  avec `AZURE_VISION_ENDPOINT` et `AZURE_VISION_KEY` lus dans les réglages/.env.
  Timeout court (15 s), pas de clé dans les logs.
- Endpoint `POST /api/echantillons/ocr/` (multipart, champ image) pour collecteur,
  dégustateur et chef : renvoie les champs pré-remplis (`reference_bouteille`, `variete`,
  `quantite`, `num_citerne`, `fournisseur_nom` si trouvés) + le texte brut lu.
- `GET /api/echantillons/ocr/statut/` → `{"actif": true/false}`.
- **Si les variables Azure sont vides** : l'endpoint OCR répond **503** avec
  `{"detail": "La lecture automatique n'est pas encore activée. Contactez l'administrateur."}`.
  Aucun plantage au démarrage.
- `backend_new/.env.example` : ajoute `AZURE_VISION_ENDPOINT=` et `AZURE_VISION_KEY=` vides,
  avec un commentaire.
- Tests serveur : statut actif/inactif ; 503 sans configuration ; avec un appel Azure
  **simulé** (mock de `requests.post`), les champs sont bien extraits ; rôles non autorisés → 403.

Application (les trois formulaires, dans le bloc photo commun) :
- Un bouton **« Lire l'étiquette »** à côté de la photo. Au démarrage du formulaire,
  l'application appelle `ocr/statut/` :
  - inactif → le bouton est affiché **grisé** avec le texte « Lecture automatique bientôt
    disponible » (pas d'erreur) ;
  - actif → le bouton envoie la photo, puis **pré-remplit** les champs vides trouvés ;
    l'utilisateur vérifie et corrige avant d'enregistrer. Rien n'est enregistré
    automatiquement. Message clair si rien n'est lu.

## C — Documentation

Dans `docs/MISE-EN-SERVICE.md`, ajoute une courte section **« Activer la lecture automatique
des étiquettes (Azure) »** : créer une ressource *Azure AI Vision* dans le compte de la
société, copier l'endpoint et la clé dans `backend_new/.env`, redémarrer le serveur,
vérifier que le bouton devient actif. En français simple, sans clé réelle.

## Vérification

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Lance les tests Django `echantillons`
et `makemigrations --check --dry-run`. Claude lancera Flutter.

## RAPPORT

### Fait

- `backend_new/core/ocr_azure.py` créé : le serveur peut appeler Azure AI Vision Read avec `AZURE_VISION_ENDPOINT` / `AZURE_VISION_KEY`, extraire les champs utiles de l'étiquette et rapprocher le fournisseur lu avec les fournisseurs connus.
- `backend_new/aljazeera_stca/settings.py` modifié : les deux variables Azure sont lues depuis `.env` avec une valeur vide par défaut, sans plantage au démarrage.
- `backend_new/.env.example` modifié : les deux variables Azure vides sont documentées.
- `backend_new/echantillons/views.py` et `backend_new/echantillons/urls.py` modifiés : ajout de `GET /api/echantillons/ocr/statut/` et `POST /api/echantillons/ocr/` pour collecteur, dégustateur et chef ; sans configuration Azure, l'OCR répond 503 avec le message demandé.
- `backend_new/echantillons/tests.py` modifié : ajout des tests statut actif/inactif, 503 sans configuration, extraction avec Azure simulé, rôles non autorisés à 403.
- `lib/core/services/bottle_label_ocr_service.dart` créé : l'application interroge le statut OCR et envoie la photo en multipart via `ApiClient`, sans HTTP direct dans les widgets.
- `lib/2_collecteur/mes_echantillons/widgets/dialogs/formulaire_dialog.dart` modifié : le choix photo propose `Prendre une photo` et `Importer depuis la galerie`, le bouton `Lire l'étiquette` préremplit les champs vides, et la photo remplacée en modification est envoyée au serveur.
- `lib/3_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` modifié : chaque bouteille a maintenant sa propre photo, le même choix photo, le même bouton OCR et l'envoi multipart par échantillon.
- `lib/5_chef_degustateur/gestion_echantillons/widgets/dialogs/formulaire_dialog.dart` modifié : même comportement que dégustateur, avec une photo et une lecture OCR par bouteille.
- `docs/MISE-EN-SERVICE.md` modifié : ajout de la section `Activer la lecture automatique des étiquettes (Azure)`.

### Vérifié

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test echantillons -v 1
```

```text
Ran 51 tests in 215.780s
FAILED (errors=1)
ERROR: test_patch_multipart_remplace_la_photo (echantillons.tests.PhotoModificationTests.test_patch_multipart_remplace_la_photo)
PermissionError: [WinError 5] Access is denied: 'C:\\Users\\takwa\\AppData\\Local\\Temp\\tmphnqysoxf\\echantillons'
Found 51 test(s).
System check identified no issues (1 silenced).
```

Relance en forçant `TMP/TEMP` dans le workspace :

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; $env:TMP=(Resolve-Path '.\media').Path; $env:TEMP=$env:TMP; .\venv\Scripts\python.exe manage.py test echantillons -v 1
```

```text
Ran 51 tests in 192.532s
FAILED (errors=1)
ERROR: test_patch_multipart_remplace_la_photo (echantillons.tests.PhotoModificationTests.test_patch_multipart_remplace_la_photo)
PermissionError: [WinError 5] Access is denied: 'C:\\Users\\takwa\\Desktop\\flash5\\more\\flutterpfe\\project3\\backend_new\\media\\tmp8o5hogfa\\echantillons'
Found 51 test(s).
System check identified no issues (1 silenced).
```

Tests OCR isolés :

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test echantillons.tests.EchantillonOcrApiTests -v 1
```

```text
Found 5 test(s).
Creating test database for alias 'default'...
.....
----------------------------------------------------------------------
Ran 5 tests in 21.447s

OK
Destroying test database for alias 'default'...
System check identified no issues (1 silenced).
```

Vérification migrations :

```bash
cd backend_new
$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run
```

```text
No changes detected
```

Je n'ai pas lancé Flutter, conformément à la consigne de vérification de cette tâche.

### Non fait

- `flutter analyze` / `flutter test` non lancés : la tâche dit explicitement que le sandbox ne peut pas lancer Flutter et demande de ne pas essayer.
- Aucune migration créée ni appliquée : `makemigrations --check --dry-run` indique `No changes detected`.

### HORS PÉRIMÈTRE

- La suite complète `echantillons` reste bloquée par `PhotoModificationTests.test_patch_multipart_remplace_la_photo`, qui force `MEDIA_ROOT=tempfile.mkdtemp()` puis échoue avec `PermissionError` à la création du dossier `echantillons` dans ce sandbox Windows. Je n'ai pas modifié ce test hors périmètre.
- `backend_new/media/` apparaît dans `git status` après les tests ; il contient des fichiers/dossiers générés par les tests photo, dont `tmp8o5hogfa` qui renvoie aussi `Access is denied` à l'inspection dans ce sandbox. Je ne l'ai pas supprimé pour ne pas risquer d'effacer un média local non suivi.
- `git status` montre des fichiers déjà présents/non liés à cette tâche (`files/taches/FILE-ATTENTE.md`, `backend_new/backup_propre.json`, `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json`, `files/taches/CONTROLE-MANUEL.md`). Je ne les ai pas modifiés.
