# Tâche 46c — Tests restants (aucun changement de comportement)

Lis `files/taches/PROTOCOLE.md`, puis `CLAUDE.md`. **Tests seulement** : ne modifie pas
`lib/` sauf pour rendre un service injectable si un test l'exige (sans changer le
comportement par défaut). Fichiers en **UTF-8 sans BOM**, via `apply_patch`.

1. **Déconnexion** (tâche 46 A) : test widget — après la déconnexion partagée, la pile de
   navigation ne contient plus que la page de connexion, et le minuteur de 30 s d'une page
   précédente ne s'exécute plus.
2. **Photo** : tests Flutter avec un faux `ApiClient` / faux service :
   - `GestionEchantillonsService.createEchantillon` avec `photoAEnvoyer` → appel
     `postMultipart` ; sans photo → `post` JSON ;
   - `GestionEchantillonsService.updateEchantillon` avec `photoAEnvoyer` → `patchMultipart` ;
     sans photo → `patch` JSON ;
   - collecteur : `EchantillonCollecteurService.updateEchantillonWithImage` → `patchMultipart`.

Ton sandbox ne peut pas lancer Flutter : n'essaie pas. Claude lancera `flutter analyze lib
test` et `flutter test`.

## RAPPORT

### Fait

- `lib/core/services/gestion_echantillons_service.dart` — aucun changement visible : le service utilise toujours le client API partagé par défaut, mais accepte maintenant un faux `ApiClient` pour vérifier les requêtes en test.
- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart` — aucun changement visible : appel ajusté après retrait du constructeur `const` du service injectable.
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart` — aucun changement visible : appel ajusté après retrait du constructeur `const` du service injectable.
- `lib/core/widgets/messagerie/conversation_page.dart` — aucun changement visible : appel ajusté après retrait du constructeur `const` du service injectable.
- `lib/core/logout_navigation.dart` — aucun changement visible par défaut : la déconnexion partagée accepte une fonction de déconnexion injectée uniquement pour les tests.
- `test/gestion_echantillons_photo_service_test.dart` — ajoute les tests qui vérifient que `GestionEchantillonsService.createEchantillon` et `updateEchantillon` choisissent JSON sans photo et multipart avec photo.
- `test/echantillon_collecteur_service_test.dart` — ajoute le test qui vérifie que `EchantillonCollecteurService.updateEchantillonWithImage` envoie un `PATCH multipart`.
- `test/logout_navigation_test.dart` — ajoute le test widget qui vérifie que la déconnexion remplace toute la pile par `LoginPage` et dispose la page précédente avant son rafraîchissement de 30 s.

### Vérifié

```bash
git diff --check
```

Sortie brute :

```text
warning: in the working copy of 'files/taches/46c-tests-restants.md', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/core/logout_navigation.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/core/services/gestion_echantillons_service.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'lib/core/widgets/messagerie/conversation_page.dart', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'test/echantillon_collecteur_service_test.dart', LF will be replaced by CRLF the next time Git touches it
```

```bash
Get-ChildItem -Recurse -File lib,test | Select-String -Pattern 'const GestionEchantillonsService' | Select-Object Path,LineNumber,Line | Format-List
```

Sortie brute : aucune occurrence.

```bash
dart format lib/core/services/gestion_echantillons_service.dart lib/core/logout_navigation.dart
dart format test/gestion_echantillons_photo_service_test.dart test/echantillon_collecteur_service_test.dart test/logout_navigation_test.dart
dart format lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/core/widgets/messagerie/conversation_page.dart
```

Sortie brute : aucune sortie après 30 s pour chaque commande ; processus interrompus manuellement avec `Ctrl+C`, code de sortie `1`.

Non exécuté conformément à la consigne de la tâche : `flutter analyze lib test`, `flutter test`. Le sandbox ne peut pas lancer Flutter.

### Non fait

- Aucun test Flutter n'a été exécuté localement, conformément à la consigne.
- Aucun formatage Dart n'a abouti : `dart format` est resté bloqué sans sortie et a été interrompu.

### HORS PÉRIMÈTRE

- `git status --short` montre des fichiers non suivis hors de cette tâche, que je n'ai pas modifiés : `backend_new/backup_propre.json`, `backend_new/media/`, `backend_new/sauvegarde_avant_nettoyage_2026-09-25.json`, `files/taches/CONTROLE-MANUEL.md`.
