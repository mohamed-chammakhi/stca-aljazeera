// ─────────────────────────────────────────────────────────────────────────────
// FILE : sessions_degustation/models/mock_sessions.dart
// PURPOSE : mock session data for chef sessions page
// TODO: remove when backend is ready and replace with SessionsChefService.fetch()
// ─────────────────────────────────────────────────────────────────────────────

import 'session_degustation.dart';

// TODO: remove when backend is ready
final List<SessionDegustation> mockSessionsChef = [
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
    participantIds: [
      'mock-ichrak',
      'mock-maha',
      'mock-nayrouz',
      'mock-yosra',
    ],
    participantNoms: ['Ichrak C.', 'Maha O.', 'Nayrouz F.', 'Yosra S.'],
    notes: 'Préparer les verres ISO 3591',
    createdBy: 'mock-user-001',
    createdAt: '2026-02-10T08:00:00Z',
  ),
  // Sessions suggested by normal dégustateurs — awaiting chef approval
  SessionDegustation(
    id: 'SES-005',
    titre: 'Session Oueslati - Lot C',
    date: '28/04/2026',
    heure: '09:00',
    lieu: 'Salle de dégustation A',
    statut: StatutSession.enAttenteValidation,
    echantillonIds: ['OL-2024-006'],
    participantIds: ['mock-lobna', 'mock-maha'],
    participantNoms: ['Lobna E.', 'Maha O.'],
    notes: 'Proposée par Lobna E.',
    createdBy: 'mock-lobna',
    createdAt: '2026-04-17T10:00:00Z',
  ),
  SessionDegustation(
    id: 'SES-006',
    titre: 'Session Rkhami - Sfax',
    date: '02/05/2026',
    heure: '11:00',
    lieu: 'Laboratoire 1',
    statut: StatutSession.enAttenteValidation,
    echantillonIds: ['OL-2024-007', 'OL-2024-008'],
    participantIds: ['mock-ichrak', 'mock-nayrouz', 'mock-yosra'],
    participantNoms: ['Ichrak C.', 'Nayrouz F.', 'Yosra S.'],
    createdBy: 'mock-ichrak',
    createdAt: '2026-04-18T14:30:00Z',
  ),
];
