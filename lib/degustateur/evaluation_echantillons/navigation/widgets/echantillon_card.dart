// ─────────────────────────────────────────────────────────────────────────────
// FILE : evaluation_echantillons/widgets/echantillon_card.dart
// PURPOSE : displays ONE échantillon card in the evaluation list
// receives : echantillon data + onAction callback FROM the page
// does NOT touch state or navigation — page handles both via callback
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/echantillon.dart';
import 'statut_badge.dart';

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

class EchantillonCard extends StatelessWidget {
  final Echantillon echantillon;
  final VoidCallback onAction;

  const EchantillonCard({
    super.key,
    required this.echantillon,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ROW 1 : ID + Status badge ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Text(
                    e.id,
                    style: GoogleFonts.domine(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _darkText,
                    ),
                  ),
                ),
                StatutBadge(statut: e.statut),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),

            // ── ROW 2 : Référence tag ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _green.withOpacity(0.2)),
              ),
              child: Text(
                '# ${e.ref.isNotEmpty ? e.ref : "—"}',
                style: const TextStyle(
                  fontSize: 12,
                  color: _green,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── ROW 3 : Fournisseur + Variété ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.store_outlined,
                    label: 'Fournisseur',
                    value: e.fournisseur,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.eco_outlined,
                    label: 'Variété',
                    value: e.variete,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── ROW 4 : Origine + Date ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Origine',
                    value: e.origine ?? '—',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: "Date d'arrivée",
                    value: e.date,
                  ),
                ),
              ],
            ),

            // ── ACTION BUTTON — only shown if not submitted ────────────────
            if (e.statut != StatutEchantillon.soumis) ...[
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade100),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(
                    e.statut == StatutEchantillon.enAttente
                        ? Icons.play_arrow_rounded
                        : Icons.edit_outlined,
                    size: 18,
                  ),
                  label: Text(
                    e.statut == StatutEchantillon.enAttente
                        ? "Commencer l'évaluation"
                        : "Continuer l'évaluation",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: e.statut == StatutEchantillon.enAttente
                        ? _green
                        : _oliveGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],

            // ── SUBMITTED BADGE — only shown if submitted ──────────────────
            if (e.statut == StatutEchantillon.soumis) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Évaluation soumise et verrouillée',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER — label + icon above, bold value below
// private to this file — underscore prefix prevents conflicts with
// the InfoItem widget in gestion_echantillons
// ─────────────────────────────────────────────────────────────────────────────
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

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
        // label + icon on same line
        Row(
          children: [
            Icon(icon, size: 12, color: _oliveGreen),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 2),
        // bold value below
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _darkText,
          ),
        ),
      ],
    );
  }
}
