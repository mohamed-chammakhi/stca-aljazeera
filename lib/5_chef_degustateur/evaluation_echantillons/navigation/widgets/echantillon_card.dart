// ─────────────────────────────────────────────────────────────────────────────
// FILE : evaluation_echantillons/widgets/echantillon_card.dart
// PURPOSE : CEO-style card — flat tinted header (no gradient/colored shadow),
//           expandable detail panel, pill action buttons
//           — soumis: shows classification badge + "Voir" button (read-only)
//           — en cours/en attente: shows "Commencer/Continuer" + "Voir" pills
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/echantillon.dart';
import '../../../widgets/chef_colors.dart';

const Color _olive = Color(0xFF6B8143);

// ── Status palette (matching CEO) ─────────────────────────────────────────────
Color _statusColor(StatutEchantillon s) {
  switch (s) {
    case StatutEchantillon.enCours:
      return const Color(0xFFD07B2F);
    case StatutEchantillon.soumis:
      return chefGreen;
    default:
      return const Color(0xFF3A6EA5);
  }
}

Color _classifColor(String? c) {
  if (c == 'Extra Vierge') return chefGreen;
  if (c == 'Vierge') return const Color(0xFFD07B2F);
  if (c == 'Vierge Ordinaire') return const Color(0xFFE64A19);
  if (c == 'Lampante') return const Color(0xFFD32F2F);
  return Colors.grey.shade500;
}

// ─────────────────────────────────────────────────────────────────────────────
class EchantillonCard extends StatefulWidget {
  final Echantillon echantillon;
  final VoidCallback onAction; // Commencer / Continuer
  final VoidCallback? onVoir; // Voir l'évaluation soumise (read-only)

  const EchantillonCard({
    super.key,
    required this.echantillon,
    required this.onAction,
    this.onVoir,
  });

  @override
  State<EchantillonCard> createState() => _EchantillonCardState();
}

class _EchantillonCardState extends State<EchantillonCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.echantillon;
    final accent = _statusColor(e.statut);
    final isSoumis = e.statut == StatutEchantillon.soumis;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header with left accent bar (always visible) ────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Thick left accent bar (status indicator)
                  Container(width: 4, color: accent),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: ref stacked above id
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.ref.isNotEmpty ? e.ref : '—',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: chefDark,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  e.id,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Right: classification badge above quantity pill (soumis)
                          //        OR just quantity pill (non-soumis)
                          if (isSoumis && e.classification != null) ...[
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _ClassificationBadge(e.classification!),
                                if (e.quantite != null &&
                                    e.quantite!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _QuantityPill(quantite: e.quantite!),
                                ],
                              ],
                            ),
                            const SizedBox(width: 6),
                          ] else if (e.quantite != null &&
                              e.quantite!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _QuantityPill(quantite: e.quantite!),
                            const SizedBox(width: 6),
                          ] else
                            const SizedBox(width: 6),
                          // Chevron
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail + action panel ─────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DetailPanel(
              e: e,
              accent: accent,
              isSoumis: isSoumis,
              onAction: widget.onAction,
              onVoir: widget.onVoir,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLASSIFICATION BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _ClassificationBadge extends StatelessWidget {
  final String classification;
  const _ClassificationBadge(this.classification);

  @override
  Widget build(BuildContext context) {
    final color = _classifColor(classification);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        classification,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUANTITY PILL
// ─────────────────────────────────────────────────────────────────────────────
class _QuantityPill extends StatelessWidget {
  final String quantite;
  const _QuantityPill({required this.quantite});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: _olive.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _olive.withValues(alpha: 0.25)),
    ),
    child: Text(
      'Qté : $quantite T',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _olive,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final Echantillon e;
  final Color accent;
  final bool isSoumis;
  final VoidCallback onAction;
  final VoidCallback? onVoir;

  const _DetailPanel({
    required this.e,
    required this.accent,
    required this.isSoumis,
    required this.onAction,
    this.onVoir,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey.shade100, height: 1),

        // Info grid
        Container(
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: chefBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 10,
            children: [
              _DetailItem('N° échantillon', e.id),
              _DetailItem('Réf. bouteille', e.ref.isNotEmpty ? e.ref : '—'),
              _DetailItem('Fournisseur', e.fournisseur),
              _DetailItem('Variété', e.variete),
              if (e.gouvernorat != null)
                _DetailItem(
                  'Gouvernorat',
                  '${e.gouvernorat}${e.delegation != null ? " — ${e.delegation}" : ""}',
                ),
              if (e.quantite != null && e.quantite!.isNotEmpty)
                _DetailItem('Quantité', '${e.quantite} T'),
              _DetailItem('Date arrivée', e.date),
              if (e.collecteur != null && e.collecteur!.isNotEmpty)
                _DetailItem('Collecteur', e.collecteur!),
              if (isSoumis && e.classification != null)
                _DetailItem('Classification', e.classification!),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Action row — pill-style buttons ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            children: [
              if (!isSoumis) ...[
                // Commencer / Continuer
                _PillButton(
                  label: e.statut == StatutEchantillon.enAttente
                      ? 'Commencer'
                      : 'Continuer',
                  icon: e.statut == StatutEchantillon.enAttente
                      ? Icons.play_arrow_rounded
                      : Icons.edit_outlined,
                  color: accent,
                  filled: true,
                  onTap: onAction,
                ),
                if (onVoir != null) ...[
                  const SizedBox(width: 8),
                  _PillButton(
                    label: 'Voir',
                    icon: Icons.visibility_outlined,
                    color: Colors.grey.shade600,
                    filled: false,
                    onTap: onVoir!,
                  ),
                ],
              ] else ...[
                // Soumis — only "Voir" (read-only)
                _PillButton(
                  label: 'Voir l\'évaluation',
                  icon: Icons.visibility_outlined,
                  color: chefGreen,
                  filled: false,
                  onTap: onVoir ?? () {},
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PILL BUTTON — compact, inline action
// ─────────────────────────────────────────────────────────────────────────────
class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: filled ? color : color.withValues(alpha: 0.3),
          width: filled ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: filled ? Colors.white : color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ITEM — label (grey) above value (dark bold)
// ─────────────────────────────────────────────────────────────────────────────
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9C9B9B),
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: chefDark,
        ),
      ),
    ],
  );
}
