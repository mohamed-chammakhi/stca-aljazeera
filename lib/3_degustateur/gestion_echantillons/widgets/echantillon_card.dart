// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/echantillon_card.dart
// PURPOSE : CEO-style card — flat tinted header (no gradient/colored shadow),
//           expandable detail panel, modifier/supprimer actions
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/echantillon_gestion.dart';

const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _cream = Color(0xFFF9F6EF);
const Color _olive = Color(0xFF6B8143);

// ── Status palette (matching CEO) ─────────────────────────────────────────────
Color _statusColor(String s) {
  switch (s) {
    case 'En cours':
      return const Color(0xFFD07B2F); // orange
    case 'Soumis':
      return const Color(0xFF38835A); // green
    default:
      return const Color(0xFF3A6EA5); // blue  (En attente)
  }
}

Color _statusTint(String s) {
  switch (s) {
    case 'En cours':
      return const Color(0xFFFAF0E6);
    case 'Soumis':
      return const Color(0xFFEAF4EE);
    default:
      return const Color(0xFFEAF0F8);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class EchantillonCard extends StatefulWidget {
  final EchantillonGestion echantillon;
  final VoidCallback onModifier;
  final VoidCallback onSupprimer;

  const EchantillonCard({
    super.key,
    required this.echantillon,
    required this.onModifier,
    required this.onSupprimer,
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
    final tint = _statusTint(e.statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          // ── Tinted header (always visible) ───────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: tint,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: ref + id
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.ref.isNotEmpty ? e.ref : '—',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          e.id,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: quantity pill + status badge + arrow
                  if (e.quantite.isNotEmpty) ...[
                    _QuantityPill(quantite: e.quantite),
                    const SizedBox(width: 8),
                  ],
                  _StatusBadge(statut: e.statut, color: accent),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail panel ──────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DetailPanel(
              e: e,
              accentColor: accent,
              onModifier: widget.onModifier,
              onSupprimer: widget.onSupprimer,
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
// STATUS BADGE — pill shaped
// ─────────────────────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String statut;
  final Color color;
  const _StatusBadge({required this.statut, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      statut,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    ),
  );
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
        fontSize: 11,
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
  final EchantillonGestion e;
  final Color accentColor;
  final VoidCallback onModifier;
  final VoidCallback onSupprimer;

  const _DetailPanel({
    required this.e,
    required this.accentColor,
    required this.onModifier,
    required this.onSupprimer,
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
            color: _cream,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Wrap(
            spacing: 50,
            runSpacing: 10,
            children: [
              _DetailItem('N° échantillon', e.id),
              _DetailItem('Réf. bouteille', e.ref.isNotEmpty ? e.ref : '—'),
              _DetailItem('Fournisseur', e.codeFournisseur),
              _DetailItem('Variété', e.variete),
              _DetailItem(
                'Gouvernorat',
                '${e.gouvernorat}${e.delegation != null ? " — ${e.delegation}" : ""}',
              ),
              _DetailItem('Quantité', '${e.quantite} T'),
              _DetailItem('Date arrivée', e.dateArrivee),
              if (e.collecteur != null && e.collecteur!.isNotEmpty)
                _DetailItem('Collecteur', e.collecteur!),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Action buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Row(
            children: [
              _ActionButton(
                label: 'Modifier',
                icon: Icons.edit_outlined,
                color: _olive,
                onTap: onModifier,
              ),
              const SizedBox(width: 10),
              _ActionButton(
                label: 'Supprimer',
                icon: Icons.delete_outline,
                color: Colors.red.shade400,
                onTap: onSupprimer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTON — pill style
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ITEM — label (grey small) above value (dark bold)
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
          color: _dark,
        ),
      ),
    ],
  );
}
