import '../navigation/models/echantillon.dart';
import '../../../core/api_client.dart';

class EvaluationEchantillonsChefService {
  /// Fetches all echantillons grouped for chef evaluation review.
  ///
  /// Backend: GET /api/chef/evaluations/
  /// Returns a plain (non-paginated) list of grouped objects:
  ///   [{echantillon_id, echantillon_numero, variete, evaluations, divergence}, ...]
  /// The local Echantillon model needs: id, ref, fournisseur, date, variete, statut.
  /// Fields not present in the grouped response are defaulted to empty strings.
  Future<List<Echantillon>> fetchEchantillons() async {
    final items = await apiClient.getList('/api/chef/evaluations/');
    return items.map((e) {
      final api = e as Map<String, dynamic>;
      return Echantillon.fromJson({
        'id':          api['echantillon_id'] ?? '',
        'ref':         api['echantillon_numero'] ?? '',
        'fournisseur': api['fournisseur'] ?? '',
        'date_arrivee': api['date_arrivee'] ?? '',
        'variete':     api['variete'] ?? '',
        'gouvernorat': api['gouvernorat'],
        'delegation':  api['delegation'],
        'photo_url':   api['photo_url'],
        'quantite':    api['quantite'],
        'collecteur':  api['collecteur'],
        'statut':      api['statut'] ?? 'EN_ATTENTE',
        'classification': api['classification'],
      });
    }).toList();
  }

  /// Not used by the chef role — the chef approves/refuses sessions, not individual evaluations.
  /// Call [SessionsChefService.approuverSession] or [SessionsChefService.refuserSession] instead.
  Future<void> submitEvaluation(String id, String classification) async {
    throw UnimplementedError(
      'submitEvaluation is not implemented for the chef panel. '
      'Use SessionsChefService.approuverSession / refuserSession instead.',
    );
  }
}
