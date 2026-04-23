# CLAUDE.md

## Always Do First
- **Invoke the `frontend-design` skill** before writing any frontend code, every session, no exceptions.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands
```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter analyze          # Run linter (flutter_lints)
flutter test             # Run tests
dart format lib/         # Format code
flutter build apk --release   # Build Android
flutter build ios --release   # Build iOS
```

## Architecture

**Domain:** Multi-role olive oil sample evaluation and stock acquisition management system for **Al Jazeera STCA**, a Tunisian olive oil production and distribution company. The app manages the full lifecycle of olive oil samples — from collection and registration, through sensory and laboratory analysis, to purchase confirmation and stock acquisition. UI is in French.

**Four user roles**, each with their own isolated module under `lib/`:

| # | Module | Role | French |
|---|--------|------|--------|
| `1_ceo/` | Direction/CEO | Approvals, KPIs, user management | Directeur |
| `2_collecteur/` | Sample Collector | Sample registration, geo mapping, negotiation | Collecteur |
| `3_degustateur/` | Taster (Panel Member) | Tasting sessions, sensory evaluations | Dégustateur |
| `4_laboratoire/` | Lab Technician | Lab analyses, reports | Technicien Labo |

Each role module follows this internal structure:
<role>/
<feature>/
models/        # Plain Dart classes with fromJson() factories
widgets/       # Reusable UI components (cards, dialogs, forms)
services/      # Business logic (e.g., GeoService singleton)
widgets/         # Role-level shared widgets (e.g., *_drawer.dart)

**State management:** Local `StatefulWidget` + `setState()` only — no Provider, Riverpod, BLoC, or GetX. Data is passed via constructor and callbacks.

**Navigation:** `Navigator.push()` / `pushReplacement()` with `MaterialPageRoute` or `PageRouteBuilder`. Each role uses a `Drawer` for internal navigation. No named routes or go_router.

**Entry point:** [lib/main.dart](lib/main.dart) contains `MyApp`, global theme (green `#38835A`, cream `#F9F6EF`, Google Fonts Domine/Alegreya), and the login page. The login page has **4 debug buttons** that bypass auth and jump directly to each role's dashboard — these must be removed before production.

**Geospatial:** `GeoService` (singleton at `lib/2_collecteur/carte_geo/services/geo_service.dart`) parses `assets/img/delegations.geojson` for Tunisian delegation zones rendered via `flutter_map`.

**Data:** All data is currently mock/hardcoded in pages. No HTTP client, no Firebase, no local DB. Backend integration is TODO (`main.dart` login has `// TODO: replace with real API call`).

**Map API key:** Stored in [lib/config.dart](lib/config.dart) as `mapTilerApiKey`.

---

## Project Status

**This is a real-life, production-bound application** being built for an actual client — Al Jazeera STCA. It is not a demo, prototype, or academic exercise. All decisions (architecture, data modeling, service layer, auth, offline sync) must reflect production quality. The app will be deployed to real users across multiple roles. Shortcuts that would be acceptable in a prototype are not acceptable here.

---

## Business Context

Al Jazeera STCA collects olive oil samples from external suppliers across Tunisia. Each sample goes through a structured evaluation process. If accepted, the company negotiates and purchases the full stock, then processes, packages, and distributes it under their own brand.

---

## Actors & Their Roles

### 1. Direction (1_ceo/)
Cannot register or modify samples.

**Pages:**
- **Échantillons** — all samples grouped by collector, filterable by date. Samples have three statut badges: **Réceptionné**, **En négociation**, **Achat confirmé**. Click any sample to see full details including delivery date and purchase details where applicable.
- **Analyse Organoleptique** — all samples with per-panel-member evaluation details. CEO views each panel member's completed sensory evaluation form and from this page decides whether to approve a sample for purchase (sets `budgetNegociation` and `dateLivraisonStockSouhaitee`).
- **Analyse Laboratoire** — samples with their linked lab analysis results, filterable by date.
- **Achats Confirmés** — confirmed purchases split into two sub-states: **Stock en transit** (purchased, stock not yet arrived) and **Stock reçu** (stock physically arrived at company). Filterable by date.
- **Carte** — geographic map showing, per collector, which Tunisian delegations have been visited and which have not yet been reached.
- **Dashboard** — KPIs (TBD)
- **Utilisateurs** — all app users with contact info. CEO can view user details, delete a user, or activate/deactivate an account.
- **Profile** — edit name, phone number, email, password.

