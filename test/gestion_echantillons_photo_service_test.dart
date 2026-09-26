import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/api_client.dart';
import 'package:project3/core/models/echantillon.dart';
import 'package:project3/core/models/enums.dart';
import 'package:project3/core/services/gestion_echantillons_service.dart';

void main() {
  group('GestionEchantillonsService photo', () {
    test('createEchantillon sans photo envoie un POST JSON', () async {
      final api = _RecordingApiClient();
      final service = GestionEchantillonsService(api: api);

      await service.createEchantillon(_sample());

      expect(api.calls, ['post']);
      expect(api.lastPath, '/api/echantillons/');
      expect(api.lastBody?['reference_bouteille'], 'B-001');
    });

    test('createEchantillon avec photo envoie un POST multipart', () async {
      final api = _RecordingApiClient();
      final service = GestionEchantillonsService(api: api);

      await service.createEchantillon(
        _sample()
          ..photoAEnvoyer = [1, 2, 3]
          ..photoNomFichier = 'bouteille-test.jpg',
      );

      expect(api.calls, ['postMultipart']);
      expect(api.lastPath, '/api/echantillons/');
      expect(api.lastBytes, [1, 2, 3]);
      expect(api.lastFilename, 'bouteille-test.jpg');
      expect(api.lastFields?['reference_bouteille'], 'B-001');
    });

    test('updateEchantillon sans photo envoie un PATCH JSON', () async {
      final api = _RecordingApiClient();
      final service = GestionEchantillonsService(api: api);

      await service.updateEchantillon(_sample());

      expect(api.calls, ['patch']);
      expect(
        api.lastPath,
        '/api/echantillons/11111111-1111-1111-1111-111111111111/',
      );
      expect(api.lastBody?['reference_bouteille'], 'B-001');
    });

    test('updateEchantillon avec photo envoie un PATCH multipart', () async {
      final api = _RecordingApiClient();
      final service = GestionEchantillonsService(api: api);

      await service.updateEchantillon(
        _sample()
          ..photoAEnvoyer = [4, 5, 6]
          ..photoNomFichier = 'bouteille-edit.jpg',
      );

      expect(api.calls, ['patchMultipart']);
      expect(
        api.lastPath,
        '/api/echantillons/11111111-1111-1111-1111-111111111111/',
      );
      expect(api.lastBytes, [4, 5, 6]);
      expect(api.lastFilename, 'bouteille-edit.jpg');
      expect(api.lastFields?['reference_bouteille'], 'B-001');
    });
  });
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(baseUrl: 'http://test.invalid');

  final List<String> calls = [];
  String? lastPath;
  Map<String, dynamic>? lastBody;
  Map<String, String>? lastFields;
  List<int>? lastBytes;
  String? lastFilename;

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    calls.add('post');
    lastPath = path;
    lastBody = Map<String, dynamic>.from(body);
    return _response(body);
  }

  @override
  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    calls.add('patch');
    lastPath = path;
    lastBody = Map<String, dynamic>.from(body);
    return _response(body);
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required List<int> bytes,
    required String filename,
    String fileField = 'image',
    Map<String, String>? fields,
  }) async {
    calls.add('postMultipart');
    lastPath = path;
    lastBytes = List<int>.from(bytes);
    lastFilename = filename;
    lastFields = fields == null ? null : Map<String, String>.from(fields);
    return _response(fields ?? {});
  }

  @override
  Future<Map<String, dynamic>> patchMultipart(
    String path, {
    required List<int> bytes,
    required String filename,
    String fileField = 'image',
    Map<String, String>? fields,
  }) async {
    calls.add('patchMultipart');
    lastPath = path;
    lastBytes = List<int>.from(bytes);
    lastFilename = filename;
    lastFields = fields == null ? null : Map<String, String>.from(fields);
    return _response(fields ?? {});
  }

  Map<String, dynamic> _response(Map<dynamic, dynamic> data) => {
    ...Map<String, dynamic>.from(data),
    'id': '11111111-1111-1111-1111-111111111111',
    'numero': '2026/0001',
    'fournisseur': '22222222-2222-2222-2222-222222222222',
    'collecteur': '33333333-3333-3333-3333-333333333333',
    'fournisseur_nom': 'Domaine Test',
    'collecteur_nom': 'Collecteur Test',
    'gouvernorat': data['gouvernorat'] ?? 'Sfax',
    'reference_bouteille': data['reference_bouteille'] ?? 'B-001',
    'statut_collecteur': data['statut_collecteur'] ?? 'receptionne',
    'recu_physiquement': false,
    'stock_arrive': false,
    'date_ajout': '2026-08-05T10:00:00Z',
  };
}

Echantillon _sample() => Echantillon(
  id: '11111111-1111-1111-1111-111111111111',
  numero: '2026/0001',
  fournisseurId: '22222222-2222-2222-2222-222222222222',
  collecteurId: '33333333-3333-3333-3333-333333333333',
  fournisseurNom: 'Domaine Test',
  gouvernorat: 'Sfax',
  referenceBouteille: 'B-001',
  statutCollecteur: StatutCollecteur.receptionne,
  dateAjout: '2026-08-05T10:00:00Z',
);
