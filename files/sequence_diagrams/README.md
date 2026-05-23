# Sequence Diagrams — Rendering Guide

Each sequence diagram is provided in three forms:

| File | Purpose | How to render |
|------|---------|---------------|
| `NN_name.md` | Full report content (textual scenario + diagram + implementation notes) | Open in any Markdown viewer (VS Code, GitHub, Obsidian) |
| `NN_name.puml` | **PlantUML source — recommended for the report** | Paste into [plantuml.com/plantuml](https://www.plantuml.com/plantuml) → download PNG/SVG |
| `NN_name.mmd` | Mermaid source (digital fallback) | Paste into [mermaid.live](https://mermaid.live) → export PNG/SVG |

---

## Why PlantUML for the report

PlantUML uses the **classical UML icons** that match the reference student's diagrams exactly:

- `actor` → stick figure
- `boundary` → circle with vertical bar (◯⊢) — for Flutter pages / interfaces
- `control` → circle with curved arrow (◯↻) — for Django ViewSets / controllers
- `entity` → plain circle (◯) — for Django models

Mermaid only renders generic boxes, which look less academic. Use Mermaid for digital previews while iterating, then export the final report image from PlantUML.

---

## Local rendering (optional — for offline / batch export)

Install PlantUML locally and export every diagram to PNG in one command:

```bash
# Requires Java + PlantUML jar on PATH
plantuml -tpng files/sequence_diagrams/*.puml
```

Or render to SVG (sharper for the printed report):

```bash
plantuml -tsvg files/sequence_diagrams/*.puml
```

The PNG / SVG files appear next to each `.puml` source.

---

## Diagram catalog

| ID | Diagram | Source files | Sprint | User story |
|----|---------|--------------|--------|-----------|
| 01 | Authentication | `01_authentication.{md,puml,mmd}` | 1 | 1 |

(More diagrams will be added as the report progresses — Add sample with OCR, Confirm physical reception, Submit organoleptic evaluation, Approve tasting session, Detect panel divergence, Scan laboratory report, Decide sample purchase.)
