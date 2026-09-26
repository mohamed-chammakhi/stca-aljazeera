// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/echantillons/widgets/collecteur_section.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import '../../utilisateurs/models/echantillon_ceo_view.dart';
import '../../widgets/sample_card_echantillon.dart';
import '../../widgets/base_sample_card.dart';
import '../models/collecteur_group.dart';

String _initials(String name) {
  final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

// ─────────────────────────────────────────────────────────────────────────────
// COLLECTEUR SECTION
// ─────────────────────────────────────────────────────────────────────────────
class CollecteurSection extends StatelessWidget {
  final CollecteurGroup group;
  final bool isExpanded;
  final Set<String> expandedSamples;
  final VoidCallback onToggleCollecteur;
  final void Function(String id) onToggleSample;

  const CollecteurSection({
    required this.group,
    required this.isExpanded,
    required this.expandedSamples,
    required this.onToggleCollecteur,
    required this.onToggleSample,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kGreen.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: onToggleCollecteur,
            behavior: HitTestBehavior.opaque,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(14),
                bottom: isExpanded ? Radius.zero : const Radius.circular(14),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      group.isInterne
                          ? Colors.purple.shade50.withValues(alpha: 0.5)
                          : kGreen.withValues(alpha: 0.05),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 58,
                      color: group.isInterne ? Colors.purple.shade300 : kGreen,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: group.isInterne
                            ? Colors.purple.shade50
                            : kGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: group.isInterne
                            ? Icon(
                                Icons.business_outlined,
                                size: 16,
                                color: Colors.purple.shade400,
                              )
                            : Text(
                                _initials(group.displayName),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kGreen,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: kDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),

          // Expandable sample list
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(color: Colors.grey.shade100, height: 1),
                ...group.echantillons.asMap().entries.map(
                  (entry) => SampleRow(
                    echantillon: entry.value,
                    isExpanded: expandedSamples.contains(entry.value.id),
                    isOdd: entry.key.isOdd,
                    isLast: entry.key == group.echantillons.length - 1,
                    onToggle: () => onToggleSample(entry.value.id),
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}
