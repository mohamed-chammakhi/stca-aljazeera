# Backend Map

This file is the backend checkpoint map. Keep it updated after every backend
change so we always know what is done, what is left, and where to continue.

## Non-Negotiable Guardrails

- Preserve all existing mock/fake data. Mock data is useful for showing UI
  scenarios before every backend endpoint is connected.
- Do not delete mock data files when connecting real APIs. Keep them behind the
  service layer as fallback/dev data unless the user explicitly asks to remove
  them.
- Do not change page design, layouts, colors, spacing, cards, drawers, or
  navigation style while doing backend work.
- Backend work should change services, models, API clients, Django code, and
  minimal state-loading glue only.
- Widgets must not call HTTP directly. Pages call services; services call
  `apiClient`; services return models.
- No offline mode is in scope.
- No PDF export is in scope.

## Current Checkpoint

Last confirmed working path:

1. Django backend runs on PC:
   `python manage.py runserver 0.0.0.0:8000`
2. Phone connects by USB.
3. ADB reverse maps phone localhost to PC backend:
   `adb reverse tcp:8000 tcp:8000`
4. Flutter runs with:
   `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000`
5. Login works from the phone.

Seeded test accounts:

| Role | Email | Password |
| --- | --- | --- |
| Direction / CEO | `direction@stca.tn` | `Test@12345` |
| Collecteur | `collecteur@stca.tn` | `Test@12345` |
| Degustateur | `degustateur@stca.tn` | `Test@12345` |
| Technicien Labo | `labo@stca.tn` | `Test@12345` |
| Chef de Dégustation | `chef@stca.tn` | `Test@12345` |

## Done

### Authentication

Backend:

- Custom Django user model exists in `backend_new/users/models.py`.
- JWT login is exposed at `POST /api/auth/login/`.
- JWT refresh is exposed at `POST /api/auth/refresh/`.
- JWT logout is exposed at `POST /api/auth/logout/`.
- Current user profile is exposed at `GET /api/users/me/`.
- Login JWT payload includes `role`, `nom`, `prenom`, and `email`.
- Login response includes `access`, `refresh`, and `user`.
- Seed command exists:
  `python manage.py seed_auth_users`
- Login errors distinguish:
  - `email_not_found`
  - `password_incorrect`
  - `account_inactive`

Flutter:

- `lib/config.dart` supports runtime API URL through:
  `--dart-define=API_BASE_URL=...`
- `lib/core/api_client.dart` stores JWT tokens in `flutter_secure_storage`.
- `lib/core/api_client.dart` sends `Authorization: Bearer <token>`.
- `lib/core/api_client.dart` supports refresh-token retry behavior.
- `lib/core/services/auth_service.dart` exists.
- `lib/main.dart` uses an auth gate to restore valid sessions.
- `lib/main.dart` routes users by role after login.
- Android allows local HTTP during development through manifest cleartext
  traffic.

### Profile Management

Backend:

- Current user profile now supports:
  `PATCH /api/users/me/`
- Authenticated users can update:
  - `nom`
  - `prenom`
  - `telephone`
  - `email`
- Duplicate email validation is enforced case-insensitively.
- Self-profile updates reject protected fields:
  - `id`
  - `role`
  - `is_active`
  - `is_staff`
  - `is_superuser`
  - `password`
  - `date_creation`
  - `last_login`
- Backend API tests cover profile load, allowed update, duplicate email
  rejection, and protected-field rejection.

Flutter tasks:

- Shared profile service exists in `lib/core/services/profile_service.dart`.
- Existing profile pages now load and save through `/api/users/me/` without
  changing their design:
  - `lib/1_ceo/profil_ceo_page.dart`
  - `lib/2_collecteur/profilcom.dart`
  - `lib/3_degustateur/profil/profil_page.dart`
  - `lib/4_laboratoire/profil_labo_page.dart`
  - `lib/5_chef_degustateur/profil.dart`
- Profile fields populate from the logged-in Django user.
- Saving any profile field sends a service-layer `PATCH /api/users/me/`.
- UI layout, colors, drawers, navigation, cards, and mock data files were not
  changed.

