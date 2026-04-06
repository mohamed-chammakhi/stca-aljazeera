// ═════════════════════════════════════════════════════════════════════════════
// FILE : shared/widgets/sample_card_widgets.dart
// Reusable sample-card widgets: DetailItem, SampleDetails, SampleRow.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../utilisateurs/models/echantillon_ceo_view.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _dark = Color(0xFF1A2E1F);
const Color _olive = Color(0xFF6B8143);
const Color _sageTint = Color(0xFFF2F5F0);

// ─────────────────────────────────────────────────────────────────────────────
// STATUT CONFIG  (public so callers can use it if needed)
// ─────────────────────────────────────────────────────────────────────────────
class StatutCfg {
  final Color color;
  final String label;
  const StatutCfg(this.color, this.label);
}

StatutCfg statutConfig(StatutCeoView s) {
  switch (s) {
    case StatutCeoView.selectionne:
      return StatutCfg(Colors.blue.shade400, 'Sélectionné');
    case StatutCeoView.enNegociation:
      return StatutCfg(Colors.orange.shade500, 'En négociation');
    case StatutCeoView.achatConfirme:
      return const StatutCfg(_green, 'Achat confirmé');
    case StatutCeoView.refuse:
      return StatutCfg(Colors.red.shade400, 'Refusé');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ITEM  — a small label + value column, used inside SampleDetails
// ─────────────────────────────────────────────────────────────────────────────
class DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const DetailItem(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 100),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9C9B9B),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _dark,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE DETAILS  — expanded detail panel for one echantillon
// ─────────────────────────────────────────────────────────────────────────────
class SampleDetails extends StatefulWidget {
  final EchantillonCeoView e;
  const SampleDetails({super.key, required this.e});

  @override
  State<SampleDetails> createState() => _SampleDetailsState();
}

class _SampleDetailsState extends State<SampleDetails> {
  bool _purchaseExpanded = false;

  Color _statutColor(StatutCeoView s) {
    switch (s) {
      case StatutCeoView.selectionne:
        return Colors.blue.shade500;
      case StatutCeoView.enNegociation:
        return Colors.orange.shade600;
      case StatutCeoView.achatConfirme:
        return _green;
      case StatutCeoView.refuse:
        return Colors.red.shade500;
    }
  }

  String _statutLabel(StatutCeoView s) {
    switch (s) {
      case StatutCeoView.selectionne:
        return 'Sélectionné';
      case StatutCeoView.enNegociation:
        return 'En négociation';
      case StatutCeoView.achatConfirme:
        return 'Achat confirmé';
      case StatutCeoView.refuse:
        return 'Refusé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.e;
    final statutColor = _statutColor(e.statut);
    final statutLabel = _statutLabel(e.statut);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _green.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Status badge (pill with border) ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statutColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statutColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              statutLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: statutColor,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Detail grid ───────────────────────────────────────────────────
          Wrap(
            spacing: 60,
            runSpacing: 12,
            children: [
              DetailItem('N° échantillon', e.id),
              DetailItem('Ref. bouteille', e.referenceBouteille),
              DetailItem(
                'Gouvernorat',
                '${e.gouvernorat}${e.delegation != null ? " — ${e.delegation}" : ""}',
              ),
              DetailItem('Fournisseur', e.codeFournisseur),
              if (e.variete != null) DetailItem('Variété', e.variete!),
              if (e.scellage != null) DetailItem('Scellage', e.scellage!),
              if (e.quantiteEstimee != null)
                DetailItem('Quantité', '${e.quantiteEstimee} T'),
              DetailItem('Date d\'ajout', e.dateAjout),
              if (e.dateLivraisonPrevue != null)
                DetailItem('Livraison prévue', e.dateLivraisonPrevue!),
            ],
          ),
          const SizedBox(height: 15),

          // ── Réception / livraison indicator (6 states) ───────────────────
          if (e.stockArrive) ...[
            // ① Stock physically arrived → delivery text, then "Détails" on next line
            Text(
              e.dateLivraisonStock != null
                  ? '— Stock réceptionné le ${e.dateLivraisonStock} —'
                  : '— Stock réceptionné —',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9C9B9B),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () =>
                  setState(() => _purchaseExpanded = !_purchaseExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Détails de l\'achat',
                    style: TextStyle(
                      fontSize: 12,
                      color: statutColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: statutColor.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 2),
                  AnimatedRotation(
                    turns: _purchaseExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 15,
                      color: statutColor,
                    ),
                  ),
                ],
              ),
            ),
            // Collapsible purchase details panel
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: PurchaseDetailsPanel(e: e, color: statutColor),
              crossFadeState: _purchaseExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ] else if (e.dateLivraisonStock != null) ...[
            // ② Stock delivery date set but not yet received
            Text(
              '— Livraison du stock prévue le ${e.dateLivraisonStock} —',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9C9B9B),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () =>
                  setState(() => _purchaseExpanded = !_purchaseExpanded),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Détails de la commande',
                    style: TextStyle(
                      fontSize: 12,
                      color: statutColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: statutColor.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 2),
                  AnimatedRotation(
                    turns: _purchaseExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 15,
                      color: statutColor,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: PurchaseDetailsPanel(e: e, color: statutColor),
              crossFadeState: _purchaseExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ] else if (e.recuPhysiquement) ...[
            // ③ Sample physically received (taster confirmed arrival)
            Text(
              e.dateArriveeEchantillon != null
                  ? '— Échantillon réceptionné le ${e.dateArriveeEchantillon} —'
                  : '— Échantillon réceptionné —',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9C9B9B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ] else if (e.dateLivraisonPrevue != null) ...[
            // ④ Collector stated a delivery date but sample hasn't arrived yet
            Text(
              '— Arrivée prévue le ${e.dateLivraisonPrevue} —',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9C9B9B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ] else if (e.statut == StatutCeoView.enNegociation ||
              e.statut == StatutCeoView.achatConfirme) ...[
            // ⑤ Stock purchase confirmed but no delivery date set yet
            const Text(
              '— Livraison du stock non programmée —',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9C9B9B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ] else ...[
            // ⑥ Sample registered, no delivery date announced yet
            const Text(
              '— Livraison non planifiée —',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF9C9B9B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],

          // ── Refusal reason ────────────────────────────────────────────────
          if (e.statut == StatutCeoView.refuse && e.raisonRefus != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Text(
                'Raison du refus : ${e.raisonRefus}',
                style: TextStyle(fontSize: 13, color: Colors.red.shade700),
              ),
            ),
          ],

          // ── Remarks ───────────────────────────────────────────────────────
          if (e.remarques != null && e.remarques!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Remarques : ${e.remarques}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PURCHASE DETAILS PANEL  — collapsible receipt shown under "Détails de l'achat"
// ─────────────────────────────────────────────────────────────────────────────
class PurchaseDetailsPanel extends StatelessWidget {
  final EchantillonCeoView e;
  final Color color;
  const PurchaseDetailsPanel({super.key, required this.e, required this.color});

  @override
  Widget build(BuildContext context) {
    final hasDetails =
        e.quantiteCibleT != null ||
        e.budgetNegociation != null ||
        e.camionReserve != null;
    if (!hasDetails) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 6,
        children: [
          if (e.quantiteCibleT != null)
            _ReceiptLine(
              label: 'Quantité livrée',
              value: '${e.quantiteCibleT} T',
            ),
          if (e.budgetNegociation != null)
            _ReceiptLine(label: 'Montant total', value: e.budgetNegociation!),
          if (e.camionReserve != null)
            _ReceiptLine(label: 'Camion', value: e.camionReserve!),
        ],
      ),
    );
  }
}

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
          color: Color(0xFF9C9B9B),
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 12,
          color: _dark,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE ROW  — one row in the collecteur list, with expandable details
// ─────────────────────────────────────────────────────────────────────────────
class SampleRow extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final bool isExpanded;
  final bool isOdd;
  final bool isLast;
  final VoidCallback onToggle;

  const SampleRow({
    super.key,
    required this.echantillon,
    required this.isExpanded,
    required this.isOdd,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    final cfg = statutConfig(e.statut);

    return Column(
      children: [
        Container(
          color: e.statut == StatutCeoView.refuse
              ? Colors.red.shade50
              : isOdd
              ? _sageTint
              : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status dot
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: cfg.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),

              // Left: bottle reference (top) + sample ID (bottom)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.referenceBouteille,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _dark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      e.id,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 111, 111, 111),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: quantity (top) + date (bottom)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (e.quantiteEstimee != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _olive.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Qté : ${e.quantiteEstimee} T',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _olive,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18),
                  const SizedBox(height: 2),
                  Text(
                    e.dateAjout,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(255, 111, 111, 111),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),
              // Expand / collapse arrow
              GestureDetector(
                onTap: onToggle,
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
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
        // Animated detail panel
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: SampleDetails(e: e),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        // Divider between rows
        if (!isLast)
          Divider(
            color: Colors.grey.shade100,
            height: 1,
            indent: 14,
            endIndent: 14,
          ),
      ],
    );
  }
}
