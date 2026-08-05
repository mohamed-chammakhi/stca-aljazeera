# AGENTS.md

Codex project instructions. This is the Codex equivalent of `CLAUDE.md`.
Keep this file as a lightweight index: load only the role/context file needed
for the current task.

## Always Do First

- Identify the role module or layer being changed before editing.
- Before writing any frontend code, invoke the `frontend-design` skill when it
  is available, then follow the design system below and the relevant role file
  from `files/`.
- Before services, models, auth, API, or Django edits, read
  `files/backend.md`.
- Before backend implementation planning, read `files/backend_sprint_plan.md`.
- Before continuing backend implementation, read `files/mapbackend.md` to see
  what is done, what remains, and where to continue.
- Preserve production quality. This is not a prototype app.
- Preserve existing mock/fake data unless the user explicitly asks to remove
  it.
- Backend wiring must not change the visual design, layout, colors, spacing,
  or navigation behavior of existing interfaces.

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
- Entry point: `lib/main.dart`, with global green theme and Google Fonts
  Domine/Alegreya.
- Geospatial: `GeoService` singleton at
  `lib/2_collecteur/carte_geo/services/geo_service.dart`, using
  `assets/img/delegations.geojson` with `flutter_map`.
- Data access: service classes only, never direct HTTP/data access in widgets.
- Current Flutter data is service-layer/mock unless connected to Django.
- Mock/fake data is intentional and must remain available for UI scenario
  previews while backend integration is incomplete.
- Auth tokens: `flutter_secure_storage`, not `SharedPreferences`.
- `baseUrl` belongs only in `lib/config.dart`.

## Final Year Report Backlog

This project is documented in the final year report with a 19-feature product
backlog. Use this backlog as the official scope reference when explaining the
project to the jury, preparing diagrams, or aligning implementation work with
the report.

| ID | Feature | Priority | Estimation |
| --- | --- | --- | --- |
| 1 | Authentication | High | 4 Days |
| 2 | Profile management | Medium | 3 Days |
| 3 | User management | High | 5 Days |
| 4 | Notification management | Medium | 5 Days |
| 5 | Admin dashboard | Medium | 7 Days |
| 6 | Sample consultation | High | 6 Days |
| 7 | Organoleptic analysis consultation | High | 7 Days |
| 8 | Laboratory analysis consultation | High | 6 Days |
| 9 | Confirmed purchases management | High | 6 Days |
| 10 | Evaluation dashboard | Medium | 7 Days |
| 11 | Sample management for panel roles | High | 14 Days |
| 12 | Sample evaluation | High | 9 Days |
| 13 | Laboratory analysis consultation for panel roles | Medium | 5 Days |
| 14 | Tasting session management | High | 8 Days |
| 15 | Panel members consultation | Low | 2 Days |
| 16 | Cross-panel evaluation supervision with AI divergence detection | High | 8 Days |
| 17 | Collector sample management | High | 10 Days |
| 18 | Interactive geographic coverage consultation | Medium | 4 Days |
| 19 | Laboratory analysis management | High | 10 Days |

Backlog role mapping:

- `Administrator` in the report corresponds to Direction / CEO in the app.
- `Panel Member` corresponds to Degustateur.
- `Panel Evaluation Supervisor` corresponds to Chef de Dégustation.
- `Collector` corresponds to Collecteur.
- `Laboratory Technician` corresponds to Technicien Labo.

Important product backlog details:

- Admin/Direction covers user management, dashboards, sample consultation,
  organoleptic results, lab reports, purchase decisions, stock delivery dates,
  and geographic coverage.
- Panel members and the chef cover sample reception, sample management,
  evaluation drafts/submission, lab report consultation, urgent lab requests,
  tasting sessions, attendance, dashboards, and panel supervision.
- The chef has exclusive cross-panel supervision, side-by-side submitted
  evaluations, and AI-assisted divergence detection.
- Collectors manage their own samples, OCR extraction from handwritten bottle
  labels, negotiation/purchase confirmation, stock delivery information, and
  geographic coverage.
- Laboratory technicians manage lab analysis reports manually or with
  AI-assisted OCR from paper reports.

## Final Year Report Sprint Plan

The report uses this 7-sprint division. The durations below are the sum of the
feature estimations assigned to each sprint. They total 126 days
(`17 + 19 + 13 + 30 + 23 + 14 + 10 = 126`). If the report describes Scrum
sprints as fixed time boxes, rename these to phases or normalize the durations;
as written, they are variable-duration sprint groups.