Expected endpoints:

| Method | URL | Purpose |
| --- | --- | --- |
| `GET` | `/api/users/me/` | Load current authenticated profile |
| `PATCH` | `/api/users/me/` | Update current authenticated profile |

### Direction User Management

Backend:

- User management endpoints are now Direction-only:
  - `GET /api/users/`
  - `POST /api/users/`
  - `POST /api/users/create/`
  - `GET /api/users/{id}/`
  - `PATCH /api/users/{id}/`
  - `DELETE /api/users/{id}/`
  - `POST /api/users/{id}/toggle-active/`
- Direction can list, create, update, delete, and activate/deactivate users.
- Non-Direction roles are forbidden from user management.
- Direction cannot deactivate or delete its own account.
- Duplicate email validation is enforced case-insensitively.
- New accounts default to temporary password `Test@12345` if no password is
  provided.
- Backend API tests cover Direction permissions and user-management actions.

Flutter:

- CEO user management service exists in:
  `lib/1_ceo/utilisateurs/services/utilisateurs_ceo_service.dart`
- CEO `Utilisateurs` page now loads users from `/api/users/`.
- Add user now calls `POST /api/users/`.
- Activate/deactivate now calls `POST /api/users/{id}/toggle-active/`.
- Delete now calls `DELETE /api/users/{id}/`.
- Existing mock users remain as fallback if the API cannot be reached.
- UI layout, colors, spacing, navigation, cards, and mock data files were not
  changed.

### Laboratory Basic Analysis CRUD

Backend:

- Lab-scoped sample list endpoint exists:
  `GET /api/analyses/echantillons/`
- This endpoint returns only samples where `recu_physiquement=true`.
- Returned lab samples include nested analysis data when an analysis exists.
- Analysis CRUD is available through:
  - `GET /api/analyses/`
  - `POST /api/analyses/`
  - `GET /api/analyses/{id}/`
  - `PATCH /api/analyses/{id}/`
  - `DELETE /api/analyses/{id}/`
  - `POST /api/analyses/{id}/soumettre/`
- Lab technicians can create, update, delete, and submit analyses.
- Direction and Chef de Dégustation can read lab analysis data but cannot create,
  update, delete, or submit analyses.
- Analysis creation is blocked unless the sample was physically received.
- Creating or saving an analysis sets the sample lab status to `en_cours`.
- Submitting an analysis sets both the analysis and the sample lab status to
  `soumis`.
- Submitted analyses are read-only and cannot be updated or deleted.
- No PDF export endpoint is in scope.
- Focused API tests were added in `backend_new/analyses/tests.py`.

Flutter:

- Lab service now calls `GET /api/analyses/echantillons/`.
- Lab analysis create/update/delete now goes through `LaboService` and the
  shared `apiClient`.
- Existing mock lab data remains in:
  `lib/4_laboratoire/echantillons_labo/models/mock_echantillons_labo.dart`
- If the lab API cannot be reached, the lab page keeps showing mock data as
  fallback/dev data.
- `AnalyseLabo` now stores the backend analysis `id` and parses Django
  `snake_case` statuses.
- Submitted analyses stay visible but their edit/delete actions are hidden.
- UI layout, colors, spacing, navigation, cards, and mock data files were not
  changed.

Verification:

- Dart analysis passed for the touched lab Flutter files.
- Django tests could not be run from this Codex shell because the project venv
  points to a missing Python executable. Run this locally in CMD/PowerShell:

```bat
cd /d C:\flutterpfe\project3\backend_new
venv\Scripts\activate
python manage.py test analyses
```

### Collector Supplier and Sample CRUD

Backend:

- Supplier endpoints are available:
  - `GET /api/fournisseurs/`
  - `POST /api/fournisseurs/`
  - `GET /api/fournisseurs/{id}/`
  - `PATCH /api/fournisseurs/{id}/`
  - `DELETE /api/fournisseurs/{id}/`
