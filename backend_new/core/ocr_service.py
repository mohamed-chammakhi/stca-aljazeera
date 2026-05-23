"""
OCR service — fully offline, on-premise. No data ever leaves the machine.

Company rule: bottle / report images may NOT be sent to any cloud service.
  - extract_echantillon_from_image (bottle photo)  → EasyOCR, local
  - extract_analyse_from_image    (lab report)     → PaddleOCR, local
No Google / Gemini / cloud anywhere. Both run on the on-premise server only.

The collector writes 3 things with a marker on a small plastic bottle:
  - quantité      e.g. "8T", "10.5T"   (number, optional decimal, unit T)
  - citerne N°    e.g. "c2", "aa11"    (short letter+number code, no dictionary)
  - fournisseur   e.g. "issa rached"   (free name → matched to known suppliers)

OCR is an ASSISTANT that pre-fills the form. The collector confirms/corrects
every field. Accuracy on marker-on-plastic is inherently modest — the human
in the loop, not the model, guarantees correctness.

Endpoint contract is unchanged. The returned dict still has the keys the
existing EchantillonOCRView / Flutter form expect:
    {"reference", "variete", "quantite", "fournisseur_nom", "gouvernorat"}
plus a non-breaking "_confidence" map.
"""

import io
import re

# ── EasyOCR reader singleton ─────────────────────────────────────────────────
# Loaded lazily on first use (torch model load is heavy). French + English
# cover the supplier names; digits/codes are language-independent.
_READER = None


def _get_reader():
    global _READER
    if _READER is None:
        import easyocr  # local, offline; first run downloads models once
        # verbose=False suppresses the unicode progress bar that crashes
        # Python's default cp1252 stdout on Windows servers.
        _READER = easyocr.Reader(['fr', 'en'], gpu=False, verbose=False)
    return _READER


def _read_lines(image_bytes: bytes):
    """Return list of (text, confidence) for every string EasyOCR detects."""
    from PIL import Image
    import numpy as np

    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    arr = np.array(img)
    reader = _get_reader()
    results = reader.readtext(arr, detail=1, paragraph=False)
    lines = []
    for item in results:
        # EasyOCR returns (bbox, text, confidence)
        try:
            _, text, conf = item
        except (ValueError, TypeError):
            continue
        text = (text or '').strip()
        if text:
            lines.append((text, float(conf)))
    return lines


# ── Field classification ─────────────────────────────────────────────────────

_QTY_RE = re.compile(r'(\d+(?:[.,]\d+)?)\s*[tT]?\b')
_CITERNE_RE = re.compile(r'^[A-Za-z0-9]{1,4}$')
# A token that is just digits (optional decimal) with an optional trailing T
# is a quantity, NOT a citerne (e.g. "8T", "10.5T", "12").
_QTY_LIKE_RE = re.compile(r'^\d+(?:[.,]\d+)?[tT]?$')


def _pick_quantite(lines):
    """Number, optional decimal, optionally followed by T. Prefer tokens with T."""
    best = None  # (has_T, confidence, value_str)
    for text, conf in lines:
        m = _QTY_RE.search(text)
        if not m:
            continue
        num = m.group(1).replace(',', '.')
        has_t = bool(re.search(r'\d\s*[tT]\b', text))
        cand = (has_t, conf, f"{num}T")
        if best is None or (cand[0], cand[1]) > (best[0], best[1]):
            best = cand
    if best:
        return best[2], best[1]
    return None, 0.0


def _pick_citerne(lines, used_texts):
    """Short alnum token (<=4) containing BOTH a letter and a digit."""
    best = None  # (confidence, value)
    for text, conf in lines:
        token = text.strip().replace(' ', '')
        if token in used_texts:
            continue
        if not _CITERNE_RE.match(token):
            continue
        if _QTY_LIKE_RE.match(token):  # it's a quantity, not a citerne
            continue
        if not (re.search(r'[A-Za-z]', token) and re.search(r'\d', token)):
            continue
        if best is None or conf > best[0]:
            best = (conf, token.lower())
    if best:
        return best[1], best[0]
    return None, 0.0


