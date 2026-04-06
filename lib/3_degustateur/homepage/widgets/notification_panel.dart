// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/widgets/notification_panel.dart
// PURPOSE : the bottom sheet panel showing the list of notifications
// receives : notifications list FROM the page
// does NOT modify the list — read only display
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/notification_item.dart';

const Color _green    = Color(0xFF38835A);
const Color _cream    = Color(0xFFF9F6EF);
const Color _darkText = Color(0xFF1A2E1F);

// Function — called from homepage like :
// showNotificationPanel(context, notifications: _notifications)
void showNotificationPanel(
  BuildContext context, {
  required List<NotificationItem> notifications,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand:          false,
        initialChildSize: 0.5,
        maxChildSize:    0.85,
        minChildSize:    0.3,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [

                // ── HEADER ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notifications',
                        style: GoogleFonts.domine(
                          fontSize:   20,
                          fontWeight: FontWeight.w700,
                          color:      _darkText,
                        ),
                      ),
                      IconButton(
                        icon:      const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),

                // ── LIST ──
                Expanded(
                  child: notifications.isEmpty
                      ? _buildEmptyNotifications()
                      : ListView.builder(
                          controller: scrollController,
                          itemCount:  notifications.length,
                          itemBuilder: (context, index) =>
                              _buildNotificationCard(notifications[index]),
                        ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ── One notification card ──
Widget _buildNotificationCard(NotificationItem notif) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        _cream,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _green, width: 4),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: _green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.message,
                  style: const TextStyle(
                    fontSize:   14,
                    fontWeight: FontWeight.w600,
                    color:      _darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notif.time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Empty state when no notifications ──
Widget _buildEmptyNotifications() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.notifications_off_outlined, size: 50, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          'Aucune notification',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        ),
      ],
    ),
  );
}
