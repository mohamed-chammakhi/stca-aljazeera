// ─────────────────────────────────────────────────────────────────────────────
// FILE : evaluation_echantillons/models/mock_echantillons.dart
// PURPOSE : mock sample data for evaluation page — remove when backend is ready
// TODO: remove when backend is ready and replace with EchantillonService.fetch()
// ─────────────────────────────────────────────────────────────────────────────

import 'echantillon.dart';

// TODO: remove when backend is ready
final List<Echantillon> mockEchantillonsEvaluation = [
  Echantillon(
    id:          '2026/0001',
    ref:         'CHEMLALI-C1',
    fournisseur: 'Domaine Bel-Air',
    date:        '01/03/2026',
    variete:     'Chemlali',
    gouvernorat: 'Sfax',
    delegation:  'Sfax Sud',
    quantite:    '25',
    collecteur:  'Ahmed Dridi',
    statut:      StatutEchantillon.enAttente,
  ),
  Echantillon(
    id:          '2026/0002',
    ref:         'CHEMLALI-C4',
    fournisseur: 'SF-17',
    date:        '05/03/2026',
    variete:     'Chemlali',
    gouvernorat: 'Sfax',
    delegation:  'Mahres',
    quantite:    '12',
    collecteur:  'Ahmed Dridi',
    statut:      StatutEchantillon.enCours,
  ),
  Echantillon(
    id:          '2026/0003',
    ref:         'CHETOUI-C3',
    fournisseur: 'Ferme Al Jazira',
    date:        '21/02/2026',
    variete:     'Chetoui',
    gouvernorat: 'Béja',
    delegation:  'Béja Nord',
    quantite:    '32',
    collecteur:  'Rania Hammami',
    statut:      StatutEchantillon.soumis,
    classification: 'Extra Vierge',
  ),
  Echantillon(
    id:          '2026/0004',
    ref:         'OUESLATI-C2',
    fournisseur: 'Green Valley',
    date:        '23/02/2026',
    variete:     'Oueslati',
    gouvernorat: 'Kairouan',
    delegation:  'Kairouan Nord',
    quantite:    '18',
    statut:      StatutEchantillon.enAttente,
  ),
  Echantillon(
    id:          '2026/0005',
    ref:         'CHEMLALI-C5',
    fournisseur: 'Domaine Bel-Air',
    date:        '24/02/2026',
    variete:     'Chemlali',
    gouvernorat: 'Sfax',
    delegation:  'Sakiet Eddaïer',
    quantite:    '20',
    collecteur:  'Ahmed Dridi',
    statut:      StatutEchantillon.enAttente,
  ),
];