def _pick_fournisseur(lines, used_texts):
    """Longest mostly-alphabetic string (the supplier / huilerie name)."""
    best = None  # (length, confidence, value)
    for text, conf in lines:
        if text in used_texts:
            continue
        letters = re.sub(r'[^A-Za-zÀ-ÿ]', '', text)
        if len(letters) < 3:
            continue
        # mostly letters (allow spaces); reject code-like strings
        if len(letters) / max(len(text.replace(' ', '')), 1) < 0.6:
            continue
        cand = (len(letters), conf, text.strip())
        if best is None or cand[0] > best[0]:
            best = cand
    if best:
        return best[2], best[1]
    return None, 0.0


def _match_known_supplier(raw_name):
    """
    Fuzzy-match the OCR'd supplier against existing Fournisseur.nom.
    If a close match exists, snap to it; otherwise keep the raw reading
    (a new supplier — the serializer will get_or_create it on save).
    Returns (name, score 0..1).
    """
    if not raw_name:
        return raw_name, 0.0
    try:
        import difflib
        from fournisseurs.models import Fournisseur

        names = list(
            Fournisseur.objects.values_list('nom', flat=True)
        )
        if not names:
            return raw_name, 0.0
        best, best_score = raw_name, 0.0
        low = raw_name.lower()
        for name in names:
            score = difflib.SequenceMatcher(None, low, (name or '').lower()).ratio()
            if score > best_score:
                best, best_score = name, score
        # Only snap when the match is convincing; else trust the raw reading.
        if best_score >= 0.72:
            return best, best_score
        return raw_name, best_score
    except Exception:
        # DB not ready / any failure → never block OCR, keep raw reading.
        return raw_name, 0.0


# ── Public API (unchanged contract) ──────────────────────────────────────────

def extract_echantillon_from_image(image_bytes: bytes,
                                    content_type: str = 'image/jpeg') -> dict:
    """
    Offline OCR of a bottle photo. Returns best-guess pre-fill values.
    Never raises on recognition failure — returns nulls so the collector
    just fills the form manually.
    """
    try:
        lines = _read_lines(image_bytes)
    except Exception as exc:
        return {
            "reference": None, "variete": None, "quantite": None,
            "fournisseur_nom": None, "gouvernorat": None,
            "_confidence": {}, "_error": f"OCR indisponible: {exc}",
        }

    quantite, q_conf = _pick_quantite(lines)
    used = set()

    citerne, c_conf = _pick_citerne(lines, used)
    if citerne:
        used.add(citerne)

    raw_fourn, f_conf = _pick_fournisseur(lines, used)
    fournisseur, match_score = _match_known_supplier(raw_fourn)

    return {
        # citerne is written on the bottle as its reference
        "reference": citerne,
        "variete": None,
        "quantite": quantite,
        "fournisseur_nom": fournisseur,
        "gouvernorat": None,
        # non-breaking extra: lets the UI flag low-confidence fields for the
        # collector to double-check (human-in-the-loop).
        "_confidence": {
            "quantite": round(q_conf, 3),
            "reference": round(c_conf, 3),
            "fournisseur_nom": round(match_score or f_conf, 3),
        },
        "_raw": [t for t, _ in lines],
    }


# ── Lab report OCR — fully offline (PaddleOCR). No cloud. ────────────────────
#
# A lab report is a PRINTED structured document whose content is numbers that
# drive a purchase decision. We deliberately do NOT use a vision-LLM here: an
# LLM can silently hallucinate a wrong value. PaddleOCR only reads what is
# literally printed; we then parse label→number with regex and range-check
# every value. Anything missing / out of range is flagged for human confirm.

_PADDLE = None


