// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/analyse_organoleptique/widgets/panel_section.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/theme/app_colors.dart';
import '../../utilisateurs/models/echantillon_ceo_view.dart';
import '../../widgets/shared_evaluation_form_sheet.dart';
import '../models/sample_status.dart';
import 'panel_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANEL SECTION  — bottom slot for organoleptique cards
// ─────────────────────────────────────────────────────────────────────────────
class PanelSection extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(EvaluationOrganoleptique) onViewForm;
  final VoidCallback onApprouver;
  final VoidCallback onRefuser;
  final bool isUrgent;
  final VoidCallback onUrgent;

  const PanelSection({
    super.key,
    required this.echantillon,
    required this.isExpanded,
    required this.onToggle,
    required this.onViewForm,
    required this.onApprouver,
    required this.onRefuser,
    required this.isUrgent,
    required this.onUrgent,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;

    final approved =
        e.statut == StatutCeo.enNegociation ||
        e.statut == StatutCeo.achatConfirme;
    final refused = e.statut == StatutCeo.refuse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
            child: Row(
              children: [
                DecisionButton(
                  label: 'Approuver',
                  active: approved,
                  dimmed: refused,
                  activeColor: kGreen,
                  onTap: onApprouver,
                ),
                const SizedBox(width: 6),
                DecisionButton(
                  label: 'Refuser',
                  active: refused,
                  dimmed: approved,
                  activeColor: Colors.red.shade500,
                  onTap: onRefuser,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onUrgent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? const Color(0xFFD07B2F).withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isUrgent
                            ? const Color(0xFFD07B2F).withValues(alpha: 0.40)
                            : Colors.grey.shade300,
                        width: isUrgent ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUrgent
                              ? Icons.notification_important
                              : Icons.notification_important_outlined,
                          size: 12,
                          color: isUrgent
                              ? const Color(0xFFD07B2F)
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Urgent',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isUrgent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isUrgent
                                ? const Color(0xFFD07B2F)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: kOlive,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: PanelList(echantillon: e, onViewForm: onViewForm),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
