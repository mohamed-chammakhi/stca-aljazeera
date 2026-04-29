import 'package:flutter/material.dart';

import '../../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../models/dashboard_chef_degustateur.dart';
import 'home_shared.dart';
import '../../widgets/chef_colors.dart';

class UrgentesSection extends StatelessWidget {
  final List<EvaluationUrgenteChef> urgentes;
  final List<EvaluationUrgenteCeoChef> urgentesCeo;
  final Set<String> ignoredUrgentes;
  final Set<String> ignoredUrgentesCeo;
  final void Function(String id) onIgnoreUrgente;
  final void Function(String id) onIgnoreUrgenteCeo;

  const UrgentesSection({
    super.key,
    required this.urgentes,
    required this.urgentesCeo,
    required this.ignoredUrgentes,
    required this.ignoredUrgentesCeo,
    required this.onIgnoreUrgente,
    required this.onIgnoreUrgenteCeo,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCeo = urgentesCeo
        .where((e) => !ignoredUrgentesCeo.contains(e.id))
        .toList();
    final visible1j = urgentes
        .where((e) => !ignoredUrgentes.contains(e.id) && e.joursEnAttente == 1)
        .toList();
    final visible2j = urgentes
        .where((e) => !ignoredUrgentes.contains(e.id) && e.joursEnAttente >= 2)
        .toList();
    final total = visibleCeo.length + visible1j.length + visible2j.length;

    if (total == 0) return const SizedBox.shrink();

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: chefWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: chefRed.withValues(alpha: 0.15)),
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
                    color: chefRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: chefRed.withValues(alpha: 0.3),
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
                      color: chefRed,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: chefRed,
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
                  if (visibleCeo.isNotEmpty) ...[
                    subsectionHeader(
                      'Demandes urgentes — Direction',
                      chefPurple,
                      visibleCeo.length,
                    ),
                    ...visibleCeo.map(
                      (u) => _urgenteCeoRow(context, u),
                    ),
                  ],
                  if (visible1j.isNotEmpty) ...[
                    if (visibleCeo.isNotEmpty) subsectionDivider(),
                    subsectionHeader(
                      'En attente depuis 1 jour',
                      chefAmber,
                      visible1j.length,
                    ),
                    ...visible1j.map((u) => _urgenteRow(context, u)),
                  ],
                  if (visible2j.isNotEmpty) ...[
                    if (visibleCeo.isNotEmpty || visible1j.isNotEmpty)
                      subsectionDivider(),
                    subsectionHeader(
                      'Critique — 2j et plus',
                      chefRed,
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

  Widget _urgenteCeoRow(BuildContext context, EvaluationUrgenteCeoChef u) =>
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EvaluationEchantillonsPage()),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
          color: chefPurple.withValues(alpha: 0.025),
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
                        color: chefDark,
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
              IgnoreButton(onConfirm: () => onIgnoreUrgenteCeo(u.id)),
            ],
          ),
        ),
      );

  Widget _urgenteRow(BuildContext context, EvaluationUrgenteChef u) {
    final isCritique = u.joursEnAttente >= 2;
    final color = isCritique ? chefRed : chefAmber;
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
                      color: chefDark,
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
            IgnoreButton(onConfirm: () => onIgnoreUrgente(u.id)),
          ],
        ),
      ),
    );
  }
}

// ── Ignore button — uses Overlay so the popup floats above the row ────────────
class IgnoreButton extends StatefulWidget {
  final VoidCallback onConfirm;
  const IgnoreButton({super.key, required this.onConfirm});

  @override
  State<IgnoreButton> createState() => _IgnoreButtonState();
}

class _IgnoreButtonState extends State<IgnoreButton> {
  OverlayEntry? _entry;

  void _showPopup() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;

    const popupWidth = 200.0;
    double left = position.dx - popupWidth + box.size.width;
    if (left < 8) left = 8;
    if (left + popupWidth > screenWidth - 8) {
      left = screenWidth - popupWidth - 8;
    }

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _dismiss,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            top: position.dy - 80,
            left: left,
            width: popupWidth,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ignorer cet échantillon ?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2E1F),
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
                            onTap: _dismiss,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F8F8),
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: const Color(0xFFE8E8E8),
                                ),
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
                              _dismiss();
                              widget.onConfirm();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: chefRed,
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
              ),
            ),
          ),
        ],
      ),
    );

    overlay.insert(_entry!);
  }

  void _dismiss() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _dismiss();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPopup,
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
}
