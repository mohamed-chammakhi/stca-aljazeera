import '../api_client.dart';

class MotDePasseOublieService {
  final ApiClient _api;

  MotDePasseOublieService({ApiClient? api}) : _api = api ?? apiClient;

  Future<void> envoyerCode(String email) async {
    await _api.postPublic('/api/auth/mot-de-passe-oublie/', {
      'email': email,
    });
  }

  Future<String> verifierCode({
    required String email,
    required String code,
  }) async {
    final data = await _api.postPublic(
      '/api/auth/mot-de-passe-oublie/verifier/',
      {
        'email': email,
        'code': code,
      },
    );
    return data['jeton'] as String;
  }

  Future<void> enregistrerNouveauMotDePasse({
    required String jeton,
    required String nouveauMotDePasse,
  }) async {
    await _api.postPublic('/api/auth/mot-de-passe-oublie/nouveau/', {
      'jeton': jeton,
      'nouveau_mot_de_passe': nouveauMotDePasse,
    });
  }

  String messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
  }
}

final motDePasseOublieService = MotDePasseOublieService();
