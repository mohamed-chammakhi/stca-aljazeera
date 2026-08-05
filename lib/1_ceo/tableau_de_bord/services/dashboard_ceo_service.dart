import '../../../core/api_client.dart';
import '../../../core/services/resultat_service.dart';
import '../models/dashboard_models.dart';

class DashboardCeoService {
  Future<Resultat<DashboardCeoSnapshot>> fetchDashboard({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) => avecSecours(() async {
    final query = <String>[];
    if (dateDebut != null) {
      query.add('date_debut=${_date(dateDebut)}');
    }
    if (dateFin != null) {
      query.add('date_fin=${_date(dateFin)}');
    }
    final suffix = query.isEmpty ? '' : '?${query.join('&')}';
    final data = await apiClient.get('/api/ceo/dashboard/$suffix');
    return DashboardCeoSnapshot.fromJson(data);
  }, DashboardCeoSnapshot.mock);

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
