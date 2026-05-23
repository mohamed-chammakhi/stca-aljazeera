# OCR Workflow — Collector Handwriting & Lab Reports

Design and jury-defense document. No code here — this is the architecture you build against and present.

---

## 1. The core idea (say this to the jury first)

Quality does not come from choosing a "best" AI model. It comes from the **pipeline around the model**: constraining the input, validating the output with domain knowledge, and asking a human when the system is unsure. Any recognition model is a swappable brick inside this pipeline. This is the defensible contribution.

---

## 2. Constraints (non-negotiable)

- **Fully on-premise.** No cloud API, no data leaving the company. Every model runs locally.
- **Free / unlimited.** Open-source only (EasyOCR, PaddleOCR, TrOCR — Apache/MIT).
- **Offline-first.** Collector works in the field with no connectivity.
- **Auditable.** A wrong sample ID or chemical value corrupts a purchase decision, so errors must be caught, not hidden.

---

## 3. Two different problems

| | Collector slip | Lab report |
|---|---|---|
| Content | Handwritten codes/IDs + names | Printed structured chemical analysis |
| Hard part | Faithful reading of arbitrary codes | Reliable numeric values from tables |
| Approach | Constrained form + character recognition | Table OCR + strict numeric validation |

---

## 4. Collector handwriting — the workflow

**Step 1 — Constrain the input (design the slip).**
Structured paper form: labeled zones, **boxed cells (one character per box)** for the critical fields (sample ID, quantity, supplier code, date), plus corner markers for alignment.
*Defense:* "Errors on a sample ID corrupt a purchase, so I constrained the input to make those fields highly reliable instead of trusting a model on free handwriting." This single decision improves quality more than any model swap.

**Step 2 — Align & locate fields.**
Photo is deskewed and aligned to the known form template using a perspective transform (deterministic, classic, easy to explain). Each field is cropped by its known position. Free-text zones use text detection (EasyOCR's detector).

**Step 3 — Recognize, split by field type (key quality move).**
- **Boxed fields (IDs, codes, numbers, dates):** isolated-character recognition with **no language model** — either a small CNN trained in-house (EMNIST + own samples) or EasyOCR locked to the `A–Z 0–9` charset. No "guess a real word" bias. This is also the student-built AI component.
- **Free-text fields (supplier name, notes):** a handwriting line reader. Highest quality = TrOCR-FR fine-tuned on real collected slips. EasyOCR = no-training baseline and working demo.

**Step 4 — Validate with domain knowledge.**
Per-field rules: ID format/checksum, quantity numeric range, date format. Free-text fuzzy-matched (edit distance) against real lists — supplier registry, and Tunisian delegations already in `assets/img/delegations.geojson`. The model reads; the rules correct using what we know.

**Step 5 — Human-in-the-loop.**
Low-confidence fields are flagged in the app for the collector to confirm.
*Defense:* "The system knows when it is unsure and asks, instead of silently writing a wrong value." Present this as a quality feature, not a weakness.

**Step 6 — On-premise, offline-first.**
Phone captures + queues offline → syncs to the company server → server runs the pipeline → collector reviews. Data never leaves the building. Privacy by design.

---

## 5. Lab reports — the workflow

Printed structured document, so a different and simpler path.

- **PaddleOCR PP-Structure** extracts the tables and values (layout-aware, deterministic, offline).
- **Strict numeric validation:** every chemical value (acidity, peroxide, K232, K270, …) checked against expected ranges; out-of-range or low-confidence values flagged for human confirmation.
- **Deliberately NOT a vision-LLM here.** An LLM can silently hallucinate a number. For values that drive a purchase decision, deterministic OCR + validation is the higher-quality, auditable choice — and you defend that choice explicitly.

---

## 6. Model decisions (committed)

| Use | Decision | Why |
|---|---|---|
| Collector codes/IDs | In-house CNN **or** EasyOCR charset-locked | Faithful, no language bias, controllable, in-house AI |
| Collector free text | TrOCR-FR fine-tuned (quality) / EasyOCR (baseline) | Best offline handwriting reader |
| Lab report values | PaddleOCR PP-Structure + validation | Auditable, no hallucinated numbers |
| Field assignment | Rules + fuzzy match to known vocab | Domain knowledge corrects recognition noise |

---

## 7. The honest tradeoff (state this yourself to the jury)

Free-text handwriting is the weakest link. It is mitigated by form constraints, vocabulary matching, and human confirmation — not by pretending the model is perfect. Owning this limitation makes the defense stronger, not weaker.

---

## 8. Build order

1. Design the slip template (boxed cells + markers).
2. Alignment + field cropping (perspective transform).
3. EasyOCR recognition on cropped fields (already installed — first working demo).
4. Validation rules + fuzzy match against supplier list / delegations.
5. Human-confirm review screen in the collector app.
6. Quality upgrades (if time): in-house CNN for boxed fields; fine-tune TrOCR-FR for names.
7. Lab report path: PaddleOCR PP-Structure + numeric validation.
