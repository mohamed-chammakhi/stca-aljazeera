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
- `Panel Evaluation Supervisor` corresponds to Chef de Panel.
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
| `lib/5_chef_degustateur/` | Chef de Panel | `files/role_chef_degustateur.md` |
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
  `IsLaboratoire`, `IsDirection`, `IsChefPanel`.

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
  sealing, optional expected arrival, and optional OCR from bottle-label photo.
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

Chef de Panel:

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
and chef de panel. Lab receives urgent analysis notifications. Notification
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

# [project3] recent context, 2026-05-23 6:36pm GMT+1

Legend: 🎯session 🔴bugfix 🟣feature 🔄refactor ✅change 🔵discovery ⚖️decision 🚨security_alert 🔐security_note
Format: ID TIME TYPE TITLE
Fetch details: get_observations([IDs]) | Search: mem-search skill

Stats: 50 obs (20 371t read) | 351 871t work | 94% savings

### May 22, 2026
737 7:26p ✅ Removed exception scenarios 2 and 4 from sprint report
### May 23, 2026
743 5:05a 🔵 OCR Service Word Detection and Field Classification Implementation
744 " 🔵 Fuzzy Supplier Matching and OCR Orchestration Pipeline
745 " 🔵 EchantillonOCRView API Endpoint for Image Upload and OCR Processing
746 " 🔵 Flutter Form Auto-Fill with Confidence Display and Human-in-the-Loop Preservation
766 2:30p 🔵 PDF processing libraries not available in project environment
767 2:31p 🔵 pdftotext command-line tool available despite missing Python PDF libraries
768 " 🔵 PDF is scanned document with image-based content, not extractable text
769 " 🔵 Dashboard PDF is 15-page A4 document scanned via CamScanner on May 20, 2026
770 " 🔵 PDF-to-image conversion tools available (pdftoppm, pdfimages) but OCR unavailable
771 " ✅ Scanned dashboard PDF converted to 15 PNG images at 160 DPI resolution
S724 User requested a complete, polished Chapter 8 for their final year project by adapting the reference student's dashboard reporting methodology to their olive oil evaluation application (May 23, 2:33 PM)
S725 Continuation of Chapter 8 writing for final year project on administrator dashboard and geographic coverage (May 23, 2:34 PM)
S726 Analyze another student's dashboard project (dash.pdf) and understand its approach to inform the user's own dashboard implementation (May 23, 2:35 PM)
S727 Review administrator dashboard interfaces and determine how to document/explain them as part of a system design presentation (May 23, 2:44 PM)
S728 Understand a reference student's dashboard chapter structure (Power BI-based manufacturing QA system) and identify how to adapt it for the olive oil Flutter app (May 23, 2:56 PM)
S730 Document and understand existing CEO dashboard and geographic coverage map implementations to write Chapter 8 of technical documentation (May 23, 3:15 PM)
772 3:20p 🔵 CEO Role Architecture and Notification System Discovered
773 3:35p 🔵 CEO Dashboard Module Structure and Architecture
774 3:36p 🔵 KPI Card Widget with Explicit Height Constraint Fix
775 " 🔵 Sales Evolution Line Chart with Dual-Season Comparison
776 " 🔵 KPI Grid Card: Dark-Themed Top Banner with Season Investment and Price Metrics
777 " 🔵 Oil Classification Card with Donut Chart and Animated Progress Breakdown
778 3:37p 🔵 Stock Donut Card: In-Transit vs. Received Inventory Visualization
779 " 🔵 Urgent Panel: Red-Bordered Alert for Pending CEO Decisions
780 " 🟣 GeoService: Singleton for GeoJSON Delegation Zones with Visited State Tracking
781 " 🟣 CarteGeoPage: Interactive Map with Polygon Tap Detection and Visited Zone Visualization
S731 Guidance on implementing OCR for final year project dashboard - which approach is most practical for passing evaluation (May 23, 3:39 PM)
S732 Implement offline OCR for bottle label reading in the wine collector sample form, enabling automatic extraction and pre-population of bottle metadata from camera/gallery photos (May 23, 5:06 PM)
782 5:11p 🔵 Sample identity architecture: two-identifier system (numero + reference_bouteille)
783 " 🔵 Flutter collector module structure: mes_echantillons, carte_geo, notifications, profilcom
784 5:12p 🔵 Form architecture: section-based field organization with per-bottle data isolation
785 " 🔵 OCR integration for bottle label photo capture and field auto-fill
786 " 🔵 Backend service layer and API client pattern
787 " 🔵 API field mapping layer: Django snake_case ↔ Flutter camelCase conversion
788 " 🔵 OCR endpoint and multipart image upload integration
789 " 🔵 Sample lifecycle operations: CRUD, OCR, purchase confirmation
790 5:13p 🟣 On-device OCR service with field-specific extraction heuristics
791 5:18p 🔵 Dependency resolution timeout: google_mlkit_text_recognition package
792 5:19p 🟣 Code implementation complete: on-device OCR with field extraction for bottle labels
793 " 🔵 Dependency resolution succeeded with extended timeout
794 5:21p 🔵 Code analysis passed: no semantic errors in OCR implementation
795 5:22p 🔵 Focused analysis: BottleLabelOcrService clean, formulaire_dialog cosmetic issues only
796 " ✅ Style cleanup and final validation: OCR implementation complete
797 5:23p ✅ Unused import detected: echantillon_collecteur_service still imported
798 " 🔵 Final analysis: OCR implementation complete with minimal cosmetic warnings
799 " 🔵 Analysis resolution: warnings are lint hints on optional parameters with defaults
800 5:24p 🔵 Usage pattern confirms: _FormField rarely instantiated with optional parameters
801 " 🔵 Code inspection confirms: _FormField usage relies on default parameters
802 " 🔵 Parameter usage confirmed: keyboardType and suffixText ARE used in widget implementation
803 " ✅ Code cleanup: removed unused import and unused optional parameters
804 " ✅ Cleanup patch applied successfully: formulaire_dialog.dart refactored
805 5:25p ✅ Code formatting applied: formulaire_dialog.dart cleaned
806 " 🔵 Final validation: OCR implementation complete with zero warnings
807 5:36p ✅ Major backend migration and frontend refactor across role-based modules
808 5:37p 🔵 Active Flutter APK debug build with intensive Gradle and Kotlin compilation
809 " 🔵 Flutter APK debug build completed successfully with updated artifact
810 " 🟣 Offline OCR for bottle label reading in collector sample form
S733 Rewrite Chapter 8 of final year project report in English covering Administrator Dashboard and Geographic Coverage features (May 23, 5:38 PM)
S734 Viability assessment: Will the OCR-based bottle label extraction system function for the intended use case? (May 23, 6:32 PM)
**Investigated**: OCR functionality and accuracy with various label formats; system behavior with different input quality; limitations of automated field extraction; production readiness requirements

**Learned**: OCR works reliably when labels follow predictable formats with clear field names; performance degrades with messy handwriting, blurry photos, or unstructured labels; the system is positioned as AI-assisted pre-fill (not automatic final saving), requiring human verification before data persistence; this design choice makes it appropriate for educational projects and allows graceful degradation in production

**Completed**: Viability determination: System CAN function effectively as an AI-assisted tool with human verification. Current implementation meets requirements for final year project defensibility.

**Next Steps**: Implementation likely continues with testing against real bottle labels; refinement of OCR accuracy and field classification; consideration of database integration for supplier matching if moving toward production deployment


Access 352k tokens of past work via get_observations([IDs]) or mem-search skill.
</claude-mem-context>