### 2. Collector (2_collecteur/)
External participant who collects samples from across the country.

**Pages & Features:**
- **Échantillons** — list of the collector's own registered samples, filterable by date. Each sample shows its current state. States:
  - **Réceptionné** (registered only, not yet physically at company) — collector can edit and delete freely.
  - **Réceptionné – reçu physiquement** (taster confirmed physical arrival) — collector can edit limited fields but cannot delete. Any edit produces a visible edit history accessible to the taster, CEO, and lab technician (like the "edited" label in messaging apps, showing the previous value alongside the new one).
  - **En négociation** — CEO has approved the sample for purchase. Collector sees the negotiation details provided by the CEO (budget, desired stock delivery date) in a collapsible section. Collector can confirm the purchase from this state.
  - **Achat confirmé** — purchase confirmed by collector. Collector can edit the planned stock delivery date.
- **Ajouter un échantillon** (FAB / add button) — form with fields: supplier name, origin, reference (the bottle reference IS the sample reference — each bottle is a sample in itself), variety, quantity, number of bottles, optional expected arrival date at company, etc. Collector can take a photo of the handwritten bottle label; AI OCR (Gemini Vision) reads the handwriting and auto-fills the form fields. Collector reviews and can correct the pre-filled values before saving. When registering multiple bottles, each bottle gets its own reference and is saved as a separate Echantillon record.
- **Carte** — map of Tunisian delegations. Delegations the collector has visited are highlighted, unvisited ones are not. Helps the collector plan future routes.
- **Chat** — messaging interface with the Direction (CEO). Planned feature; implemented if time allows.
- **Dashboard** — collector-level KPIs and activity summary.
- **Profile** — edit personal info (name, phone, email, password, photo).
- **Offline mode** — data syncs when connection is restored. All writes are queued locally when offline. Critical feature; sync logic must not be broken.
- Cannot see taster evaluations.

### 3. Taster / Panel Member (3_degustateur/)
Part of a tasting team (multiple tasters, not just one).

**Pages & Features:**
- **Gestion des échantillons** — full list of all samples in the application, filterable by date. Taster can:
  - Add a new sample (in case a collector missed it or a sample arrived outside the collector flow).
  - Edit a sample — edits are tracked and the previous value remains visible to all actors (edit history, same mechanic as the collector).
  - Delete a sample — only allowed if the sample has **not** yet entered the **En négociation** state. Once a sample is in negotiation or beyond, it cannot be edited or deleted.
  - Toggle the physical receipt confirmation (`recuPhysiquement`) — marks that the sample is physically present at the company, which unlocks lab analysis.
- **Évaluation organoleptique** — list of all samples with evaluation states:
  - **En attente** — no evaluation started yet.
  - **En cours** — taster has opened the evaluation form and partially filled it but has not submitted.
  - **Soumis** — taster has submitted the evaluation. Submitted evaluations are read-only (can be viewed but not modified).
  Each taster submits their own individual evaluation per sample. The CEO sees all tasters' evaluations side by side.
- **Séances de dégustation** — tasting session planner. States: **Planifiée** (upcoming) and **Terminée** (past). To create a session: enter title, date, time, location, notes, and select participant panel members from the list. Only selected participants receive the notification. Each invited participant can confirm their attendance by tapping a checkmark.
- **Analyse laboratoire** — read-only view of lab analyses per sample. Filter states: **En attente** (no analysis submitted yet) and **Soumis** (lab technician has submitted the analysis).
- **Membres du panel** — list of all panel members in the app.
- **Dashboard** — taster-level KPIs and activity summary.
- **Profile** — edit name, family name, phone number, email, password, profile photo. Logout.

