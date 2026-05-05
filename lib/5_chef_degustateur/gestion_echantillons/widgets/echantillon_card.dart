// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/echantillon_card.dart
// PURPOSE : Card for one échantillon — accent bar for status, inline actions,
//           expandable detail panel with all attributes + delivery date.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/models/echantillon.dart';
import '../../../../core/models/enums.dart';
import '../../widgets/chef_colors.dart';

const Color _olive = Color(0xFF6B8143);
const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);

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
  bool _showRecuMsg = false;
  Timer? _msgTimer;

  @override
  void dispose() {
    _msgTimer?.cancel();
    super.dispose();
  }

  Future<void> _confirmToggleRecu() async {
    final e = widget.echantillon;
    final willBeReceived = !e.recuPhysiquement;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RecuConfirmDialog(
        referenceBouteille: e.referenceBouteille,
        isConfirming: willBeReceived,
      ),
    );
    if (confirmed != true) return;

    _msgTimer?.cancel();
    widget.onToggleRecu();
    if (willBeReceived) {
      setState(() => _showRecuMsg = true);
      _msgTimer = Timer(const Duration(seconds: 6), () {
        if (mounted) setState(() => _showRecuMsg = false);
      });
    } else {
      setState(() => _showRecuMsg = false);
    }
  }

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
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (_expanded) ...[
                                      // ── Inline confirmation message ───────
                                      Flexible(
                                        fit: FlexFit.loose,
                                        child: AnimatedSize(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          child: _showRecuMsg
                                              ? Container(
                                                  margin: const EdgeInsets.only(right: 6),
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _green,
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(Icons.check, size: 10, color: Colors.white),
                                                      const SizedBox(width: 4),
                                                      Flexible(
                                                        child: Text(
                                                          'Réception physique confirmée',
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ),
                                      // ── Physically received toggle ────────
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
                                              : const Color.fromARGB(255, 137, 136, 136),
                                          onTap: () => _confirmToggleRecu(),
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
                              ),
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
// RECEPTION CONFIRMATION DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class _RecuConfirmDialog extends StatelessWidget {
  final String referenceBouteille;
  final bool isConfirming;

  const _RecuConfirmDialog({
    required this.referenceBouteille,
    required this.isConfirming,
  });

  @override
  Widget build(BuildContext context) {
    final headerColor = isConfirming
        ? const Color(0xFFE6F4ED)
        : const Color(0xFFFEF3E8);
    final iconColor = isConfirming ? _green : const Color(0xFFD07B2F);
    final subtitleColor = isConfirming
        ? const Color(0xFF6B8E7A)
        : const Color(0xFF9E7A4B);
    final confirmColor = isConfirming ? _green : const Color(0xFFD07B2F);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isConfirming
                      ? Icons.check_circle_outline
                      : Icons.remove_circle_outline,
                  color: iconColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isConfirming
                            ? 'Confirmer la réception'
                            : 'Annuler la réception',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      Text(
                        referenceBouteille,
                        style: TextStyle(fontSize: 11, color: subtitleColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Text(
              isConfirming
                  ? 'Confirmez-vous que cet échantillon est physiquement présent dans la société ?'
                  : 'Voulez-vous annuler la réception physique de cet échantillon ?',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A4A4A),
                height: 1.5,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F6EF),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isConfirming ? 'Confirmer' : 'Annuler réception',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
