# AGENTS.md

Codex project instructions. This is the Codex equivalent of `CLAUDE.md`.
Keep this file as a lightweight index and load only the context needed for the
current task.

## Always Do First

- Identify which role module or layer is being changed.
- Before frontend edits, follow the design system in `CLAUDE.md`.
- Before role-specific edits, read the matching role file from `files/`.
- Before services, models, auth, API, or offline-sync edits, read
  `files/backend.md`.

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
dart format lib/
flutter build apk --release
flutter build ios --release
```

## Project Snapshot

- Product: Flutter + Django app for Al Jazeera STCA olive oil sample evaluation
  and stock acquisition in Tunisia.
- UI language: French.
- Production app: avoid prototype shortcuts.
- State management: `StatefulWidget` + `setState()` only.
- Navigation: `Navigator.push()` / `pushReplacement()` with
  `MaterialPageRoute`; no named routes.
- Data access: service classes only, never direct HTTP/data access in widgets.
- Auth tokens: `flutter_secure_storage`, not `SharedPreferences`.

## Role Files - Load the One You Need

| Working on | Read |
| --- | --- |
| `lib/1_ceo/` | `files/role_ceo.md` |
| `lib/2_collecteur/` | `files/role_collecteur.md` |
| `lib/3_degustateur/` | `files/role_degustateur.md` |
| `lib/4_laboratoire/` | `files/role_laboratoire.md` |
| Services / models / auth / offline sync | `files/backend.md` |

## Key Rules

- All IDs are `String` UUIDs, never `int`.
- JSON keys must be `snake_case`.
- All models implement `fromJson()` and `toJson()`.
- Assets are declared in `pubspec.yaml` under `assets/img/`.
- `baseUrl` belongs in `lib/config.dart`.
- Collector offline writes are critical and must stay service-driven.
- Once `recuPhysiquement = true`, edits must preserve previous values in edit
  history visible to relevant roles.
- Debug login buttons in `lib/main.dart` are development-only and must be
  removed or gated before production.

## Reference Implementations

- `lib/1_ceo/echantillons/echantillons_ceo_page.dart`
- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`
- `lib/2_collecteur/carte_geo/services/geo_service.dart`
- `lib/core/api_client.dart`

## Temporary Worktrees

The repo may contain temporary git worktrees under `.worktrees/`:

- `.worktrees/cleanup-ceo`
- `.worktrees/cleanup-degustateur`
- `.worktrees/cleanup-laboratoire`

These are comparison/refactor branches, not the canonical source. Use them only
for review or selective cherry-picking. Do not copy a whole worktree into `main`;
compare the relevant role folder against the main `lib/` version and preserve
newer main changes.
