import 'package:flutter/material.dart';
import 'package:project3/core/analyses/widgets/tableau_rapport_labo.dart';
import 'package:project3/core/utils/date_utils.dart';

import '../../utilisateurs/models/echantillon_ceo_view.dart';

const Color _teal = Color(0xFF00796B);

class LaboFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBg;
  final Color activeFg;
  final VoidCallback onTap;

  const LaboFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.activeBg,
    required this.activeFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const inactiveBg = Color(0xFFF0F0F0);
    const inactiveFg = Color(0xFF9E9E9E);
    final bg = isActive ? activeBg : inactiveBg;
    final fg = isActive ? activeFg : inactiveFg;
    final borderColor = isActive
        ? activeFg.withValues(alpha: activeFg == Colors.white ? 0.0 : 0.3)
        : const Color(0xFFE0E0E0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class RapportSection extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final bool hasAnalyse;
  final bool isExpanded;
  final VoidCallback onToggle;

  const RapportSection({
    super.key,
    required this.echantillon,
    required this.hasAnalyse,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  Icons.biotech_outlined,
                  size: 13,
                  color: hasAnalyse ? _teal : Colors.grey.shade300,
                ),
                const SizedBox(width: 6),
                Text(
                  'Rapport laboratoire',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasAnalyse ? _teal : Colors.grey.shade300,
                  ),
                ),
                const Spacer(),
                if (hasAnalyse && e.analyse!.dateAnalyse != null)
                  Text(
                    'Soumis le ${DegDateUtils.formaterDateHeureOuTiret(e.analyse!.dateAnalyse)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: hasAnalyse ? _teal : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: hasAnalyse
              ? _RapportDirecteur(analyse: e.analyse!)
              : EnAttenteHint(),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _RapportDirecteur extends StatelessWidget {
  final RapportLabo analyse;

  const _RapportDirecteur({required this.analyse});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableauRapportLabo(rapport: analyse),
        if (analyse.notes != null && analyse.notes!.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes_outlined,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    analyse.notes!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class EnAttenteHint extends StatelessWidget {
  const EnAttenteHint({super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange.shade100),
    ),
    child: Row(
      children: [
        Text(
          'Analyse non encore soumise',
          style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
        ),
      ],
    ),
  );
}
