// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/models/notification_item.dart
// PURPOSE : defines what a Notification IS — data only
// ─────────────────────────────────────────────────────────────────────────────

class NotificationItem {
  final String message;
  final String time;

  NotificationItem({
    required this.message,
    required this.time,
  });

  // Used later when Spring Boot sends notifications via API
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      message: json['message'],
      time:    json['time'],
    );
  }
}
