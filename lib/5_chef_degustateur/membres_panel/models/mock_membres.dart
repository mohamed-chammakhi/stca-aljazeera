// ─────────────────────────────────────────────────────────────────────────────
// FILE : membres_panel/models/mock_membres.dart
// PURPOSE : mock panel member data
// TODO: remove when backend is ready and replace with MembresPanelChefService.fetch()
// ─────────────────────────────────────────────────────────────────────────────

import 'package:project3/core/models/membre_panel.dart';

// TODO: remove when backend is ready
const List<MembrePanel> mockMembresPanel = [
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
