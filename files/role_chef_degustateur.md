# role_chef_degustateur.md — Chef de Panel (`5_chef_degustateur/`)

Senior taster who also manages the tasting panel. Submits their own individual evaluation like a regular taster, AND oversees all other tasters' evaluations, manages sessions, and tracks panel performance.

---

## Pages

- **Tableau de Bord** — multi-section dashboard. See Dashboard Business Logic below.

- **Gestion des échantillons** — full list of ALL samples, filterable by date. Same capabilities as the regular taster:
  - Add a new sample.
  - Edit a sample — edits tracked, previous value visible to all actors.
  - Delete — only if sample has NOT entered `En négociation`.
  - Toggle `recuPhysiquement` — marks physical arrival, unlocks lab analysis.

- **Évaluation des échantillons** — the chef submits their OWN individual organoleptique evaluation, same form as a regular taster. States: `En attente` / `En cours` / `Soumis`.

- **Vue d'ensemble des évaluations** — EXCLUSIVE to this role. Read-only overview of all tasters' submitted evaluations per sample, side by side. Key behaviors:
  - Expand/collapse per-sample to see each taster's classification + scores.
  - "Formulaire" button opens the shared CEO-style read-only evaluation form sheet.
  - **Divergence detection**: if any taster's score on an attribute deviates more than 1.5 from the panel average (requires ≥ 3 submitted evals), a `Divergence` warning badge appears on the sample card.
  - Filterable by date of physical reception (`recuPhysiquement` date) and by search query.

- **Séances de dégustation** — full CRUD on sessions. States:
  - `En attente validation` — proposed by a panel member, awaiting chef approval.
  - `Planifiée` — approved/confirmed upcoming session.
  - `Terminée` — past session.
  The chef can approve or refuse sessions in `En attente validation`. When creating a session: title, date, time, location, notes, participant selection, planned sample count. Only selected participants are notified.

- **Analyse laboratoire** — read-only view of lab analyses per sample. Filter: `En attente` / `Soumis`.

- **Membres du panel** — list of all panel members in the app.

- **Notifications** — see Notification System below.

- **Profil** — edit name, family name, phone, email, password, photo. Logout.

---

## Edit History Rule

Once `recuPhysiquement = true`, any field edit must store the previous value in `editHistory`. All actors see old value + new value, clearly labelled.

---

## Dashboard Business Logic

### Pipeline section

Counts of all samples across states:
- `Réceptionné` — received but not yet evaluated
- `En attente éval` — physically received, evaluations not yet started
- `En cours` — at least one evaluation in progress
- `Soumis` — all evaluations submitted

Endpoint: `GET /api/chef/dashboard/pipeline/`
Returns: `{ "receptionne": N, "en_attente_eval": N, "en_cours": N, "soumis": N }`

### Évaluations urgentes section

Samples where at least one taster has not submitted yet, sorted by days waiting:
- `joursEnAttente == 1` → amber badge `"1j en attente"`
- `joursEnAttente >= 2` → red badge `"Xj — critique"`

Endpoint: `GET /api/chef/dashboard/urgentes/`

### Sessions en attente section

Sessions in `En attente validation` state — awaiting chef approval.

Endpoint: `GET /api/chef/dashboard/sessions-en-attente/`

### Délai par membre section

Per-taster average submission delay vs. panel average. Filterable by date range.
- **delai per eval** = `date_evaluation_soumise − date_reception_echantillon` (fractional days)
- **delai_moyen** = AVG of that taster's delays in the chosen period
- **panel_moyen** = AVG across all active tasters for the same period

Endpoint: `GET /api/chef/dashboard/delai/?date_debut=YYYY-MM-DD&date_fin=YYYY-MM-DD`
Returns: `{ "membres": [{ "nom": "...", "delai_moyen": 1.8, "panel_moyen": 1.4 }, ...], "panel_moyen": 1.4 }`

### Alignement panel section

Divergence percentage per taster — how often a taster's classification diverges from the panel consensus. Filterable by date range.

Endpoint: `GET /api/chef/dashboard/alignement/?date_debut=YYYY-MM-DD&date_fin=YYYY-MM-DD`
Returns: `{ "membres": [{ "nom": "...", "divergence_pct": 28.0 }, ...] }`

### Classifications section

Historical bar chart: Extra Vierge / Vierge / Lampante counts per month. Filterable by date range.

Endpoint: `GET /api/chef/dashboard/classifications/?date_debut=YYYY-MM-DD&date_fin=YYYY-MM-DD`
Returns: `[{ "label": "Jan", "extra_vierge": 5, "vierge": 2, "lampante": 0 }, ...]`

