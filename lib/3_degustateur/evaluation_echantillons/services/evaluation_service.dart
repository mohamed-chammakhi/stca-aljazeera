import '../../../core/api_client.dart';
import '../../../core/models/echantillon_evaluation.dart';
import '../navigation/models/mock_echantillons.dart';

class EvaluationService {
  bool _usingMockData = false;
  final Map<String, Map<String, dynamic>> _cachedEvaluationsBySample = {};

  Future<List<Echantillon>> fetchEchantillons() async {
    try {
      final sampleItems = await apiClient.getList('/api/echantillons/');
      final evaluationItems = await apiClient.getList('/api/evaluations/');
      _usingMockData = false;
      _cachedEvaluationsBySample
        ..clear()
        ..addEntries(
          evaluationItems.map((item) {
            final evaluation = item as Map<String, dynamic>;
            return MapEntry(evaluation['echantillon'] as String, evaluation);
          }),
        );
      return sampleItems
          .map(
            (item) => Echantillon.fromJson(
              _toFlutterSampleMap(item as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (_) {
      _usingMockData = true;
      _cachedEvaluationsBySample.clear();
      return List.of(mockEchantillonsEvaluation);
    }
  }

  Future<Map<String, dynamic>?> fetchEvaluation(String echantillonId) async {
    if (_usingMockData) return _cachedEvaluationsBySample[echantillonId];
    final cached = _cachedEvaluationsBySample[echantillonId];
    if (cached != null) return cached;
    try {
      final items = await apiClient.getList(
        '/api/evaluations/?echantillon=$echantillonId',
      );
      if (items.isEmpty) return null;
      final evaluation = items.first as Map<String, dynamic>;
      _cachedEvaluationsBySample[echantillonId] = evaluation;
      return evaluation;
    } catch (_) {
      _usingMockData = true;
      return null;
    }
  }

  Future<Map<String, dynamic>> createEvaluation(
    Map<String, dynamic> data,
  ) async {
    if (_usingMockData) {
      final saved = {
        'id': 'mock-eval-${DateTime.now().millisecondsSinceEpoch}',
        ...data,
      };
      _cachedEvaluationsBySample[data['echantillon'] as String] = saved;
      return saved;
    }
    final saved = await apiClient.post('/api/evaluations/', data);
    _cachedEvaluationsBySample[saved['echantillon'] as String] = saved;
    return saved;
  }

  Future<Map<String, dynamic>> updateEvaluation(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (_usingMockData) {
      final saved = {'id': id, ...data};
      _cachedEvaluationsBySample[data['echantillon'] as String] = saved;
      return saved;
    }
    final saved = await apiClient.patch('/api/evaluations/$id/', data);
    _cachedEvaluationsBySample[saved['echantillon'] as String] = saved;
    return saved;
  }

  Future<Map<String, dynamic>> soumettre(String evaluationId) async {
    if (_usingMockData) {
      final saved = {
        'id': evaluationId,
        'statut': 'soumis',
        'soumis_le': DateTime.now().toIso8601String(),
      };
      return saved;
    }
    final saved = await apiClient.post(
      '/api/evaluations/$evaluationId/soumettre/',
      {},
    );
    _cachedEvaluationsBySample[saved['echantillon'] as String] = saved;
    return saved;
  }

  String messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'Impossible de joindre le serveur. Les donnees de demonstration restent affichees.';
  }

  Map<String, dynamic> _toFlutterSampleMap(Map<String, dynamic> api) {
    final id = api['id'] as String;
    final evaluation = _cachedEvaluationsBySample[id];
    final status = evaluation?['statut'] as String?;
    final classification = evaluation?['classification'] as String?;
    return {
      'id': id,
      'ref': api['reference_bouteille'] ?? api['numero'] ?? '',
      'fournisseur':
          api['fournisseur_nom'] ?? api['code_fournisseur'] ?? 'Non specifie',
      'date_arrivee':
          api['date_arrivee_echantillon'] ?? api['date_ajout'] ?? '',
      'variete': api['variete'] ?? '',
      'gouvernorat': api['gouvernorat'],
      'delegation': api['delegation'],
      'photo_url': api['image_url'],
      'quantite': api['quantite_estimee'],
      'collecteur': api['collecteur_nom'],
      'statut': status ?? 'en_attente',
      'classification': _classificationLabel(classification),
    };
  }

  String? _classificationLabel(String? value) {
    switch (value) {
      case 'extra_vierge':
        return 'Extra Vierge';
      case 'vierge':
        return 'Vierge';
      case 'vierge_ordinaire':
        return 'Vierge Ordinaire';
      case 'lampante':
        return 'Lampante';
      default:
        return value;
    }
  }
}
