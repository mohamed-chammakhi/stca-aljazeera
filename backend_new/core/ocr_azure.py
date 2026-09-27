import difflib
import re

import requests
from django.conf import settings


OCR_INACTIVE_DETAIL = (
    "La lecture automatique n'est pas encore activée. "
    "Contactez l'administrateur."
)

_QTY_RE = re.compile(r'(\d+(?:[.,]\d+)?)\s*(?:t|tn|tonne|tonnes)?\b', re.I)
_TANK_RE = re.compile(r'\b(?:citerne|cuve|tank|n)\s*[:=\-]?\s*([A-Za-z]{0,4}\d{1,4})\b', re.I)
_REFERENCE_RE = re.compile(r'\b[A-Z0-9]{2,}[-/][A-Z0-9]{1,8}\b|\b[A-Z]{2,}\d{1,4}\b', re.I)
_VARIETES = [
    'chemlali',
    'chetoui',
    'chétoui',
    'sahli',
    'oueslati',
    'zalmati',
    'gerboui',
    'sayali',
    'meski',
]


def azure_ocr_configured():
    return bool(settings.AZURE_VISION_ENDPOINT and settings.AZURE_VISION_KEY)


def read_image_text(image_bytes, content_type='image/jpeg'):
    endpoint = settings.AZURE_VISION_ENDPOINT.rstrip('/')
    url = (
        f'{endpoint}/computervision/imageanalysis:analyze'
        '?features=read&api-version=2024-02-01'
    )
    response = requests.post(
        url,
        headers={
            'Ocp-Apim-Subscription-Key': settings.AZURE_VISION_KEY,
            'Content-Type': content_type or 'application/octet-stream',
        },
        data=image_bytes,
        timeout=15,
    )
    response.raise_for_status()
    return _lines_from_azure_response(response.json())


def extract_echantillon_from_image(image_bytes, content_type='image/jpeg'):
    lines = read_image_text(image_bytes, content_type=content_type)
    raw_text = '\n'.join(lines)
    fournisseur = _match_known_supplier(_extract_supplier(lines))
    return {
        'reference_bouteille': _extract_by_label(
            lines,
            ['reference', 'référence', 'ref', 'bouteille'],
        ) or _guess_reference(lines),
        'variete': _extract_by_label(lines, ['variete', 'variété', 'olive', 'type'])
        or _guess_variete(raw_text),
        'quantite': _extract_by_label(
            lines,
            ['quantite', 'quantité', 'qte', 'qté', 'volume', 'poids'],
        ) or _guess_quantity(raw_text),
        'num_citerne': _extract_by_label(
            lines,
            ['citerne', 'cuve', 'tank', 'n citerne', 'n° citerne'],
        ) or _guess_tank(raw_text),
        'fournisseur_nom': fournisseur,
        'raw_text': raw_text,
    }


def _lines_from_azure_response(payload):
    lines = []
    read_result = payload.get('readResult') or payload.get('read_result') or {}
    for block in read_result.get('blocks', []):
        for line in block.get('lines', []):
            text = (line.get('text') or '').strip()
            if text:
                lines.append(text)
    if lines:
        return lines

    # Test-friendly and future-proof fallback for simplified payloads.
    for line in payload.get('lines', []):
        text = line.get('text') if isinstance(line, dict) else line
        text = (text or '').strip()
        if text:
            lines.append(text)
    return lines


def _extract_by_label(lines, labels):
    for index, line in enumerate(lines):
        normalized = _normalize(line)
        for label in labels:
            key = _normalize(label)
            if key not in normalized:
                continue
            after_separator = re.search(r'[:=\-]\s*(.+)$', line)
            if after_separator and _usable(after_separator.group(1)):
                return _clean(after_separator.group(1))
            label_index = normalized.find(key)
            after_label = line[label_index + len(label):].strip(' :=-')
            if _usable(after_label):
                return _clean(after_label)
            if index + 1 < len(lines) and _usable(lines[index + 1]):
                return _clean(lines[index + 1])
    return None


def _guess_quantity(text):
    match = _QTY_RE.search(text or '')
    if not match:
        return None
    return match.group(1).replace(',', '.')


def _guess_tank(text):
    match = _TANK_RE.search(text or '')
    if match:
        return _clean(match.group(1)).upper()
    return None


def _guess_reference(lines):
    for line in lines:
        match = _REFERENCE_RE.search(line)
        if match:
            return _clean(match.group(0)).upper()
    return None


def _guess_variete(text):
    normalized = _normalize(text or '')
    for variete in _VARIETES:
        if _normalize(variete) in normalized:
            return variete[:1].upper() + variete[1:].lower()
    return None


def _extract_supplier(lines):
    labeled = _extract_by_label(
        lines,
        ['fournisseur', 'supplier', 'producteur', 'domaine', 'ferme', 'nom'],
    )
    if labeled:
        return labeled
    candidates = []
    for line in lines:
        cleaned = _clean(line)
        if len(cleaned) < 5 or _guess_quantity(cleaned) or _guess_tank(cleaned):
            continue
        if re.search(r'[A-Za-zÀ-ÿ]{3,}', cleaned) and not re.search(r'\d{2,}', cleaned):
            candidates.append(cleaned)
    return candidates[0] if candidates else None


def _match_known_supplier(raw_name):
    if not raw_name:
        return None
    try:
        from fournisseurs.models import Fournisseur

        names = list(Fournisseur.objects.values_list('nom', flat=True))
    except Exception:
        return raw_name
    if not names:
        return raw_name
    best = raw_name
    best_score = 0
    low = raw_name.lower()
    for name in names:
        score = difflib.SequenceMatcher(None, low, (name or '').lower()).ratio()
        if score > best_score:
            best = name
            best_score = score
    return best if best_score >= 0.72 else raw_name


def _normalize(value):
    return (
        value.lower()
        .replace('à', 'a')
        .replace('á', 'a')
        .replace('â', 'a')
        .replace('ä', 'a')
        .replace('è', 'e')
        .replace('é', 'e')
        .replace('ê', 'e')
        .replace('ë', 'e')
        .replace('î', 'i')
        .replace('ï', 'i')
        .replace('ô', 'o')
        .replace('ö', 'o')
        .replace('ù', 'u')
        .replace('û', 'u')
        .replace('ü', 'u')
        .replace('ç', 'c')
    )


def _clean(value):
    return re.sub(r'^[\s:;=\-]+|[\s;]+$', '', value or '').strip()


def _usable(value):
    cleaned = _clean(value)
    return len(cleaned) >= 2 and _normalize(cleaned) not in {
        'fournisseur',
        'reference',
        'bouteille',
        'variete',
        'quantite',
        'citerne',
    }