| Sprint | Focus | IDs Used | Duration |
| --- | --- | --- | --- |
| Sprint 1 | Core platform foundation | 1, 2, 3, 4 | 17 Days |
| Sprint 2 | Administrator monitoring workflow | 5, 6, 8 | 19 Days |
| Sprint 3 | Administrator decision and purchase workflow | 7, 9 | 13 Days |
| Sprint 4 | Panel member sample and evaluation workflow | 10, 11, 12 | 30 Days |
| Sprint 5 | Tasting session and supervision workflow | 13, 14, 15, 16 | 23 Days |
| Sprint 6 | Collector workflow | 17, 18 | 14 Days |
| Sprint 7 | Laboratory technician workflow | 19 | 10 Days |
| Total | Full product backlog | 1 -> 19 | 126 Days |

Use this sprint plan for report explanations unless the user explicitly asks to
revise the planning. For backend implementation details, still read
`files/backend_sprint_plan.md` before editing Django/API work.

## Role Modules

| Module | Role | Read Before Editing |
| --- | --- | --- |
| `lib/1_ceo/` | Direction / CEO | `files/role_ceo.md` |
| `lib/2_collecteur/` | Collecteur | `files/role_collecteur.md` |
| `lib/3_degustateur/` | Degustateur | `files/role_degustateur.md` |
| `lib/4_laboratoire/` | Technicien Labo | `files/role_laboratoire.md` |
| `lib/5_chef_degustateur/` | Chef de Dégustation | `files/role_chef_degustateur.md` |
| Services / models / auth / API integration | Shared backend integration | `files/backend.md` |
| Backend sprint order / API plan | Django backend | `files/backend_sprint_plan.md` |
| Backend checkpoint / continuation map | Django + Flutter integration | `files/mapbackend.md` |

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
- `numero`: official sample sequence, JSON key `"numero"`, example
  `2025/0003`. It is read-only in Flutter and never typed by the collector.
  In the final backend-connected architecture, the server generates it. Current
  mock Flutter flows may simulate it locally only for development.
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

Deletion/editing guardrails:

- Collector can delete only their own samples while still at initial
  `receptionne` state.
- Taster / chef can delete only if the sample has not entered negotiation.
- CEO cannot register or directly modify samples.
- Lab technician does not register samples and only sees physically received
  samples.

## Backend Integration Rules

Before touching any service/model/API/auth code, read
`files/backend.md`.

Required pattern:

- Pages call service classes.
- Services call `ApiClient` when backend-connected; mock services must stay
  behind the service layer until replaced.
- Do not delete existing mock data while adding backend calls; keep it as
  fallback/dev scenario data unless the user explicitly approves removal.
- Services return models.
- Models parse/emit JSON.
- Never call HTTP directly in a widget, `build()`, or `initState()`.
- Do not instantiate `ApiClient` inside services; use the app-level instance.
- Backend integration should change only data-loading/saving behavior. It must
  not redesign pages, drawers, cards, filters, buttons, colors, typography, or
  spacing.
- Store JWT tokens in `flutter_secure_storage`.
- Every authenticated request sends `Authorization: Bearer <token>`.
- Keep `// TODO: add token refresh logic` marker in `ApiClient` until refresh
  is implemented.
- Keep the login page's `// TODO: replace with real API call` marker until
  authentication is connected.

Django conventions:

- Backend uses `djangorestframework-simplejwt`.
- Errors use `{ "detail": "..." }` or `{ "field": ["error"] }`.
- Role permissions must be explicit: `IsCollecteur`, `IsDegustateur`,
  `IsLaboratoire`, `IsDirection`, `IsChefDegustation`.

## Backend Sprint Order

When implementing backend work, follow `files/backend_sprint_plan.md`.

1. Sprint 1: Collector supplier/sample CRUD:
   `/api/fournisseurs/`, `/api/echantillons/`, bulk sample create, purchase
   confirmation, filters by status/date/governorate, and search by `numero`,
   `reference_bouteille`, supplier code, or variety.
2. Sprint 2: Collector OCR, map, authentication:
   `/api/echantillons/ocr/`, `/api/collecteur/carte/`, `/api/auth/`, and
   `/api/users/me/`; JWT payload includes `role`, `nom`, and `prenom`.
3. Sprint 3: Taster reception, evaluations, sessions:
   reception confirmation, organoleptic evaluations, submit action, and
   tasting-session create/approve/refuse flows.
