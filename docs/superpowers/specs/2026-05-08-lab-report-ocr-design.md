# Laboratory Report OCR — Design Spec

**Backlog item:** 19/4 (Lab Technician)
**Status:** Design

---

## Goal

Lab Technician scans a paper laboratory analysis report with the phone, and the system auto-fills the structured analysis form (acidity, peroxides, K270, K232, ΔK).

---

## Approach

Server-side OCR via a dedicated **Python Flask microservice**. This is intentional — to demonstrate Python AI work to the jury (image preprocessing, OCR engine, regex extraction) instead of a black-box mobile API.

Stack:
- **OCR engine:** Tesseract (`pytesseract`) with French language data
- **Preprocessing:** Pillow + OpenCV (grayscale, denoise, threshold)
- **Field extraction:** regex patterns matched against known field labels
- **Service layer:** Flask
- **Containerization:** Docker (optional but cleaner deployment)

---

## Architecture

```
Flutter (lab analysis form)
        │
        ├─ "Scanner rapport" button
        │       ↓
        │   Camera captures lab report
        │       ↓
        │   POST /ocr/lab-report  (multipart image)
        │
        ▼
Flask ML service
        │
        ├─ image preprocessing (Pillow + OpenCV)
        │       ↓ grayscale, denoise, adaptive threshold
        │
        ├─ Tesseract OCR (lang=fra)
        │       ↓ raw text
        │
        ├─ FieldExtractor (regex)
        │       ↓ structured dict
        │
        └─ JSON response
                  ↓
Flutter populates analysis form
```

---

## Components

### Python service (`ml_service/`)

```
ml_service/
├── app.py                    # Flask app
├── ocr/
│   ├── preprocessor.py       # image cleanup
│   ├── tesseract_runner.py   # OCR wrapper
│   └── field_extractor.py    # regex parsing
├── tests/
│   └── test_field_extractor.py
└── requirements.txt
```

### Endpoint

```
POST /ocr/lab-report
Content-Type: multipart/form-data
body: image=<file>

Response 200:
{
  "raw_text": "...",
  "fields": {
    "acidite_libre": 0.4,
    "peroxydes": 8.2,
    "k270": 0.15,
    "k232": 1.85,
    "delta_k": 0.002
  },
  "confidence": {
    "acidite_libre": "high",
    "peroxydes": "high",
    "k270": "medium"
  }
}
```

### Regex patterns

```python
PATTERNS = {
  "acidite_libre": r"Acidit[eé]\s*(?:libre)?\s*[:\s]+(\d+[\.,]\d+)",
  "peroxydes":    r"Peroxydes?\s*[:\s]+(\d+[\.,]\d+)",
  "k270":         r"K\s*270\s*[:\s]+(\d+[\.,]\d+)",
  "k232":         r"K\s*232\s*[:\s]+(\d+[\.,]\d+)",
  "delta_k":      r"(?:Δ\s*K|Delta\s*K)\s*[:\s]+(\d+[\.,]\d+)",
}
```

### Confidence heuristic
- `high` — clean numeric match
- `medium` — match found but with character ambiguity (e.g., O vs 0)
- `low` — no match or value out of plausible range

---

## Image Preprocessing Pipeline

1. Convert to grayscale
2. Resize so smallest side ≥ 1000px (Tesseract works better)
3. Denoise (median blur)
4. Adaptive threshold for handwritten/printed mix
5. Optional: deskew via Hough transform

---

## Flutter Side

### Service: `LabReportOcrService` (lib/4_laboratoire/.../services/)
- `Future<ParsedLabReport> scanReport(File image)`
- POSTs to Flask service base URL (in `lib/config.dart`)

### UI flow
1. Lab tech taps "Scanner rapport" on analysis form
2. Camera or gallery picker
3. Loading spinner while waiting
4. Form auto-populates with extracted values
5. Each field shows confidence badge (vert / jaune / rouge)
6. Lab tech reviews, edits low-confidence fields, saves

---

## Testing

- Unit tests for `FieldExtractor` with 20 sample texts
- Integration tests with 10 real lab report photos
- Postman collection for endpoint testing (good demo for jury)

---

## What This Demonstrates To Jury

- Python image processing pipeline (not just calling an API)
- Custom field extraction logic
- Microservice architecture (Django main + Flask ML sidecar)
- Confidence scoring (not blind trust in OCR output)

---

## Out of Scope

- Multi-page report support (only single image per scan)
- Handwritten lab reports (only printed/typed)
- Auto-detection of report template variant
