// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/widgets/notification_bell.dart
// PURPOSE : the bell icon with the red badge counter
// receives : count and onTap FROM the page
// does NOT manage notifications itself — purely display
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class NotificationBell extends StatelessWidget {
  final int          count;   // number shown on the badge
  final VoidCallback onTap;   // called when user taps the bell

  const NotificationBell({
    super.key,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon:      const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: onTap,
        ),
        // Red badge — only visible if count > 0
        if (count > 0)
          Positioned(
            right: 8,
            top:   8,
            child: Container(
              width:  20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