### 4. Laboratory Technician (4_laboratoire/)
Simplest role — only 2 pages: profile + sample list.

**Features:**
- Does NOT register samples — sees samples added by tasters or collectors that are physically present at the company (`recuPhysiquement = true`).
- Performs laboratory analysis on physically present samples. Two entry methods:
  1. **Photo upload** — take or upload a photo of the physical paper analysis report; AI automatically detects and extracts table values to fill the form fields. Technician reviews and confirms.
  2. **Manual entry** — fill the analysis form directly without a photo.
  The physical paper photo is preserved and stored alongside the digital form.
- Export analysis results.
- Samples grouped by state: **En attente** / **En cours** / **Soumis**
- Profile page (no dashboard).

---

## Sample Lifecycle & States

### Collector-facing states (`StatutCollecteur`):
- **Réceptionné** — sample registered in app; not yet physically at company. Collector can edit and delete freely.
- **Réceptionné (reçu physiquement)** — taster confirmed physical arrival (`recuPhysiquement = true`, `dateReceptionEchantillon` set); checkmark appears on card. Collector can edit limited fields but **cannot delete**. Edits are tracked — the previous value remains visible alongside the updated one to all actors (edit history).
- **En négociation** — CEO approved for purchase from the Analyse Organoleptique page. CEO's negotiation details (`budgetNegociation`, `dateLivraisonStockSouhaitee`) are visible to the collector in a collapsible section. Collector can proceed to confirm the purchase.
- **Achat confirmé** — collector confirmed purchase with `prixFinal`, `camionLivraison`, and planned stock delivery date (`planificationLivraison`). Sub-states tracked by CEO: **Stock en transit** and **Stock reçu**.

### Data flow per status transition:
| Transition | Who acts | Fields set |
|---|---|---|
| Register → Réceptionné | Collector or Taster | All sample fields, optionally `dateArriveeEchantillon` |
| Réceptionné → recuPhysiquement | Taster | `recuPhysiquement = true`, `dateReceptionEchantillon` |
| Réceptionné → En négociation | CEO (Analyse Organoleptique page) | `budgetNegociation`, `dateLivraisonStockSouhaitee` |
| En négociation → Achat confirmé | Collector | `prixFinal`, `camionLivraison`, `planificationLivraison` |
| Achat confirmé → Stock reçu | CEO or Collector | `dateArriveeStock` |

### Edit history rule:
Once a sample is physically received (`recuPhysiquement = true`), any edit to its fields must be stored with the previous value. All actors (CEO, taster, lab technician) see both the old value and the new value, clearly labelled, similar to the "edited" indicator in messaging applications.

### What each role sees on a sample:
- **Collector**: their own samples + status badge + CEO negotiation details (when En négociation) + physical receipt checkmark. Cannot see taster evaluations.
- **CEO**: all samples grouped by collector; statut badge; approve/refuse action from Analyse Organoleptique page; negotiation details after approval; purchase details after confirmation.
- **Taster**: all samples regardless of collector; can toggle `recuPhysiquement`; fills individual sensory evaluation forms; can edit/delete until sample reaches En négociation state.
- **Lab**: physically-received samples only; lab analysis form.

### Lab Technician-facing states:
- **En attente** — analysis not yet started
- **En cours** — analysis started but not submitted
- **Soumis** — analysis submitted (read-only)

---

## Key Features
- AI OCR for handwritten bottle label reading (collector sample registration)
- AI table extraction from lab analysis paper photos
- Offline mode with sync for collectors (rural areas with no connectivity)
- Geographic map for collector visit tracking (Tunisian delegations)
- Chat/messagerie between collector and direction
- Role-based access control (each actor sees only what they need)
- Sensory/organoleptic evaluation forms per sample per taster
- Laboratory analysis forms with photo upload and export

---

## Planned Backend: Django + PostgreSQL

