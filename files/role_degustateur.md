# role_degustateur.md — Taster / Panel Member (`3_degustateur/`)

Part of a tasting team (multiple tasters, not just one).

---

## Pages

- **Gestion des échantillons** — full list of ALL samples in the app, filterable by date. Taster can:
  - Add a new sample (if a collector missed it or a sample arrived outside collector flow).
  - Edit a sample — edits tracked, previous value visible to all actors.
  - Delete a sample — **only if sample has NOT yet entered `En négociation`**. Once in negotiation or beyond: no edit, no delete.
  - Toggle `recuPhysiquement` — marks sample physically present at company, which unlocks lab analysis.

- **Évaluation organoleptique** — list of all samples with per-taster evaluation states:
  - `En attente` — no evaluation started.
  - `En cours` — form partially filled, not yet submitted.
  - `Soumis` — submitted, read-only.
  Each taster submits their own individual evaluation. CEO sees all tasters' evaluations side by side.

- **Séances de dégustation** — tasting session planner. States: `Planifiée` (upcoming) / `Terminée` (past). To create: title, date, time, location, notes, select participant panel members. Only selected participants receive notification. Each invited participant can confirm attendance with a checkmark.

- **Analyse laboratoire** — read-only view of lab analyses per sample. Filter: `En attente` / `Soumis`.

- **Membres du panel** — list of all panel members in the app.

- **Dashboard** — see business logic below.

- **Profile** — edit name, family name, phone, email, password, photo. Logout.

---

## Edit History Rule

Once `recuPhysiquement = true`, any field edit must store the previous value in `editHistory` (list on the model). All actors (CEO, taster, lab) see old value + new value, clearly labelled — like the "edited" indicator in messaging apps.

---

## Dashboard Business Logic

### Urgency rule (Évaluations urgentes)

A sample appears in the urgent panel if ALL of the following are true:
- `recuPhysiquement == true`
- This taster has NOT yet submitted their evaluation for this sample
- Days waiting = `DateTime.now().difference(sample.dateReceptionEchantillon).inDays`
  - 1 day → amber badge: `"1j en attente"`
  - 2+ days → red badge: `"Xj — critique"`

### Délai de soumission formula

- **Per evaluation:** `delai = date_evaluation_soumise − date_reception_echantillon` (fractional days)
- **Mon délai moy.:** AVG of my delays for evaluations submitted in chosen period
- **Moy. panel:** AVG of all active tasters' delays for the same period
- Endpoint: `GET /api/degustateur/dashboard/delai/?date_debut=YYYY-MM-DD&date_fin=YYYY-MM-DD`
- Returns: `{ "mon_delai_moyen": 1.8, "panel_moyen": 1.4, "nb_evals": 23, "points": [...] }`

### Activité récente — pagination

- Page size: **5 items per load**
- Auto-loads next batch on scroll to bottom (no explicit button)
- Endpoint: `GET /api/activite/?date_debut=...&date_fin=...&offset=0&limit=5`
- Format: `{ "count": N, "results": [...] }`
- Clearing the filter badge requires a confirmation dialog
