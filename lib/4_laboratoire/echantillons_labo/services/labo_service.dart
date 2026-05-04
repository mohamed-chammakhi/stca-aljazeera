// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/services/labo_service.dart
// PURPOSE : Data access for the lab technician module — real HTTP calls.
// ═════════════════════════════════════════════════════════════════════════════

import '../../../core/api_client.dart';
import '../models/echantillon_labo.dart';
import '../../analyse_labo.dart';

class LaboService {
  // Singleton API client shared across the app.
  final _api = apiClient;

  // Internal cache: echantillonId → analyseId (Django PK).
  // AnalyseLabo has no id field, so we track the server-assigned id here.
  // This is populated on fetchEchantillons() and used by saveAnalyse / deleteAnalyse.
  final Map<String, String> _analyseIds = {};

  // ── Date helper ──────────────────────────────────────────────────────────
  // Django sends ISO-8601 dates (e.g. "2026-03-01"). The model expects "dd/MM/yyyy".
  // Uses Dart's built-in DateTime.parse — no external package required.
  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      return '$dd/$mm/$yyyy';
    } catch (_) {
      return iso; // return as-is if parsing fails
    }
  }

  // ── Build EchantillonLabo from Django response ────────────────────────────
  // Django field names differ from the Flutter model in several places:
  //   Django "numero"                → Flutter "ref"
  //   Django "date_arrivee_echantillon" → Flutter "date_arrivee" (formatted)
  //   Django "acidite"               → Flutter "acidite_libre"  (in AnalyseLabo)
  //   Django "echantillon" (FK id)   → Flutter "echantillon_id"
  EchantillonLabo _buildEchantillon(
    Map<String, dynamic> json,
    Map<String, dynamic>? analyseJson,
  ) {
    AnalyseLabo? analyse;
    if (analyseJson != null) {
      // Normalize analysis JSON to what AnalyseLabo.fromJson expects.
      final normalizedAnalyse = <String, dynamic>{
        'echantillon_id':  json['id']?.toString() ?? '',
        'echantillon_ref': json['numero']?.toString() ?? '',
        // Physicochemical fields — Django uses "acidite", Flutter uses "acidite_libre"
        'acidite_libre':   analyseJson['acidite'],
        'indice_peroxyde': analyseJson['indice_peroxyde'],
        'k232':            analyseJson['k232'],
        'k270':            analyseJson['k270'],
        'delta_k':         analyseJson['delta_k'],
        'humidite':        analyseJson['humidite'],
        'impuretes':       analyseJson['impuretes'],
        // Optional fields not returned by Django — pass null
        'polyphenols_totaux': null,
        'tocopherols':        null,
        'acide_oleique':      null,
        'acide_linoleique':   null,
        'acide_palmitique':   null,
        'classification':     null,
        // Metadata
        'statut':            analyseJson['statut'],
        'date_analyse':      analyseJson['date_analyse'],
        'technicien_id':     analyseJson['technicien']?.toString(),
        'notes':             analyseJson['notes'],
        'image_rapport_url': analyseJson['photo'],
      };
      analyse = AnalyseLabo.fromJson(normalizedAnalyse);
    }

    // Normalize echantillon JSON to what EchantillonLabo.fromJson expects.
    final normalized = <String, dynamic>{
      'id':                  json['id']?.toString() ?? '',
      'ref':                 json['numero']?.toString() ?? '',
      'gouvernorat':         json['gouvernorat']         ?? '',
      'code_fournisseur':    json['code_fournisseur']    ?? '',
      'collecteur_nom':      json['collecteur_nom']      ?? '',
      'reference_bouteille': json['reference_bouteille'] ?? '',
      'variete':             json['variete'],
      'quantite_estimee':    json['quantite_estimee']?.toString(),
      'date_arrivee':        _fmtDate(json['date_arrivee_echantillon'] as String?),
      'numero_lot':          null,
      'origine_campagne':    null,
      'priorite':            'normale',
      'notes_reception':     json['remarques'],
      'analyse':             null, // injected below after construction
    };

    final echantillon = EchantillonLabo.fromJson(normalized);
    echantillon.analyse = analyse;
    return echantillon;
  }

  // ── fetchEchantillons ─────────────────────────────────────────────────────
  // Two-step fetch using a single analyses call to avoid N+1:
  //   1. GET /api/echantillons/?recu_physiquement=true
  //   2. GET /api/analyses/ (all analyses, build a map echantillonId → analysis)
  //   3. Merge: attach the matching analysis to each echantillon.
  Future<List<EchantillonLabo>> fetchEchantillons() async {
    // Step 1: fetch all physically received samples.
    final rawEchantillons = await _api.getList(
      '/api/echantillons/?recu_physiquement=true',
    );

    // Step 2: fetch all analyses in one call.
    final rawAnalyses = await _api.getList('/api/analyses/');

    // Build a lookup map: echantillon UUID → analysis JSON.
    final analyseByEchantillon = <String, Map<String, dynamic>>{};
    for (final a in rawAnalyses) {
      final analysisMap = a as Map<String, dynamic>;
      final echId = analysisMap['echantillon']?.toString();
      if (echId != null) {
        analyseByEchantillon[echId] = analysisMap;
        // Cache the server-assigned analyse id for PATCH / DELETE.
        _analyseIds[echId] = analysisMap['id']?.toString() ?? '';
      }
    }

    // Step 3: build EchantillonLabo objects with their analysis attached.
    return rawEchantillons.map((raw) {
      final json = raw as Map<String, dynamic>;
      final echId = json['id']?.toString() ?? '';
      final analyseJson = analyseByEchantillon[echId];
      return _buildEchantillon(json, analyseJson);
    }).toList();
  }

  // ── saveAnalyse ───────────────────────────────────────────────────────────
  // PATCH if we already have a server id for this echantillon's analysis,
  // POST otherwise (creates a new analysis record).
  Future<void> saveAnalyse(String echantillonId, AnalyseLabo analyse) async {
    final existingId = _analyseIds[echantillonId];

    // Build the payload that the Django API expects.
    final payload = <String, dynamic>{
      'echantillon':    echantillonId,
      // Map Flutter field names back to Django field names.
      'acidite':        analyse.aciditeLibre,
      'indice_peroxyde': analyse.indicePeroxyde,
      'k232':           analyse.k232,
      'k270':           analyse.k270,
      'delta_k':        analyse.deltaK,
      'humidite':       analyse.humidite,
      'impuretes':      analyse.impuretes,
      'notes':          analyse.notes,
      'photo':          analyse.imageRapportUrl,
      'statut':         analyse.statut.name,
    };

    if (existingId != null && existingId.isNotEmpty) {
      // Update existing analysis.
      await _api.patch('/api/analyses/$existingId/', payload);
    } else {
      // Cache cold — check if an analyse already exists before deciding POST vs PATCH
      final existing = await _api.getList(
        '/api/analyses/?echantillon=$echantillonId',
      );
      if (existing.isNotEmpty) {
        final existingMap = existing.first as Map<String, dynamic>;
        final fetchedId = existingMap['id'] as String;
        _analyseIds[echantillonId] = fetchedId;
        await _api.patch('/api/analyses/$fetchedId/', payload);
      } else {
        final created = await _api.post('/api/analyses/', payload);
        _analyseIds[echantillonId] = created['id'] as String;
      }
    }
  }

  // ── deleteAnalyse ─────────────────────────────────────────────────────────
  // Looks up the analyse id from the cache or fetches it from the API,
  // then issues a DELETE.
  Future<void> deleteAnalyse(String echantillonId) async {
    String? analyseId = _analyseIds[echantillonId];

    if (analyseId == null || analyseId.isEmpty) {
      // Not in cache — fetch from the API.
      final results = await _api.getList(
        '/api/analyses/?echantillon=$echantillonId',
      );
      if (results.isEmpty) return; // nothing to delete
      final first = results.first as Map<String, dynamic>;
      analyseId = first['id']?.toString();
      if (analyseId == null) return;
      _analyseIds[echantillonId] = analyseId;
    }

    await _api.delete('/api/analyses/$analyseId/');
    _analyseIds.remove(echantillonId);
  }

  // ── soumettre ─────────────────────────────────────────────────────────────
  // Submits an analysis (changes statut → 'soumis') via the dedicated action.
  Future<void> soumettre(String analyseId) async {
    await _api.post('/api/analyses/$analyseId/soumettre/', {});
  }
}