- Collectors can create/update/delete suppliers.
- Direction, Degustateur, and Chef de Dégustation can read suppliers.
- Supplier creation requires `code_fournisseur`.
- Supplier list supports search by name, code, region, and phone.
- Collector sample endpoints are available:
  - `GET /api/echantillons/`
  - `POST /api/echantillons/`
  - `GET /api/echantillons/{id}/`
  - `PATCH /api/echantillons/{id}/`
  - `DELETE /api/echantillons/{id}/`
  - `POST /api/echantillons/bulk/`
  - `POST/PATCH /api/echantillons/{id}/confirmer-achat/`
- Collector list/retrieve is scoped to the logged-in collector's own samples.
- `numero` remains server-generated and read-only.
- `reference_bouteille` is required on sample creation.
- Sample create/update accepts `code_fournisseur`; Django links an existing
  supplier or creates a minimal supplier with that code.
- Sample delete is blocked after physical reception or after the collector
  status advances beyond `receptionne`.
- Direct collector status edits through generic update are blocked; status
  changes use dedicated actions.
- Collector purchase confirmation is blocked unless the sample is in
  `en_negociation`.
- Focused API tests were added in:
  - `backend_new/echantillons/tests.py`
  - `backend_new/fournisseurs/tests.py`

Flutter:

- Collector sample service now calls `/api/echantillons/` first.
- Existing collector mock data remains in:
  `lib/2_collecteur/mes_echantillons/services/echantillon_mock_data.dart`
- If Django cannot be reached, the collector page keeps showing mock samples.
- Create/update/delete/confirm purchase now go through the service layer.
- `numero` is no longer sent in create/update payloads.
- `reference_bouteille` and `code_fournisseur` are sent to Django with
  `snake_case` keys.
- The collector model parses backend `snake_case` statuses safely.
- Add/edit/delete failures now show an error snackbar instead of silently
  changing local state.
- UI layout, colors, spacing, navigation, cards, drawers, and mock data files
  were not changed.

Verification:

- Dart analysis passed for the touched collector Flutter files.
- Django tests could not be run from this Codex shell because the project venv
  points to a missing Python executable. Run this locally in CMD/PowerShell:

```bat
cd /d C:\flutterpfe\project3\backend_new
venv\Scripts\activate
python manage.py test echantillons fournisseurs
```

### Taster Reception and Organoleptic Evaluations

Backend:

- Physical reception can now be confirmed by Degustateur and Chef de Dégustation:
  - `PATCH /api/echantillons/{id}/confirmer_reception/`
  - `POST/PATCH /api/echantillons/{id}/confirmer-reception/`
- Reception confirmation is idempotent: already received samples keep their
  existing reception timestamp.
- Evaluation endpoints are Degustateur/Chef only:
  - `GET /api/evaluations/`
  - `GET /api/evaluations/?echantillon={id}`
  - `POST /api/evaluations/`
  - `GET /api/evaluations/{id}/`
  - `PATCH /api/evaluations/{id}/`
  - `DELETE /api/evaluations/{id}/`
  - `POST /api/evaluations/{id}/soumettre/`
- Each evaluator only sees and edits their own evaluations.
- Evaluation creation is blocked unless the sample is physically received.
- Creating a draft moves the sample degustation status to `en_cours`.
- Submitted evaluations are locked and cannot be updated or deleted.
- Submitting an evaluation sets `soumis_le` and keeps the sample degustation
  status `en_cours` until all active Degustateur/Chef users have submitted.
- Focused API tests were added in `backend_new/evaluations/tests.py`.
- Reception tests were added in `backend_new/echantillons/tests.py`.

Flutter:

- Degustateur evaluation list now loads samples from `/api/echantillons/`.
- The evaluation service overlays the logged-in taster's own
  `/api/evaluations/` records so status is per evaluator in the UI.
- Evaluation form now saves drafts with `POST/PATCH /api/evaluations/`.
- Submitting now saves the draft first, then calls
  `POST /api/evaluations/{id}/soumettre/`.
