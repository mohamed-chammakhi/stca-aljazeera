import '../navigation/models/echantillon.dart';
import '../navigation/models/mock_echantillons.dart';

class EvaluationService {
  // TODO: inject ApiClient here when backend is ready

  Future<List<Echantillon>> fetchEchantillons() async {
    // TODO: replace with: return _api.get('/echantillons/evaluation/');
    return _mockEchantillons();
  }

  Future<Map<String, dynamic>?> fetchEvaluation(String echantillonId) async {
    // TODO: replace with: return _api.get('/evaluations/?echantillon=$echantillonId');
    return null;
  }

  Future<void> createEvaluation(Map<String, dynamic> data) async {
    // TODO: replace with: await _api.post('/evaluations/', data);
  }

  Future<void> updateEvaluation(String id, Map<String, dynamic> data) async {
    // TODO: replace with: await _api.put('/evaluations/$id/', data);
  }

  // TODO: remove when backend is ready
  List<Echantillon> _mockEchantillons() =>
      List.from(mockEchantillonsEvaluation);
}
