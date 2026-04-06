import 'package:flutter/material.dart';
import 'sample_card_widgets.dart'; // DetailItem lives here
import '../utilisateurs/models/echantillon_ceo_view.dart';

const Color _dark = Color(0xFF1A2E1F);
const Color _cream = Color(0xFFF9F6EF);

// ─────────────────────────────────────────────────────────────────────────────
// BASE SAMPLE CARD
// ─────────────────────────────────────────────────────────────────────────────
class BaseSampleCard extends StatefulWidget {
  final String referenceBouteille;
  final String id;
  final Color tintColor;
  final Widget badge;
  final List<DetailItem> detailItems;
  final Widget? bottomSection;

  final Widget? deliveryWidget;

  const BaseSampleCard({
    super.key,
    required this.referenceBouteille,
    required this.id,
    required this.tintColor,
    required this.badge,
    required this.detailItems,
    this.bottomSection,
    this.deliveryWidget,
  });

  @override
  State<BaseSampleCard> createState() => _BaseSampleCardState();
}

class _BaseSampleCardState extends State<BaseSampleCard> {
  bool _detailExpanded = false;

  @override
  Widget build(BuildContext context) {
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
          // ── Tinted header ──────────────────────────────────────────────
          Container(
            color: widget.tintColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.referenceBouteille,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _dark,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.id,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                widget.badge,
                const SizedBox(width: 11),
                GestureDetector(
                  onTap: () =>
                      setState(() => _detailExpanded = !_detailExpanded),
                  child: AnimatedRotation(
                    turns: _detailExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Expandable detail panel ──────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DetailPanel(
              items: widget.detailItems,
              deliveryWidget: widget.deliveryWidget,
            ),
            crossFadeState: _detailExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          // ── Optional bottom section ──────────────────────────────────
          if (widget.bottomSection != null) ...[
            Divider(color: Colors.grey.shade100, height: 1),
            widget.bottomSection!,
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final List<DetailItem> items;
  final Widget? deliveryWidget;
  const _DetailPanel({required this.items, this.deliveryWidget});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _cream,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(spacing: 60, runSpacing: 10, children: items),
        if (deliveryWidget != null) ...[
          const SizedBox(height: 12),
          deliveryWidget!,
        ],
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CARD BADGE HELPERS
// ─────────────────────────────────────────────────────────────────────────────
class CardBadge extends StatelessWidget {
  final String label;
  final Color color;

  const CardBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

class CardBadgeRow extends StatelessWidget {
  final List<Widget> badges;
  const CardBadgeRow({super.key, required this.badges});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (int i = 0; i < badges.length; i++) ...[
        if (i > 0) const SizedBox(width: 6),
        badges[i],
      ],
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE DELIVERY INDICATOR
// Full 6-state delivery section matching SampleDetails in sample_card_widgets.
// ─────────────────────────────────────────────────────────────────────────────
class SampleDeliveryIndicator extends StatefulWidget {
  final EchantillonCeoView e;
  final Color accentColor;
  const SampleDeliveryIndicator({
    super.key,
    required this.e,
    this.accentColor = const Color(0xFF38835A),
  });

  @override
  State<SampleDeliveryIndicator> createState() =>
      _SampleDeliveryIndicatorState();
}

class _SampleDeliveryIndicatorState extends State<SampleDeliveryIndicator> {
  bool _expanded = false;

  static const TextStyle _greyStyle = TextStyle(
    fontSize: 13,
    color: Color(0xFF9C9B9B),
    fontWeight: FontWeight.w400,
  );

  @override
  Widget build(BuildContext context) {
    final e = widget.e;
    final color = widget.accentColor;

    if (e.stockArrive) {
      // ① Stock physically arrived
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            e.dateLivraisonStock != null
                ? '— Stock réceptionné le ${e.dateLivraisonStock} —'
                : '— Stock réceptionné —',
            style: _greyStyle,
          ),
          const SizedBox(height: 6),
          _ToggleLink(
            label: "Détails de l'achat",
            color: color,
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: PurchaseDetailsPanel(e: e, color: color),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      );
    } else if (e.dateLivraisonStock != null) {
      // ② Stock delivery date set but not yet received
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '— Livraison du stock prévue le ${e.dateLivraisonStock} —',
            style: _greyStyle,
          ),
          const SizedBox(height: 6),
          _ToggleLink(
            label: 'Détails de la commande',
            color: color,
            expanded: _expanded,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: PurchaseDetailsPanel(e: e, color: color),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      );
    } else if (e.recuPhysiquement) {
      // ③ Sample physically received
      return Text(
        e.dateArriveeEchantillon != null
            ? '— Échantillon réceptionné le ${e.dateArriveeEchantillon} —'
            : '— Échantillon réceptionné —',
        style: _greyStyle,
      );
    } else if (e.dateLivraisonPrevue != null) {
      // ④ Delivery date announced but not yet arrived
      return Text(
        '— Arrivée prévue le ${e.dateLivraisonPrevue} —',
        style: _greyStyle,
      );
    } else if (e.statut == StatutCeoView.enNegociation ||
        e.statut == StatutCeoView.achatConfirme) {
      // ⑤ Purchase confirmed but no stock delivery date yet
      return const Text(
        '— Livraison du stock non programmée —',
        style: _greyStyle,
      );
    } else {
      // ⑥ Sample registered, no delivery date announced
      return const Text('— Livraison non planifiée —', style: _greyStyle);
    }
  }
}

class _ToggleLink extends StatelessWidget {
  final String label;
  final Color color;
  final bool expanded;
  final VoidCallback onTap;
  const _ToggleLink({
    required this.label,
    required this.color,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: color.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 2),
        AnimatedRotation(
          turns: expanded ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 180),
          child: Icon(Icons.keyboard_arrow_down, size: 15, color: color),
        ),
      ],
    ),
  );
}
