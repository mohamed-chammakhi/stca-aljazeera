# Chef Dégustateur Dashboard — Design Spec (Final)
**Date:** 2026-04-24  
**Module:** `lib/5_chef_degustateur/tableau_de_bord/`  
**Reference:** `lib/3_degustateur/tableau_de_bord/` (taster dashboard — visual base)

---

## Goal

Rebuild `5_chef_degustateur/tableau_de_bord/widgets/home_body.dart` with a clean service-backed architecture. The visual style follows the taster dashboard (green AppBar, white cards, same section-label pattern). The content is chef-specific.

---

## App Bar

- Background: `Color(0xFF38835A)` (green — same as taster)
- Title: **"Tableau de bord"**
- Hamburger icon (opens drawer) — white
- Notification bell with unread count badge — white

No greeting, no period tabs, no period navigator, no stats strip.

---

## Sections (top to bottom)

### 1. Pipeline des échantillons
Card with 4 columns separated by `›` arrows:

| Column | Color | Status label |
|--------|-------|-------------|
| Réceptionné | `#3A6EA5` (blue) | "Réceptionné" |
| En attente éval. | `#D07B2F` (amber) | "En attente éval." |
| En cours | `#7B3FC4` (purple) | "En cours" |
| Soumis | `#38835A` (green) | "Soumis" |

Each column:
- Large number: formatted as `10K`, `2.4K`, `187` etc. (divide by 1000, 1 decimal if ≥ 1000)
- Small number below: exact count in smaller gray font
- Thin colored bar below number (opacity 0.3)
- Label below bar

No date filter on this section — shows current live counts.

---

### 2. Évaluations urgentes *(conditional — hidden if empty)*
Same design as taster dashboard `_buildUrgentes()`:
- Red pulsing dot header with count badge
- Each row: reference + collector·supplier + badge (amber "1j en attente" or red "Xj — critique")
- Footer hint: "Appuyez pour ouvrir l'évaluation organoleptique"
- Taps navigate to `EvaluationEchantillonsPage`

---

### 3. Sessions en attente d'approbation *(conditional — hidden if empty)*
- Purple section bar + title + purple count badge
- Each session card: purple left accent + title + date/time/lieu + "Proposée par X"
- Boutons: **✕ Refuser** (outlined red) + **✓ Approuver** (filled green)

---

### 4. Délai de soumission *(panel-wide)*
- Section label + date filter chip (right-aligned)
- Scrollable container, **3 rows visible**, vertical scroll for the rest
- Sorted **worst (slowest) → best (fastest)**
- Each row: `[Name] [progress bar] [X.Xj]`
  - Red if delay > 150% of panel average
  - Orange if delay > 110% of panel average
  - Green otherwise
- Scroll hint below: "↕ défiler pour voir tous"
- Note: *"Délai moyen entre la réception d'un échantillon et la soumission de l'évaluation."*

---

### 5. Alignement avec le panel *(classification divergence)*
- Section label + date filter chip (right-aligned)
- Scrollable container, **3 rows visible**, sorted **most divergent → most aligned**
- Each row: `[Name] [progress bar] [XX%]`
  - Red if ≥ 40%
  - Orange if ≥ 20%
  - Green otherwise
- Note: *"Plus le % est élevé, plus le dégustateur classe différemment du reste du panel."*

**Divergence logic:**
- Per sample where all active tasters have submitted:
  - Find majority classification (EV / Vierge / Lampante)
  - Taster differs by **2 levels** (EV ↔ Lampante) → divergence counted
  - Taster differs by **1 level** (EV ↔ Vierge or Vierge ↔ Lampante) → acceptable, not counted
  - No clear majority (e.g. 3 EV, 3 Vierge) → sample skipped
- Divergence % = divergent samples / total evaluated samples × 100

---

### 6. Mes classifications *(personal — same as taster dashboard)*
- Section label + date filter chip (right-aligned)
- Grouped bar chart (same as taster `_buildClassifications()`):
  - X axis: months/periods
  - Y axis: **échelle visible** (left axis with numeric scale labels: 1, 2, 3…)
  - 3 bars per group: Extra Vierge (green `#38835A`), Vierge (olive `#6B8143`), Lampante (amber `#D07B2F`)
  - Rounded top corners on bars
- Legend row below: ■ Extra Vierge · ■ Vierge · ■ Lampante

---

## Removed sections (compared to current home_body.dart)
- ~~Greeting / header zone~~
- ~~Period tabs (Jour/Semaine/Mois/Année)~~
- ~~Period navigator~~
- ~~Stats strip~~
- ~~KPI grid (4 rectangles)~~
- ~~Activité du panel (bar chart per taster)~~
- ~~Cohérence des dégustateurs (score agreement)~~
- ~~Profil sensoriel consensus (radar chart)~~

---

## Architecture

### New files to create

```
lib/5_chef_degustateur/tableau_de_bord/
  models/
    dashboard_chef_degustateur.dart
  services/
    dashboard_chef_degustateur_service.dart
```

### File to rewrite

```
lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
```

`homepage_page.dart` — no changes needed (keeps `onSimulerNotification` callback).

---

## Models

```dart
// Pipeline
class PipelineChefData {
  final int receptionne;
  final int enAttenteEval;
  final int enCours;
  final int soumis;
}

// Urgents (reuse taster EvaluationUrgente model or duplicate)
class EvaluationUrgenteChef {
  final String id, reference, collecteurNom, fournisseurNom;
  final int joursEnAttente;
}

// Session en attente d'approbation
class SessionEnAttente {
  final String id, titre, date, heure, lieu, proposePar;
}

// Délai panel
class DelaiMembre {
  final String nom;
  final double delaiMoyen;
  final double panelMoyen;
}
class DelaiPanelData {
  final List<DelaiMembre> membres; // pre-sorted worst→best
  final double panelMoyen;
}

// Alignement panel
class AlignementMembre {
  final String nom;
  final double divergencePct;
}
class AlignementPanelData {
  final List<AlignementMembre> membres; // pre-sorted worst→best
}

// Classifications (personal — same structure as taster)
class ClassificationPoint {
  final String label;
  final int extraVierge, vierge, lampante;
}
```

All models implement `fromJson` / `toJson` with `snake_case` keys. All IDs are `String`.

---

## Service

```dart
class DashboardChefDegustateurService {
  Future<PipelineChefData> fetchPipeline();
  Future<List<EvaluationUrgenteChef>> fetchUrgentes();
  Future<List<SessionEnAttente>> fetchSessionsEnAttente();
  Future<DelaiPanelData> fetchDelai({DateTime? dateDebut, DateTime? dateFin});
  Future<AlignementPanelData> fetchAlignement({DateTime? dateDebut, DateTime? dateFin});
  Future<List<ClassificationPoint>> fetchClassifications({DateTime? dateDebut, DateTime? dateFin});
}
```

All methods return mock data with `// TODO: replace with API call` markers.

---

## Design constants

```dart
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _white    = Color(0xFFFFFFFF);
const Color _amber    = Color(0xFFD07B2F);
const Color _red      = Color(0xFFC0392B);
const Color _blue     = Color(0xFF3A6EA5);
const Color _purple   = Color(0xFF7B3FC4);
const Color _olive    = Color(0xFF6B8143);
```
