import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/facture.dart';

const Color _green = Color(0xFF38835A);
const Color _dark  = Color(0xFF1A2E1F);
const Color _olive = Color(0xFF6B8143);

Color _statutColor(StatutFacture s) {
  switch (s) {
    case StatutFacture.brouillon: return const Color(0xFF757575);
    case StatutFacture.emise:     return const Color(0xFFD07B2F);
    case StatutFacture.payee:     return _green;
  }
}

Color _statutBg(StatutFacture s) {
  switch (s) {
    case StatutFacture.brouillon: return const Color(0xFFF0F0F0);
    case StatutFacture.emise:     return const Color(0xFFFEF3E8);
    case StatutFacture.payee:     return const Color(0xFFE8F5E9);
  }
}

class FactureCard extends StatefulWidget {
  final Facture facture;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;

  const FactureCard({
    super.key,
    required this.facture,
    this.onModifier,
    this.onSupprimer,
  });

  @override
  State<FactureCard> createState() => _FactureCardState();
}

class _FactureCardState extends State<FactureCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.facture;
    final color = _statutColor(f.statut);
    final bg    = _statutBg(f.statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 11, 12, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  f.numeroFacture,
                                  style: GoogleFonts.domine(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: bg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  f.statut.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                          const SizedBox(height: 3),
                          Text(
                            '${f.referenceBouteille} · ${f.gouvernorat} · ${f.fournisseur}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                f.montantFormate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${f.quantiteT.toStringAsFixed(1)} T · ${f.prixUnitaireTnd.toStringAsFixed(0)} DT/T',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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

          // ── Expandable detail ─────────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _FactureDetail(
              facture: f,
              accentColor: color,
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
class _FactureDetail extends StatelessWidget {
  final Facture facture;
  final Color accentColor;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;

  const _FactureDetail({
    required this.facture,
    required this.accentColor,
    this.onModifier,
    this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    final f = facture;
    return Column(
      children: [
        Divider(color: Colors.grey.shade100, height: 1),
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAF8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 30, runSpacing: 10,
                children: [
                  _DetailRow('N° achat', f.achatId),
                  _DetailRow('Créée le', f.dateCreation),
                  if (f.dateEmission != null)
                    _DetailRow('Émise le', f.dateEmission!),
                  if (f.datePaiement != null)
                    _DetailRow('Payée le', f.datePaiement!),
                ],
              ),
              if (f.notes != null && f.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes_outlined, size: 13, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Expanded(child: Text(
                      f.notes!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    )),
                  ],
                ),
              ],
              if (onModifier != null || onSupprimer != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onSupprimer != null)
                      _ActionBtn(
                        icon: Icons.delete_outline,
                        label: 'Supprimer',
                        color: Colors.red.shade400,
                        onTap: onSupprimer!,
                      ),
                    if (onModifier != null) ...[
                      const SizedBox(width: 8),
                      _ActionBtn(
                        icon: Icons.edit_outlined,
                        label: 'Modifier',
                        color: _olive,
                        onTap: onModifier!,
                      ),
                    ],
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

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _dark)),
    ],
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ]),
    ),
  );
}
