// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/models/mock_echantillons.dart
// PURPOSE : mock sample data for gestion page — remove when backend is ready
// TODO: remove when backend is ready and replace with EchantillonService.fetch()
// ─────────────────────────────────────────────────────────────────────────────

import 'echantillon_gestion.dart';

// TODO: remove when backend is ready
final List<EchantillonGestion> mockEchantillonsGestion = [
  EchantillonGestion(
    id:              '2026/0001',
    ref:             'CHEMLALI-C1',
    codeFournisseur: 'Domaine Bel-Air',
    variete:         'Chemlali',
    dateArrivee:     '01/03/2026',
    gouvernorat:     'Sfax',
    delegation:      'Sfax Sud',
    quantite:        '25',
    statut:          'En attente',
    collecteur:      'Ahmed Dridi',
  ),
  EchantillonGestion(
    id:              '2026/0002',
    ref:             'CHEMLALI-C4',
    codeFournisseur: 'SF-17',
    variete:         'Chemlali',
    dateArrivee:     '05/03/2026',
    gouvernorat:     'Sfax',
    delegation:      'Mahres',
    quantite:        '12',
    statut:          'En cours',
    collecteur:      'Ahmed Dridi',
  ),
  EchantillonGestion(
    id:              '2026/0003',
    ref:             'CHETOUI-C3',
    codeFournisseur: 'Ferme Al Jazira',
    variete:         'Chetoui',
    dateArrivee:     '21/02/2026',
    gouvernorat:     'Béja',
    delegation:      'Béja Nord',
    quantite:        '32',
    statut:          'Soumis',
    collecteur:      'Rania Hammami',
  ),
  EchantillonGestion(
    id:              '2026/0004',
    ref:             'OUESLATI-C2',
    codeFournisseur: 'Green Valley',
    variete:         'Oueslati',
    dateArrivee:     '23/02/2026',
    gouvernorat:     'Kairouan',
    delegation:      'Kairouan Nord',
    quantite:        '18',
    statut:          'En attente',
  ),
];
