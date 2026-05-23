import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import '../../utilisateurs/models/echantillon_ceo_view.dart';
import '../../widgets/sample_card_echantillon.dart';

class PropositionSection extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback? onConfirmer;
  final VoidCallback? onRefuser;

  const PropositionSection({
    super.key,
    required this.echantillon,
    required this.accentColor,
    required this.isExpanded,
    required this.onToggle,
    this.onConfirmer,
    this.onRefuser,
  });

  bool get _isPending => echantillon.statut == StatutCeo.enNegociation;
  bool get _isConfirmed => echantillon.statut == StatutCeo.achatConfirme;
  bool get _isRefused => echantillon.statut == StatutCeo.refuse;

  @override
  Widget build(BuildContext context) {
    final headerLabel = _isPending
        ? "Proposition d'achat"
        : _isConfirmed
            ? 'Décision : achat confirmé'
            : 'Décision : refusé';

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
                  _isPending
                      ? Icons.pending_actions_outlined
                      : _isConfirmed
                          ? Icons.handshake_outlined
                          : Icons.block_outlined,
                  size: 13,
                  color: accentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  headerLabel,
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
          secondChild: _PropositionDetails(
            echantillon: echantillon,
            accentColor: accentColor,
            showActions: _isPending,
            isRefused: _isRefused,
            onConfirmer: onConfirmer,
            onRefuser: onRefuser,
          ),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _PropositionDetails extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final Color accentColor;
  final bool showActions;
  final bool isRefused;
  final VoidCallback? onConfirmer;
  final VoidCallback? onRefuser;

  const _PropositionDetails({
    required this.echantillon,
    required this.accentColor,
    required this.showActions,
    required this.isRefused,
    this.onConfirmer,
    this.onRefuser,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails de la proposition',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kOlive,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 20,
            runSpacing: 10,
            children: [
              if (e.budgetNegociation != null)
                DetailItem('Prix négocié', e.budgetNegociation!),
              if (e.quantiteCibleT != null)
                DetailItem('Quantité', '${e.quantiteCibleT} T'),
              if (e.camionReserve != null)
                DetailItem('Camion', e.camionReserve!),
              if (e.scellage != null)
                DetailItem('Scellage', e.scellage!),
              if (e.dateLivraisonStock != null)
                DetailItem(
                  'Livraison stock',
                  e.dateLivraisonStockFin != null
                      ? '${e.dateLivraisonStock} → ${e.dateLivraisonStockFin}'
                      : e.dateLivraisonStock!,
                ),
              if (e.collecteurNom != null)
                DetailItem('Soumise par', e.collecteurNom!),
            ],
          ),
          if (isRefused &&
              e.raisonRefus != null &&
              e.raisonRefus!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x33B71C1C)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.block_outlined,
                    size: 14,
                    color: Color(0xFFB71C1C),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Raison du refus : ${e.raisonRefus}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (showActions) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRefuser,
                    icon: const Icon(Icons.block_outlined,
                        size: 16, color: Color(0xFFB71C1C)),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFB71C1C),
                      side: const BorderSide(
                          color: Color(0xFFB71C1C), width: 1.4),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onConfirmer,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text("Confirmer l'achat"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