- Degustateur sample management now confirms physical reception through
  `/api/echantillons/{id}/confirmer-reception/`.
- Existing degustateur mock data remains in place as fallback/dev scenario
  data.
- UI layout, colors, spacing, cards, drawers, geography dropdown assets, and
  mock data files were not changed.

Verification:

- Flutter analysis passed for touched degustateur files:
  `flutter analyze lib/3_degustateur/evaluation_echantillons/services/evaluation_service.dart lib/3_degustateur/evaluation_echantillons/navigation/models/echantillon.dart lib/3_degustateur/evaluation_echantillons/formulaire_evaluation.dart lib/3_degustateur/gestion_echantillons/gestion_echantillons_page.dart lib/3_degustateur/gestion_echantillons/services/gestion_echantillons_service.dart`
- Django focused tests passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test evaluations echantillons`

### Sessions and Chef Session Validation

Backend:

- Sprint session route is now available:
  `GET/POST /api/sessions/`
- Existing compatibility route remains available:
  `GET/POST /api/sessions_degustation/`
- Session detail/update/delete remains available through both route prefixes.
- Degustateur and Chef de Dégustation can list and create tasting sessions.
- Sessions created by a Degustateur start as `en_attente_validation`.
- Sessions created by Chef de Dégustation start as `planifiee`.
- Chef de Dégustation can approve pending sessions:
  `POST /api/sessions/{id}/approuver/`
- Chef de Dégustation can refuse pending sessions:
  `POST /api/sessions/{id}/refuser/`
- Refused sessions are excluded from normal session lists.
- Degustateur/Chef can confirm attendance on planned/in-progress sessions:
  `POST /api/sessions/{id}/confirmer_presence/`
- Session API now returns Flutter-aligned fields:
  - `created_by`
  - `created_at`
  - `participant_ids`
  - `participant_noms`
  - `confirmed_participant_ids`
  - `confirmed_participant_noms`
  - `echantillon_ids`
  - `nombre_echantillons_prevus`
- Focused API tests were added in `backend_new/sessions_degustation/tests.py`.

Flutter:

- Shared `SessionDegustation` model now parses backend `snake_case` session
  JSON while preserving the existing UI-friendly date/time display format.
- Degustateur sessions service now calls `/api/sessions/` first.
- Chef sessions service now calls `/api/sessions/` first.
- Create/update/delete/approve/refuse/attendance confirmation now go through
  service methods.
- Existing Degustateur mock session data remains in:
  `lib/3_degustateur/sessions_degustation/models/mock_sessions.dart`
- Existing Chef mock session data remains in:
  `lib/5_chef_degustateur/sessions_degustation/models/mock_sessions.dart`
- If Django cannot be reached, both session pages still fall back to mock data.
- UI layout, colors, spacing, cards, drawers, dialogs, and mock data files were
  not changed.

Verification:

- Django focused tests passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test sessions_degustation`
- Flutter analysis passed for touched session files:
  `flutter analyze lib/core/models/session_degustation.dart lib/3_degustateur/sessions_degustation/services/sessions_service.dart lib/3_degustateur/sessions_degustation/sessions_degustation_page.dart lib/3_degustateur/sessions_degustation/widgets/session_card.dart lib/5_chef_degustateur/sessions_degustation/services/sessions_chef_service.dart lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart lib/5_chef_degustateur/sessions_degustation/widgets/session_card.dart`
- `makemigrations sessions_degustation --check --dry-run` reports no changes.
- Global `makemigrations --check --dry-run` still reports an unrelated pending
  notifications migration:
  `notifications/migrations/0002_alter_notification_type.py`

### Panel Members Consultation

Backend:

- Authenticated panel-member consultation endpoint is available:
  `GET /api/users/panel-members/`
- The endpoint returns active users with role `degustateur` or `chef_degustation`.
- Direction, collector, lab, and inactive panel accounts are excluded from the
  panel-member list.
- Response fields match the existing Flutter member-card contract:
  `id`, `nom`, `prenom`, `role`, `membre_depuis`, and `est_en_ligne`.
