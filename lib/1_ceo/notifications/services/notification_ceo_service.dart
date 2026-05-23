import '../models/notification_ceo.dart';

// TODO: switch back to real API when backend is ready
class NotificationCeoService {
  static final List<NotificationCeo> _mock = [
    NotificationCeo(
      id: 'n-ceo-001',
      type: 'evaluation_soumise',
      titre: 'Évaluation soumise',
      message: 'L\'évaluation de CHEMLALI-C1 a été soumise par Ali Ben Salem.',
      echantillonId: '2026/0001',
      echantillonReference: 'CHEMLALI-C1',
      section: 'EVALUATIONS',
      isRead: false,
      dateCreation: DateTime(2026, 5, 5, 9, 15),
    ),
    NotificationCeo(
      id: 'n-ceo-002',
      type: 'analyse_soumise',
      titre: 'Analyse laboratoire disponible',
      message: 'L\'analyse chimique de OUESLATI-C2 est disponible. Acidité : 0.55 %.',
      echantillonId: '2026/0005',
      echantillonReference: 'OUESLATI-C2',
      section: 'ANALYSES',
      isRead: false,
      dateCreation: DateTime(2026, 5, 4, 14, 30),
    ),
    NotificationCeo(
      id: 'n-ceo-003',
      type: 'achat_confirme',
      titre: 'Achat confirmé',
      message: 'L\'achat du lot CHETOUI-C5 (18 T) a été confirmé. Camion TRK-007 réservé.',
      echantillonId: '2026/0008',
      echantillonReference: 'CHETOUI-C5',
      section: 'ACHATS',
      isRead: false,
      dateCreation: DateTime(2026, 5, 3, 10, 0),
    ),
    NotificationCeo(
      id: 'n-ceo-004',
      type: 'stock_arrive',
      titre: 'Stock arrivé',
      message: 'Le stock du lot CHEMLALI-C8 (25 T) est arrivé. Livraison confirmée.',
      echantillonId: '2026/0007',
      echantillonReference: 'CHEMLALI-C8',
      section: 'ACHATS',
      isRead: true,
      dateCreation: DateTime(2026, 5, 1, 8, 0),
    ),
    NotificationCeo(
      id: 'n-ceo-005',
      type: 'echantillon_recu',
      titre: 'Échantillon reçu physiquement',
      message: 'L\'échantillon CHEMLALI-C9 a été reçu physiquement au laboratoire.',
      echantillonId: '2026/0010',
      echantillonReference: 'CHEMLALI-C9',
      section: 'ECHANTILLONS',
      isRead: true,
      dateCreation: DateTime(2026, 4, 30, 13, 10),
    ),
    NotificationCeo(
      id: 'n-ceo-006',
      type: 'evaluation_urgente',
      titre: 'Évaluation urgente requise',
      message: 'OUESLATI-C2 attend une évaluation depuis 14 jours. Veuillez accélérer le processus.',
      echantillonId: '2026/0004',
      echantillonReference: 'OUESLATI-C2',
      section: 'EVALUATIONS',
      isRead: true,
      dateCreation: DateTime(2026, 4, 28, 9, 0),
    ),
    NotificationCeo(
      id: 'n-ceo-007',
      type: 'echantillon_enregistre',
      titre: 'Nouvel échantillon enregistré',
      message: 'NOURI-03 (Nabeul, 22 T) enregistré par Mounir Zouaghi.',
      echantillonId: '2026/0011',
      echantillonReference: 'NOURI-03',
      section: 'ECHANTILLONS',
      isRead: true,
      dateCreation: DateTime(2026, 4, 10, 10, 0),
    ),
    NotificationCeo(
      id: 'n-ceo-008',
      type: 'proposition_achat_attente',
      titre: "Proposition d'achat en attente",
      message: "CHEMLALI-K7 (40 T) : Ahmed Dridi propose 8.20 TND/L. À valider.",
      echantillonId: '2026/0012',
      echantillonReference: 'CHEMLALI-K7',
      section: 'ACHATS_VALIDATION',
      isRead: false,
      dateCreation: DateTime(2026, 5, 20, 14, 45),
    ),
    NotificationCeo(
      id: 'n-ceo-009',
      type: 'proposition_achat_attente',
      titre: "Proposition d'achat en attente",
      message: "CHETOUI-J3 (28 T) : Sami Khaled propose 7.95 TND/L. À valider.",
      echantillonId: '2026/0013',
      echantillonReference: 'CHETOUI-J3',
      section: 'ACHATS_VALIDATION',
      isRead: true,
      dateCreation: DateTime(2026, 5, 19, 11, 20),
    ),
    NotificationCeo(
      id: 'n-ceo-010',
      type: 'proposition_achat_attente',
      titre: "Proposition d'achat en attente",
      message: "OUESLATI-M1 (15 T) : Mounir Zouaghi propose 8.50 TND/L. À valider.",
      echantillonId: '2026/0014',
      echantillonReference: 'OUESLATI-M1',
      section: 'ACHATS_VALIDATION',
      isRead: true,
      dateCreation: DateTime(2026, 5, 17, 9, 0),
    ),
  ];

  Future<List<NotificationCeo>> fetchNotifications() async {
    return List.of(_mock);
  }

  Future<void> markAsRead(String id) async {
    final idx = _mock.indexWhere((n) => n.id == id);
    if (idx != -1) _mock[idx] = _mock[idx].copyWith(isRead: true);
  }

  Future<void> markAllAsRead() async {
    for (var i = 0; i < _mock.length; i++) {
      _mock[i] = _mock[i].copyWith(isRead: true);
    }
  }

  Future<int> fetchUnreadCount() async {
    return _mock.where((n) => !n.isRead).length;
  }
}
