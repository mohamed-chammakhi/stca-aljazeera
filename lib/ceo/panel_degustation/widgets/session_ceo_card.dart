// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/panel_degustation/widgets/session_ceo_card.dart
// PURPOSE : Session card for the CEO — shows progress, actions, AI report link
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/session_ceo.dart';

class SessionCeoCard extends StatelessWidget {
  final SessionCeo session;
  final VoidCallback? onCloturer;
  final VoidCallback? onVoirRapport;
  final VoidCallback? onVoirEvaluations;

  const SessionCeoCard({
    super.key,
    required this.session,
    this.onCloturer,
    this.onVoirRapport,
    this.onVoirEvaluations,
  });

  static const Color _green = Color(0xFF38835A);
  static const Color _darkText = Color(0xFF1A2E1F);

  Color get _statutColor {
    switch (session.statut) {
      case StatutSessionCeo.planifiee:
        return Colors.blue.shade600;
      case StatutSessionCeo.active:
        return _green;
      case StatutSessionCeo.cloturee:
        return Colors.grey.shade500;
    }
  }

  String get _statutLabel {
    switch (session.statut) {
      case StatutSessionCeo.planifiee:
        return 'PLANIFIÉE';
      case StatutSessionCeo.active:
        return 'EN COURS';
      case StatutSessionCeo.cloturee:
        return 'CLÔTURÉE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _statutColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.wine_bar_outlined, color: _statutColor, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.titre,
                      style: GoogleFonts.domine(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    Text(
                      '${session.date} à ${session.heure} — ${session.lieu}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statutColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statutColor.withOpacity(0.3)),
                ),
                child: Text(
                  _statutLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: _statutColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 12),

          // ── Submission progress ───────────────────────────────────────────
          if (session.statut == StatutSessionCeo.active) ...[
            Row(
              children: [
                Text(
                  '${session.soumissions} / ${session.totalMembres}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _green,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'évaluations soumises',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: session.totalMembres > 0
                    ? session.soumissions / session.totalMembres
                    : 0,
                backgroundColor: Colors.grey.shade100,
                valueColor: const AlwaysStoppedAnimation<Color>(_green),
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Samples + members summary ──────────────────────────────────
          Row(
            children: [
              Icon(Icons.science_outlined, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                '${session.echantillonIds.length} échantillon(s)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(width: 14),
              Icon(Icons.group_outlined, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                '${session.totalMembres} dégustateur(s)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),

          // ── AI report available ───────────────────────────────────────────
          if (session.statut == StatutSessionCeo.cloturee &&
              session.rapportAi != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7F4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _green.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: _green, size: 14),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Rapport IA disponible',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _green,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onVoirRapport,
                    child: Text(
                      'Voir →',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 10),

          // ── Actions ───────────────────────────────────────────────────────
          Row(
            children: [
              if (session.statut == StatutSessionCeo.active)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCloturer,
                    icon: const Icon(Icons.lock_outline, size: 14),
                    label: const Text(
                      'Clôturer',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38835A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              if (session.statut == StatutSessionCeo.active)
                const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onVoirEvaluations,
                  icon: const Icon(Icons.bar_chart_outlined, size: 14),
                  label: const Text(
                    'Évaluations',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF38835A),
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
