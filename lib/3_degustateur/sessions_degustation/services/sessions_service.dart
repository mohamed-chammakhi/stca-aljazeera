import '../../../../core/models/session_degustation.dart';

import '../../../../core/api_client.dart';

class SessionsService {
  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches all tasting sessions.
  Future<List<SessionDegustation>> fetchSessions() async {
    final items = await apiClient.getList('/api/sessions_degustation/');
    return items
        .map((e) => SessionDegustation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new tasting session and returns the saved record.
  Future<SessionDegustation> createSession(SessionDegustation s) async {
    final response = await apiClient.post('/api/sessions_degustation/', s.toJson());
    return SessionDegustation.fromJson(response);
  }

  /// Updates an existing tasting session via PATCH and returns the updated record.
  Future<SessionDegustation> updateSession(SessionDegustation s) async {
    final response = await apiClient.patch(
      '/api/sessions_degustation/${s.id}/',
      s.toJson(),
    );
    return SessionDegustation.fromJson(response);
  }

  /// Deletes a tasting session by ID.
  Future<void> deleteSession(String id) async {
    await apiClient.delete('/api/sessions_degustation/$id/');
  }

  /// Confirms the current user's presence for a tasting session.
  Future<void> confirmerPresence(String sessionId) async {
    await apiClient.post('/api/sessions_degustation/$sessionId/confirmer_presence/', {});
  }
}
