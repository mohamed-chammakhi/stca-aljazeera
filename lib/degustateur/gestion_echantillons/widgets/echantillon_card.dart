// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/echantillon_card.dart
// PURPOSE : displays ONE échantillon as a card
// receives : the échantillon data + two callbacks for actions
// does NOT touch _recherche, _filtreStatut, or setState directly
// setState is triggered in the PAGE via onModifier and onSupprimer callbacks
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/echantillon_gestion.dart';
import 'statut_badge.dart';
import 'info_item.dart';

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

class EchantillonCard extends StatelessWidget {
  final EchantillonGestion echantillon;
  final VoidCallback onModifier; // called when user taps "Modifier"
  final VoidCallback onSupprimer; // called when user taps "Supprimer"

  const EchantillonCard({
    super.key,
    required this.echantillon,
    required this.onModifier,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon; // shorthand for cleaner code below

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
            // ── ROW 1 : Photo + ID + Status badge ──────────────────────────
            Row(
              children: [
                // Photo thumbnail
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green.withOpacity(0.3)),
                  ),
                  child: e.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(e.photoUrl!, fit: BoxFit.cover),
                        )
                      : Icon(
                          Icons.image_outlined,
                          size: 22,
                          color: _green.withOpacity(0.5),
                        ),
                ),

                const SizedBox(width: 12),

                // ID
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

                // Status badge — imported from statut_badge.dart
                StatutBadge(statut: e.statut),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),

            // ── ROW 2 : Ref ──────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _green.withOpacity(0.2)),
                  ),
                  child: Text(
                    '# ${e.ref.isNotEmpty ? e.ref : "—"}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _green,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── ROW 2 : Fournisseur + Variété ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: InfoItem(
                    icon: Icons.store_outlined,
                    label: 'Fournisseur',
                    value: e.fournisseur,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    icon: Icons.eco_outlined,
                    label: 'Variété',
                    value: e.variete,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── ROW 3 : Fournisseur + Variété ───────────────────────────────────────
            // ── ROW 4 : Origine + Quantité ───────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: InfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Origine',
                    value: e.origine,
                  ),
                ),
                Expanded(
                  child: InfoItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Quantité',
                    value: e.quantite,
                    valueColor: _oliveGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── ROW 4 : Date ────────────────────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 5),
                Text(
                  'Arrivée le ${e.dateArrivee}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),

            // ── ROW 5 : Modifier + Supprimer buttons ────────────────────────
            Row(
              children: [
                // Modifier button
                Expanded(
                  child: GestureDetector(
                    onTap: onModifier, // triggers the callback from the page
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _oliveGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: _oliveGreen.withOpacity(0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 15,
                            color: _oliveGreen,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Modifier',
                            style: TextStyle(
                              fontSize: 13,
                              color: _oliveGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Supprimer button
                Expanded(
                  child: GestureDetector(
                    onTap: onSupprimer, // triggers the callback from the page
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 15,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Supprimer',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
