import 'package:flutter/material.dart';

const Color _dark = Color(0xFF1A2E1F);

class KpiGridCard extends StatelessWidget {
  final double totalInvestment;
  final int confirmedPurchases;
  final int submittedAnalyses;

  const KpiGridCard({
    super.key,
    required this.totalInvestment,
    required this.confirmedPurchases,
    required this.submittedAnalyses,
  });

  String _money(double value) {
    final rounded = value.round().toString();
    return rounded.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
  }

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
          Expanded(
            child: _kpiCell(
              'INVESTISSEMENTS SAISON',
              _money(totalInvestment),
              'TND',
              '$confirmedPurchases achats confirmes',
            ),
          ),
          Container(
            width: 1,
            height: 52,
            color: Colors.white.withValues(alpha: 0.12),
            margin: const EdgeInsets.symmetric(horizontal: 18),
          ),
          Expanded(
            child: _kpiCell(
              'ANALYSES SOUMISES',
              '$submittedAnalyses',
              'rapports',
              'Resultats laboratoire disponibles',
            ),
          ),
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
                  letterSpacing: 0,
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
