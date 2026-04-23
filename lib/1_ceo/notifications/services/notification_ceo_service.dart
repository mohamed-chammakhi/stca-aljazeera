import '../models/notification_ceo.dart';

class NotificationCeoService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<NotificationCeo>> fetchNotifications() async {
    // TODO: replace with: final data = await _api.get('/notifications/');
    // TODO: return (data['results'] as List).map((e) => NotificationCeo.fromJson(e)).toList();
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockNotifications(); // TODO: remove when backend is ready
  }

  Future<void> markAsRead(String id) async {
    // TODO: replace with: await _api.put('/notifications/$id/', {'is_read': true});
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> markAllAsRead() async {
    // TODO: replace with: await _api.post('/notifications/read-all/', {});
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<int> fetchUnreadCount() async {
    // TODO: replace with: final data = await _api.get('/notifications/unread-count/');
    // TODO: return data['count'] as int;
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockNotifications().where((n) => !n.isRead).length; // TODO: remove when backend is ready
  }

  // TODO: remove when backend is ready
  List<NotificationCeo> _mockNotifications() {
    final now = DateTime.now();
    return [
      // ── Aujourd'hui ───────────────────────────────────────────────────────────
      NotificationCeo(
        id: '1',
        type: 'NOUVEL_ECHANTILLON',
        titre: 'Nouvel échantillon enregistré',
        message: "Le collecteur Ahmed Dridi a ajouté l'échantillon ECH-2026-041 (Chemlali, Sfax) au système.",
        echantillonId: 'abc-1', echantillonReference: 'ECH-2026-041',
        section: 'ECHANTILLONS', isRead: false,
        dateCreation: now.subtract(const Duration(minutes: 8)),
      ),
      NotificationCeo(
        id: '2',
        type: 'ECHANTILLON_RECU',
        titre: 'Échantillon reçu physiquement',
        message: "Le dégustateur a confirmé la réception physique de l'échantillon ECH-2026-039 le ${_fmt(now.subtract(const Duration(hours: 1)))}. L'analyse laboratoire est maintenant débloquée.",
        echantillonId: 'abc-2', echantillonReference: 'ECH-2026-039',
        section: 'ECHANTILLONS', isRead: false,
        dateCreation: now.subtract(const Duration(hours: 1)),
      ),
      NotificationCeo(
        id: '3',
        type: 'ECHANTILLON_MODIFIE',
        titre: 'Échantillon modifié',
        message: "Le collecteur Fatma Bouzid a modifié les informations de l'échantillon ECH-2026-038 (quantité : 80 L → 95 L).",
        echantillonId: 'abc-3', echantillonReference: 'ECH-2026-038',
        section: 'ECHANTILLONS', isRead: false,
        dateCreation: now.subtract(const Duration(hours: 2)),
      ),
      NotificationCeo(
        id: '4',
        type: 'PREMIERE_EVALUATION',
        titre: 'Première évaluation soumise',
        message: "Karim B. a soumis la première évaluation organoleptique pour l'échantillon ECH-2026-037. 4 dégustateurs restants.",
        echantillonId: 'abc-4', echantillonReference: 'ECH-2026-037',
        section: 'EVALUATIONS', isRead: false,
        dateCreation: now.subtract(const Duration(hours: 3)),
      ),
      NotificationCeo(
        id: '5',
        type: 'ANALYSE_SOUMISE',
        titre: 'Analyse laboratoire soumise',
        message: "Le technicien a soumis l'analyse laboratoire complète de l'échantillon ECH-2026-035. Résultats disponibles pour consultation.",
        echantillonId: 'abc-5', echantillonReference: 'ECH-2026-035',
        section: 'ANALYSES', isRead: false,
        dateCreation: now.subtract(const Duration(hours: 5)),
      ),
      // ── Hier ─────────────────────────────────────────────────────────────────
      NotificationCeo(
        id: '6',
        type: 'TOUTES_EVALUATIONS',
        titre: 'Toutes les évaluations soumises',
        message: "Les 5 dégustateurs ont soumis leur évaluation pour l'échantillon ECH-2026-033. Vous pouvez maintenant prendre votre décision d'approbation.",
        echantillonId: 'abc-6', echantillonReference: 'ECH-2026-033',
        section: 'EVALUATIONS', isRead: false,
        dateCreation: now.subtract(const Duration(days: 1, hours: 1)),
      ),
      NotificationCeo(
        id: '7',
        type: 'ACHAT_CONFIRME',
        titre: 'Achat confirmé par le collecteur',
        message: "Sami Kraiem a confirmé l'achat de l'échantillon ECH-2026-031 : prix final 8.20 TND/L, camion TUN-4821, livraison prévue le 28/04/2026.",
        echantillonId: 'abc-7', echantillonReference: 'ECH-2026-031',
        section: 'ACHATS', isRead: false,
        dateCreation: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      NotificationCeo(
        id: '8',
        type: 'ECHANTILLON_SUPPRIME',
        titre: 'Échantillon supprimé',
        message: "Le dégustateur a supprimé l'échantillon ECH-2026-028 (Arbequina, Nabeul) du système. Aucune analyse ni négociation n'avait débuté.",
        echantillonId: null, echantillonReference: 'ECH-2026-028',
        section: 'ECHANTILLONS', isRead: false,
        dateCreation: now.subtract(const Duration(days: 1, hours: 7)),
      ),
    ];
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
