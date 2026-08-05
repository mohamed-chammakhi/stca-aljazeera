import '../../../core/api_client.dart';
import '../models/membre_panel.dart';

class MembresPanelService {
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

  List<MembrePanel> _mockMembres() => const [
    MembrePanel(
      id: '001',
      nom: 'Chammakhi',
      prenom: 'Ichrak',
      role: 'Dégustateur',
      membreDepuis: 'Jan 2026',
      estEnLigne: true,
    ),
    MembrePanel(
      id: '002',
      nom: 'Ennouri',
      prenom: 'Lobna',
      role: 'Dégustateur',
      membreDepuis: 'Jan 2026',
      estEnLigne: false,
    ),
    MembrePanel(
      id: '003',
      nom: 'Ouni',
      prenom: 'Maha',
      role: 'Dégustateur',
      membreDepuis: 'Fév 2026',
      estEnLigne: true,
    ),
    MembrePanel(
      id: '004',
      nom: 'Fezai',
      prenom: 'Nayrouz',
      role: 'Dégustateur',
      membreDepuis: 'Fév 2026',
      estEnLigne: false,
    ),
    MembrePanel(
      id: '005',
      nom: 'Smaali',
      prenom: 'Yosra',
      role: 'Dégustateur',
      membreDepuis: 'Mar 2026',
      estEnLigne: false,
    ),
  ];
}
