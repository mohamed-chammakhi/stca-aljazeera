# role_laboratoire.md — Lab Technician (`4_laboratoire/`)

Simplest role — 2 pages only: sample list + profile.

---

## Pages

- **Échantillons / Analyses** — samples that are physically present at the company (`recuPhysiquement = true`). Grouped by state: `En attente` / `En cours` / `Soumis`. Lab technician does NOT register samples.

- **Profile** — edit personal info. No dashboard.

---

## Lab Analysis Flow

Two entry methods:

1. **Photo upload** — take or upload a photo of the physical paper analysis report. AI automatically detects and extracts table values to fill the form fields. Technician reviews and confirms. The paper photo is preserved and stored alongside the digital form.

2. **Manual entry** — fill the analysis form directly without a photo.

Export analysis results is supported.

---

## Sample States (lab view)

| State | Meaning |
|-------|---------|
| `En attente` | Analysis not yet started |
| `En cours` | Analysis started but not submitted |
| `Soumis` | Analysis submitted — read-only |

---

## What Lab Sees

Only samples with `recuPhysiquement = true`. Does not see taster evaluations or collector negotiation details.
