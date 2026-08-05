import '../../../core/api_client.dart';
import '../models/membre_panel.dart';
import '../models/mock_membres.dart';

class MembresPanelChefService {
  Future<List<MembrePanel>> fetchMembres() async {
    try {
      final data = await apiClient.getList('/api/users/panel-members/');
      return data
          .map((e) => MembrePanel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _mockMembres();
    }
  }

  List<MembrePanel> _mockMembres() => List.from(mockMembresPanel);
}
