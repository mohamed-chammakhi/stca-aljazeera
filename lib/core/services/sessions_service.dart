import 'package:project3/core/api_client.dart';
import 'package:project3/core/models/mock_sessions.dart';
import 'package:project3/core/models/session_degustation.dart';
import 'package:project3/core/services/resultat_service.dart';

class SessionsService {
  final bool peutValider;

  const SessionsService({this.peutValider = false});

  static final _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  Future<Resultat<List<SessionDegustation>>> fetchSessions() => avecSecours(
    () async {
      final data = await apiClient.getList('/api/sessions/');
      return data
          .map(
            (item) => SessionDegustation.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    },
    () => List.of(peutValider ? mockSessionsChef : mockSessionsDegustateur),
  );

  Future<SessionDegustation> createSession(SessionDegustation s) async {
    final created = await apiClient.post('/api/sessions/', _payload(s));
    return SessionDegustation.fromJson(created);
  }

  Future<SessionDegustation> updateSession(SessionDegustation s) async {
    if (!_uuidPattern.hasMatch(s.id)) {
      throw StateError(
        'Modification indisponible pour une session de démonstration.',
      );
    }
    final updated = await apiClient.patch(
      '/api/sessions/${s.id}/',
      _payload(s),
    );
    return SessionDegustation.fromJson(updated);
  }

  Future<void> deleteSession(String id) async {
    if (!_uuidPattern.hasMatch(id)) {
      throw StateError(
        'Suppression indisponible pour une session de démonstration.',
      );
    }
    await apiClient.delete('/api/sessions/$id/');
  }

  Future<void> approuverSession(String id) async {
    if (!peutValider) {
      throw StateError("Approbation réservée au chef dégustateur.");
    }
    if (!_uuidPattern.hasMatch(id)) {
      throw StateError(
        'Approbation indisponible pour une session de démonstration.',
      );
    }
    await apiClient.post('/api/sessions/$id/approuver/', {});
  }

  Future<void> refuserSession(String id) async {
    if (!peutValider) {
      throw StateError("Refus réservé au chef dégustateur.");
    }
    if (!_uuidPattern.hasMatch(id)) {
      throw StateError('Refus indisponible pour une session de démonstration.');
    }
    await apiClient.post('/api/sessions/$id/refuser/', {});
  }

  Future<SessionDegustation?> confirmerPresence(String sessionId) async {
    if (!_uuidPattern.hasMatch(sessionId)) {
      throw StateError(
        'Confirmation indisponible pour une session de démonstration.',
      );
    }
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
