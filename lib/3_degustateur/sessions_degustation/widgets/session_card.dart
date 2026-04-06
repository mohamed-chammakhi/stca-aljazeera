// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/widgets/session_card.dart
// PURPOSE : displays ONE session card in the list with left accent bar,
//           gradient header, and elegant info layout
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/session_degustation.dart';
import 'statut_session_badge.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);
const Color _cream      = Color(0xFFF9F6EF);

class SessionCard extends StatelessWidget {
  final SessionDegustation session;
  final VoidCallback       onModifier;
  final VoidCallback       onSupprimer;

  const SessionCard({
    super.key,
    required this.session,
    required this.onModifier,
    required this.onSupprimer,
  });

  Color _statusColor(StatutSession s) {
    switch (s) {
      case StatutSession.planifiee: return Colors.amber.shade600;
      case StatutSession.enCours:   return Colors.blue.shade500;
      case StatutSession.terminee:  return _green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s           = session;
    final statusColor = _statusColor(s.statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:      statusColor.withValues(alpha: 0.14),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── HEADER: left bar + gradient + titre + badge ──────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Left accent bar
                Container(width: 4, color: statusColor),

                // Header content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.07),
                          Colors.white,
                        ],
                        begin: Alignment.centerLeft,
                        end:   Alignment.centerRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.titre,
                            style: GoogleFonts.domine(
                              fontSize:   15,
                              fontWeight: FontWeight.w700,
                              color:      _darkText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatutSessionBadge(statut: s.statut),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── BODY: info rows + notes + actions ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 10),

                // ROW: date + heure
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon:  Icons.calendar_today_outlined,
                        label: 'Date',
                        value: s.date,
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon:  Icons.access_time_outlined,
                        label: 'Heure',
                        value: s.heure,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ROW: lieu + nb échantillons
                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon:  Icons.location_on_outlined,
                        label: 'Lieu',
                        value: s.lieu,
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon:  Icons.science_outlined,
                        label: 'Échantillons',
                        value: '${s.nbEchantillons}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Participants row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:        statusColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border:       Border.all(
                            color: statusColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_outlined,
                              size: 13, color: statusColor),
                          const SizedBox(width: 5),
                          Text(
                            '${s.nbParticipants} participant(s)',
                            style: TextStyle(
                              fontSize:   12,
                              color:      statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Notes (optional)
                if (s.notes != null && s.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width:   double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color:        _cream,
                      borderRadius: BorderRadius.circular(8),
                      border:       Border.all(
                          color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_outlined,
                            size: 13, color: Colors.grey.shade400),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.notes!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade100, height: 1),
                const SizedBox(height: 8),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onModifier,
                        icon:  const Icon(Icons.edit_outlined, size: 15),
                        label: const Text('Modifier',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _oliveGreen,
                          side:    BorderSide(
                              color: _oliveGreen.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape:   RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSupprimer,
                        icon:  const Icon(Icons.delete_outline, size: 15),
                        label: const Text('Supprimer',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          side:    BorderSide(color: Colors.red.shade200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape:   RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO ITEM — icon + label above bold value
// ─────────────────────────────────────────────────────────────────────────────
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: _oliveGreen),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w600,
                color:      _darkText)),
      ],
    );
  }
}
