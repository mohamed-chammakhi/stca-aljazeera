// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/widgets/empty_state.dart
// PURPOSE : Shown when a list has no results.
//           Two cases: nothing recorded yet (brand-new system), or filters /
//           search that match nothing. Stateless, no logic — purely display.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Title and explanation when nothing has been recorded yet.
const String kTitreSystemeNeuf = 'Aucun échantillon pour le moment';
const String kTexteSystemeNeuf =
    'Le système est tout neuf : rien n\'a encore été enregistré. '
    'Les échantillons apparaîtront ici dès qu\'ils seront ajoutés.';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  /// true = the full list is empty (not just the filtered view).
  final bool systemeNeuf;

  const EmptyState({
    super.key,
    this.message = 'Aucun échantillon trouvé',
    this.icon = Icons.search_off_rounded,
    this.systemeNeuf = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              systemeNeuf ? Icons.inventory_2_outlined : icon,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 10),
            Text(
              systemeNeuf ? kTitreSystemeNeuf : message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            ),
            if (systemeNeuf) ...[
              const SizedBox(height: 6),
              Text(
                kTexteSystemeNeuf,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