### Présence section

Chef's own session attendance stats:
- `present` / `manquee` counts → attendance rate
- Next upcoming session: title, date, location, countdown

Endpoint: `GET /api/chef/dashboard/presence/?date_debut=...&date_fin=...`
Returns: `{ "present": 18, "manquee": 1, "prochaine_titre": "...", "prochaine_date": "...", "prochaine_lieu": "...", "prochaine_countdown": "4j" }`

### Urgentes CEO section

Samples where all evaluations are submitted but the CEO has not yet acted (approved/refused for purchase). Chef can see which samples are blocking the CEO.

Endpoint: `GET /api/chef/dashboard/urgentes-ceo/`
Returns: `[{ "id": "...", "numero": "...", "reference_bouteille": "...", "collecteur_nom": "...", "fournisseur_nom": "..." }, ...]`

### Activité récente section

Paginated chef activity log. Page size: **5 items per load**. Auto-loads next batch on scroll to bottom.

Endpoint: `GET /api/chef/dashboard/activite/?date_debut=...&date_fin=...&offset=0&limit=5`
Returns: `{ "count": N, "results": [{ "id": "...", "action": "...", "horodatage": "...", "type": "..." }, ...] }`

Activity types: `evaluation`, `approbation`, `refus`, `seance_presente`, `seance_manquee`

---

## Notification System

Bell icon in the dashboard AppBar shows live unread count badge (orange). Navigates to `NotificationsDegustateurPage`.

### Types & triggers

| Type | Trigger | Deep-link |
|---|---|---|
| `NOUVEL_ECHANTILLON` | Sample created | ECHANTILLONS |
| `ECHANTILLON_MODIFIE` | Any field edited | ECHANTILLONS |
| `ECHANTILLON_SUPPRIME` | Sample deleted | ECHANTILLONS |
| `ECHANTILLON_RECU` | `recuPhysiquement` toggled True | ECHANTILLONS |
| `EVALUATION_SOUMISE` | Any taster submits an evaluation | EVALUATIONS |
| `TOUTES_EVALUATIONS` | All active tasters submitted for a sample | EVALUATIONS |
| `ANALYSE_SOUMISE` | Lab technician submits lab analysis | ANALYSES |
| `NOUVELLE_SESSION` | A panel member proposes a new session | SESSIONS |

Note: `EVALUATION_SOUMISE` and `TOUTES_EVALUATIONS` are exclusive to the chef de panel role.

### Deep-link navigation

| `section` | Navigates to |
|---|---|
| `ECHANTILLONS` | `GestionEchantillonsPage` |
| `EVALUATIONS` | `EvaluationEchantillonsPage` |
| `ANALYSES` | `AnalyseLaboratoirePage` |
| `SESSIONS` | `SessionsDegustationPage` |

---

## Flutter Files

- `lib/5_chef_degustateur/tableau_de_bord/homepage_page.dart` — dashboard entry, AppBar with notification bell
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart` — dashboard body assembly
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_pipeline_section.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_urgentes_section.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_sessions_section.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_delai_section.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_alignement_section.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_classifications_section.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_presence_section.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/home_activite_section.dart`
- `lib/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart`
- `lib/5_chef_degustateur/tableau_de_bord/models/dashboard_chef_degustateur.dart`
- `lib/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart`
- `lib/5_chef_degustateur/gestion_echantillons/gestion_echantillons_page.dart`
- `lib/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart`
- `lib/5_chef_degustateur/vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart`
- `lib/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart`
- `lib/5_chef_degustateur/sessions_degustation/models/session_degustation.dart` (re-exports from `core/`)
- `lib/5_chef_degustateur/analyse_labo/analyse_laboratoire_page.dart`
- `lib/5_chef_degustateur/membres_panel/membres_panel_page.dart`
- `lib/5_chef_degustateur/notifications/models/notification_degustateur.dart`
- `lib/5_chef_degustateur/notifications/services/notification_degustateur_service.dart`
- `lib/5_chef_degustateur/notifications/notifications_degustateur_page.dart`
- `lib/5_chef_degustateur/widgets/chef_colors.dart` — shared color constants (`chefGreen`, `chefDark`, `chefBg`, `chefHeaderBg`)
- `lib/5_chef_degustateur/widgets/chef_nav_mixin.dart` — `ChefNavMixin` for drawer navigation
- `lib/5_chef_degustateur/widgets/statut_chip.dart`
- `lib/5_chef_degustateur/profil.dart`
