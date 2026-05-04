import '../../../core/api_client.dart';

class DashboardCeoService {
  Future<Map<String, dynamic>> fetchDashboard() async {
    return await apiClient.get('/api/ceo/dashboard/');
  }
}