This project **will be integrated with a Django REST API backed by PostgreSQL**. The Flutter app is currently using mock/hardcoded data, but all code must be written with backend integration in mind. The goal is that swapping mock data for real API calls requires minimal restructuring.

### Guiding Principle
**Never hardcode data directly in page widgets.** All data access — even mock data — must go through a service layer. Pages call services; services return models; models are built from JSON. This is the exact same pattern that will be used once the Django API is live.

---

### Service Layer (mandatory pattern)

Every feature that involves data must have a dedicated service class. Currently these services return mock data, but they must be structured so that replacing mock data with an HTTP call is a one-line change.

**Structure to follow for every service:**

```dart
// lib/2_collecteur/echantillons/services/echantillon_service.dart

class EchantillonService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<Echantillon>> fetchEchantillons() async {
    // TODO: replace with: return _api.get('/echantillons/');
    return _mockEchantillons();
  }

  Future<Echantillon> createEchantillon(Echantillon e) async {
    // TODO: replace with: return _api.post('/echantillons/', e.toJson());
    return e;
  }

  List<Echantillon> _mockEchantillons() => [ /* mock data here */ ];
}
```

Mark every mock method with `// TODO: remove when backend is ready` so they are easy to locate and delete.

---

### Model Requirements

All models must implement **both** `fromJson()` and `toJson()`. This is non-negotiable — even if `toJson()` is not used yet, it will be needed for POST/PUT requests to the Django API.

```dart
class Echantillon {
  final String id;       // must use String (UUID from Django)
  final String reference;
  // ...

  factory Echantillon.fromJson(Map<String, dynamic> json) => Echantillon(
    id: json['id'] as String,
    reference: json['reference'] as String,
    // ...
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    // ...
  };
}
```

**ID convention:** Use `String` for all IDs (UUIDs), not `int`. Django will use UUIDs as primary keys.

**Field naming:** JSON keys must use `snake_case` to match Django's serializer output (e.g., `date_creation`, `statut_labo`, not `dateCreation`).

---

### ApiClient (prepare the skeleton now)

Create `lib/core/api_client.dart` as an empty-but-structured placeholder. Services will import it when the backend is ready. Do not leave HTTP logic scattered across pages.

```dart
// lib/core/api_client.dart

class ApiClient {
  final String baseUrl;
  String? _authToken;

  ApiClient({required this.baseUrl});

  void setToken(String token) => _authToken = token;
  void clearToken() => _authToken = null;

  Future<dynamic> get(String path) async {
    // TODO: implement with http or dio
    throw UnimplementedError('Backend not connected yet');
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    throw UnimplementedError('Backend not connected yet');
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    throw UnimplementedError('Backend not connected yet');
  }

  Future<void> delete(String path) async {
    throw UnimplementedError('Backend not connected yet');
  }
}
```

A single `ApiClient` instance should be created at app startup and passed down (or accessed via a singleton) — do not instantiate it inside individual services.

---

### Authentication

The Django backend will use **JWT authentication** (likely via `djangorestframework-simplejwt`). Prepare for this now:

- The login page already has a `// TODO: replace with real API call` comment — keep it and make sure the login function signature accepts a token response.
- After login, the JWT access token must be stored securely (use `flutter_secure_storage`, not `SharedPreferences`) and attached to every request via an `Authorization: Bearer <token>` header inside `ApiClient`.
- Plan for token refresh: the `ApiClient` should have a refresh mechanism or at minimum a clear `// TODO: add token refresh logic` marker.
- The 4 debug login buttons in `main.dart` must be removed before production.

---

### Offline Mode (Collector)

The collector's offline sync logic is critical. Structure it so it is backend-agnostic:

- **Queue writes locally** (using `sqflite` or `hive`) when offline.
- The sync process calls the same service methods that will eventually hit the Django API.
- Do not mix sync logic into widgets — it belongs in `CollecteurSyncService`.
- Mark all offline queue entries with a `synced: false` flag and a local-only UUID; the server will assign the canonical UUID upon sync, and the local record must be updated accordingly.

---

