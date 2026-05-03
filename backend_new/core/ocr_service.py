import base64
import json
import os


def _get_gemini_model():
    import google.generativeai as genai
    api_key = os.environ.get('GEMINI_API_KEY', '')
    if not api_key:
        raise EnvironmentError('GEMINI_API_KEY not configured')
    genai.configure(api_key=api_key)
    return genai.GenerativeModel('gemini-1.5-flash')


def _parse_json_response(text: str) -> dict:
    text = text.strip()
    if text.startswith('```'):
        parts = text.split('```')
        text = parts[1]
        if text.startswith('json'):
            text = text[4:]
    return json.loads(text.strip())


def extract_echantillon_from_image(image_bytes: bytes, content_type: str = 'image/jpeg') -> dict:
    model = _get_gemini_model()
    image_data = base64.b64encode(image_bytes).decode('utf-8')
    prompt = (
        "Analyse cette étiquette de bouteille d'huile d'olive et extrais les informations en JSON:\n"
        '{"reference": null, "variete": null, "quantite": null, "fournisseur_nom": null, "gouvernorat": null}\n'
        "Si une information est absente, mets null. Réponds UNIQUEMENT avec le JSON."
    )
    response = model.generate_content([{'mime_type': content_type, 'data': image_data}, prompt])
    return _parse_json_response(response.text)


def extract_analyse_from_image(image_bytes: bytes, content_type: str = 'image/jpeg') -> dict:
    model = _get_gemini_model()
    image_data = base64.b64encode(image_bytes).decode('utf-8')
    prompt = (
        "Analyse ce rapport d'analyse de laboratoire d'huile d'olive et extrais les valeurs en JSON:\n"
        '{"acidite": null, "indice_peroxyde": null, "k232": null, "k270": null, "delta_k": null, "humidite": null, "impuretes": null}\n'
        "Valeurs doivent être des nombres décimaux ou null. Réponds UNIQUEMENT avec le JSON."
    )
    response = model.generate_content([{'mime_type': content_type, 'data': image_data}, prompt])
    return _parse_json_response(response.text)
