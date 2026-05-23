import '../models/notification_collecteur.dart';
import '../../../../core/api_client.dart';
import 'notification_mock_data.dart';

class NotificationCollecteurService {
  static const bool useMock = true;

  Future<List<NotificationCollecteur>> fetchNotifications() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return mockNotifications();
    }
    final items = await apiClient.getList('/api/notifications/');
    return items
        .map((e) => NotificationCollecteur.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 100));
      return;
    }
    await apiClient.patch('/api/notifications/$id/', {'is_read': true});
  }

  Future<void> markAllAsRead() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 100));
      return;
    }
    await apiClient.post('/api/notifications/read-all/', {});
  }

  Future<int> fetchUnreadCount() async {
    if (useMock) {
      await Future.delayed(const Duration(milliseconds: 100));
      return mockNotifications().where((n) => !n.isRead).length;
    }
    final data = await apiClient.get('/api/notifications/unread-count/');
    return data['count'] as int? ?? 0;
  }
}
