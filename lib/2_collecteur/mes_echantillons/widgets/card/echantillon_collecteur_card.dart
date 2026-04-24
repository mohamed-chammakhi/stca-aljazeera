// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/widgets/card/echantillon_collecteur_card.dart
//
// Collecteur sample card — professional, minimal design.
//
// Layout:
//   Header (always visible, tap to expand):
//     Left  : referenceBouteille (bold) + ref code (small gray)
//     Right : qty pill + received ✓ (if applicable)
//     Far right: chevron
//   [Confirmer l'achat button — always visible when enNegociation]
//   Expanded detail panel:
//     • Attribute grid
//     • Sample delivery line (réceptionné/enNégociation only)
//     • Stock delivery line (achatConfirme only)
//     • Remarques
//     • Icons (edit / delete) — only when canModify/canDelete
//   [Détails de la négociation/commande — always visible, collapsible at card bottom]
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../models/echantillon_collecteur.dart';
import 'card_theme.dart';

// ── Status accent color (left bar only) ──────────────────────────────────────
Color _accentColor(StatutCollecteur s) {
  switch (s) {
    case StatutCollecteur.receptionne:
      return const Color(0xFF3A6EA5);
    case StatutCollecteur.enNegociation:
      return const Color(0xFFD07B2F);
    case StatutCollecteur.achatConfirme:
      return const Color(0xFF38835A);
  }
}

const Color _grayText = Color(0xFF9C9B9B);

// ─────────────────────────────────────────────────────────────────────────────
class EchantillonComCard extends StatefulWidget {
  final EchantillonCollecteur echantillon;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;
  final VoidCallback? onConfirmerAchat;
  final VoidCallback? onPlanifierLivraison;
  final VoidCallback? onScheduleArrivee;

  const EchantillonComCard({
    super.key,
    required this.echantillon,
    this.onModifier,
    this.onSupprimer,
    this.onConfirmerAchat,
    this.onPlanifierLivraison,
    this.onScheduleArrivee,
  });

  @override
  State<EchantillonComCard> createState() => _EchantillonComCardState();
}

