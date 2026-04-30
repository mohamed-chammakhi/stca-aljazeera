import '../navigation/models/echantillon.dart';
import '../navigation/models/mock_echantillons.dart';

class EvaluationEchantillonsChefService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<Echantillon>> fetchEchantillons() async {
    // TODO: replace with: return _api.get('/echantillons/evaluation/?role=chef_degustateur');
    return _mockEchantillons();
  }

  Future<void> submitEvaluation(String id, String classification) async {
    // TODO: replace with: await _api.post('/evaluations/', {'echantillon_id': id, 'classification': classification});
  }

  // TODO: remove when backend is ready
  List<Echantillon> _mockEchantillons() => List.from(mockEchantillonsEvaluation);
}
