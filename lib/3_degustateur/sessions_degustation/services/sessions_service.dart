import '../../../../core/models/session_degustation.dart';
import '../../../../core/models/enums.dart';

class SessionsService {
  // TODO: inject ApiClient here when backend is ready

  Future<List<SessionDegustation>> fetchSessions() async {
    // TODO: replace with: return _api.get('/sessions/degustation/');
    return _mockSessions();
  }

  Future<SessionDegustation> createSession(SessionDegustation s) async {
    // TODO: replace with: return _api.post('/sessions/degustation/', s.toJson());
    return s;
  }

  Future<SessionDegustation> updateSession(SessionDegustation s) async {
    // TODO: replace with: return _api.put('/sessions/degustation/${s.id}/', s.toJson());
    return s;
  }

  Future<void> deleteSession(String id) async {
    // TODO: replace with: await _api.delete('/sessions/degustation/$id/');
  }

  Future<void> confirmerPresence(String sessionId, String participantId) async {
    // TODO: replace with: await _api.post('/sessions/degustation/$sessionId/presence/', {'participant_id': participantId});
  }

  // TODO: remove when backend is ready
  List<SessionDegustation> _mockSessions() => [
        SessionDegustation(
          id: 'SES-001',
          titre: 'Session Chemlali - Lot A',
          date: '20/02/2026',
          heure: '09:00',
          lieu: 'Salle de dégustation A',
          statut: StatutSession.terminee,
          echantillonIds: ['OL-2024-001', 'OL-2024-005'],
          participantIds: ['mock-ichrak', 'mock-lobna', 'mock-maha'],
          participantNoms: ['Ichrak C.', 'Lobna E.', 'Maha O.'],
          confirmedParticipantIds: ['mock-ichrak', 'mock-lobna', 'mock-maha'],
          confirmedParticipantNoms: ['Ichrak C.', 'Lobna E.', 'Maha O.'],
          notes: 'Apporter les fiches de notation',
          createdBy: 'mock-user-001',
          createdAt: '2026-02-01T08:00:00Z',
        ),
        SessionDegustation(
          id: 'SES-002',
          titre: 'Session Chetoui - Lot B',
          date: '21/02/2026',
          heure: '10:30',
          lieu: 'Laboratoire 2',
          statut: StatutSession.planifiee,
          echantillonIds: ['OL-2024-002'],
          participantIds: ['mock-nayrouz', 'mock-yosra'],
          participantNoms: ['Nayrouz F.', 'Yosra S.'],
          confirmedParticipantIds: ['mock-nayrouz'],
          confirmedParticipantNoms: ['Nayrouz F.'],
          createdBy: 'mock-user-001',
          createdAt: '2026-02-05T08:00:00Z',
        ),
        SessionDegustation(
          id: 'SES-003',
          titre: 'Session Zalmati',
          date: '25/02/2026',
          heure: '14:00',
          lieu: 'Salle de dégustation B',
          statut: StatutSession.planifiee,
          echantillonIds: ['OL-2024-003', 'OL-2024-004'],
          participantIds: ['mock-ichrak', 'mock-maha', 'mock-nayrouz', 'mock-yosra'],
          participantNoms: ['Ichrak C.', 'Maha O.', 'Nayrouz F.', 'Yosra S.'],
          confirmedParticipantIds: ['mock-ichrak', 'mock-maha'],
          confirmedParticipantNoms: ['Ichrak C.', 'Maha O.'],
          notes: 'Préparer les verres ISO 3591',
          createdBy: 'mock-user-001',
          createdAt: '2026-02-10T08:00:00Z',
        ),
        SessionDegustation(
          id: 'SES-004',
          titre: 'Session Oueslati - Kairouan',
          date: '01/03/2026',
          heure: '09:30',
          lieu: 'Salle de dégustation A',
          statut: StatutSession.planifiee,
          echantillonIds: ['OL-2024-004'],
          participantIds: ['mock-lobna', 'mock-yosra'],
          participantNoms: ['Lobna E.', 'Yosra S.'],
          confirmedParticipantIds: [],
          confirmedParticipantNoms: [],
          createdBy: 'mock-user-001',
          createdAt: '2026-02-15T08:00:00Z',
        ),
      ];
}