- Email and other account-management fields are not exposed through this
  consultation endpoint.
- Focused API tests were added in `backend_new/users/tests.py`.

Flutter:

- Degustateur panel-member service now calls:
  `GET /api/users/panel-members/`
- Chef de Dégustation panel-member service now calls:
  `GET /api/users/panel-members/`
- Existing mock panel member data remains as fallback/dev scenario data if the
  API cannot be reached.
- No visual design, layout, colors, spacing, cards, drawers, or navigation
  behavior was changed.

Verification:

- Django focused tests passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test users`
- Flutter analysis passed:
  `flutter analyze lib/3_degustateur/membres_panel/services/membres_panel_service.dart lib/5_chef_degustateur/membres_panel/services/membres_panel_chef_service.dart`

### Chef Evaluation Overview and Divergence

Backend:

- Chef-only evaluation overview endpoint is available:
  `GET /api/chef/evaluations/`
- Access is restricted to `chef_degustation`; other authenticated roles receive
  `403`.
- The endpoint returns submitted organoleptic evaluations grouped by sample.
- Draft/in-progress evaluations are not exposed in the chef overview.
- Groups include sample metadata needed by the Flutter overview screen:
  `numero`, `reference_bouteille`, `gouvernorat`, `delegation`, `variete`,
  physical reception date, supplier name, submitted count, active panel count,
  completion flag, and per-taster evaluation rows.
- Active panel members without a submitted evaluation are returned as
  `en_attente` rows so the chef can see who has not submitted yet.
- Search supports sample number, bottle reference, variety, supplier name, and
  supplier code.
- Date filters use physical reception date:
  `date_debut=YYYY-MM-DD` and `date_fin=YYYY-MM-DD`.
- Divergence detection now checks all organoleptic score fields and flags a
  sample when at least 3 submitted evaluations exist and any score deviates by
  more than `1.5` from the panel average.
- Divergence details include the attribute, panel average, taster score, and
  absolute deviation.
- Focused API tests were added in `backend_new/chef/tests.py`.

Flutter:

- No visual or navigation changes were made.
- Existing chef overview mock data remains in:
  `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart`
- The endpoint is ready for a later service-layer wiring pass with mock
  fallback preserved.

Verification:

- Django focused tests passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test chef`

### Notifications and Basic Messaging

Backend:

- Authenticated notification endpoints are available:
  - `GET /api/notifications/`
  - `GET /api/notifications/?is_read=false`
  - `PATCH /api/notifications/{id}/`
  - `PATCH /api/notifications/{id}/lire/`
  - `POST /api/notifications/read-all/`
  - `POST /api/notifications/lire-tout/`
  - `GET /api/notifications/unread-count/`
  - `GET /api/notifications/non-lus/`
- Notification list/detail actions are scoped to the logged-in recipient only.
- Notification serializer now returns valid sample identifiers:
  `echantillon`, `echantillon_reference`, and `echantillon_numero`.
- Notification type choices now include:
  `EVALUATION_SOUMISE` and `NOUVELLE_SESSION`.
- Notification section choices now include `SESSIONS`.
- Notification signals are loaded through
  `notifications.apps.NotificationsConfig`.
- Django signals generate notifications for:
  - `NOUVEL_ECHANTILLON`
  - `ECHANTILLON_MODIFIE`
  - `ECHANTILLON_SUPPRIME`
  - `ECHANTILLON_RECU`
  - `EVALUATION_SOUMISE`
  - `TOUTES_EVALUATIONS`
  - `ANALYSE_SOUMISE`
  - `ACHAT_CONFIRME`
  - `NOUVELLE_SESSION`
- `TOUTES_EVALUATIONS` now compares submitted evaluations with all active
  Degustateur/Chef de Dégustation users instead of firing after the first submitted
  evaluation when no draft exists.
- Notification migration was added:
  `backend_new/notifications/migrations/0002_alter_notification_section_alter_notification_type.py`
