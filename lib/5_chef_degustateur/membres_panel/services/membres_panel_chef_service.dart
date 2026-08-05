import '../../../core/api_client.dart';
import '../../../core/services/resultat_service.dart';
import '../models/membre_panel.dart';
import '../models/mock_membres.dart';

class MembresPanelChefService {
  Future<Resultat<List<MembrePanel>>> fetchMembres() => avecSecours(() async {
    final data = await apiClient.getList('/api/users/panel-members/');
    return data
        .map((e) => MembrePanel.fromJson(e as Map<String, dynamic>))
        .toList();
  }, _mockMembres);

  List<MembrePanel> _mockMembres() => List.from(mockMembresPanel);
}
