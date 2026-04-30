import '../models/analyse_labo.dart';
import '../models/mock_analyses.dart';

class AnalyseLaboChefService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<AnalyseLabo>> fetchAnalyses() async {
    // TODO: replace with: return _api.get('/analyses/?role=chef_degustateur');
    return _mockAnalyses();
  }

  Future<AnalyseLabo> createAnalyse(AnalyseLabo a) async {
    // TODO: replace with: return _api.post('/analyses/', a.toJson());
    return a;
  }

  Future<AnalyseLabo> updateAnalyse(AnalyseLabo a) async {
    // TODO: replace with: return _api.put('/analyses/${a.id}/', a.toJson());
    return a;
  }

  Future<void> deleteAnalyse(String id) async {
    // TODO: replace with: await _api.delete('/analyses/$id/');
  }

  // TODO: remove when backend is ready
  List<AnalyseLabo> _mockAnalyses() => List.from(mockAnalysesChef);
}
