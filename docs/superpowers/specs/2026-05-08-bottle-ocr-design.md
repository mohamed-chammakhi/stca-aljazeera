# Bottle Label OCR — Design Spec

**Backlog items:** 11/2 (Panel) + 17/2 (Collector)
**Status:** Design

---

## Goal

Let Collector and Panel member scan a handwritten olive oil bottle label with the phone camera and auto-fill the sample creation form.

---

## Approach

On-device OCR using **Google ML Kit Text Recognition v2**. No backend needed.

Why ML Kit:
- Free, no API key
- Runs offline (Collector works in rural areas)
- Supports handwriting (Latin script, French)
- Native Flutter plugin available

---

## Architecture

```
Flutter sample form
        │
        ├─ "Scanner étiquette" button
        │       ↓
        │   Camera / Gallery picker
        │       ↓
        │   ML Kit TextRecognizer (on-device)
        │       ↓
        │   Raw text string
        │       ↓
        │   LabelParser (regex)
        │       ↓
        │   { supplier, region, quantity, date }
        │       ↓
        └─ Auto-populates form fields (user can edit)
```

---

## Components

### 1. `BottleScanService` (lib/<role>/.../services/)
- `Future<String> extractRawText(File image)` — wraps ML Kit call
- Uses `google_mlkit_text_recognition` package

### 2. `LabelParser` (lib/shared/parsers/)
- `ParsedLabel parse(String rawText)`
- Regex patterns:
  - **Quantity:** `(\d+[\.,]?\d*)\s*(kg|kilo|l|litre)`
  - **Date:** `(\d{1,2})[/\-](\d{1,2})[/\-](\d{2,4})`
  - **Supplier name:** heuristic — first capitalized non-keyword line
  - **Region:** match against known Tunisian governorates list

### 3. `BottleScanPage` (UI)
- Camera preview + capture button
- Shows extracted text + parsed fields side-by-side
- "Confirmer" button to inject values into sample form
- "Modifier" allows manual edits before save

---

## Data Flow

1. User taps "Scanner étiquette" on sample form
2. Camera opens, user captures bottle image
3. Image saved to temp dir
4. `BottleScanService.extractRawText()` → ML Kit returns raw text
5. `LabelParser.parse()` → structured fields
6. Navigate back to form, populate fields
7. User reviews, edits if needed, saves sample

---

## Testing

- Unit tests for `LabelParser` with sample raw texts
- Manual tests with 10 real bottle photos (varying lighting/handwriting)
- Edge cases: blurry image, no text detected, partial text

---

## Out of Scope

- Cloud-based OCR fallback (later if accuracy too low)
- Auto-correction of extracted text
- Multilingual labels (only French/Arabic numerals for now)