def _get_paddle():
    global _PADDLE
    if _PADDLE is None:
        from paddleocr import PaddleOCR  # local, offline after first run
        # Constructor kwargs differ across PaddleOCR versions — degrade safely.
        for kwargs in (
            {"use_angle_cls": True, "lang": "fr", "show_log": False},
            {"use_angle_cls": True, "lang": "fr"},
            {"lang": "fr"},
            {},
        ):
            try:
                _PADDLE = PaddleOCR(**kwargs)
                break
            except (TypeError, ValueError):
                continue
        if _PADDLE is None:
            from paddleocr import PaddleOCR as _P
            _PADDLE = _P()
    return _PADDLE


def _paddle_lines(image_bytes: bytes):
    """Return list of recognised text strings from the lab report image."""
    from PIL import Image
    import numpy as np

    img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
    arr = np.array(img)
    ocr = _get_paddle()
    try:
        result = ocr.ocr(arr, cls=True)
    except TypeError:
        result = ocr.ocr(arr)  # newer API: no cls kwarg

    texts = []

    def _walk(node):
        # PaddleOCR result shape varies by version:
        #   [[ [box, (text, conf)], ... ]]  or  [[box, (text, conf)], ...]
        if isinstance(node, (list, tuple)):
            if (len(node) == 2 and isinstance(node[0], str)
                    and isinstance(node[1], (int, float))):
                texts.append(node[0])
                return
            for sub in node:
                _walk(sub)
        elif isinstance(node, str):
            texts.append(node)

    _walk(result)
    return texts


# field key → (label synonyms, plausible [min, max] range)
_LAB_FIELDS = {
    "acidite":         (["acidite", "acidite libre", "acidity"],            0.0, 10.0),
    "indice_peroxyde": (["peroxyde", "indice de peroxyde", "peroxide", "ip"], 0.0, 50.0),
    "k232":            (["k232", "k 232"],                                    0.0, 5.0),
    "k270":            (["k270", "k 270"],                                    0.0, 2.0),
    "delta_k":         (["delta k", "delta-k", "deltak", "delta"],            0.0, 1.0),
    "humidite":        (["humidite", "eau", "humidity"],                      0.0, 5.0),
    "impuretes":       (["impurete", "impuretes", "impurity"],                0.0, 5.0),
}

_NUM_RE = re.compile(r'(\d+(?:[.,]\d+)?)')


def _strip_accents(s: str) -> str:
    import unicodedata
    return ''.join(
        c for c in unicodedata.normalize('NFD', s)
        if unicodedata.category(c) != 'Mn'
    ).lower()


def extract_analyse_from_image(image_bytes: bytes,
                               content_type: str = 'image/jpeg') -> dict:
    """
    Offline OCR of a printed lab report. Returns the chemical values as
    floats (or None) plus _warnings for missing / out-of-range values that
    the lab technician must confirm. Never raises on failure.
    """
    result = {k: None for k in _LAB_FIELDS}
    warnings = []
    try:
        texts = _paddle_lines(image_bytes)
    except Exception as exc:
        result["_warnings"] = ["OCR indisponible — saisie manuelle."]
        result["_error"] = str(exc)
        return result

    blob = _strip_accents(' '.join(texts))

    for key, (labels, lo, hi) in _LAB_FIELDS.items():
        value = None
        for label in labels:
            idx = blob.find(label)
            if idx == -1:
                continue
            # look for the first number in the ~25 chars after the label
            window = blob[idx + len(label): idx + len(label) + 25]
            m = _NUM_RE.search(window)
            if m:
                value = float(m.group(1).replace(',', '.'))
                break
        if value is None:
            warnings.append(f"{key}: non lu — à saisir manuellement")
        elif not (lo <= value <= hi):
            warnings.append(
                f"{key}={value} hors plage attendue [{lo}, {hi}] — vérifier"
            )
        result[key] = value

    result["_warnings"] = warnings
    result["_raw"] = texts
    return result