### Django API Conventions to anticipate

When building models and services, assume the Django API will follow these conventions:

| Convention | Detail |
|---|---|
| Base URL | Configurable via `lib/config.dart` (add `apiBaseUrl`) |
| Auth | JWT — `Authorization: Bearer <token>` header |
| IDs | UUIDs (string), not integers |
| Field names | `snake_case` in JSON |
| Lists | Paginated responses: `{ "count": N, "results": [...] }` |
| Errors | `{ "detail": "..." }` or field-level `{ "field": ["error"] }` |
| Dates | ISO 8601 strings (`"2024-11-03T14:22:00Z"`) |
| File uploads | `multipart/form-data` for photos (lab analysis, OCR) |

Build `fromJson()` factories that can handle paginated list responses, e.g.:

```dart
static List<Echantillon> fromJsonList(Map<String, dynamic> json) =>
    (json['results'] as List).map((e) => Echantillon.fromJson(e)).toList();
```

---

### What NOT to do

- **Do not** put `http.get(...)` or `Dio` calls directly inside page `build()` methods or `initState()` without going through a service.
- **Do not** use `int` for IDs — they will be UUIDs in Django.
- **Do not** use `camelCase` for JSON keys in `toJson()` / `fromJson()` — Django serializers output `snake_case`.
- **Do not** store auth tokens in `SharedPreferences` — use `flutter_secure_storage`.
- **Do not** hardcode `baseUrl` strings anywhere except `lib/config.dart`.

---

## Design System & Visual Theme

A consistent visual theme **must be applied across all role modules**. Use the following constants in every page:

```dart
const Color _headerBg = Color.fromARGB(255, 220, 233, 226); // light green — AppBar + header zone bg
const Color _green    = Color(0xFF38835A);                   // primary brand green
const Color _dark     = Color(0xFF1A2E1F);                   // dark text
const Color _bg       = Color.fromARGB(255, 255, 255, 255);  // page background (white, NOT cream)
const Color _white    = Color.fromARGB(255, 255, 255, 255);  // sample card details background (replaces old _cream)
```

**AppBar pattern (mandatory for all pages):**
```dart
AppBar(
  backgroundColor: _headerBg,
  elevation: 0,
  centerTitle: false,
  toolbarHeight: 65,
  title: Text('Page title', style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: _dark)),
  iconTheme: const IconThemeData(color: _dark),
  // actions: date filter icon if page has date filtering
)
```

**Page body layout pattern:**
1. **Header zone** — `Container(color: _headerBg)` containing search bar + filter chips (same background as AppBar, visually seamless)
2. **Thin divider** — `Container(height: 1, color: Colors.black.withValues(alpha: 0.06))`
3. **Stats strip** — `Container(color: _bg)` with item count and active-filter clear button
4. **List** — `Expanded` scrollable content on white background

**Filter chips pattern** — use per-status colors (active = solid color + shadow, inactive = soft pastel):
- Tous: `Color(0xFF616161)` / inactive bg `Color(0xFFF0F0F0)`
- En attente / Réceptionné: `Color(0xFF3A6EA5)` / inactive bg `Color(0xFFE8F1FB)`
- En cours / En négociation: `Color(0xFFD07B2F)` / inactive bg `Color(0xFFFEF3E8)`
- Soumis / Achat confirmé: `Color(0xFF38835A)` / inactive bg `Color(0xFFE6F4ED)`

**FAB pattern** (when present): gray background `Color.fromARGB(255, 197, 206, 201)`, dark icon and label text.

The reference implementations are `lib/1_ceo/echantillons/echantillons_ceo_page.dart` and `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`.

---

## CEO Notification System

Notifications are sent automatically to all active CEO accounts (`role='direction'`) via Django signals. No manual triggering — every relevant state change fires a notification.

### Notification types & triggers

