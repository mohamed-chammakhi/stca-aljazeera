import '../models/membre_panel.dart';

class MembresPanelService {
  // TODO: inject ApiClient here when backend is ready

  Future<List<MembrePanel>> fetchMembres() async {
    // TODO: replace with: return _api.get('/utilisateurs/?role=degustateur');
    return _mockMembres();
  }

  // TODO: remove when backend is ready
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
