import '../../../core/api_client.dart';
import '../models/notification_ceo.dart';

class NotificationCeoService {
  Future<List<NotificationCeo>> fetchNotifications() async {
    final items = await apiClient.getList('/api/notifications/');
    return items
        .map((e) => NotificationCeo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    await apiClient.patch('/api/notifications/$id/', {'is_read': true});
  }

  Future<void> markAllAsRead() async {
    await apiClient.post('/api/notifications/read-all/', {});
  }

  Future<int> fetchUnreadCount() async {
    final data = await apiClient.get('/api/notifications/unread-count/');
    return data['count'] as int;
  }
}
