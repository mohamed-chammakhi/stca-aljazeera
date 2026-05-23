import '../../../../core/api_client.dart';
import '../../../../core/models/session_degustation.dart';
import '../models/mock_sessions.dart';

class SessionsService {
  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<List<SessionDegustation>> fetchSessions() async {
    try {
      final data = await apiClient.getList('/api/sessions/');
      return data
          .map(
            (item) => SessionDegustation.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return List.of(mockSessionsDegustateur);
    }
  }

  Future<SessionDegustation> createSession(SessionDegustation s) async {
    try {
      final created = await apiClient.post('/api/sessions/', _payload(s));
      return SessionDegustation.fromJson(created);
    } catch (_) {
      mockSessionsDegustateur.add(s);
      return s;
    }
  }

  Future<SessionDegustation> updateSession(SessionDegustation s) async {
    if (!_uuidPattern.hasMatch(s.id)) return s;
    try {
      final updated = await apiClient.patch(
        '/api/sessions/${s.id}/',
        _payload(s),
      );
      return SessionDegustation.fromJson(updated);
    } catch (_) {
      return s;
    }
  }

  Future<void> deleteSession(String id) async {
    if (!_uuidPattern.hasMatch(id)) {
      mockSessionsDegustateur.removeWhere((s) => s.id == id);
      return;
    }
    try {
      await apiClient.delete('/api/sessions/$id/');
    } catch (_) {}
    mockSessionsDegustateur.removeWhere((s) => s.id == id);
  }

  Future<SessionDegustation?> confirmerPresence(String sessionId) async {
    if (!_uuidPattern.hasMatch(sessionId)) return null;
    final updated = await apiClient.post(
      '/api/sessions/$sessionId/confirmer_presence/',
      {},
    );
    return SessionDegustation.fromJson(updated);
  }

  Map<String, dynamic> _payload(SessionDegustation s) {
    final body = s.toJson()
      ..remove('id')
      ..remove('created_by')
      ..remove('created_at')
      ..remove('confirmed_participant_ids');
    body['participant_ids'] = s.participantIds
        .where((id) => _uuidPattern.hasMatch(id))
        .toList();
    body.remove('echantillon_ids');
    body.removeWhere((_, value) => value == null);
    return body;
  }
}