- Basic message endpoints are available through both route prefixes:
  - `GET/POST /api/messages/`
  - `GET/DELETE /api/messages/{id}/`
  - `PATCH /api/messages/{id}/lire/`
  - Existing compatibility prefix remains:
    `/api/messages_chat/`
- Message list/detail actions are scoped to messages sent or received by the
  logged-in user.
- Message creation forces `expediteur` from the authenticated user token and
  rejects self-messages.
- Only the message recipient can mark a message as read.
- Message serializer keeps existing fields and adds sprint-friendly aliases:
  `is_read` and `horodatage`.
- Focused API tests were added in:
  - `backend_new/notifications/tests.py`
  - `backend_new/messages_chat/tests.py`

Flutter:

- No Flutter UI or service wiring changes were made.
- Existing role-specific notification mock data and fallback services remain
  available.

Verification:

- Django focused tests passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test notifications messages_chat`
- Migration check passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run`

### Dashboards and Aggregations

Backend:

- Direction-only CEO dashboard endpoint is available:
  `GET /api/ceo/dashboard/`
- Non-Direction roles receive `403` from the CEO dashboard.
- CEO dashboard accepts optional sample creation date filters:
  `date_debut=YYYY-MM-DD` and `date_fin=YYYY-MM-DD`.
- CEO dashboard keeps simple legacy keys for easy Flutter wiring:
  `echantillons_total`, `echantillons_selectionnes`, `achats_confirmes`,
  `stocks_arrives`, `evaluations_en_attente`, and `analyses_soumises`.
- CEO dashboard also returns structured aggregates:
  - `kpis`
  - `pipeline`
  - `performance_collecteurs`
  - `collecteurs`
  - `fournisseurs`
  - `classifications`
  - `decisions_urgentes`
  - `stock`
  - `evolution_achats`
- CEO collector performance includes sample count, approval rate, total
  confirmed-purchase value, and average days to close.
- CEO urgent decisions list samples whose evaluations are submitted while CEO
  action is still pending.
- Chef dashboard endpoints are restricted to `chef_degustation`:
  - `GET /api/chef/dashboard/pipeline/`
  - `GET /api/chef/dashboard/urgentes/`
  - `GET /api/chef/dashboard/sessions-en-attente/`
  - `GET /api/chef/dashboard/delai/`
  - `GET /api/chef/dashboard/alignement/`
  - `GET /api/chef/dashboard/classifications/`
  - `GET /api/chef/dashboard/presence/`
  - `GET /api/chef/dashboard/urgentes-ceo/`
  - `GET /api/chef/dashboard/activite/`
- Chef urgent evaluation rows now include Flutter-aligned fields:
  `reference`, `collecteur_nom`, `fournisseur_nom`, and `jours_en_attente`.
- Chef pending-session rows now include `propose_par`.
- Chef delay metrics now use fractional day differences between sample
  physical reception and evaluation submission.
- Chef alignment metrics require at least 3 submitted evaluations and evaluate
  all organoleptic score fields instead of treating missing scores as `0`.
- Chef activity rows now include `id`, `action`, and `horodatage`, and exclude
  unsent draft evaluations so pagination does not crash on null submission
  dates.
- Focused API tests were added/expanded in:
  - `backend_new/ceo/tests.py`
  - `backend_new/chef/tests.py`

Flutter:

- No Flutter UI or service wiring changes were made.
- Existing dashboard mock data remains in place for CEO and Chef dashboards.
- Backend responses are ready for a later service-layer wiring pass with mock
  fallback preserved.

Verification:

- Django focused tests passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test ceo chef`
- Migration check passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run`

### CEO Purchase Validation

Backend:

- CEO purchase validation now follows the Flutter mock contract:
  `en_negociation` plus non-null `budget_negociation` means a proposal is
  submitted and awaiting Direction validation.
- Direction can list submitted proposals with:
  `GET /api/echantillons/?statut=en_negociation&proposition_soumise=true`
- Direction can list decided proposals with:
  `GET /api/echantillons/?statut__in=achat_confirme,refuse`
- Collector `POST/PATCH /api/echantillons/{id}/confirmer-achat/` now submits a
  proposal without moving the sample to `achat_confirme`.
