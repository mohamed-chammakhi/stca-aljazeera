// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/services/labo_service.dart
// PURPOSE : Data access for the lab technician module.
//           Currently returns mock data; swap each method body for an
//           _api.get / _api.post call when the Django backend is ready.
// ═════════════════════════════════════════════════════════════════════════════

import '../models/echantillon_labo.dart';
import '../../analyse_labo.dart';

class LaboService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<EchantillonLabo>> fetchEchantillons() async {
    // TODO: replace with: return EchantillonLabo.fromJsonList(await _api.get('/laboratoire/echantillons/'));
    return _mockEchantillons();
  }

  Future<void> saveAnalyse(String echantillonId, AnalyseLabo analyse) async {
    // TODO: replace with: await _api.post('/laboratoire/echantillons/$echantillonId/analyse/', analyse.toJson());
  }

  Future<void> deleteAnalyse(String echantillonId) async {
    // TODO: replace with: await _api.delete('/laboratoire/echantillons/$echantillonId/analyse/');
  }

  // TODO: remove when backend is ready
  List<EchantillonLabo> _mockEchantillons() => [
    EchantillonLabo(
      id: 'ECH-001',
      ref: '2026/0001',
      gouvernorat: 'Sfax',
      codeFournisseur: 'SF-42',
      collecteurNom: 'Ahmed D.',
      referenceBouteille: 'CHEMLALI-C1',
      variete: 'Chemlali',
      quantiteEstimee: '10',
      dateArrivee: '01/03/2026',
      origineCampagne: '2025/2026',
    ),
    EchantillonLabo(
      id: 'ECH-002',
      ref: '2026/0002',
      gouvernorat: 'Béja',
      codeFournisseur: 'BJ-15',
      collecteurNom: 'Ahmed D.',
      referenceBouteille: 'CHETOUI-C3',
      variete: 'Chetoui',
      quantiteEstimee: '8',
      dateArrivee: '28/02/2026',
      analyse: AnalyseLabo(
        echantillonId: 'ECH-002',
        echantillonRef: '2026/0002',
        aciditeLibre: 0.42,
        indicePeroxyde: 8.6,
        k232: 1.92,
        k270: 0.14,
        polyphenolsTotaux: 318,
        statut: StatutAnalyse.soumis,
        dateAnalyse: '28/02/2026',
      ),
    ),
    EchantillonLabo(
      id: 'ECH-003',
      ref: '2026/0003',
      gouvernorat: 'Gafsa',
      codeFournisseur: 'GF-08',
      collecteurNom: 'Sami B.',
      referenceBouteille: 'ZALMATI-C7',
      variete: 'Zalmati',
      quantiteEstimee: '30',
      dateArrivee: '20/02/2026',
      priorite: PrioriteLabo.urgente,
      analyse: AnalyseLabo(
        echantillonId: 'ECH-003',
        echantillonRef: '2026/0003',
        aciditeLibre: 1.8,
        indicePeroxyde: 18.0,
        k270: 0.19,
        k232: 2.40,
        statut: StatutAnalyse.soumis,
        dateAnalyse: '21/02/2026',
      ),
    ),
    EchantillonLabo(
      id: 'ECH-004',
      ref: '2026/0004',
      gouvernorat: 'Kairouan',
      codeFournisseur: 'KR-22',
      collecteurNom: 'Leila M.',
      referenceBouteille: 'OUESLATI-C2',
      variete: 'Oueslati',
      quantiteEstimee: '15',
      dateArrivee: '25/02/2026',
    ),
  ];
}
