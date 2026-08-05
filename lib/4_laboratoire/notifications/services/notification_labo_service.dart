import '../models/notification_labo.dart';
import '../../../core/api_client.dart';
import '../../../core/services/resultat_service.dart';

class NotificationLaboService {
  Future<Resultat<List<NotificationLabo>>> fetchNotifications() =>
      avecSecours(() async {
        final data = await apiClient.getList('/api/notifications/');
        return data
            .map((e) => NotificationLabo.fromJson(e as Map<String, dynamic>))
            .toList();
      }, _mockNotifications);

  Future<void> markAsRead(String id) async {
    await apiClient.patch('/api/notifications/$id/lire/', {});
  }

  Future<void> markAllAsRead() async {
    await apiClient.post('/api/notifications/lire-tout/', {});
  }

  Future<Resultat<int>> fetchUnreadCount() => avecSecours(() async {
    final data = await apiClient.get('/api/notifications/unread-count/');
    return data['count'] as int;
  }, () => _mockNotifications().where((n) => !n.isRead).length);

  // TODO: remove when backend is ready
  List<NotificationLabo> _mockNotifications() {
    final now = DateTime.now();
    return [
      // ── Aujourd'hui ────────────────────────────────────────────────────────
      NotificationLabo(
        id: 'notif-labo-1',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Lobna E. (dégustateur) a marqué l'échantillon ECH-2026-041 (Chemlali, Sfax) comme urgent. Veuillez prioriser son analyse chimique.",
        echantillonId: 'ech-041',
        echantillonReference: 'ECH-2026-041',
        section: 'ANALYSES',
        isRead: false,
        dateCreation: now.subtract(const Duration(minutes: 5)),
      ),
      NotificationLabo(
        id: 'notif-labo-2',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Karim B. (chef dégustateur) demande en urgence l'analyse de l'échantillon ECH-2026-039 (Chetoui, Béja). Une décision d'achat en dépend.",
        echantillonId: 'ech-039',
        echantillonReference: 'ECH-2026-039',
        section: 'ANALYSES',
        isRead: false,
        dateCreation: now.subtract(const Duration(hours: 2)),
      ),
      NotificationLabo(
        id: 'notif-labo-3',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Nayrouz F. (dégustateur) a signalé l'échantillon ECH-2026-037 (Zalmati, Monastir) comme prioritaire. L'évaluation organoleptique est déjà soumise et en attente du rapport chimique.",
        echantillonId: 'ech-037',
        echantillonReference: 'ECH-2026-037',
        section: 'ANALYSES',
        isRead: false,
        dateCreation: now.subtract(const Duration(hours: 4, minutes: 30)),
      ),
      // ── Hier ───────────────────────────────────────────────────────────────
      NotificationLabo(
        id: 'notif-labo-4',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Yosra S. (chef dégustateur) a demandé en urgence l'analyse de l'échantillon ECH-2026-035 (Arbequina, Nabeul, 95 L). Le fournisseur attend une réponse dans 48h.",
        echantillonId: 'ech-035',
        echantillonReference: 'ECH-2026-035',
        section: 'ANALYSES',
        isRead: true,
        dateCreation: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      NotificationLabo(
        id: 'notif-labo-5',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Ahmed D. (dégustateur) a marqué ECH-2026-033 (Oueslati, Kairouan, 60 L) comme urgent. Les résultats de dégustation sont excellents — confirmation chimique attendue.",
        echantillonId: 'ech-033',
        echantillonReference: 'ECH-2026-033',
        section: 'ANALYSES',
        isRead: true,
        dateCreation: now.subtract(const Duration(days: 1, hours: 5)),
      ),
      // ── Plus tôt ───────────────────────────────────────────────────────────
      NotificationLabo(
        id: 'notif-labo-6',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Rania H. (chef dégustateur) demande la priorisation de l'analyse chimique pour ECH-2026-029 (Chemlali, Sfax Sud, 140 L). Potentiel Extra Vierge selon l'évaluation panel.",
        echantillonId: 'ech-029',
        echantillonReference: 'ECH-2026-029',
        section: 'ANALYSES',
        isRead: true,
        dateCreation: now.subtract(const Duration(days: 2, hours: 3)),
      ),
      NotificationLabo(
        id: 'notif-labo-7',
        type: 'ANALYSE_URGENTE',
        titre: 'Analyse urgente requise',
        message:
            "Sami K. (dégustateur) a signalé ECH-2026-025 (Chetoui, Bizerte) comme prioritaire suite à une évaluation organoleptique exceptionnelle. Panel unanime — analyse chimique requise d'urgence.",
        echantillonId: 'ech-025',
        echantillonReference: 'ECH-2026-025',
        section: 'ANALYSES',
        isRead: true,
        dateCreation: now.subtract(const Duration(days: 3, hours: 2)),
      ),
    ];
  }
}
