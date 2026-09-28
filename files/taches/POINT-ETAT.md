# Point d'état — à lire en premier sur un autre PC

Mis à jour le 28/09/2026 par Claude (PC principal). Ce fichier explique où en est le projet,
les règles de travail et ce qu'il reste à faire. Lis-le avant toute modification.

## 1. Dépôt GitHub et deux PC

- Dépôt : **https://github.com/mohamed-chammakhi/stca-aljazeera** (privé, transféré à Mohamed ;
  `takwachkkkk` garde le droit d'écriture). Remote git : `origin`.
- Branche principale : `main` — toujours stable, tests verts.
- Travail pas fini : dans une branche à part (aujourd'hui : `tache-50b-en-cours`).
- **Deux PC travaillent sur le même dépôt. Règles :**
  1. Avant de commencer et avant chaque envoi : `git pull --rebase origin main`.
  2. **Jamais** `git push --force`.
  3. En cas de conflit : s'arrêter et expliquer à l'utilisatrice, ne pas choisir seul.
- L'ancien dépôt `flutter-echantillons-app` est **périmé** (140 commits de retard) : ne plus l'utiliser.

## 2. Règles de travail (demandées par l'utilisatrice)

- Réponses **en français simple et court**. Ne dire « fait » qu'après vérification réelle.
- **Codex code, Claude vérifie** : Claude écrit une fiche de tâche dans `files/taches/NN-….md`,
  lance Codex (`bash files/taches/lancer_codex.sh NN fichier.md`), puis relit, teste et commite.
  Claude ne code lui-même que les petites corrections (≤ 20 lignes) — sauf si l'utilisatrice
  dit « fais-le toi-même ».
- Les nouvelles demandes vont **en bas** de `files/taches/FILE-ATTENTE.md` et se font dans l'ordre.
- **Même correction pour tous les rôles** qui partagent un écran (collecteur, dégustateur, chef,
  laboratoire, direction).
- Pas de fausses données : tout est branché sur le vrai serveur.
- Commiter quand les tests passent. Vérifier l'encodage (pas de « Ã© », pas de BOM).
- **OCR : uniquement Azure Document Intelligence côté serveur. Jamais ML Kit** ni autre OCR
  sur le téléphone (décision définitive).
- Ne jamais afficher de code d'erreur technique (« 400 », « 500 »…) à l'utilisateur.

## 3. Vérifications avant chaque commit

```
flutter analyze            # regarder les lignes « error - » (il reste des « info »/« warning » anciens)
flutter test               # 177 tests aujourd'hui
cd backend_new && python manage.py test      # tests Django
python manage.py makemigrations --check --dry-run
```

## 4. Ce qu'il reste à faire

1. **Tâche 50b** — branche `tache-50b-en-cours`, fiche
   `files/taches/50b-ocr-document-intelligence-et-mlkit.md` (section « REPRISE » à la fin) :
   le service serveur passe déjà par Azure Document Intelligence ; reste à mettre à jour les
   tests `EchantillonOcrApiTests`, la section Azure de `docs/MISE-EN-SERVICE.md`, lancer les
   tests, puis fusionner dans `main`.
   → Avant de commencer : `git checkout tache-50b-en-cours && git merge main`
   (la branche a été créée avant les deux derniers correctifs de connexion).
2. **Codex bloqué** depuis le 27/09 : « le modèle gpt-5.5 n'existe pas ou pas d'accès ».
   Vérifier l'abonnement ChatGPT / se reconnecter dans l'extension Codex.
3. Optionnel (à confirmer par l'utilisatrice) :
   - notifier le collecteur quand un achat est confirmé ou refusé ;
   - notifier le dégustateur quand sa session est approuvée ou refusée (fait en tâche 48 — à vérifier) ;
   - afficher la fin de la plage de dates de livraison dans le stock.
4. Côté société : configurer l'envoi d'emails Gmail (mot de passe d'application) et plus tard
   la clé Azure — voir `docs/MISE-EN-SERVICE.md`.

## 5. Dernières tâches faites (voir `git log`)

- 48 : sessions — nombre prévu, visibilité, droits du créateur, notifications, dates passées.
- 49 : sessions triées de la plus récente à la plus ancienne, statut écrit, filtres.
- Réception physique : plus de bandeau en double.
- 50 : même bloc photo par échantillon pour les 3 rôles (appareil photo / galerie) + bouton
  « Lire l'étiquette » (grisé tant qu'Azure n'est pas configuré).
- Connexion : messages clairs, plus aucun code HTTP affiché.

## 6. Installer le projet sur un nouveau PC

Ces éléments **ne sont pas sur GitHub** (volontairement) et doivent être recréés ou copiés :

- `backend_new/venv` : `python -m venv venv` puis `venv\Scripts\pip install -r requirements.txt`.
- `backend_new/.env` : partir de `backend_new/.env.example`.
- `backend_new/db.sqlite3` (la base) et `backend_new/media/` (photos) : à copier depuis le PC
  principal si on veut les mêmes données ; sinon `python manage.py migrate` crée une base vide.
- `lib/config.dart` : adresse du serveur pour l'application — fichier ignoré par git, à copier
  depuis le PC principal (avec le téléphone en USB + `adb reverse`, l'adresse est
  `http://127.0.0.1:8000`).
- Téléphone branché en USB : `adb reverse tcp:8000 tcp:8000`, puis
  `python manage.py runserver 0.0.0.0:8000`.

## 7. Comptes de test (base du PC principal)

- Direction : `direction@stca.tn` / `Test@123455`.
- Les autres comptes : voir la page Utilisateurs (direction ou chef).
