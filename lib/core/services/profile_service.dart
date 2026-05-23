import '../api_client.dart';
import '../models/user_profile.dart';

class ProfileService {
  const ProfileService();

  Future<UserProfile> currentProfile() async {
    final data = await apiClient.get('/api/users/me/');
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateCurrentProfile({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
  }) async {
    final data = await apiClient.patch('/api/users/me/', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
    });
    return UserProfile.fromJson(data);
  }

  String messageFor(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 400 && error.message.contains('email')) {
        return 'Cet email est déjà utilisé ou invalide.';
      }
      return error.message;
    }
    return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
  }
}

const profileService = ProfileService();