4. Sprint 4: Lab analysis and OCR:
   lab-scoped analyses for physically received samples only, analysis OCR,
   and submit.
5. Sprint 5: CEO and chef dashboards, approvals:
   CEO dashboard/approval/user management and chef evaluation overview plus
   dashboard endpoints.
6. Sprint 6: Notifications and messaging:
   notification list/read/unread-count endpoints and basic messages.

Important: start backend work with Collector core, not authentication. The
collector is the entry point of the data pipeline.

## Role-Specific Summary

CEO / Direction:

- Sees all samples, evaluations, lab analyses, purchases, map, dashboard,
  users, notifications, and profile.
- Approves/refuses samples from organoleptic analysis.
- Approval sets negotiation budget and desired stock delivery date.
- Confirmed purchases display as stock in transit or stock received.
- Delivery text in expanded sample details uses gray sentence text, not chips
  or icons.
- Can manage users.
- Cannot register or directly modify samples.
- Read `files/role_ceo.md` for delivery display rules and notification
  deep-links.

Collecteur:

- Registers own samples and suppliers.
- Each bottle is one `Echantillon`; multiple bottles become separate samples.
- Creation includes supplier/origin, `reference_bouteille`, variety, quantity,
  tank number, optional expected arrival, and optional OCR from bottle-label photo.
- Uses map of Tunisian delegations.
- Cannot see taster evaluations.
- Read `files/role_collecteur.md` before touching sample creation, map, or
  collector statuses.

Degustateur:

- Sees all samples.
- Can add/edit samples, toggle physical reception, and submit their own
  organoleptic evaluations.
- Submitted evaluations are read-only.
- Has tasting sessions, panel members, lab read-only view, dashboard, profile.
- Can send an `ANALYSE_URGENTE` lab notification from the lab read-only view;
  once sent, the urgent button locks for the session.
- Dashboard urgent evaluations depend on physically received samples awaiting
  this taster's submission; recent activity paginates 5 items per load.
- Read `files/role_degustateur.md` for urgency and dashboard formulas.

Laboratoire:

- Three pages only: sample/analysis list, notifications, and profile. No
  dashboard.
- Sees only samples where `recuPhysiquement = true`.
- Analysis can be entered manually or extracted from a paper report photo.
- Submitted analyses are read-only.
- Notifications contain urgent analysis requests (`ANALYSE_URGENTE`) from
  tasters or chef; support unread state, date grouping, and mark-as-read.
- Drawer destinations are samples to analyze, notifications, profile, and
  logout.
- Read `files/role_laboratoire.md`.

Chef de Dégustation:

- Senior taster plus panel manager.
- Same sample/evaluation capability as degustateur for their own evaluation.
- Exclusive overview of all tasters' evaluations, divergence detection,
  session approval/refusal, dashboards, notifications.
- Divergence flag appears when a submitted score deviates by more than 1.5 from
  panel average and at least 3 evaluations exist.
- Sessions can be pending validation, planned, or finished; chef approves or
  refuses pending sessions.
- Chef dashboard covers pipeline, urgent evaluations, pending sessions, delays,
  panel alignment, classifications, presence, CEO blockers, and recent activity.
- Shared colors/navigation live under `lib/5_chef_degustateur/widgets/`.
- Read `files/role_chef_degustateur.md`.

## Notifications

Notifications are generated by Django signals for important events:

- `NOUVEL_ECHANTILLON`
- `ECHANTILLON_MODIFIE`
- `ECHANTILLON_SUPPRIME`
- `ECHANTILLON_RECU`
- `PREMIERE_EVALUATION`
- `EVALUATION_SOUMISE`
- `TOUTES_EVALUATIONS`
- `ANALYSE_SOUMISE`
- `ANALYSE_URGENTE`
- `ACHAT_CONFIRME`
- `NOUVELLE_SESSION`

Role files define which notification types and deep-link sections apply to CEO
and chef de dégustation. Lab receives urgent analysis notifications. Notification
sections navigate to role-specific pages such as echantillons, evaluations,
analyses, achats, or sessions.

CEO notification signal logic:

- Use `pre_save` snapshots to detect `recuPhysiquement` and purchase-status
  transitions.
- Fire `ECHANTILLON_MODIFIE` only for ordinary edits, not creation, physical
  reception, or purchase confirmation.
- Fire delete notifications from `pre_delete` so sample identifiers are still
  available.
