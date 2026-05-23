import 'dart:math' as math;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class BottleLabelOcrService {
  static const _varietes = <String>[
    'chemlali',
    'chetoui',
    'chétoui',
    'sahli',
    'oueslati',
    'zalmati',
    'gerboui',
    'sayali',
    'meski',
  ];

  Future<Map<String, dynamic>> readLabel(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final image = InputImage.fromFilePath(imagePath);
      final recognized = await recognizer.processImage(image);
      return _classify(recognized);
    } finally {
      await recognizer.close();
    }
  }

  Map<String, dynamic> _classify(RecognizedText recognized) {
    final lines = recognized.blocks
        .expand((block) => block.lines)
        .map((line) => line.text.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final fullText = lines.join('\n');

    final fournisseur = _extractByLabel(lines, const [
      'fournisseur',
      'supplier',
      'producteur',
      'domaine',
      'ferme',
      'nom',
    ]);
    final reference = _extractByLabel(lines, const [
      'reference',
      'référence',
      'ref',
      'bouteille',
      'bottle',
    ]);
    final quantite = _extractQuantity(lines);
    final scellage = _extractByLabel(lines, const [
      'scellage',
      'scelle',
      'scellé',
      'sceau',
      'seal',
    ]);
    final variete = _extractByLabel(lines, const [
      'variete',
      'variété',
      'olive',
      'type',
    ]);

    final fallbackReference = reference ?? _guessReference(lines);
    final fallbackScellage = scellage ?? _guessScellage(fullText);
    final fallbackVariete = variete ?? _guessVariete(fullText);
    final fallbackFournisseur = fournisseur ?? _guessSupplier(lines);

    return {
      'fournisseur_nom': fallbackFournisseur,
      'reference': fallbackReference,
      'variete': fallbackVariete,
      'scellage': fallbackScellage,
      'quantite': quantite,
      'raw_text': fullText,
      '_confidence': {
        'fournisseur_nom': fournisseur == null ? 0.45 : 0.85,
        'reference': reference == null ? 0.55 : 0.9,
        'variete': variete == null ? 0.55 : 0.85,
        'scellage': scellage == null ? 0.55 : 0.9,
        'quantite': quantite == null ? 0.0 : 0.9,
      },
    };
  }

  String? _extractByLabel(List<String> lines, List<String> labels) {
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final normalized = _normalize(line);
      for (final label in labels) {
        final key = _normalize(label);
        if (!normalized.contains(key)) continue;

        final afterSeparator = RegExp(
          r'[:=\-]\s*(.+)$',
        ).firstMatch(line)?.group(1)?.trim();
        if (_isUsableValue(afterSeparator)) {
          return _cleanValue(afterSeparator!);
        }

        final labelIndex = normalized.indexOf(key);
        final afterLabel = line
            .substring(math.min(labelIndex + label.length, line.length))
            .replaceFirst(RegExp(r'^\s*[:=\-]?\s*'), '')
            .trim();
        if (_isUsableValue(afterLabel)) return _cleanValue(afterLabel);

        if (i + 1 < lines.length && _isUsableValue(lines[i + 1])) {
          return _cleanValue(lines[i + 1]);
        }
      }
    }
    return null;
  }

  String? _extractQuantity(List<String> lines) {
    final labeled = _extractByLabel(lines, const [
      'quantite',
      'quantité',
      'qte',
      'qté',
      'volume',
      'poids',
    ]);
    final source = labeled ?? lines.join(' ');
    final match = RegExp(
      r'(\d+(?:[,.]\d+)?)\s*(t|tn|tonne|tonnes|l|lt|litre|litres)?\b',
      caseSensitive: false,
    ).firstMatch(source);
    if (match == null) return null;
    return match.group(1)?.replaceAll(',', '.');
  }

  String? _guessScellage(String text) {
    final match = RegExp(
      r'\b(?:z|s|sc|seal)\s*[-/]?\s*\d{1,3}\b',
      caseSensitive: false,
    ).firstMatch(text);
    return match == null ? null : _cleanValue(match.group(0)!).toUpperCase();
  }

  String? _guessVariete(String text) {
    final normalized = _normalize(text);
    for (final variete in _varietes) {
      if (normalized.contains(_normalize(variete))) {
        return _titleCase(variete);
      }
    }
    return null;
  }

  String? _guessReference(List<String> lines) {
    final candidates = lines
        .map(_cleanValue)
        .where((line) => line.length >= 3 && line.length <= 24)
        .where((line) => !_looksLikeLabel(line))
        .where((line) => _extractQuantity([line]) == null)
        .where((line) => _guessScellage(line) == null)
        .where(
          (line) => RegExp(
            r'\b[A-Z0-9]{2,}[-/][A-Z0-9]{1,8}\b|\b[A-Z]{2,}\d{1,4}\b',
            caseSensitive: false,
          ).hasMatch(line),
        )
        .toList();
    if (candidates.isEmpty) return null;
    return candidates.first.toUpperCase();
  }

  String? _guessSupplier(List<String> lines) {
    final candidates = lines
        .map(_cleanValue)
        .where((line) => line.length >= 5 && line.length <= 40)
        .where((line) => !_looksLikeLabel(line))
        .where((line) => _extractQuantity([line]) == null)
        .where((line) => _guessScellage(line) == null)
        .where(
          (line) =>
              RegExp(r'[A-Za-zÀ-ÿ]{3,}').hasMatch(line) &&
              !RegExp(r'\d{2,}').hasMatch(line),
        )
        .toList();
    if (candidates.isEmpty) return null;
    return candidates.first;
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâãäå]'), 'a')
        .replaceAll(RegExp(r'[èéêë]'), 'e')
        .replaceAll(RegExp(r'[ìíîï]'), 'i')
        .replaceAll(RegExp(r'[òóôõö]'), 'o')
        .replaceAll(RegExp(r'[ùúûü]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _isUsableValue(String? value) {
    if (value == null) return false;
    final cleaned = _cleanValue(value);
    return cleaned.length >= 2 && !_looksLikeLabel(cleaned);
  }

  bool _looksLikeLabel(String value) {
    final normalized = _normalize(value);
    return const [
      'fournisseur',
      'supplier',
      'producteur',
      'reference',
      'ref',
      'bouteille',
      'variete',
      'olive',
      'scellage',
      'quantite',
      'qte',
      'volume',
    ].any((label) => normalized == label || normalized == '$label:');
  }

  String _cleanValue(String value) {
    return value
        .replaceAll(RegExp(r'^[\s:;=\-]+'), '')
        .replaceAll(RegExp(r'[\s;]+$'), '')
        .trim();
  }

  String _titleCase(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return cleaned;
    return cleaned[0].toUpperCase() + cleaned.substring(1).toLowerCase();
  }
}
