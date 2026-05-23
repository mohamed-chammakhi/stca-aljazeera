# CLAUDE.md

## Always Do First
- **Invoke the `frontend-design` skill** before writing any frontend code, every session, no exceptions.

---

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

---

## Architecture

**Domain:** Multi-role olive oil sample evaluation and stock acquisition system for **Al Jazeera STCA** (Tunisia). UI in **French**. Production app â€” no prototype shortcuts.

**Four role modules under `lib/`:**

| Module | Role | French |
|--------|------|--------|
| `1_ceo/` | Direction/CEO | Directeur |
| `2_collecteur/` | Sample Collector | Collecteur |
| `3_degustateur/` | Taster | DÃ©gustateur |
| `4_laboratoire/` | Lab Technician | Technicien Labo |

Al Jazeera STCA collects olive oil samples from suppliers across Tunisia, evaluates them, and purchases the best stocks to process and sell under their own brand. The collector travels the country registering samples on-site, sometimes offline. The taster physically receives samples at the company and runs sensory evaluations. The lab technician performs chemical analysis on those same received samples. The CEO oversees everything â€” reviewing evaluations, approving purchases, and tracking stock delivery â€” but never touches a sample directly.


Each module: `<role>/<feature>/models/`, `widgets/`, `services/`

**State management:** `StatefulWidget` + `setState()` only. No Provider/Riverpod/BLoC/GetX.  
**Navigation:** `Navigator.push()` / `pushReplacement()` + `MaterialPageRoute`. Each role uses a `Drawer`. No named routes.  
**Entry point:** `lib/main.dart` â€” global theme (green `#38835A`, Google Fonts Domine/Alegreya) + login with 4 debug buttons (**remove before production**).  
**Geospatial:** `GeoService` singleton at `lib/2_collecteur/carte_geo/services/geo_service.dart`, parses `assets/img/delegations.geojson` via `flutter_map`.  
**Data:** All mock via service layer. No HTTP/Firebase/local DB yet.

---

## Sample States (overview)

**Collector-facing:** `RÃ©ceptionnÃ©` â†’ `RÃ©ceptionnÃ© (reÃ§u physiquement)` â†’ `En nÃ©gociation` â†’ `Achat confirmÃ©`  
**Lab-facing:** `En attente` â†’ `En cours` â†’ `Soumis`  
**Edit history rule:** Once `recuPhysiquement = true`, any field edit must store the previous value. All roles see old + new values.

---

## Design System

```dart
const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _bg       = Color.fromARGB(255, 255, 255, 255);
const Color _white    = Color.fromARGB(255, 255, 255, 255);
```

**AppBar (mandatory for all pages):**
```dart
AppBar(
  backgroundColor: _headerBg,
  elevation: 0,
  centerTitle: false,
  toolbarHeight: 65,
  title: Text('Title', style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: _dark)),
  iconTheme: const IconThemeData(color: _dark),
)
```

**Page body layout:**
1. Header zone â€” `Container(color: _headerBg)` with search + filter chips
2. Divider â€” `Container(height: 1, color: Colors.black.withValues(alpha: 0.06))`
3. Stats strip â€” `Container(color: _bg)` with count + clear-filter button
4. List â€” `Expanded` scrollable on white

**Filter chip colors:**
| State | Active | Inactive bg |
|-------|--------|-------------|
| Tous | `0xFF616161` | `0xFFF0F0F0` |
| En attente / RÃ©ceptionnÃ© | `0xFF3A6EA5` | `0xFFE8F1FB` |
| En cours / En nÃ©gociation | `0xFFD07B2F` | `0xFFFEF3E8` |
| Soumis / Achat confirmÃ© | `0xFF38835A` | `0xFFE6F4ED` |

**FAB:** gray bg `Color.fromARGB(255, 197, 206, 201)`, dark icon + label.  
**Reference implementations:** `lib/1_ceo/echantillons/echantillons_ceo_page.dart` and `lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart`

---

## Key Conventions

- All IDs are `String` (UUID), never `int`
- JSON keys must be `snake_case`
- All models implement `fromJson()` and `toJson()`
- All data access through a service class â€” never in widgets
- Auth tokens â†’ `flutter_secure_storage`, NOT `SharedPreferences`
- `baseUrl` only in `lib/config.dart`
- Linter allows `unused_local_variable`, `unused_import`, `unused_element`
- Assets declared in `pubspec.yaml` under `assets/img/`
- Always clarify which role module is being worked on before making changes
- The 4 debug login buttons in `main.dart` must be removed before production

---

## Role Files â€” Load the One You Need

| Working on... | Read this file |
|---------------|---------------|
| `1_ceo/` | [`files/role_ceo.md`](files/role_ceo.md) |
| `2_collecteur/` | [`files/role_collecteur.md`](files/role_collecteur.md) |
| `3_degustateur/` | [`files/role_degustateur.md`](files/role_degustateur.md) |
| `4_laboratoire/` | [`files/role_laboratoire.md`](files/role_laboratoire.md) |
| `5_chef_degustateur/` | [`files/role_chef_degustateur.md`](files/role_chef_degustateur.md) |
| Services / models / auth / offline sync | [`files/backend.md`](files/backend.md) |
| Backend sprint order & API reference | [`files/backend_sprint_plan.md`](files/backend_sprint_plan.md) |
| Product backlog & sprint planning (report) | [`files/product_backlog.md`](files/product_backlog.md) |

## Backend Development Order

**Start with Sprint 1 — Collector module, NOT authentication.**
Authentication (JWT) is Sprint 2. The Collector is the entry point of the data pipeline.

See [`files/backend_sprint_plan.md`](files/backend_sprint_plan.md) for the full sprint order, models, endpoints, and permissions per sprint.
