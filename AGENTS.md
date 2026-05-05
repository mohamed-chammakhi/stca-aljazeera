# AGENTS.md

Codex project instructions. This is the Codex equivalent of `CLAUDE.md`.
Keep this file as a lightweight index: load only the role/context file needed
for the current task.

## Always Do First

- Identify the role module or layer being changed before editing.
- Before frontend edits, follow the design system below and the relevant role
  file from `files/`.
- Before services, models, auth, API, Django, or offline-sync edits, read
  `files/backend.md`.
- Before backend implementation planning, read `files/backend_sprint_plan.md`.
- Preserve production quality. This is not a prototype app.

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
- Domain: collectors register olive oil samples across Tunisia; tasters receive
  and evaluate samples; lab technicians perform chemical analyses; CEO reviews
  results, approves purchases, and tracks stock delivery.
- State management: `StatefulWidget` + `setState()` only.
- Navigation: `Navigator.push()` / `pushReplacement()` with
  `MaterialPageRoute`; no named routes.
- Each role uses a `Drawer`.
- Data access: service classes only, never direct HTTP/data access in widgets.
- Current Flutter data is service-layer/mock unless connected to Django.
- Auth tokens: `flutter_secure_storage`, not `SharedPreferences`.
- `baseUrl` belongs only in `lib/config.dart`.

## Role Modules

| Module | Role | Read Before Editing |
| --- | --- | --- |
| `lib/1_ceo/` | Direction / CEO | `files/role_ceo.md` |
| `lib/2_collecteur/` | Collecteur | `files/role_collecteur.md` |
| `lib/3_degustateur/` | Degustateur | `files/role_degustateur.md` |
| `lib/4_laboratoire/` | Technicien Labo | `files/role_laboratoire.md` |
| `lib/5_chef_degustateur/` | Chef de Panel | `files/role_chef_degustateur.md` |
| Services / models / auth / offline sync | Shared backend integration | `files/backend.md` |
| Backend sprint order / API plan | Django backend | `files/backend_sprint_plan.md` |

Each role module follows this rough shape:

```text
<role>/<feature>/models/
<role>/<feature>/widgets/
<role>/<feature>/services/
```

## Design System

Use these shared colors unless the role file defines a role-specific wrapper:

```dart
const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _bg       = Color.fromARGB(255, 255, 255, 255);
const Color _white    = Color.fromARGB(255, 255, 255, 255);
```

Mandatory AppBar pattern:

```dart
AppBar(
  backgroundColor: _headerBg,
  elevation: 0,
  centerTitle: false,
  toolbarHeight: 65,
  title: Text(
    'Title',
    style: GoogleFonts.domine(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: _dark,
    ),
  ),
  iconTheme: const IconThemeData(color: _dark),
)
```

Page body layout:

1. Header zone: `Container(color: _headerBg)` with search and filter chips.
2. Divider: `Container(height: 1, color: Colors.black.withValues(alpha: 0.06))`.
3. Stats strip: `Container(color: _bg)` with count and clear-filter button.
4. List: `Expanded` scrollable on white.

Filter chip colors:

| State | Active | Inactive bg |
| --- | --- | --- |
| Tous | `0xFF616161` | `0xFFF0F0F0` |
| En attente / Receptionne | `0xFF3A6EA5` | `0xFFE8F1FB` |
| En cours / En negociation | `0xFFD07B2F` | `0xFFFEF3E8` |
| Soumis / Achat confirme | `0xFF38835A` | `0xFFE6F4ED` |

FAB: gray background `Color.fromARGB(255, 197, 206, 201)`, dark icon and
label.

Reference implementations:

- `lib/1_ceo/echantillons/echantillons_ceo_page.dart`
- `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`
- `lib/2_collecteur/carte_geo/services/geo_service.dart`
- `lib/core/api_client.dart`

## Core Data Rules

- All IDs are `String` UUIDs, never `int`.
- JSON keys must be `snake_case`.
- All models implement both `fromJson()` and `toJson()`.
- Lists from Django use `{ "count": N, "results": [...] }`.
- Dates use ISO 8601.
- File uploads use `multipart/form-data`.
- Assets are declared in `pubspec.yaml` under `assets/img/`.
- Linter currently allows `unused_local_variable`, `unused_import`, and
  `unused_element`.
- Debug login buttons in `lib/main.dart` are development-only and must be
  removed or gated before production.

## Sample Identity

For collector samples, do not confuse the three identifiers:

- `id`: UUID primary key.
- `numero`: app-generated sequence, JSON key `"numero"`, example `2025/0003`.
  It is read-only in Flutter and never typed by the collector.
- `reference_bouteille`: physical bottle label written by the collector. This
  is required in the creation form and editable.

`toJson()` for create/update must not send `numero`; the server assigns it.

