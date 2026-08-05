import 'package:flutter/material.dart';

import '../models/dashboard_degustateur.dart';
import '../../evaluation_echantillons/evaluation_echantillons_page.dart';
import 'home_shared.dart';

class HomeUrgentesSection extends StatelessWidget {
  const HomeUrgentesSection({
    super.key,
    required this.urgentes,
    required this.ignoredUrgentes,
    required this.onIgnore,
  });
  final List<EvaluationUrgente> urgentes;
  final Set<String> ignoredUrgentes;
  final void Function(String id) onIgnore;

  @override
  Widget build(BuildContext context) {
    final visible1j = urgentes
        .where((e) => !ignoredUrgentes.contains(e.id) && e.joursEnAttente == 1)
        .toList();
    final visible2j = urgentes
        .where((e) => !ignoredUrgentes.contains(e.id) && e.joursEnAttente >= 2)
        .toList();
    final total = visible1j.length + visible2j.length;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: homeWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: homeRed.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // header
          Container(
            color: const Color(0xFFFDF4F3),
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: homeRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: homeRed.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Évaluations urgentes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: homeRed,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: homeRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$total',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // scrollable body
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1-day ──
                  if (visible1j.isNotEmpty) ...[
                    _subsectionHeader(
                      'En attente depuis 1 jour',
                      homeAmber,
                      visible1j.length,
                    ),
                    ...visible1j.map((u) => _urgenteRow(context, u)),
                  ],
                  // ── 2+ days ──
                  if (visible2j.isNotEmpty) ...[
                    if (visible1j.isNotEmpty) _subsectionDivider(),
                    _subsectionHeader(
                      'Critique — 2j et plus',
                      homeRed,
                      visible2j.length,
                    ),
                    ...visible2j.map((u) => _urgenteRow(context, u)),
                  ],
                ],
              ),
            ),
          ),
          // footer
          Container(
            color: const Color(0xFFF8F8F8),
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
            child: const SizedBox(
              width: double.infinity,
              child: Text(
                "Appuyez sur la ligne pour évaluer · Icône œil pour ignorer",
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFAAAAAA),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _subsectionHeader(String label, Color color, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
    child: Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _subsectionDivider() => Container(
    height: 1,
    color: const Color(0xFFF0F0F0),
    margin: const EdgeInsets.symmetric(horizontal: 14),
  );

  Widget _urgenteRow(BuildContext context, EvaluationUrgente u) {
    final isCritique = u.joursEnAttente >= 2;
    final color = isCritique ? homeRed : homeAmber;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EvaluationEchantillonsPage()),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFFAFAFA))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    u.reference,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: homeDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${u.collecteurNom}  ·  ${u.fournisseurNom}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: color.withValues(alpha: 0.18)),
              ),
              child: Text(
                isCritique
                    ? '${u.joursEnAttente}j — critique'
                    : '${u.joursEnAttente}j en attente',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            _IgnoreButton(onConfirm: () => onIgnore(u.id)),
          ],
        ),
      ),
    );
  }
}

// ── Ignore button with self-contained popup ──────────────────────────────────
class _IgnoreButton extends StatefulWidget {
  final VoidCallback onConfirm;
  const _IgnoreButton({required this.onConfirm});

  @override
  State<_IgnoreButton> createState() => _IgnoreButtonState();
}

class _IgnoreButtonState extends State<_IgnoreButton> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    if (!_open) {
      return GestureDetector(
        onTap: () {
          setState(() => _open = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final overlay = Overlay.of(context);
              late OverlayEntry entry;
              entry = OverlayEntry(
                builder: (_) => GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (mounted) setState(() => _open = false);
                    entry.remove();
                  },
                  child: const SizedBox.expand(),
                ),
              );
              overlay.insert(entry);
            }
          });
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: const Icon(
            Icons.visibility_off_outlined,
            size: 14,
            color: Color(0xFFAAAAAA),
          ),
        ),
      );
    }

    // Popup open
    return Container(
      decoration: BoxDecoration(
        color: homeWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      padding: const EdgeInsets.all(12),
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ignorer cet échantillon ?',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: homeDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Il ne sera plus affiché dans les urgences.",
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF888888),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _open = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: const Text(
                      'Annuler',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _open = false);
                    widget.onConfirm();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: homeRed,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Text(
                      'Ignorer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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
