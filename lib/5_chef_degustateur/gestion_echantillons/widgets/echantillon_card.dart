// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/echantillon_card.dart
// PURPOSE : Card for one échantillon — accent bar for status, inline actions,
//           expandable detail panel with all attributes + delivery date.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../core/models/echantillon.dart';
import '../../../../core/models/enums.dart';
import '../../widgets/chef_colors.dart';

const Color _olive = Color(0xFF6B8143);

// ── Status palette ────────────────────────────────────────────────────────────
Color _statusColor(StatutDegustateur? s) {
  switch (s) {
    case StatutDegustateur.enCours:
      return const Color(0xFFD07B2F);
    case StatutDegustateur.soumis:
      return chefGreen;
    default:
      return const Color(0xFF3A6EA5);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class EchantillonCard extends StatefulWidget {
  final Echantillon echantillon;
  final VoidCallback onModifier;
  final VoidCallback onSupprimer;
  final VoidCallback onToggleRecu;

  const EchantillonCard({
    super.key,
    required this.echantillon,
    required this.onModifier,
    required this.onSupprimer,
    required this.onToggleRecu,
  });

  @override
  State<EchantillonCard> createState() => _EchantillonCardState();
}

class _EchantillonCardState extends State<EchantillonCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.echantillon;
    final accent = _statusColor(e.statutDegustateur);

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
          // ── Header (always visible) ─────────────────────────────────────
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Row 1: ref + qty pill + chevron ────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  e.referenceBouteille.isNotEmpty
                                      ? e.referenceBouteille
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: chefDark,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (e.quantiteEstimee != null &&
                                  e.quantiteEstimee!.isNotEmpty) ...[
                                _QuantityPill(quantite: e.quantiteEstimee!),
                                const SizedBox(width: 8),
                              ],
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

                          const SizedBox(height: 2),

                          // ── Row 2: id + action icons (only when expanded) ───
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                e.ref,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const Spacer(),
                              if (_expanded) ...[
                                // Physically received toggle
                                Tooltip(
                                  message: e.recuPhysiquement
                                      ? 'Annuler la réception'
                                      : 'Confirmer la réception physique',
                                  child: _SmallIconBtn(
                                    icon: e.recuPhysiquement
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    color: e.recuPhysiquement
                                        ? chefGreen
                                        : const Color.fromARGB(
                                            255,
                                            137,
                                            136,
                                            136,
                                          ),
                                    onTap: widget.onToggleRecu,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Tooltip(
                                  message: 'Modifier',
                                  child: _SmallIconBtn(
                                    icon: Icons.edit_outlined,
                                    color: _olive,
                                    onTap: widget.onModifier,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Tooltip(
                                  message: 'Supprimer',
                                  child: _SmallIconBtn(
                                    icon: Icons.delete_outline,
                                    color: Colors.red.shade300,
                                    onTap: widget.onSupprimer,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail panel ────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DetailPanel(e: e, accentColor: accent),
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
// SMALL ICON BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Icon(icon, size: 18, color: color),
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
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _olive.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: _olive.withValues(alpha: 0.22)),
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
// DETAIL PANEL — expandable with all attributes + delivery date
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final Echantillon e;
  final Color accentColor;

  const _DetailPanel({required this.e, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey.shade100, height: 1),
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: chefBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Attribute grid ─────────────────────────────────────────
              Wrap(
                spacing: 90,
                runSpacing: 10,
                children: [
                  _DetailItem('N° échantillon', e.ref),
                  _DetailItem('Réf. bouteille', e.referenceBouteille),
                  if (e.codeFournisseur != null)
                    _DetailItem('Fournisseur', e.codeFournisseur!),
                  if (e.variete != null && e.variete!.isNotEmpty)
                    _DetailItem('Variété', e.variete!),
                  _DetailItem(
                    'Gouvernorat',
                    e.delegation != null
                        ? '${e.gouvernorat} — ${e.delegation}'
                        : e.gouvernorat,
                  ),
                  if (e.collecteurNom != null && e.collecteurNom!.isNotEmpty)
                    _DetailItem('Collecteur', e.collecteurNom!),
                  if (e.scellage != null && e.scellage!.isNotEmpty)
                    _DetailItem('Scellage', e.scellage!),
                  _DetailItem(
                    'Reçu physiquement',
                    e.recuPhysiquement ? 'Oui' : 'Non',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ITEM
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
          color: Color(0xFFAAAAAA),
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
