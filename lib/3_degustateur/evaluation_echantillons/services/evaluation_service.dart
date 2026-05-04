import '../navigation/models/echantillon.dart';
import '../../../core/api_client.dart';

class EvaluationService {
  // ── Field mapping: Django API → local Echantillon.fromJson ────────────────
  //
  // The local evaluation Echantillon model differs from the core model:
  //   Django: numero             → ref
  //   Django: fournisseur_nom    → fournisseur  (display name, not UUID)
  //   Django: date_arrivee_echantillon → date_arrivee
  //   Django: statut_degustateur → statut       (EN_ATTENTE | EN_COURS | SOUMIS)
  //   Django: image_url          → photo_url
  //   Django: quantite_estimee   → quantite
  //   Django: collecteur_nom     → collecteur   (display name, not UUID)
  // ─────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _toFlutterMap(Map<String, dynamic> api) {
    // Map Django statut_degustateur to the local enum string.
    final statutDeg = (api['statut_degustateur'] as String? ?? 'en_attente').toUpperCase();
    final String statutMapped;
    switch (statutDeg) {
      case 'EN_COURS':
        statutMapped = 'EN_COURS';
        break;
      case 'SOUMIS':
        statutMapped = 'SOUMIS';
        break;
      default:
        statutMapped = 'EN_ATTENTE';
    }

    return {
      'id':          api['id'] ?? '',
      'ref':         api['numero'] ?? '',
      'fournisseur': api['fournisseur_nom'] ?? '',
      'date_arrivee': api['date_arrivee_echantillon'] ?? '',
      'variete':     api['variete'] ?? '',
      'gouvernorat': api['gouvernorat'],
      'delegation':  api['delegation'],
      'photo_url':   api['image_url'],
      'quantite':    api['quantite_estimee'],
      'collecteur':  api['collecteur_nom'],
      'statut':      statutMapped,
      'classification': api['classification'],
    };
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches all physically received echantillons for the evaluation workflow.
  Future<List<Echantillon>> fetchEchantillons() async {
    final items = await apiClient.getList('/api/echantillons/?recu_physiquement=true');
    return items
        .map((e) => Echantillon.fromJson(_toFlutterMap(e as Map<String, dynamic>)))
        .toList();
  }

  /// Fetches the evaluation for a given echantillon (returns the first result or null).
  Future<Map<String, dynamic>?> fetchEvaluation(String echantillonId) async {
    final items = await apiClient.getList('/api/evaluations/?echantillon=$echantillonId');
    if (items.isEmpty) return null;
    return items.first as Map<String, dynamic>;
  }

  /// Creates a new evaluation record on the server.
  Future<Map<String, dynamic>> createEvaluation(Map<String, dynamic> data) async {
    return await apiClient.post('/api/evaluations/', data);
  }

  /// Updates an existing evaluation via PATCH.
  Future<Map<String, dynamic>> updateEvaluation(String id, Map<String, dynamic> data) async {
    return await apiClient.patch('/api/evaluations/$id/', data);
  }

  /// Submits a completed evaluation for review.
  ///
  /// Calls `POST /api/evaluations/<id>/soumettre/` — the backend sets
  /// `statut = SOUMIS` and records the `soumis_le` timestamp.
  Future<Map<String, dynamic>> soumettre(String evaluationId) async {
    return await apiClient.post('/api/evaluations/$evaluationId/soumettre/', {});
  }
}