- Direction `POST/PATCH /api/echantillons/{id}/confirmer-achat/` confirms the
  submitted proposal, sets `statut_collecteur=achat_confirme`,
  `statut_ceo=achat_confirme`, and keeps `stock_arrive=false`.
- Direction can refuse a submitted proposal with:
  `POST /api/echantillons/{id}/refuser-achat/`
- Refusal stores `raison_refus` and moves only the CEO status to `refuse`,
  preserving the collector status choices.
- Purchase proposal notifications now support exactly:
  `type=proposition_achat_attente` and `section=ACHATS_VALIDATION`.
- Submitting a proposal creates the CEO notification message using bottle
  reference, quantity, collector name, and negotiated price.
- `date_livraison_stock_fin` was added so backend responses can support the
  mock date-range shape used by the validation and confirmed-purchase pages.
- Focused API tests cover proposal submission, pending/decided filters,
  Direction confirmation, Direction refusal, and notification creation.

Flutter:

- No Flutter UI, design, navigation, layout, or mock data files were changed.
- Existing mock validation data remains intact and available as the sacred
  frontend contract until a later service-wiring pass.

Verification:

- Django focused tests passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test echantillons -v 1`
- Notifications focused tests passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py test notifications -v 2`
- Migration check passed:
  `$env:DEBUG='True'; $env:DB_ENGINE='sqlite'; .\venv\Scripts\python.exe manage.py makemigrations --check --dry-run`

### Collector Purchase Remark

Backend:

- Collector purchase proposals accept and return the optional
  `remarque_collecteur` field.
- The remark is stored separately from the sample registration `remarques`
  field and survives subsequent sample retrievals.

Flutter:

- The purchase-confirmation dialog sends and reloads the collector's optional
  remark through `EchantillonCollecteurService`.

Verification:

- Migration consistency check passed with `No changes detected`.
- The focused persistence/reload API test passed: 1 test.
- The complete `echantillons` suite passed: 25 tests.
- The full Django suite ran 159 tests; its only failure remains the documented
  pre-existing Chef dashboard classification test.

### Backlog Table Completion Pass - Non-AI Scope

Backend:

- Panel member consultation is available to Degustateur and Chef roles through:
  `GET /api/users/panel-members/`
- Urgent laboratory requests are available to Degustateur and Chef roles through:
  `POST /api/notifications/analyse-urgente/`
- Urgent request creation validates physical sample reception, prevents duplicate
  urgent requests for the same requester/sample pair, and notifies active lab
  technicians with `type=ANALYSE_URGENTE`.
- Laboratory analysis consultation now allows Direction, Chef, and Degustateur
  read access while keeping create/update/delete/submit restricted to
  `laboratoire`.
- Direction can read submitted organoleptic evaluations from
  `GET /api/evaluations/`; create/update/submit remains restricted to
  Degustateur/Chef.
- CEO dashboard endpoint is implemented at `GET /api/ceo/dashboard/` and returns
  KPIs, pipeline counts, collector performance, supplier frequency,
  classifications, urgent decisions, stock state, and purchase evolution.

Flutter:

- Panel member consultation services for Degustateur and Chef now call
  `/api/users/panel-members/` with mock fallback.
- Degustateur and Chef lab consultation services now call backend analysis/sample
  endpoints with mock fallback.
- Degustateur and Chef urgent lab buttons now call
  `/api/notifications/analyse-urgente/`.
- CEO notification service now uses backend list/read/read-all/unread-count
  endpoints with mock fallback.
- Degustateur and Chef notification services now use backend notification
  endpoints with mock fallback.
- Chef sample-management service now uses backend sample CRUD/reception endpoints
  with mock fallback.
- Chef evaluation list/form now loads drafts, saves drafts, updates existing
  evaluations, and submits through `/api/evaluations/`.
- Chef cross-panel overview now calls `/api/chef/evaluations/`, including
  divergence data, with mock fallback.
