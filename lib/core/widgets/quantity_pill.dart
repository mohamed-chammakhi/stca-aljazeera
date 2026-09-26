import 'package:flutter/material.dart';

const Color _olive = Color(0xFF6B8143);

class QuantityPill extends StatelessWidget {
  final String quantite;

  const QuantityPill({super.key, required this.quantite});

  @override
  Widget build(BuildContext context) => Container(
    // A typed quantity can be any length: cap the pill so it never pushes the
    // card off screen (the full value is in the detail panel).
    constraints: const BoxConstraints(maxWidth: 120),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _olive.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: _olive.withValues(alpha: 0.22)),
    ),
    child: Text(
      'Qté : $quantite T',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _olive,
      ),
    ),
  );
}
