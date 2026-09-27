# Tâche 50b — OCR : Azure Document Intelligence + lecture sur le téléphone (ML Kit)

Lis `files/taches/PROTOCOLE.md`, `CLAUDE.md`, puis le RAPPORT de
`files/taches/50-photo-echantillon-et-ocr-azure.md` (ce qui existe déjà). Flutter + backend.
Pas de migration.

**Encodage** : UTF-8 sans BOM, `apply_patch` uniquement. Aucun « Ã© » / « â”€ » à la fin.
**Ne laisse jamais un fichier à moitié modifié.**

Contexte : l'ancienne version du projet utilisait **Azure Document Intelligence** (c'était le
meilleur résultat). La société n'a pas encore de compte Azure. Il faut :
1. revenir à **Document Intelligence** côté serveur (prêt à activer avec une clé) ;
2. une lecture qui **marche dès aujourd'hui sans clé** : **Google ML Kit** sur le téléphone.

## A — Serveur : Document Intelligence au lieu de AI Vision

- Remplace l'appel Azure AI Vision de `backend_new/core/ocr_azure.py` par **Azure AI
  Document Intelligence**, modèle **`prebuilt-read`** (API REST
  `…/documentintelligence/documentModels/prebuilt-read:analyze?api-version=2024-11-30`,
  réponse asynchrone : lire l'en-tête `Operation-Location` puis interroger jusqu'à
  `succeeded`, 15 s au total maximum). HTTP simple avec `requests`.
- Variables : `AZURE_DOCINTEL_ENDPOINT` et `AZURE_DOCINTEL_KEY` (remplacent
  `AZURE_VISION_*` dans `settings.py`, `.env.example` et la doc). Vides → OCR serveur inactif
  (503 comme aujourd'hui, `ocr/statut/` → `actif: false`).
- La logique d'extraction des champs reste la même (sur les lignes lues).
- Tests serveur mis à jour : appel Azure simulé (POST puis GET de l'opération), inactif,
  délai dépassé → 503 propre.

## B — Téléphone : ML Kit hors ligne

- Ajoute `google_mlkit_text_recognition` (script latin) au `pubspec.yaml`.
- Le bouton **« Lire l'étiquette »** des trois formulaires (collecteur, dégustateur, chef) :
  1. si `ocr/statut/` dit **actif** → envoie la photo au serveur (Azure) ;
     si le serveur échoue → bascule sur ML Kit ;
  2. sinon → **ML Kit sur le téléphone**, puis envoie le **texte lu** au serveur pour
     l'extraction des champs : nouvel endpoint `POST /api/echantillons/ocr/texte/`
     (`{"texte": "..."}`, mêmes rôles, même réponse que `ocr/`), qui réutilise la même
     logique d'extraction + le rapprochement fournisseur. Cet endpoint marche **sans Azure**.
- Le bouton n'est donc **plus grisé** : il marche toujours sur Android/iOS. Sur une
  plateforme sans ML Kit (web, Windows), s'il n'y a pas Azure → grisé « Lecture non
  disponible sur cet appareil ».
- Pré-remplissage : seulement les champs vides ; l'utilisateur vérifie avant d'enregistrer.
  Message « Aucun texte lisible » si rien n'est trouvé.
- Tests : serveur pour `ocr/texte/` (extraction, rôles 403, texte vide 400) ; Flutter pour
  le choix du chemin (Azure actif / inactif) avec un faux service.

## C — Documentation

Mets à jour la section Azure de `docs/MISE-EN-SERVICE.md` : la lecture marche déjà sur le
téléphone ; pour une meilleure précision, créer une ressource **Azure AI Document
Intelligence** (formule gratuite F0 possible) et remplir `AZURE_DOCINTEL_ENDPOINT` /
`AZURE_DOCINTEL_KEY`, redémarrer.

## Vérification

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Lance les tests Django `echantillons`
(si un test photo échoue par `PermissionError` de ton sandbox, dis-le simplement) et
`makemigrations --check --dry-run`. Claude lancera Flutter.

## RAPPORT

(Fait / Vérifié / Non fait / HORS PÉRIMÈTRE.)