- CEO sample consultation, organoleptic consultation, laboratory consultation,
  and confirmed-purchases pages now load aggregated backend sample data through
  `EchantillonCeoService.fetchCeoViews()` with mock fallback.
- CEO dashboard service/page now calls `/api/ceo/dashboard/` and feeds the
  existing KPI, pipeline, collector, purchase-evolution, classification,
  supplier, and stock cards from live data while preserving mock fallback.

Verification:

- Flutter focused analysis passed for the updated CEO dashboard files.
- Flutter focused analysis passed for the Chef evaluation form/service.
- Earlier focused Django tests in this pass passed for `users`, `notifications`,
  `analyses`, and `evaluations`.
- The PostgreSQL fresh-test-database blocker was fixed by correcting the
  historical `evaluations` migrations so `fruite_vert` is created as a boolean
  from the start.
- Fresh PostgreSQL focused test passed:
  `python manage.py test evaluations -v 1 --noinput`
- The backend was started on `0.0.0.0:8000` and verified from the LAN API URL
  used by the phone build: `http://10.207.180.8:8000/api/schema/` returned `200`.
- Android debug and release APKs were built with:
  `--dart-define=API_BASE_URL=http://10.207.180.8:8000`
  - `build/app/outputs/flutter-apk/app-debug.apk`
  - `build/app/outputs/flutter-apk/app-release.apk`
- Full-project `flutter analyze` still reports pre-existing warnings/infos in
  older role files, but the APK build succeeds.

Deferred:

- AI/OCR extraction is intentionally left for the later AI work the user
  requested to handle separately. Existing OCR-related mock/dev flows remain in
  place.

### Distinct Scheduled and Physical Reception Dates

Backend:

- `Echantillon.date_arrivee_echantillon` now stores only the arrival date
  announced by the collector.
- `Echantillon.date_reception_echantillon` stores the timestamp set by the
  Degustateur/Chef physical-reception action and is exposed read-only by the
  sample API.
- Migration `echantillons.0013` copies the former arrival value into the new
  reception field for already physically received samples without clearing the
  original value, because the historical scheduled date cannot be recovered.
- Reception confirmation preserves the scheduled arrival date and remains
  restricted to Degustateur/Chef.

Flutter:

- The collector sample service now maps and sends the scheduled arrival date
  through `date_arrivee_echantillon` and maps the physical timestamp from
  `date_reception_echantillon`.
- `EchantillonCollecteur.fromJson()` parses both API fields independently.

Verification:

- Django migration consistency check passed with `No changes detected`.
- The complete `echantillons` suite passed: 26 tests.
- The full Django suite passed: 160 tests.

## Next Recommended Backend Feature

### 1. Physical Phone Smoke Test

- Connect an Android phone with USB debugging enabled, then run:
  `flutter install --debug --dart-define=API_BASE_URL=http://10.207.180.8:8000`
- Keep Django running with:
  `python manage.py runserver 0.0.0.0:8000 --noreload`
- Phone and PC must stay on the same Wi-Fi network, and Windows Firewall must
  allow inbound TCP traffic on port `8000`.

### 2. AI/OCR Work

- Azure AI/OCR wiring is now in place in
  `backend_new/core/ocr_service.py`.
- Flutter continues to call the existing multipart endpoints:
  `/api/echantillons/ocr/` and `/api/analyses/ocr/`.
- Django now maps Azure Document Intelligence custom-model fields back to the
  existing Flutter JSON contracts, with configurable field aliases in
  `backend_new/.env`.
- Remaining step: fill the local Azure endpoint, API key, model IDs, and exact
  custom field aliases, then run a phone smoke test with real label/report
  photos.

## How To Continue Next Time

Before starting backend work:

1. Read `AGENTS.md`.
2. Read this file.
3. Read `files/backend.md`.
4. If planning backend implementation, read `files/backend_sprint_plan.md`.
5. Identify the exact role/module being changed.
6. Confirm whether the change touches UI. If yes, preserve visual design and
   only wire data.
7. Update this file at the end with:
   - what was completed
   - what remains
   - the next recommended step
