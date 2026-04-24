# Chef Dégustateur Dashboard — Design Spec
**Date:** 2026-04-24  
**Module:** `lib/5_chef_degustateur/tableau_de_bord/`  
**Reference:** `lib/3_degustateur/tableau_de_bord/` (taster dashboard)

---

## Goal

Rebuild `5_chef_degustateur/tableau_de_bord/widgets/home_body.dart` so it:
1. Follows the same service-backed architecture as the taster dashboard (model + service + widget layers)
2. Adds two new panel-wide sections: **Délai de soumission** and **Alignement avec le panel**
3. Preserves all existing sections (KPI grid, bar chart, cohérence table, radar, pending sessions)

---

## Sections (top to bottom)

### 1. Header zone *(keep as-is)*
- "Bonjour, Chef 👋" greeting
- Period tabs: Jour / Semaine / Mois / Année
- Period navigator (back / label / forward) with date picker on label tap
- Purple badge showing count of sessions en attente

### 2. Stats strip *(keep as-is)*
`X évaluations · Y dégustateurs actifs · Z alerte(s)`

### 3. KPI Grid *(keep as-is)*
4 cards: Sessions en attente · Évaluations du panel · Accord moyen panel · Alertes cohérence

### 4. Activité du panel *(keep as-is)*
Bar chart — evaluations per taster for the selected period. Orange bars = outlier tasters.

### 5. Délai de soumission *(new — panel-wide)*
- Section label + date filter chip (right-aligned)
- Scrollable container, **3 rows visible**, scroll to see rest
- Ordered **worst (slowest) → best (fastest)**
- Each row: `[Name] [progress bar] [X.Xj]`
  - Red if delay > 150% of panel average
  - Orange if delay > 110% of panel average
  - Green otherwise
- Note at bottom: *"Délai moyen entre la réception d'un échantillon et la soumission de l'évaluation."*
- Data model: `DelaiMembreData` — `List<DelaiMembre>` where each has `nom`, `delaiMoyen` (double), `panelMoyen` (double)
- Backend endpoint (future): `GET /api/chef/dashboard/delai/?date_debut=...&date_fin=...`

### 6. Alignement avec le panel *(new — classification divergence)*
- Section label + date filter chip (right-aligned)
- Scrollable container, **3 rows visible**, scroll to see rest
- Ordered **worst (most divergent) → best (most aligned)**
- Each row: `[Name] [progress bar] [XX%]`
  - Red if divergence ≥ 40%
  - Orange if divergence ≥ 20%
  - Green otherwise
- Note at bottom: *"Plus le % est élevé, plus le dégustateur classe différemment du reste du panel."*

#### Classification divergence logic
For each sample where **all active tasters have submitted** their evaluation:
1. Find the **majority classification** (most common vote: Extra Vierge / Vierge / Lampante)
2. A taster's vote is a **significant divergence** if it differs by **2 levels** from the majority:
   - Extra Vierge ↔ Lampante = divergence (skip one level)
   - Extra Vierge ↔ Vierge = acceptable (adjacent)
   - Vierge ↔ Lampante = acceptable (adjacent)
3. Count divergent samples per taster → divide by total evaluated samples → divergence %
4. Samples where **no single majority** exists (e.g. 3 EV, 3 Vierge, 1 Lampante) → skip, not counted

- Data model: `AlignementMembreData` — `List<AlignementMembre>` where each has `nom`, `divergencePct` (double), `nbEchantillons` (int)
- Backend endpoint (future): `GET /api/chef/dashboard/alignement/?date_debut=...&date_fin=...`

### 7. Cohérence des dégustateurs *(keep as-is)*
Agreement rate table with outlier badges. Threshold < 75% = flagged.

### 8. Profil sensoriel consensus *(keep as-is)*
Radar chart — weighted average sensory scores across all submitted evaluations.

### 9. Sessions en attente d'approbation *(keep as-is)*
Cards with Refuser / Approuver buttons.

---

## Architecture

### New files to create

```
lib/5_chef_degustateur/tableau_de_bord/
  models/
    dashboard_chef_degustateur.dart     ← new
  services/
    dashboard_chef_degustateur_service.dart  ← new
```

### File to rewrite

```
lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart  ← full rewrite
```

No changes to `homepage_page.dart` — it already passes `onSimulerNotification` correctly.

---

## Models (`dashboard_chef_degustateur.dart`)

All models implement `fromJson` / `toJson` with `snake_case` keys. All IDs are `String` (UUID).

```dart
// Panel-level delay per taster
class DelaiMembre {
  final String nom;
  final double delaiMoyen;   // this taster's avg delay in days
  final double panelMoyen;   // panel avg for reference
}

class DelaiPanelData {
  final List<DelaiMembre> membres;  // pre-sorted worst→best
  final double panelMoyen;
}

// Classification alignment per taster
class AlignementMembre {
  final String nom;
  final double divergencePct;   // 0–100
  final int nbEchantillons;     // total evaluated (for context)
}

class AlignementPanelData {
  final List<AlignementMembre> membres;  // pre-sorted worst→best
}
```

Existing inline mock models (`_TasterStat`) are replaced by the above.

---

## Service (`dashboard_chef_degustateur_service.dart`)

```dart
class DashboardChefDegustateurService {
  // TODO: inject ApiClient when backend ready

  Future<DelaiPanelData> fetchDelaiPanel({DateTime? dateDebut, DateTime? dateFin});
  Future<AlignementPanelData> fetchAlignementPanel({DateTime? dateDebut, DateTime? dateFin});
  // existing mocks preserved as methods:
  Future<KpiChefData> fetchKpi(int mode, DateTime date);
  Future<List<TasterBarData>> fetchActivite(int mode, DateTime date);
  Future<List<CoherenceMembre>> fetchCoherence(int mode, DateTime date);
  Future<List<double>> fetchRadar(int mode, DateTime date);
  Future<List<SessionEnAttente>> fetchSessionsEnAttente();
}
```

All mock methods marked `// TODO: remove when backend is ready`.

---

## home_body.dart rewrite

`HomeBody` stays a `StatefulWidget` receiving `onSimulerNotification` from `homepage_page.dart`.

State holds:
- `_mode` (int 0–3), `_date` (DateTime) — period selector
- `_delaiDateDebut`, `_delaiDateFin` — délai filter dates
- `_alignDateDebut`, `_alignDateFin` — alignement filter dates
- `DelaiPanelData? _delai`
- `AlignementPanelData? _alignement`
- Plus existing KPI / bar / cohérence / radar / sessions state

`_loadAll()` fetches all data on init and on period change. Each filterable section has its own `_reload*()` method.

---

## Design constants

```dart
const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _bg       = Color(0xFFFFFFFF);
const Color _amber    = Color(0xFFD07B2F);
const Color _red      = Color(0xFFC0392B);
const Color _purple   = Color(0xFF7B3FC4);
const Color _olive    = Color(0xFF6B8143);
```

---

## Out of scope
- Real API calls (mock data only, TODO markers left for backend swap)
- Navigation changes to `homepage_page.dart`
- Changes to any other module (`3_degustateur`, `1_ceo`, etc.)
