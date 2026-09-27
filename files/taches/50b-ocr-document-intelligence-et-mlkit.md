# Tâche 50b — OCR : passer à Azure Document Intelligence

Lis `files/taches/PROTOCOLE.md`, `CLAUDE.md`, puis le RAPPORT de
`files/taches/50-photo-echantillon-et-ocr-azure.md` (ce qui existe déjà). Flutter + backend.
Pas de migration.

**Encodage** : UTF-8 sans BOM, `apply_patch` uniquement. Aucun « Ã© » / « â”€ » à la fin.
**Ne laisse jamais un fichier à moitié modifié.**

Contexte : l'ancienne version du projet utilisait **Azure Document Intelligence** (c'était le
meilleur résultat). La société n'a pas encore de compte Azure. Il faut :
1. revenir à **Document Intelligence** côté serveur (prêt à activer avec une clé) ;
2. **pas de ML Kit**, rien sur le téléphone.

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

## B — Application : bouton « Lire l'étiquette »

**Interdit : n'ajoute pas ML Kit ni aucune bibliothèque OCR sur le téléphone** (demande
explicite). Toute la lecture passe par le serveur (Azure Document Intelligence).
- Le bouton garde son comportement de la tâche 50 : grisé « Lecture automatique bientôt
  disponible » tant que `ocr/statut/` dit inactif ; actif → envoie la photo au serveur et
  pré-remplit les champs vides. Vérifie qu'il marche pareil dans les trois formulaires.

## C — Documentation

Mets à jour la section Azure de `docs/MISE-EN-SERVICE.md` : créer une ressource **Azure AI Document
Intelligence** (formule gratuite F0 possible) et remplir `AZURE_DOCINTEL_ENDPOINT` /
`AZURE_DOCINTEL_KEY`, redémarrer.

## Vérification

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Lance les tests Django `echantillons`
(si un test photo échoue par `PermissionError` de ton sandbox, dis-le simplement) et
`makemigrations --check --dry-run`. Claude lancera Flutter.

## RAPPORT

(Fait / Vérifié / Non fait / HORS PÉRIMÈTRE.)
