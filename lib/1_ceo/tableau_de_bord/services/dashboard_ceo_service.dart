// TODO: switch back to real API when backend is ready
class DashboardCeoService {
  Future<Map<String, dynamic>> fetchDashboard() async {
    return {
      'echantillons_total': 11,
      'echantillons_selectionnes': 4,
      'achats_confirmes': 5,
      'stocks_arrives': 2,
      'evaluations_en_attente': 3,
      'analyses_soumises': 6,
    };
  }
}
