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

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
    message: json['message'] as String,
    time: json['time'] as String,
  );

  Map<String, dynamic> toJson() => {
    'message': message,
    'time': time,
  };
}
