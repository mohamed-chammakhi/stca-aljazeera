import 'package:flutter/material.dart';

const Color _dark = Color(0xFF1A2E1F);

/// Top KPI banner — investissements saison + prix moyen/L.
/// Data is hardcoded here until the Django API endpoint is wired.
class KpiGridCard extends StatelessWidget {
  const KpiGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5C49),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(child: _kpiCell('INVESTISSEMENTS SAISON', '284 500', 'TND', '+12% vs saison précédente')),
          Container(
            width: 1,
            height: 52,
            color: Colors.white.withValues(alpha: 0.12),
            margin: const EdgeInsets.symmetric(horizontal: 18),
          ),
          Expanded(child: _kpiCell('PRIX MOYEN PAR LITRE', '8.4', 'TND/L', 'Moyenne de la saison 2025/2026')),
        ],
      ),
    );
  }

  Widget _kpiCell(String label, String value, String unit, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.50),
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(fontSize: 11, color: Color(0xFF9DCBB3)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          sub,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.60),
          ),
        ),
      ],
    );
  }
}