- "All evaluations" compares submitted evaluations with active tasters.

## Temporary Worktrees

The repo may contain temporary git worktrees under `.worktrees/`:

- `.worktrees/cleanup-ceo`
- `.worktrees/cleanup-degustateur`
- `.worktrees/cleanup-laboratoire`

These are comparison/refactor branches, not the canonical source. Use them only
for review or selective cherry-picking. Do not copy a whole worktree into
`main`; compare the relevant role folder against the main `lib/` version and
preserve newer main changes.






<claude-mem-context>
# Memory Context

# [project3] recent context, 2026-06-02 9:20pm GMT+1

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision 🚨security_alert 🔐security_note
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 50 obs (22 718t read) | 330 790t work | 93% savings

### May 26, 2026
1429 9:43p 🔵 Google ML Kit Text Recognition does not support handwritten text from photographed paper labels
### May 27, 2026
1432 6:37p 🟣 Created OCR Cleaning & Validation Pipeline Diagram for Final Year Project Report
1433 6:39p 🔄 Simplified OCR Cleaning Diagram to Focus on Field Processing Pipeline
1434 6:51p 🔵 Google ML Kit Text Recognition lacks reliable handwriting recognition from photographed paper labels
1435 " ⚖️ OCR feature framed as AI-assisted label reading with mandatory human validation
1436 " ⚖️ Production OCR upgrade path identified for enhanced handwritten text recognition
1437 10:45p 🔵 Google ML Kit Text Recognition limitation for handwritten labels
1438 " ⚖️ OCR feature repositioned as AI-assisted label reading with human validation
1439 " ⚖️ Future scalability path: cloud document AI services for advanced handwritten OCR
### May 28, 2026
1461 6:33a 🔵 Google ML Kit OCR limitation with handwritten text recognition
1462 " ⚖️ OCR feature repositioned as AI-assisted label reading with mandatory human validation
1463 " ✅ Report sections expanded with technical depth and limitation acknowledgment
1465 6:48a ⚖️ OCR Feature Reframed: ML Kit Text Recognition Limited to Printed Text, Requires Human Validation
1480 7:40p 🔄 Sprint 1 class diagram refactored for clarity and naming conventions
1481 7:44p 🔄 Sprint 2 class diagram expanded with OCR bottle label extraction and cumulative role support
1482 " 🔄 Sprint 3 class diagram refactored with purchase decision and confirmation entities
1483 7:45p 🔄 Sprint 4 class diagram expanded with laboratory analysis workflow and tasting session management
1484 " 🔄 Sprint 5 global class diagram completed with full system architecture and user management
1485 8:11p ✅ Sprint 1 Class Diagram Updated with Styling and Layout Improvements
1486 " 🟣 Sprint 2 Class Diagram Adds Panel Member Role and Organoleptic Evaluation System
1487 8:12p 🟣 Sprint 3 Adds Purchase Decision and Confirmation Workflow with Expanded Admin and Collector Roles
1488 " 🟣 Sprint 4 Introduces Laboratory Analysis and Tasting Session Management with LaboratoryTechnician Role
1489 8:13p 🟣 Sprint 5 Adds User Management System and Cross-Actor Discovery with Base User Profile Capabilities
1490 8:14p ✅ Sprint 5 Diagram Relationship Semantics Refined: Panel Member Peer Consultation Changed to Dependency Arrow
### May 29, 2026
1491 7:19a ✅ Sprint 1 Class Diagram Created in PlantUML
1492 7:22a 🔵 Development Environment Rendering Tools Verified
1493 " 🔵 PlantUML Command Path Issue in Bash Environment
1494 " ✅ Sprint 1 Class Diagram Rendered to PNG Successfully
1497 7:43a ✅ Sprint 3 Class Diagram with Domain Model and Workflows
1498 7:44a ✅ Sprint 3 Class Diagram Rendered to PNG
1499 8:01a ✅ Sprint 4 Class Diagram Documentation Created
1500 8:02a ✅ Sprint 4 Class Diagram PNG Rendered Successfully
1501 8:07a ✅ Sprint 5 Class Diagram Updated with Simplified PlantUML Styling
1502 9:27a 🔵 Ripgrep search for purchase domain patterns timed out on project
1503 " 🔵 Purchase confirmation workflow architecture spans backend and frontend with state-driven UI
1504 " 🔵 Large model files cause PowerShell Get-Content timeouts on Windows
1505 9:28a 🔵 Purchase confirmation implemented as two-level backend decision flow via API endpoints
1506 9:34a 🔵 Multi-level approval workflow with decision fields embedded across CEO and taster roles
1507 9:35a 🔵 Echantillon canonical model embeds full purchase negotiation and decision workflow state
### May 31, 2026
1550 10:18a 🔵 CEO role documentation reviewed for architectural entity mapping
1551 " 🔵 Backend service and model architecture documented for Echantillon entity
1552 10:19a 🔵 CEO echantillons module entities and relationships mapped from codebase
1553 " 🔵 EchantillonCeoService API contract and approval/refusal workflows
1554 " 🔵 Echantillon canonical model: all-fields entity serving four role-specific views
1555 " 🔵 EchantillonCeoView: role-specific aggregation model for CEO pages
1556 10:20a 🔵 CEO module page structure: six pages with shared DetailItem widget architecture
1557 10:51a 🔵 Carbon Footprint Analysis Framework for PFE Project
S1219 Generate a complete carbon footprint analysis (Bilan Carbone) template for olive oil management PFE project, adapted to Flutter + Django technology stack (May 31, 10:52 AM)
S1220 Build a carbon footprint annexe for a 3-month internship (PFE) report, starting with detailed technical specifications about laptop usage, commuting, and project work patterns (May 31, 10:52 AM)
S1221 Create a personalized carbon footprint (bilan carbone) annexe for an academic project (SFE/PFE) involving an olive oil management application with Flutter frontend and Django backend (May 31, 11:16 AM)
S1222 Create a comprehensive and personalized carbon footprint (bilan carbone) annexe for an academic project (SFE/PFE): Flutter mobile application with Django backend for olive oil sample management, sensory evaluation, laboratory analysis, purchasing decisions, and inventory tracking (May 31, 11:22 AM)
S1223 Validate and refine carbon footprint annexe for academic project against institutional methodology guide; identify missing clarifications required for complete documentation (May 31, 11:22 AM)
1558 11:24a 🔵 Institutional Carbon Footprint Estimation Framework Retrieved
S1224 Validate preliminary carbon footprint annexe against institutional methodology guide; identify and catalog clarifications required before finalizing complete academic project documentation (May 31, 11:24 AM)
S1226 Carbon footprint estimation (Bilan Carbone) for a 3-month software development project (PFE), with GitHub repository investigation to anchor the assessment (May 31, 11:25 AM)
1559 11:46a 🔵 Project commit count investigation
1560 11:47a 🔵 Project scale and repository metrics
S1228 Carbon footprint estimation (Bilan Carbone SFE/PFE) for a 3-month software development project, grounded by actual GitHub repository metrics (May 31, 11:47 AM)
S1230 Recalculate carbon footprint (Bilan Carbone) for a PFE project with exact parameter clarifications: 9 people in carpool, 2 printed copies of 120-page document, ~35 GitHub commits over 3 months, and Azure AI OCR impact assessment (May 31, 11:48 AM)
S1231 Finalize carbon footprint calculation (Bilan Carbone) for PFE with confirmed parameters: 9-person carpool, 2 copies of 120-page document, 35 GitHub commits, Azure AI OCR inclusion (May 31, 11:59 AM)
**Investigated**: Emissions factors across four categories: transportation (carpool sharing), IT equipment (laptop/smartphone manufacturing), infrastructure/code operations (PC usage, internet, API calls, Azure OCR), and document printing; validated calculation methodology and data center location impact

**Learned**: Carpool distribution effectively reduces per-person transport emissions (23.04 kg CO2e ÷ 9); infrastructure/code operations represent largest impact category (48.4%, 37.53 kg CO2e) driven by development PC usage; Azure AI OCR estimated at 0.50 kg CO2e for ~100 test requests; France-based data center reduces electricity factor; using older hardware minimizes manufacturing emissions (10.42 kg from 3-year amortized laptop, 2.50 kg from ancient Redmi phone)

**Completed**: Corrected carbon footprint total from initial 77.55 kg CO2e to accurate 75.05 kg CO2e; provided final emissions breakdown by category with corrected percentages; created French-language explanation for Azure OCR module impact with datacenter location justification; drafted final conclusion statement quantifying all contributions and mitigation strategies

**Next Steps**: Integrate finalized 75.05 kg CO2e total and supporting calculations into PFE project report annexes; ensure French documentation meets project report formatting standards


Access 331k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>
