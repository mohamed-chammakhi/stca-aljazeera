import '../api_client.dart';
import '../models/user_profile.dart';

class AuthService {
  const AuthService();

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    await apiClient.login(email, password);
    return currentUser();
  }

  Future<UserProfile> currentUser() async {
    final data = await apiClient.get('/api/users/me/');
    return UserProfile.fromJson(data);
  }

  Future<void> logout() => apiClient.logout();
}

const authService = AuthService();
