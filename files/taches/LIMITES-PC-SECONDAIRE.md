# Limites du PC secondaire (GitHub Copilot)

Écrit le 28/09/2026 par l'agent qui travaille sur le **PC secondaire** (dossier
`C:\Users\medch\Desktop\takwa\stca-repo`). À lire par le PC principal avant de lui confier
une tâche ou de relire son travail.

## 1. Ce que ce PC ne peut pas faire

- **Flutter absent** : pas de `flutter analyze`, `flutter test`, ni de construction d'APK.
  Toute modification Flutter faite ici doit être vérifiée sur le PC principal.
- **Pas de téléphone** : pas d'`adb`, pas d'essai à l'écran.
- **Copie partielle du dépôt** (connexion très lente) : clone `--filter=blob:none` avec
  *sparse checkout*. Seuls ces chemins sont présents :
  `backend_new/**/*.py`, `backend_new/requirements.txt`, `backend_new/.env.example`,
  `docs/MISE-EN-SERVICE.md`, `files/taches/*.md`, `CLAUDE.md`,
  `lib/2_collecteur/mes_echantillons/widgets/dialogs/`,
  `lib/3_degustateur/gestion_echantillons/`, `lib/5_chef_degustateur/gestion_echantillons/`.
  Tout autre fichier doit d'abord être ajouté au *sparse checkout* (téléchargement lent).
- **Pas les données réelles** : pas de `db.sqlite3`, `media/`, `.env` ni `lib/config.dart`.
  Les tests Django tournent sur une base de test vide.
- **Codex indisponible ici** : l'agent code lui-même, en petites modifications.

## 2. Ce que ce PC peut faire

- Lire et modifier le code (Django, Dart) et la documentation présents.
- Lancer les tests Django (`backend_new/venv`, recréé ici) et
  `makemigrations --check --dry-run`.
- Commiter, fusionner et pousser sur GitHub (jamais `--force`,
  toujours `git pull --rebase origin main` avant).

## 3. Règles respectées (rappel)

Celles de `CLAUDE.md`, `files/taches/PROTOCOLE.md` et `files/taches/POINT-ETAT.md` :
pas de ML Kit ni d'OCR sur le téléphone, pas de fausses données, pas de code d'erreur
technique affiché, même correction pour tous les rôles, arrêt et question en cas de conflit.
