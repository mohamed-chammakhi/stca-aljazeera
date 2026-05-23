import '../navigation/models/echantillon.dart';
import '../navigation/models/mock_echantillons.dart';

class EvaluationEchantillonsChefService {
  // TODO: switch back to real API when backend is ready

  Future<List<Echantillon>> fetchEchantillons() async {
    return List.of(mockEchantillonsEvaluation);
  }

  Future<void> submitEvaluation(String id, String classification) async {
    throw UnimplementedError(
      'submitEvaluation is not implemented for the chef panel. '
      'Use SessionsChefService.approuverSession / refuserSession instead.',
    );
  }
}
