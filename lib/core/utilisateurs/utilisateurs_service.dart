import '../api_client.dart';
import '../models/enums.dart';
import '../models/user_profile.dart';
import '../services/resultat_service.dart';
import '../../1_ceo/utilisateurs/models/mock_data_patch.dart';

class UtilisateursService {
  final ApiClient _api;

  UtilisateursService({ApiClient? api}) : _api = api ?? apiClient;

  Future<Resultat<List<UserProfile>>> fetchUsers() => avecSecours(() async {
    final items = await _api.getList('/api/users/');
    return items
        .map((item) => UserProfile.fromJson(item as Map<String, dynamic>))
        .toList();
  }, () => List<UserProfile>.from(mockUtilisateurs));

  Future<UserProfile> createUser({
    required String nom,
    required String prenom,
    required String email,
    required RoleUtilisateur role,
    required String telephone,
  }) async {
    final data = await _api.post('/api/users/', {
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
    final data = await _api.post('/api/users/$id/toggle-active/', {});
    return UserProfile.fromJson(data);
  }

  Future<void> deleteUser(String id) => _api.delete('/api/users/$id/');

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
    return "Impossible de joindre le serveur. Aucune modification n'a été enregistrée.";
  }
}

final utilisateursService = UtilisateursService();
