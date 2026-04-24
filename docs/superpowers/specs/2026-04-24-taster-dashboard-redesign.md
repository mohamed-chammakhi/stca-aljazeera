# Taster Dashboard Redesign — Design Spec
**Date:** 2026-04-24  
**Module:** `lib/3_degustateur/tableau_de_bord/`  
**Also affects:** `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` (date filter replacement)

---

## Summary

Redesign the taster (dégustateur) dashboard homepage. Remove the KPI grid and unused sections. Add meaningful sections with consistent date filtering using the existing `DateFilterSheet` widget.

---

## Sections — Final Order

### 1. Évaluations urgentes (unchanged structure, new urgency logic)
- Shows samples that have been waiting for this taster's evaluation.
- **Urgency logic:**
  - `1 jour` without evaluation → **warning** (amber badge: `"1j en attente"`)
  - `2+ jours` without evaluation → **critique** (red badge: `"Xj — critique"`)
- Calculated as: `DateTime.now().difference(dateReceptionEchantillon).inDays`
- Tapping a row navigates to `EvaluationEchantillonsPage`.
- Hidden entirely if no urgent items.

### 2. Pipeline de mes évaluations (unchanged)
- 3 counters: Non évaluée (blue) → En cours (amber) → Soumise (green)
- No date filter.

### 3. Mes classifications
- **Replaces** the old "Mes classifications récentes" table.
- **Grouped bar chart** (Extra Vierge / Vierge / Lampante per time period).
- Exact value labels rendered inside each bar (white text, hidden if bar too short).
- **Date filter:** `DateFilterSheet` (Jour exact / Période modes). Calendar uses native Flutter `showDatePicker` with year-jump on header tap.
- Chart data recalculates for the chosen period.
- Legend below chart.

### 4. Présence aux séances
- Donut chart (attended / missed) + 3 stat rows + next session teaser.
- **Date filter added:** `DateFilterSheet` (Période mode). Stats and donut recalculate for chosen period.

### 5. Délai de soumission (replaces old "Performance vs panel" radar)
- **Single metric only:** average days between `dateReceptionEchantillon` and `dateEvaluationSoumise`.
- **Summary strip:** Mon délai moy. / Moy. panel / Nb évals. comptées — all recalculated per period.
- **Line chart:** one point per submitted evaluation (X = date soumission, Y = délai in days). Dashed line = panel rolling average for same period.
- **Date filter:** `DateFilterSheet` in **Période mode only** (no Jour exact toggle shown). Same-date trick (Du = Au) gives single-day view — explained in hint text.
- Diff badge: green if below panel average, red if above.

### 6. Activité récente
- Fixed-height scrollable container (height: ~220px).
- **Pagination:** loads 5 items on mount, auto-loads 5 more when user scrolls to bottom. No explicit "load more" button.
- Footer shows `"1–5 sur 23"` counter + animated dots while loading.
- **Date filter:** `DateFilterSheet` (both Période and Jour exact modes available).
- Active filter shown as a badge below the date chip. Badge has `"✕ Effacer"` button → confirmation dialog before clearing.

---

## Removed Sections

| Section | Reason |
|---|---|
| KPI grid (green container) | Redundant with pipeline + other sections |
| Mes classifications récentes (table) | Replaced by bar chart |
| Progression mensuelle (monthly bar chart) | Redundant |
| Performance vs panel (radar chart) | Too complex, confusing metrics |

---

## Date Filtering — Universal Pattern

**All date filters** use the existing `DateFilterSheet` from `lib/3_degustateur/gestion_echantillons/widgets/search_filter_bar.dart`.

- Trigger: calendar icon chip in the section header (right side).
- Active state: chip turns green with a dot indicator.
- Sheet modes:
  - **Jour exact** — single `showDatePicker` field.
  - **Période** — two `showDatePicker` fields (Du / Au).
- Year navigation: tap the month/year header in the native calendar → year grid appears.
- The "Effacer" button inside the sheet clears immediately (no confirm needed — user is still in the sheet).
- The "✕ Effacer" badge outside the sheet (activité récente only) requires a confirmation dialog.

**Also:** Replace CEO dashboard's `_PeriodSheet` + `showDateRangePicker` with `DateFilterSheet` for consistency.

---

## Urgency Logic — CLAUDE.md Addition

```
## Taster Urgency Rule (dashboard)
A sample is "urgent" for a taster if:
- The sample is physically received (recuPhysiquement = true)
- The taster has NOT yet submitted their evaluation
- Days waiting = DateTime.now().difference(sample.dateReceptionEchantillon).inDays
  - 1 day  → amber badge "1j en attente"
  - 2+ days → red badge "Xj — critique"
```

---

## Délai de Soumission — Backend Logic

```
Mon délai (per evaluation) = date_evaluation_soumise - date_reception_echantillon (in days)
Mon délai moy. (period)    = AVG of all my delays for evaluations submitted in the period
Moy. panel (period)        = AVG of all delays for ALL active tasters in the same period
```

Both are simple SQL aggregates. No complex scoring needed.

---

## Activité Récente — Backend Pagination

- Endpoint: `GET /api/activite/?date_debut=...&date_fin=...&page=1&page_size=5`
- Follows Django paginated response: `{ "count": N, "results": [...] }`
- Flutter service fetches page by page; appends to local list on scroll.
- Filter by date reduces the queryset before pagination.

---

## Files to Modify

| File | Change |
|---|---|
| `lib/3_degustateur/tableau_de_bord/homepage_page.dart` | Full rebuild of dashboard body |
| `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart` | Replace content with new sections |
| `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` | Replace `_PeriodSheet` with `DateFilterSheet` |
| `CLAUDE.md` | Add urgency logic + délai calculation + pagination rule |

### New files (if needed)
| File | Purpose |
|---|---|
| `lib/3_degustateur/tableau_de_bord/models/dashboard_degustateur.dart` | Mock data models for dashboard |
| `lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart` | Service returning mock data |

---

## Constraints

- State management: `StatefulWidget` + `setState()` only.
- All mock data via service layer (no hardcoding in widgets).
- `fl_chart` already in `pubspec.yaml` — use for bar + line charts.
- Reuse `DateFilterSheet` from `search_filter_bar.dart` — no new date picker component.
- No new packages needed.
