// ═════════════════════════════════════════════════════════════════════════════
// FILE : 6_responsable_financier/achats_confirmes/achats_confirmes_rf_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/rf_drawer.dart';
import '../widgets/base_sample_card.dart';
import '../widgets/sample_card_echantillon.dart';
import '../widgets/search_date_filter_bar.dart';
import '../factures/formulaire_facture_dialog.dart';
import '../factures/factures_page.dart';
import '../profil_rf_page.dart';
import '../../main.dart';
import '../../1_ceo/utilisateurs/models/echantillon_ceo_view.dart';
import '../../1_ceo/utilisateurs/models/mock_data_patch.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _bg       = Color.fromARGB(255, 255, 255, 255);
const Color _olive    = Color(0xFF6B8143);

// ─────────────────────────────────────────────────────────────────────────────
class AchatsConfirmesRfPage extends StatefulWidget {
  const AchatsConfirmesRfPage({super.key});
  @override
  State<AchatsConfirmesRfPage> createState() => _AchatsConfirmesRfPageState();
}

class _AchatsConfirmesRfPageState extends State<AchatsConfirmesRfPage> {
  final Set<String> _expandedAchat = {};
  String _activeFilter = 'tout';
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<EchantillonCeoView> get _allAchats => mockAchatsConfirmes;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EchantillonCeoView> get _achats {
    var result = _allAchats;
    if (_dateDebut != null) {
      result = result.where((e) {
        final d = _parseDate(e.dateAjout);
        if (d == null) return false;
        final day   = DateTime(d.year, d.month, d.day);
        final debut = DateTime(_dateDebut!.year, _dateDebut!.month, _dateDebut!.day);
        if (_dateFin != null) {
          final fin = DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day);
          return !day.isBefore(debut) && !day.isAfter(fin);
        }
        return day == debut;
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((e) =>
        e.referenceBouteille.toLowerCase().contains(q) ||
        e.id.toLowerCase().contains(q) ||
        e.codeFournisseur.toLowerCase().contains(q) ||
        e.gouvernorat.toLowerCase().contains(q) ||
        (e.variete?.toLowerCase().contains(q) ?? false) ||
        (e.collecteurNom?.toLowerCase().contains(q) ?? false),
      ).toList();
    }
    if (_activeFilter == 'arrive') {
      result = result.where((e) => e.stockArrive).toList();
    } else if (_activeFilter == 'transit') {
      result = result.where((e) => !e.stockArrive).toList();
    }
    return result;
  }

  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) { return null; }
  }

  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        onApply: (d, f) => setState(() { _dateDebut = d; _dateFin = f; }),
        onClear: () => setState(() { _dateDebut = null; _dateFin = null; }),
      ),
    );
  }

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final achats = _achats;

    return Scaffold(
      backgroundColor: _bg,
      drawer: RfDrawer(
        onAchatsConfirmes: () => Navigator.pop(context),
        onFactures: () => _goTo(const FacturesPage()),
        onProfil: () => _goTo(const ProfilRfPage()),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Achats confirmés',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        iconTheme: const IconThemeData(color: _dark),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: (_dateDebut != null || _dateFin != null)
                      ? _green
                      : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: 'Filtrer par date',
              ),
              if (_dateDebut != null || _dateFin != null)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              style: const TextStyle(fontSize: 14, color: _dark),
              decoration: InputDecoration(
                hintText: 'Rechercher réf, fournisseur, gouvernorat…',
                hintStyle: const TextStyle(color: Color(0xFF6B8E7A), fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B8E7A), size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 17, color: Color(0xFF6B8E7A)),
                        onPressed: () => setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _green, width: 1.5),
                ),
              ),
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tout',
                  isActive: _activeFilter == 'tout',
                  activeBg: const Color(0xFF757575),
                  activeFg: Colors.white,
                  onTap: () => setState(() => _activeFilter = 'tout'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Stock arrivé',
                  isActive: _activeFilter == 'arrive',
                  activeBg: _green.withValues(alpha: 0.12),
                  activeFg: _green,
                  onTap: () => setState(() => _activeFilter = 'arrive'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'En transit',
                  isActive: _activeFilter == 'transit',
                  activeBg: Colors.orange.shade700.withValues(alpha: 0.12),
                  activeFg: Colors.orange.shade700,
                  onTap: () => setState(() => _activeFilter = 'transit'),
                ),
              ],
            ),
          ),
          Expanded(
            child: achats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.handshake_outlined, size: 52, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun achat confirmé',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
                    itemCount: achats.length,
                    itemBuilder: (_, i) {
                      final e = achats[i];
                      final accentColor = e.stockArrive ? _green : Colors.orange.shade700;
                      final tintColor = e.stockArrive
                          ? const Color(0xFFEAF4EE)
                          : const Color(0xFFFFF3E0);
                      final achatExp = _expandedAchat.contains(e.id);

                      return BaseSampleCard(
                        referenceBouteille: e.referenceBouteille,
                        id: e.id,
                        tintColor: tintColor,
                        accentColor: accentColor,
                        badge: CardBadgeRow(
                          badges: [
                            if (e.quantiteCibleT != null)
                              CardBadge(label: 'Qté : ${e.quantiteCibleT}T', color: _olive),
                          ],
                        ),
                        detailItems: [
                          DetailItem('N° échantillon', e.id),
                          DetailItem('Ref. bouteille', e.referenceBouteille),
                          DetailItem(
                            'Gouvernorat',
                            '${e.gouvernorat}${e.delegation != null ? " — ${e.delegation}" : ""}',
                          ),
                          DetailItem('Fournisseur', e.codeFournisseur),
                          if (e.variete != null) DetailItem('Variété', e.variete!),
                          if (e.collecteurNom != null) DetailItem('Collecteur', e.collecteurNom!),
                          DetailItem('Date enregistrement', e.dateAjout),
                        ],
                        deliveryWidget: SampleDeliveryIndicator(e: e),
                        bottomSection: _AchatSectionRf(
                          echantillon: e,
                          accentColor: accentColor,
                          isExpanded: achatExp,
                          onToggle: () => setState(() =>
                            achatExp ? _expandedAchat.remove(e.id) : _expandedAchat.add(e.id)),
                          onCreerFacture: () => showFormulaireFactureDialog(context, echantillon: e),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACHAT SECTION (RF) — same collapsible as CEO but with "Créer une facture" btn
// ─────────────────────────────────────────────────────────────────────────────
class _AchatSectionRf extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final Color accentColor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onCreerFacture;

  const _AchatSectionRf({
    required this.echantillon,
    required this.accentColor,
    required this.isExpanded,
    required this.onToggle,
    required this.onCreerFacture,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
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
                  e.stockArrive ? Icons.inventory_2_outlined : Icons.local_shipping_outlined,
                  size: 13,
                  color: accentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Détails de l\'achat',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accentColor),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(Icons.keyboard_arrow_down, size: 16, color: accentColor),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _AchatDetailsRf(
            echantillon: e,
            accentColor: accentColor,
            onCreerFacture: onCreerFacture,
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _AchatDetailsRf extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final Color accentColor;
  final VoidCallback onCreerFacture;

  const _AchatDetailsRf({
    required this.echantillon,
    required this.accentColor,
    required this.onCreerFacture,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de l\'achat',
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: _olive, letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 20, runSpacing: 10,
            children: [
              if (e.quantiteCibleT != null)
                DetailItem('Quantité achetée', '${e.quantiteCibleT} T'),
              if (e.budgetNegociation != null)
                DetailItem('Prix négocié', e.budgetNegociation!),
              if (e.camionReserve != null)
                DetailItem('Camion réservé', e.camionReserve!),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: accentColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  e.stockArrive ? Icons.inventory_2_rounded : Icons.local_shipping_outlined,
                  size: 14, color: accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.stockArrive
                        ? 'Stock arrivé en entrepôt${e.dateLivraisonStock != null ? " — ${e.dateLivraisonStock}" : ""}'
                        : 'En transit${e.dateLivraisonStock != null ? " — Livraison prévue : ${e.dateLivraisonStock}" : ""}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accentColor),
                  ),
                ),
              ],
            ),
          ),
          if (e.noteInterne != null && e.noteInterne!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes_outlined, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Expanded(child: Text(
                  e.noteInterne!,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                )),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCreerFacture,
              icon: const Icon(Icons.receipt_long_outlined, size: 16, color: Colors.white),
              label: const Text(
                'Créer une facture',
                style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBg, activeFg;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.activeBg,
    required this.activeFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color inactiveBg = Color(0xFFF0F0F0);
    const Color inactiveFg = Color(0xFF9E9E9E);
    final bg    = isActive ? activeBg : inactiveBg;
    final fg    = isActive ? activeFg : inactiveFg;
    final border = isActive
        ? activeFg.withValues(alpha: activeFg == Colors.white ? 0.0 : 0.3)
        : const Color(0xFFE0E0E0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      ),
    );
  }
}
