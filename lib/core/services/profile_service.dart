import '../api_client.dart';
import '../models/user_profile.dart';

class ProfileService {
  final ApiClient _api;

  ProfileService({ApiClient? api}) : _api = api ?? apiClient;

  Future<UserProfile> currentProfile() async {
    final data = await _api.get('/api/users/me/');
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateCurrentProfile({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
  }) async {
    final data = await _api.patch('/api/users/me/', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
    });
    return UserProfile.fromJson(data);
  }

  Future<void> changerMotDePasse({
    required String ancien,
    required String nouveau,
  }) async {
    await _api.post('/api/users/me/changer-mot-de-passe/', {
      'ancien_mot_de_passe': ancien,
      'nouveau_mot_de_passe': nouveau,
    });
  }

  String messageFor(Object error) {
    if (error is ApiException) {
      if (error.code == 'password_incorrect') {
        return 'Mot de passe actuel incorrect.';
      }
      if (error.statusCode == 400 && error.message.contains('email')) {
        return 'Cet email est déjà utilisé ou invalide.';
      }
      return error.message;
    }
    return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
  }
}

final profileService = ProfileService();