class _EchantillonComCardState extends State<EchantillonComCard> {
  bool _expanded = false;
  bool _detailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.echantillon;
    final accent = _accentColor(e.statut);
    final bool showNegociationSection =
        e.statut == StatutCollecteur.enNegociation ||
        e.statut == StatutCollecteur.achatConfirme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header (always visible, tap anywhere to expand) ───────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar
                  Container(width: 4, color: accent),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 11, 10, 11),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left: ref bouteille + sample ID
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.referenceBouteille.isNotEmpty
                                      ? e.referenceBouteille
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: kDarkText,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  e.ref,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _grayText,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Right: qty pill + received check
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (e.quantiteEstimee != null &&
                                  e.quantiteEstimee!.isNotEmpty)
                                _QuantityPill(quantite: e.quantiteEstimee!),
                              if (e.recuPhysiquement) ...[
                                const SizedBox(width: 5),
                                Tooltip(
                                  message: e.dateReceptionEchantillon != null
                                      ? 'Reçu le ${e.dateReceptionEchantillon}'
                                      : 'Réceptionné par le labo',
                                  child: const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: kGreen,
                                  ),
                                ),
                              ],
                            ],
                          ),

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

          // ── Confirmer l'achat button (always visible when enNegociation) ──
          if (widget.onConfirmerAchat != null)
            _ConfirmerAchatRow(onConfirmerAchat: widget.onConfirmerAchat!),

          // ── Expandable detail panel ────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DetailPanel(
              e: e,
              onModifier: widget.onModifier,
              onSupprimer: widget.onSupprimer,
              onPlanifierLivraison: widget.onPlanifierLivraison,
              onScheduleArrivee: widget.onScheduleArrivee,
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          // ── Détails de la négociation / commande (always visible at bottom) ─
          if (showNegociationSection)
            _NegociationSection(
              e: e,
              accentColor: accent,
              isExpanded: _detailsExpanded,
              onToggle: () =>
                  setState(() => _detailsExpanded = !_detailsExpanded),
            ),
        ],
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
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: kOliveGreen.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      'Qté : $quantite',
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kOliveGreen,
      ),
    ),
  );
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
// CONFIRMER L'ACHAT ROW  (always visible when enNegociation)
// Compact chip-style button — not full-width
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmerAchatRow extends StatelessWidget {
  final VoidCallback onConfirmerAchat;
  const _ConfirmerAchatRow({required this.onConfirmerAchat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey.shade100, height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OutlinedButton(
                onPressed: onConfirmerAchat,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kGreen,
                  side: BorderSide(color: kGreen.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirmer l\'achat',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL PANEL  (shown when card is expanded)
//
// - achatConfirme : shows stock delivery line only (no sample delivery)
// - other statuts : shows sample delivery line only
// - edit/delete icons only when callbacks are non-null (receptionne only)
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final EchantillonCollecteur e;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;
  final VoidCallback? onPlanifierLivraison;
  final VoidCallback? onScheduleArrivee;

  const _DetailPanel({
    required this.e,
    this.onModifier,
    this.onSupprimer,
    this.onPlanifierLivraison,
    this.onScheduleArrivee,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasActions =
        e.recuPhysiquement || onModifier != null || onSupprimer != null;

    return Column(
      children: [
        Divider(color: Colors.grey.shade100, height: 1),

        // ── Action row ABOVE the details box ──────────────────────────────
        if (hasActions)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 9, 10, 0),
            child: Row(
              children: [
                // Received indicator (tick)
                if (e.recuPhysiquement) ...[
                  const Icon(Icons.check_circle, size: 14, color: kGreen),
                  const SizedBox(width: 5),
                  Text(
                    e.dateReceptionEchantillon != null
                        ? 'Reçu le ${e.dateReceptionEchantillon}'
                        : 'Réceptionné',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                // Edit button
                if (onModifier != null)
                  Tooltip(
                    message: 'Modifier',
                    child: _SmallIconBtn(
                      icon: Icons.edit_outlined,
                      color: kOliveGreen,
                      onTap: onModifier!,
                    ),
                  ),
                // Delete button
                if (onSupprimer != null) ...[
                  const SizedBox(width: 2),
                  Tooltip(
                    message: 'Supprimer',
                    child: _SmallIconBtn(
                      icon: Icons.delete_outline,
                      color: Colors.red.shade300,
                      onTap: onSupprimer!,
                    ),
                  ),
                ],
              ],
            ),
          ),

        // ── Gray details box ───────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Attribute grid ───────────────────────────────────────────
              Wrap(
                spacing: 90,
                runSpacing: 10,
                children: [
                  _DetailItem('N° échantillon', e.ref),
                  _DetailItem('Réf. bouteille', e.referenceBouteille),
                  _DetailItem('Fournisseur', e.codeFournisseur),
                  if (e.variete != null && e.variete!.isNotEmpty)
                    _DetailItem('Variété', e.variete!),
                  _DetailItem(
                    'Localisation',
                    e.delegation != null
                        ? '${e.gouvernorat} — ${e.delegation}'
                        : e.gouvernorat,
                  ),
                  if (e.scellage != null && e.scellage!.isNotEmpty)
                    _DetailItem('Scellage', e.scellage!),
                ],
              ),

              const SizedBox(height: 14),

              // ── Delivery lines ───────────────────────────────────────────
              if (e.statut == StatutCollecteur.achatConfirme) ...[
                // 1. Sample reception (always received at this stage)
                _SampleDeliveryLine(e: e, onScheduleArrivee: null),
                const SizedBox(height: 10),
                // 2. Stock delivery
                _StockDeliveryLine(
                  e: e,
                  onPlanifierLivraison: onPlanifierLivraison,
                ),
              ] else
                _SampleDeliveryLine(e: e, onScheduleArrivee: onScheduleArrivee),

              // ── Remarques ────────────────────────────────────────────────
              if (e.remarques != null && e.remarques!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
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
                        e.remarques!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
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
// NÉGOCIATION SECTION  (always visible at card bottom, like _AchatSection)
//
// enNegociation  → "Détails de la négociation" — budget + date souhaitée
// achatConfirme  → "Détails de la commande"    — prix final + camion
// ─────────────────────────────────────────────────────────────────────────────
class _NegociationSection extends StatelessWidget {
  final EchantillonCollecteur e;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _NegociationSection({
    required this.e,
    required this.accentColor,
    required this.isExpanded,
    required this.onToggle,
  });

  String get _label => e.statut == StatutCollecteur.enNegociation
      ? 'Détails de la négociation'
      : 'Détails de la commande';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey.shade100, height: 1),
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _NegociationDetails(e: e, accentColor: accentColor),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _NegociationDetails extends StatelessWidget {
  final EchantillonCollecteur e;
  final Color accentColor;

  const _NegociationDetails({required this.e, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final bool isNego = e.statut == StatutCollecteur.enNegociation;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        children: [
          if (isNego) ...[
            if (e.budgetNegociation != null)
              _ReceiptLine(
                label: 'Budget proposé',
                value: e.budgetNegociation!,
              ),
            if (e.dateStockSouhaitee != null)
              _ReceiptLine(
                label: 'Date souhaitée',
                value: e.dateStockSouhaitee!,
              ),
          ] else ...[
            if (e.prixFinal != null)
              _ReceiptLine(label: 'Prix final', value: e.prixFinal!),
            if (e.camionLivraison != null)
              _ReceiptLine(label: 'Camion', value: e.camionLivraison!),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE DELIVERY LINE  (bottle arriving at company — gray text, no colored boxes)
//
// States:
//   ① recuPhysiquement + date   → "— Échantillon réceptionné le dd/mm/yyyy —"
//   ② recuPhysiquement, no date → "— Échantillon réceptionné —"
//   ③ dateArriveeEchantillon    → "— Arrivée prévue le dd/mm/yyyy —"  [Modifier]
//   ④ nothing set               → "— Arrivée non planifiée —"          [Planifier]
// ─────────────────────────────────────────────────────────────────────────────
class _SampleDeliveryLine extends StatelessWidget {
  final EchantillonCollecteur e;
  final VoidCallback? onScheduleArrivee;

  const _SampleDeliveryLine({required this.e, this.onScheduleArrivee});

  @override
  Widget build(BuildContext context) {
    // Already received — just informational, no action needed
    if (e.recuPhysiquement) {
      return Text(
        e.dateReceptionEchantillon != null
            ? 'Échantillon réceptionné le ${e.dateReceptionEchantillon}'
            : 'Échantillon réceptionné',
        style: const TextStyle(
          fontSize: 12,
          color: _deliveryDarkGray,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    // Arrival date set or not — stacked layout with Planifier/Modifier below
    final String text;
    final String actionLabel;
    if (e.dateArriveeEchantillon != null &&
        e.dateArriveeEchantillon!.isNotEmpty) {
      text = 'Arrivée prévue le ${e.dateArriveeEchantillon}';
      actionLabel = 'Modifier';
    } else {
      text = 'Arrivée de l\'échantillon non planifiée';
      actionLabel = 'Planifier';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: _deliveryDarkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (onScheduleArrivee != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onScheduleArrivee,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A6EA5),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF3A6EA5),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STOCK DELIVERY LINE  (bulk stock delivery — dark gray, stacked layout)
//
// States (achatConfirme only):
//   ① livraison complete → date on its own line, "Modifier" below right
//   ② no livraison       → "non programmée" text, "Planifier" below right
// ─────────────────────────────────────────────────────────────────────────────
const Color _deliveryDarkGray = Color(0xFF3D3D3D);

class _StockDeliveryLine extends StatelessWidget {
  final EchantillonCollecteur e;
  final VoidCallback? onPlanifierLivraison;

  const _StockDeliveryLine({required this.e, this.onPlanifierLivraison});

  @override
  Widget build(BuildContext context) {
    final liv = e.livraison;
    final String actionLabel;
    final String dateText;

    if (liv != null && liv.isComplete) {
      final d = liv.dateExacte!;
      final dateStr =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      final parts = <String>[
        'Livraison du stock le $dateStr',
        if (liv.heure.isNotEmpty) 'à ${liv.heure}',
      ];
      dateText = parts.join('  ·  ');
      actionLabel = 'Modifier';
    } else {
      dateText = 'Livraison du stock non programmée';
      actionLabel = 'Planifier';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateText,
          style: const TextStyle(
            fontSize: 12,
            color: _deliveryDarkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (onPlanifierLivraison != null) ...[
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onPlanifierLivraison,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A6EA5),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFF3A6EA5),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRAY LINE  (simple gray italic delivery status text)
// ─────────────────────────────────────────────────────────────────────────────
class _GrayLine extends StatelessWidget {
  final String text;
  const _GrayLine({required this.text});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      color: _grayText,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w400,
    ),
  );
}

class _GrayLineWithAction extends StatelessWidget {
  final String text;
  final String actionLabel;
  final VoidCallback? onAction;

  const _GrayLineWithAction({
    required this.text,
    required this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: _grayText,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      if (onAction != null) ...[
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3A6EA5),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF3A6EA5),
            ),
          ),
        ),
      ],
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// RECEIPT LINE  (label : value)
// ─────────────────────────────────────────────────────────────────────────────
class _ReceiptLine extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '$label : ',
        style: const TextStyle(
          fontSize: 12,
          color: _grayText,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          color: kDarkText,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
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
          color: _grayText,
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kDarkText,
        ),
      ),
    ],
  );
}
