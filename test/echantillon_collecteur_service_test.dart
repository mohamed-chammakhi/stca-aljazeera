import 'package:flutter_test/flutter_test.dart';
import 'package:project3/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart';
import 'package:project3/2_collecteur/mes_echantillons/services/echantillon_collecteur_service.dart';
import 'package:project3/core/api_client.dart';

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(baseUrl: 'http://test.invalid');

  int postCount = 0;
  String? lastPath;
  Map<String, dynamic>? lastBody;

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    postCount += 1;
    lastPath = path;
    lastBody = Map<String, dynamic>.from(body);
    return {
      ...body,
      'id': '22222222-2222-2222-2222-222222222222',
      'numero': '2026/0001',
      'fournisseur': '33333333-3333-3333-3333-333333333333',
      'fournisseur_nom': body['fournisseur_nom'],
      'collecteur': '44444444-4444-4444-4444-444444444444',
      'collecteur_nom': 'Collecteur Test',
      'date_ajout': '2026-08-05T10:00:00Z',
    };
  }
}

void main() {
  test(
    'la création envoie le nom fournisseur avec une seule requête',
    () async {
      final api = _RecordingApiClient();
      final service = EchantillonCollecteurService(api: api);
      final sample = EchantillonCollecteur(
        id: 'new-1',
        numero: '2026/0001',
        gouvernorat: 'Sfax',
        fournisseurId: 'local-suggestion-id',
        fournisseurNom: 'Domaine Test',
        fournisseurTexte: 'Domaine Test',
        referenceBouteille: 'B-001',
        achatConfirme: false,
        dateAjout: DateTime(2026, 8, 5),
        collecteurId: 'collecteur-placeholder',
        collecteurNom: 'Collecteur Test',
        statut: StatutCollecteur.receptionne,
      );

      final saved = await service.createEchantillon(sample);

      expect(api.postCount, 1);
      expect(api.lastPath, '/api/echantillons/');
      expect(api.lastBody?['fournisseur_nom'], 'Domaine Test');
      expect(api.lastBody?.containsKey('fournisseur'), isFalse);
      expect(saved.fournisseurNom, 'Domaine Test');
    },
  );
}