## Sample Workflow Rules

Collector-facing states:

```text
Receptionne -> Receptionne (recu physiquement) -> En negociation -> Achat confirme
```

Lab-facing states:

```text
En attente -> En cours -> Soumis
```

Important edit-history rule:

- Once `recuPhysiquement = true`, edits must preserve old and new values in
  `editHistory`.
- This history must be visible to relevant roles.
- Collector offline writes are critical and must stay service-driven.

Deletion/editing guardrails:

- Collector can delete only their own samples while still at initial
  `receptionne` state.
- Taster / chef can delete only if the sample has not entered negotiation.
- CEO cannot register or directly modify samples.
- Lab technician does not register samples and only sees physically received
  samples.

## Backend Integration Rules

Before touching any service/model/API/auth/offline-sync code, read
`files/backend.md`.

Required pattern:

- Pages call service classes.
- Services call `ApiClient`.
- Services return models.
- Models parse/emit JSON.
- Never call HTTP directly in a widget, `build()`, or `initState()`.
- Store JWT tokens in `flutter_secure_storage`.
- Every authenticated request sends `Authorization: Bearer <token>`.
- Keep `// TODO: add token refresh logic` marker in `ApiClient` until refresh
  is implemented.

Django conventions:

- Backend uses `djangorestframework-simplejwt`.
- Errors use `{ "detail": "..." }` or `{ "field": ["error"] }`.
- Role permissions must be explicit: `IsCollecteur`, `IsDegustateur`,
  `IsLaboratoire`, `IsDirection`, `IsChefPanel`.

## Backend Sprint Order

When implementing backend work, follow `files/backend_sprint_plan.md`.

1. Sprint 1: Collector supplier/sample CRUD.
2. Sprint 2: Collector OCR, map, authentication.
3. Sprint 3: Taster reception, evaluations, sessions.
4. Sprint 4: Lab analysis and OCR.
5. Sprint 5: CEO and chef dashboards, approvals.
6. Sprint 6: Notifications, offline sync, messaging.

Important: start backend work with Collector core, not authentication. The
collector is the entry point of the data pipeline.

## Role-Specific Summary

CEO / Direction:

- Sees all samples, evaluations, lab analyses, purchases, map, dashboard,
  users, notifications, and profile.
- Approves/refuses samples from organoleptic analysis.
- Can manage users.
- Cannot register or directly modify samples.
- Read `files/role_ceo.md` for delivery display rules and notification
  deep-links.

Collecteur:

- Registers own samples and suppliers.
- Uses map of Tunisian delegations.
- Cannot see taster evaluations.
- Offline write queue is critical; sync belongs in `CollecteurSyncService`,
  never widgets.
- Read `files/role_collecteur.md` before touching sample creation, map,
  offline sync, or collector statuses.

Degustateur:

- Sees all samples.
- Can add/edit samples, toggle physical reception, and submit their own
  organoleptic evaluations.
- Submitted evaluations are read-only.
- Has tasting sessions, panel members, lab read-only view, dashboard, profile.
- Read `files/role_degustateur.md` for urgency and dashboard formulas.

Laboratoire:

- Two pages only: sample/analysis list and profile.
- Sees only samples where `recuPhysiquement = true`.
- Analysis can be entered manually or extracted from a paper report photo.
- Submitted analyses are read-only.
- Read `files/role_laboratoire.md`.

Chef de Panel:

- Senior taster plus panel manager.
- Same sample/evaluation capability as degustateur for their own evaluation.
- Exclusive overview of all tasters' evaluations, divergence detection,
  session approval/refusal, dashboards, notifications.
- Shared colors/navigation live under `lib/5_chef_degustateur/widgets/`.
- Read `files/role_chef_degustateur.md`.

## Notifications

Notifications are generated by Django signals for important events:

- `NOUVEL_ECHANTILLON`
- `ECHANTILLON_MODIFIE`
- `ECHANTILLON_SUPPRIME`
- `ECHANTILLON_RECU`
- `PREMIERE_EVALUATION`
- `TOUTES_EVALUATIONS`
- `ANALYSE_SOUMISE`
- `ACHAT_CONFIRME`

Role files define which notification types and deep-link sections apply to CEO
and chef de panel. Notification sections navigate to role-specific pages such as
echantillons, evaluations, analyses, achats, or sessions.

## Temporary Worktrees

The repo may contain temporary git worktrees under `.worktrees/`:

- `.worktrees/cleanup-ceo`
- `.worktrees/cleanup-degustateur`
- `.worktrees/cleanup-laboratoire`

These are comparison/refactor branches, not the canonical source. Use them only
for review or selective cherry-picking. Do not copy a whole worktree into
`main`; compare the relevant role folder against the main `lib/` version and
preserve newer main changes.
