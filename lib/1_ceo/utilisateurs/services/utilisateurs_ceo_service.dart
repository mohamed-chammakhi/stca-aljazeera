import '../../../../core/api_client.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/user_profile.dart';

class UtilisateursCeoService {
  const UtilisateursCeoService();

  Future<List<UserProfile>> fetchUsers() async {
    final items = await apiClient.getList('/api/users/');
    return items
        .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UserProfile> createUser({
    required String nom,
    required String prenom,
    required String email,
    required RoleUtilisateur role,
    required String telephone,
  }) async {
    final data = await apiClient.post('/api/users/', {
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'role': role.toJson,
      'telephone': telephone,
      'password': 'Test@12345',
    });
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> toggleActive(String id) async {
    final data = await apiClient.post('/api/users/$id/toggle-active/', {});
    return UserProfile.fromJson(data);
  }

  Future<void> deleteUser(String id) => apiClient.delete('/api/users/$id/');

  String messageFor(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 403) {
        return "Vous n'avez pas l'autorisation de gérer les utilisateurs.";
      }
      if (error.statusCode == 400 && error.message.contains('email')) {
        return 'Cet email est déjà utilisé ou invalide.';
      }
      return error.message;
    }
    return 'Impossible de joindre le serveur. Les données de démonstration restent affichées.';
  }
}

const utilisateursCeoService = UtilisateursCeoService();
