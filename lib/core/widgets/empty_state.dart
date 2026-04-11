// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/widgets/empty_state.dart
// PURPOSE : Shown when a filtered list has no results.
//           Stateless, no logic — purely display.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    this.message = 'Aucun échantillon trouvé',
    this.icon = Icons.search_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
