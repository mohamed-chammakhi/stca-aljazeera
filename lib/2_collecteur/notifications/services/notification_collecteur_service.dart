import '../models/notification_collecteur.dart';
import '../../../../core/api_client.dart';
import '../../../../core/services/resultat_service.dart';
import 'notification_mock_data.dart';

class NotificationCollecteurService {
  Future<Resultat<List<NotificationCollecteur>>> fetchNotifications() =>
      avecSecours(() async {
        final items = await apiClient.getList('/api/notifications/');
        return items
            .map(
              (e) => NotificationCollecteur.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }, mockNotifications);

  Future<void> markAsRead(String id) async {
    await apiClient.patch('/api/notifications/$id/lire/', {});
  }

  Future<void> markAllAsRead() async {
    await apiClient.post('/api/notifications/lire-tout/', {});
  }

  Future<Resultat<int>> fetchUnreadCount() => avecSecours(() async {
    final data = await apiClient.get('/api/notifications/unread-count/');
    return data['count'] as int? ?? 0;
  }, () => mockNotifications().where((n) => !n.isRead).length);
}
