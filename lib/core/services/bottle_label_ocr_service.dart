import '../api_client.dart';

class BottleLabelOcrResult {
  final String? referenceBouteille;
  final String? variete;
  final String? quantite;
  final String? numCiterne;
  final String? fournisseurNom;
  final String rawText;

  const BottleLabelOcrResult({
    required this.referenceBouteille,
    required this.variete,
    required this.quantite,
    required this.numCiterne,
    required this.fournisseurNom,
    required this.rawText,
  });

  factory BottleLabelOcrResult.fromJson(Map<String, dynamic> json) {
    return BottleLabelOcrResult(
      referenceBouteille: _text(json['reference_bouteille']),
      variete: _text(json['variete']),
      quantite: _text(json['quantite']),
      numCiterne: _text(json['num_citerne']),
      fournisseurNom: _text(json['fournisseur_nom']),
      rawText: _text(json['raw_text']) ?? '',
    );
  }

  bool get hasAnyValue =>
      referenceBouteille != null ||
      variete != null ||
      quantite != null ||
      numCiterne != null ||
      fournisseurNom != null;

  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class BottleLabelOcrService {
  final ApiClient _api;

  BottleLabelOcrService({ApiClient? api}) : _api = api ?? apiClient;

  Future<bool> isActive() async {
    final data = await _api.get('/api/echantillons/ocr/statut/');
    return data['actif'] == true;
  }

  Future<BottleLabelOcrResult> readLabel({
    required List<int> bytes,
    required String filename,
  }) async {
    final data = await _api.postMultipart(
      '/api/echantillons/ocr/',
      bytes: bytes,
      filename: filename,
    );
    return BottleLabelOcrResult.fromJson(data);
  }
}
