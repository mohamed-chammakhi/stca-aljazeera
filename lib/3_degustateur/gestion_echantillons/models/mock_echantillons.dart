// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/models/mock_echantillons.dart
// PURPOSE : mock sample data for gestion page
// TODO: remove when backend is ready and replace with EchantillonService.fetch()
// ─────────────────────────────────────────────────────────────────────────────

import '../../../core/models/echantillon.dart';

// TODO: remove when backend is ready
final List<Echantillon> mockEchantillonsGestion = [
  Echantillon(
    id:                  '2026/0001',
    referenceBouteille:  'CHEMLALI-C1',
    codeFournisseur:     'Domaine Bel-Air',
    variete:             'Chemlali',
    dateAjout:           '01/03/2026',
    gouvernorat:         'Sfax',
    delegation:          'Sfax Sud',
    quantiteEstimee:     '25',
    statut:              'En attente',
    collecteurNom:       'Ahmed Dridi',
    dateLivraisonPrevue: '15/03/2026',
  ),
  Echantillon(
    id:              '2026/0002',
    referenceBouteille: 'CHEMLALI-C4',
    codeFournisseur: 'SF-17',
    variete:         'Chemlali',
    dateAjout:       '05/03/2026',
    gouvernorat:     'Sfax',
    delegation:      'Mahres',
    quantiteEstimee: '12',
    statut:          'En cours',
    collecteurNom:   'Ahmed Dridi',
  ),
  Echantillon(
    id:                  '2026/0003',
    referenceBouteille:  'CHETOUI-C3',
    codeFournisseur:     'Ferme Al Jazira',
    variete:             'Chetoui',
    dateAjout:           '21/02/2026',
    gouvernorat:         'Béja',
    delegation:          'Béja Nord',
    quantiteEstimee:     '32',
    statut:              'Soumis',
    collecteurNom:       'Rania Hammami',
    dateLivraisonPrevue: '28/02/2026',
  ),
  Echantillon(
    id:              '2026/0004',
    referenceBouteille: 'OUESLATI-C2',
    codeFournisseur: 'Green Valley',
    variete:         'Oueslati',
    dateAjout:       '23/02/2026',
    gouvernorat:     'Kairouan',
    delegation:      'Kairouan Nord',
    quantiteEstimee: '18',
    statut:          'En attente',
  ),
];
