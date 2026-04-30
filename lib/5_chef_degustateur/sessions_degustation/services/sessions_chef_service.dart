import '../models/session_degustation.dart';
import '../models/mock_sessions.dart';

class SessionsChefService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<SessionDegustation>> fetchSessions() async {
    // TODO: replace with: return _api.get('/sessions/?role=chef_degustateur');
    return _mockSessions();
  }

  Future<SessionDegustation> createSession(SessionDegustation s) async {
    // TODO: replace with: return _api.post('/sessions/', s.toJson());
    return s;
  }

  Future<SessionDegustation> updateSession(SessionDegustation s) async {
    // TODO: replace with: return _api.put('/sessions/${s.id}/', s.toJson());
    return s;
  }

  Future<void> deleteSession(String id) async {
    // TODO: replace with: await _api.delete('/sessions/$id/');
  }

  Future<void> approuverSession(String id) async {
    // TODO: replace with: await _api.patch('/sessions/$id/', {'statut': 'planifiee'});
  }

  Future<void> refuserSession(String id) async {
    // TODO: replace with: await _api.delete('/sessions/$id/');
  }

  // TODO: remove when backend is ready
  List<SessionDegustation> _mockSessions() => List.from(mockSessionsChef);
}
