# OCR Bottle Registration — Build Plan

## Reality (confirmed)
Collector writes 3 things with a marker directly on a small plastic bottle:
- **Quantité** — e.g. `8T`, `10.5T`
- **Citerne** — letter+number, free, max ~4 chars, e.g. `c2`, `aa11`
- **Fournisseur/Huilerie** — free name, e.g. `issa rached`

Collector photographs the bottle. AI reads the 3 fields to pre-fill the
registration form (speed). Human confirms/corrects. Photo is stored with the
sample (proof + visual ID for tasters on gestion échantillon page).

## Honest stance
Marker scrawl on curved shiny plastic = hardest OCR case. OCR is an
*assistant that pre-fills*, never the authority. Human-in-the-loop guarantees
correctness. Defense story: "AI speeds registration, human guarantees
correctness, photo doubles as visual ID."

## Scrapped
Paper-slip / boxed-form idea (impossible on a bottle).
Obsolete files: `files/ocr_slip_template.md`, `files/collector_slip.svg`.

## Phases

### Phase 1 — OCR pipeline (no photos needed; placeholder)
- EasyOCR reads all text from a bottle photo (offline, already installed).
- Sort detected strings into the 3 fields by pattern:
  - quantité = digits + optional decimal + `T`
  - citerne = short letter/number combo
  - fournisseur = the longer alphabetic text
- Fournisseur fuzzy-matched to growing supplier list; new → kept as typed.
- Output: 3 guesses + per-field confidence. Runs on company server.

### Phase 2 — Test on real photos (BLOCKED until photos provided, ~later today)
- Run Phase 1 on 3–5 real bottle photos.
- Measure rough accuracy per field. Tune patterns/preprocessing.

### Phase 3 — Flutter registration screen
- Collector takes bottle photo → calls pipeline → 3 editable pre-filled
  fields → collector confirms → sample saved + photo stored.

### Phase 4 — Taster view
- Show stored bottle photo on gestion échantillon page so tasters can tell
  bottles apart.

### Phase 5 — Optional quality (if time)
- Fine-tune / preprocess (deskew, glare reduction, crop) to lift accuracy.

## Current step
Phase 1 — building now with a placeholder image. Phase 2 unblocks when user
supplies bottle photos (~1 hour).
