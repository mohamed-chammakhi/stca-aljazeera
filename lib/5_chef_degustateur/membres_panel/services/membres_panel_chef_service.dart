import '../models/membre_panel.dart';
import '../models/mock_membres.dart';

class MembresPanelChefService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<MembrePanel>> fetchMembres() async {
    // TODO: replace with: return _api.get('/panel/membres/');
    return _mockMembres();
  }

  // TODO: remove when backend is ready
  List<MembrePanel> _mockMembres() => List.from(mockMembresPanel);
}
