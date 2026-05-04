import '../models/session_degustation.dart';
import '../../../core/api_client.dart';

class SessionsChefService {
  /// Fetches all tasting sessions.
  ///
  /// Backend: GET /api/sessions_degustation/
  /// Django returns a paginated envelope {count, results:[...]} which
  /// [SessionDegustation.fromJsonList] unwraps, OR a plain list — handled by
  /// [apiClient.getList] which unwraps paginated responses automatically.
  Future<List<SessionDegustation>> fetchSessions() async {
    final items = await apiClient.getList('/api/sessions_degustation/');
    return items
        .map((e) => SessionDegustation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new session.
  ///
  /// Backend: POST /api/sessions_degustation/
  Future<SessionDegustation> createSession(SessionDegustation s) async {
    final raw = await apiClient.post('/api/sessions_degustation/', s.toJson());
    return SessionDegustation.fromJson(raw);
  }

  /// Updates an existing session (partial update).
  ///
  /// Backend: PATCH /api/sessions_degustation/{id}/
  Future<SessionDegustation> updateSession(SessionDegustation s) async {
    final raw = await apiClient.patch('/api/sessions_degustation/${s.id}/', s.toJson());
    return SessionDegustation.fromJson(raw);
  }

  /// Deletes a session.
  ///
  /// Backend: DELETE /api/sessions_degustation/{id}/
  Future<void> deleteSession(String id) async {
    await apiClient.delete('/api/sessions_degustation/$id/');
  }

  /// Approves a session (chef action).
  ///
  /// Backend: POST /api/sessions_degustation/{id}/approuver/
  Future<void> approuverSession(String id) async {
    await apiClient.post('/api/sessions_degustation/$id/approuver/', {});
  }

  /// Refuses a session (chef action).
  ///
  /// Backend: POST /api/sessions_degustation/{id}/refuser/
  Future<void> refuserSession(String id) async {
    await apiClient.post('/api/sessions_degustation/$id/refuser/', {});
  }
}