| Type | Trigger | Section (deep-link) |
|---|---|---|
| `NOUVEL_ECHANTILLON` | Collector or taster creates a new sample | ECHANTILLONS |
| `ECHANTILLON_MODIFIE` | Any field on a sample is edited (post-save, not a status transition) | ECHANTILLONS |
| `ECHANTILLON_SUPPRIME` | A sample is deleted (fires on `pre_delete`) | ECHANTILLONS |
| `ECHANTILLON_RECU` | Taster toggles `recu_physiquement` from `False` → `True` (includes exact date/time) | ECHANTILLONS |
| `PREMIERE_EVALUATION` | First taster submits their evaluation for a given sample (`statut = soumis`, count goes 0 → 1) | EVALUATIONS |
| `TOUTES_EVALUATIONS` | All active tasters (`role='degustateur'`) have submitted for that sample | EVALUATIONS |
| `ANALYSE_SOUMISE` | Lab technician submits the lab analysis (`statut = soumis`) | ANALYSES |
| `ACHAT_CONFIRME` | `statut_collecteur` transitions to `achat_confirme` (collector confirms purchase) | ACHATS |

### Signal detection logic
- **`pre_save`** stores `_old_recu_physiquement` and `_old_statut_collecteur` on the instance so `post_save` can compare old vs new values.
- **`ECHANTILLON_MODIFIE`** fires on any save that is NOT a creation, NOT a `recu_physiquement` flip, and NOT an `achat_confirme` transition — i.e., the fallback for all other edits.
- **`ECHANTILLON_SUPPRIME`** fires on `pre_delete` (not `post_delete`) so the reference can still be read.
- **"All evaluations submitted"** check: count `EvaluationOrganoleptique` with `statut=soumis` for that sample and compare to `User.objects.filter(role='degustateur', is_active=True).count()`.

### Backend files
- `backend_new/notifications/models.py` — `Notification` model (UUID PK, destinataire FK, type, titre, message, echantillon FK SET_NULL, section, is_read, date_creation)
- `backend_new/notifications/signals.py` — all signal handlers
- `backend_new/notifications/views.py` — list, mark-one-read, mark-all-read, unread-count
- `backend_new/notifications/urls.py` — mounted at `api/notifications/`

### Flutter files (CEO module)
- `lib/1_ceo/notifications/models/notification_ceo.dart` — model with `fromJson`/`toJson`
- `lib/1_ceo/notifications/services/notification_ceo_service.dart` — service (mock data, ready for API swap)
- `lib/1_ceo/notifications/notifications_ceo_page.dart` — full page (date grouping, filter chips, per-type icons, unread accent bar)
- Bell icon lives in `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` AppBar — shows live unread count badge, navigates to notifications page, refreshes count on return.

### Deep-link navigation (tap a notification)
| section value | Navigates CEO to |
|---|---|
| `ECHANTILLONS` | `EchantillonsCeoPage` |
| `EVALUATIONS` | `AnalyseOrganoleptiqueCeoPage` |
| `ANALYSES` | `AnalyseLaboratoireCeoPage` |
| `ACHATS` | `AchatsConfirmesCeoPage` |

---

## Key Conventions

- Sample workflow statuses are defined as enums per role (e.g., `StatutCollecteur`, `StatutEchantillon`) in each module's `models/` folder.
- Linter allows `unused_local_variable`, `unused_import`, `unused_element` (see `analysis_options.yaml`).
- Assets declared in `pubspec.yaml` under `assets/img/`.
- French is used for all UI labels, page names, and state names.
- Always clarify which actor's module is being worked on before making changes — roles are isolated and have different permissions and views for the same data.
- Edit/delete permissions are governed by sample state, not by CEO approval. There is no concept of "collector needs CEO permission to edit." State transitions determine what is editable.
- Once a sample is physically received, edits must record the previous value (edit history). Store `editHistory` as a list on the model.
- The collector has offline support — sync logic is critical and must not be broken.
- The 4 debug login buttons in `main.dart` must be removed before production.
- All data access goes through a service class — never hardcode or fetch data directly in widgets.
- All models must implement `fromJson()` and `toJson()` with `snake_case` keys.
- All IDs are `String` (UUID), never `int`.