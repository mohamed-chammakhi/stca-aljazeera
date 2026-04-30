// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/services/echantillon_collecteur_service.dart
// ═════════════════════════════════════════════════════════════════════════════

import '../models/echantillon_collecteur.dart';

class EchantillonCollecteurService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<EchantillonCollecteur>> fetchEchantillons() async {
    // TODO: replace with: return EchantillonCollecteur.fromJsonList(
    //   await _api.get('/collecteur/echantillons/'));
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockEchantillons();
  }

  Future<EchantillonCollecteur> createEchantillon(
      EchantillonCollecteur e) async {
    // TODO: replace with: return EchantillonCollecteur.fromJson(
    //   await _api.post('/collecteur/echantillons/', e.toJson()));
    await Future.delayed(const Duration(milliseconds: 100));
    return e;
  }

  Future<EchantillonCollecteur> updateEchantillon(
      EchantillonCollecteur e) async {
    // TODO: replace with: return EchantillonCollecteur.fromJson(
    //   await _api.put('/collecteur/echantillons/${e.id}/', e.toJson()));
    await Future.delayed(const Duration(milliseconds: 100));
    return e;
  }

  Future<void> deleteEchantillon(String id) async {
    // TODO: replace with: await _api.delete('/collecteur/echantillons/$id/');
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // TODO: remove when backend is ready
  List<EchantillonCollecteur> _mockEchantillons() => [
        // Scenario 1 : Réceptionné — pas encore reçu, pas d'arrivée planifiée
        EchantillonCollecteur(
          id: 'ECH-001',
          ref: '2026/0001',
          gouvernorat: 'Sfax',
          delegation: 'Sfax Sud',
          codeFournisseur: 'SF-42',
          referenceBouteille: 'CHEMLALI-C1',
          scellage: 'Z1',
          achatConfirme: false,
          dateAjout: DateTime(2026, 3, 1),
          quantiteEstimee: '10T',
          variete: 'Chemlali',
          statut: StatutCollecteur.receptionne,
          collecteurId: 'COL-001',
          collecteurNom: 'Ahmed D.',
          recuPhysiquement: false,
        ),
        // Scenario 2 : Réceptionné — arrivée planifiée, pas encore reçu physiquement
        EchantillonCollecteur(
          id: 'ECH-002',
          ref: '2026/0002',
          gouvernorat: 'Nabeul',
          delegation: 'Nabeul',
          codeFournisseur: 'NB-07',
          referenceBouteille: 'SAYALI-C2',
          scellage: 'Z3',
          achatConfirme: false,
          remarques: 'Récolte tardive',
          dateAjout: DateTime(2026, 3, 5),
          quantiteEstimee: '15T',
          variete: 'Sayali',
          statut: StatutCollecteur.receptionne,
          collecteurId: 'COL-001',
          collecteurNom: 'Ahmed D.',
          recuPhysiquement: false,
          dateArriveeEchantillon: DateTime(2026, 3, 12),
        ),
        // Scenario 3 : Réceptionné + reçu physiquement — modifiable, non supprimable
        EchantillonCollecteur(
          id: 'ECH-003',
          ref: '2026/0003',
          gouvernorat: 'Béja',
          delegation: 'Béja Nord',
          codeFournisseur: 'BJ-15',
          referenceBouteille: 'CHETOUI-C3',
          scellage: 'Z2',
          achatConfirme: false,
          dateAjout: DateTime(2026, 3, 8),
          quantiteEstimee: '20T',
          variete: 'Chetoui',
          statut: StatutCollecteur.receptionne,
          collecteurId: 'COL-001',
          collecteurNom: 'Ahmed D.',
          recuPhysiquement: true,
          dateReceptionEchantillon: DateTime(2026, 3, 10),
        ),
        // Scenario 4 : En négociation — budget + date souhaitée définis par la direction
        EchantillonCollecteur(
          id: 'ECH-004',
          ref: '2026/0004',
          gouvernorat: 'Béja',
          delegation: 'Amdoun',
          codeFournisseur: 'BJ-22',
          referenceBouteille: 'CHETOUI-C4',
          scellage: 'Z2',
          achatConfirme: false,
          remarques: 'Récolte précoce',
          dateAjout: DateTime(2026, 2, 28),
          quantiteEstimee: '25T',
          variete: 'Chetoui',
          statut: StatutCollecteur.enNegociation,
          collecteurId: 'COL-001',
          collecteurNom: 'Ahmed D.',
          recuPhysiquement: true,
          dateReceptionEchantillon: DateTime(2026, 3, 5),
          budgetNegociation: '9.50 TND/L',
          dateStockSouhaiteeDebut: DateTime(2026, 4, 1),
          dateStockSouhaiteeFin: DateTime(2026, 4, 15),
        ),
        // Scenario 5 : En négociation — pas encore de budget défini
        EchantillonCollecteur(
          id: 'ECH-005',
          ref: '2026/0005',
          gouvernorat: 'Jendouba',
          delegation: 'Tabarka',
          codeFournisseur: 'JN-09',
          referenceBouteille: 'CHETOUI-C5',
          scellage: 'Z4',
          achatConfirme: false,
          dateAjout: DateTime(2026, 3, 2),
          quantiteEstimee: '18T',
          variete: 'Chetoui',
          statut: StatutCollecteur.enNegociation,
          collecteurId: 'COL-001',
          collecteurNom: 'Ahmed D.',
          recuPhysiquement: true,
          dateReceptionEchantillon: DateTime(2026, 3, 7),
        ),
        // Scenario 6 : Achat confirmé — aucune livraison planifiée
        EchantillonCollecteur(
          id: 'ECH-006',
          ref: '2026/0006',
          gouvernorat: 'Gabès',
          delegation: 'Gabès Sud',
          codeFournisseur: 'GB-11',
          referenceBouteille: 'CHÉTOUI-C6',
          scellage: 'Z1',
          achatConfirme: true,
          dateAjout: DateTime(2026, 2, 18),
          quantiteEstimee: '12T',
          variete: 'Chetoui',
          statut: StatutCollecteur.achatConfirme,
          collecteurId: 'COL-001',
          collecteurNom: 'Ahmed D.',
          recuPhysiquement: true,
          dateReceptionEchantillon: DateTime(2026, 2, 22),
          prixFinal: '8.80 TND/L',
          camionLivraison: 'CAM-05',
        ),
        // Scenario 7 : Achat confirmé — livraison planifiée
        EchantillonCollecteur(
          id: 'ECH-007',
          ref: '2026/0007',
          gouvernorat: 'Gafsa',
          delegation: 'Gafsa Sud',
          codeFournisseur: 'GF-08',
          referenceBouteille: 'ZALMATI-C7',
          scellage: 'Z1',
          achatConfirme: true,
          dateAjout: DateTime(2026, 2, 20),
          quantiteEstimee: '30T',
          variete: 'Zalmati',
          statut: StatutCollecteur.achatConfirme,
          collecteurId: 'COL-001',
          collecteurNom: 'Ahmed D.',
          recuPhysiquement: true,
          dateReceptionEchantillon: DateTime(2026, 2, 25),
          prixFinal: '9.20 TND/L',
          camionLivraison: 'CAM-03',
          livraison: PlanificationLivraison.exact(
            date: DateTime(2026, 3, 15),
            heure: '9:00 AM',
            lieu: 'Entrepôt principal Sfax',
            camion: 'CAM-03',
          ),
        ),
      ];
}
