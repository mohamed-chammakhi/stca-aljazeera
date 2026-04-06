// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/achats_confirmes/achats_confirmes_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../utilisateurs/models/echantillon_ceo_view.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import 'achats_confirmes_ceo_page.dart';
import '../profil_ceo_page.dart';
import '../../main.dart';
import '../utilisateurs/models/mock_data_patch.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../widgets/search_date_filter_bar.dart';
import '../widgets/sample_card_widgets.dart';
import '../widgets/base_sample_card.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _dark = Color(0xFF1A2E1F);
const Color _olive = Color(0xFF6B8143);

// ─────────────────────────────────────────────────────────────────────────────
class AchatsConfirmesCeoPage extends StatefulWidget {
  const AchatsConfirmesCeoPage({super.key});
  @override
  State<AchatsConfirmesCeoPage> createState() => _AchatsConfirmesCeoPageState();
}

class _AchatsConfirmesCeoPageState extends State<AchatsConfirmesCeoPage> {
  // ✅ ADDED: track which achat cards have their details expanded
  final Set<String> _expandedAchat = {};

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
        final day = DateTime(d.year, d.month, d.day);
        final debut = DateTime(
          _dateDebut!.year,
          _dateDebut!.month,
          _dateDebut!.day,
        );
        if (_dateFin != null) {
          final fin = DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day);
          return !day.isBefore(debut) && !day.isAfter(fin);
        }
        return day == debut;
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (e) =>
                e.referenceBouteille.toLowerCase().contains(q) ||
                e.id.toLowerCase().contains(q) ||
                e.codeFournisseur.toLowerCase().contains(q) ||
                e.gouvernorat.toLowerCase().contains(q) ||
                (e.variete?.toLowerCase().contains(q) ?? false) ||
                (e.collecteurNom?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    return result;
  }

  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  bool get _anyFilter => _dateDebut != null || _searchQuery.isNotEmpty;

  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        onApply: (d, f) => setState(() {
          _dateDebut = d;
          _dateFin = f;
        }),
        onClear: () => setState(() {
          _dateDebut = null;
          _dateFin = null;
        }),
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
    final arrivesCount = achats.where((e) => e.stockArrive).length;
    final enTransitCount = achats.where((e) => !e.stockArrive).length;

    return Scaffold(
      backgroundColor: _cream,
      drawer: CeoDrawer(
        onEchantillons: () => _goTo(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () =>
            _goTo(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoireCeoPage()),
        onAchatsConfirmes: () => _goTo(const AchatsConfirmesCeoPage()),
        onTableauDeBord: () => Navigator.pop(context),
        onProfil: () => _goTo(const ProfilceoPage()),
        onutilisiateurs: () => _goTo(const UtilisateursCeoPage()),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Achats confirmés',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          DateFilterButton(
            dateDebut: _dateDebut,
            dateFin: _dateFin,
            onTap: _showDateFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (v) => setState(() => _searchQuery = v),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _StatPill(
                  value: achats.length.toString(),
                  label: 'Total',
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 10),
                _StatPill(
                  value: arrivesCount.toString(),
                  label: 'Stock arrivé',
                  color: _green,
                ),
                const SizedBox(width: 10),
                _StatPill(
                  value: enTransitCount.toString(),
                  label: 'En transit',
                  color: Colors.orange.shade700,
                ),
                if (_anyFilter) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _dateDebut = null;
                        _dateFin = null;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_off_outlined,
                          size: 13,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Effacer filtres',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: achats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.handshake_outlined,
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun achat confirmé',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
                    itemCount: achats.length,
                    itemBuilder: (_, i) {
                      final e = achats[i];
                      final accentColor = e.stockArrive
                          ? _green
                          : Colors.orange.shade700;
                      final tintColor = e.stockArrive
                          ? const Color(0xFFEAF4EE)
                          : const Color(0xFFFFF3E0);

                      // ✅ ADDED: read expanded state for this card
                      final achatExp = _expandedAchat.contains(e.id);

                      return BaseSampleCard(
                        referenceBouteille: e.referenceBouteille,
                        id: e.id,
                        tintColor: tintColor,
                        badge: CardBadgeRow(
                          badges: [
                            if (e.quantiteCibleT != null)
                              CardBadge(
                                label: '${e.quantiteCibleT}T',
                                color: _olive,
                              ),
                            CardBadge(
                              label: e.stockArrive ? 'Arrivé' : 'En transit',
                              color: accentColor,
                            ),
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
                          if (e.variete != null)
                            DetailItem('Variété', e.variete!),
                          if (e.collecteurNom != null)
                            DetailItem('Collecteur', e.collecteurNom!),
                          DetailItem('Date enregistrement', e.dateAjout),
                        ],
                        deliveryWidget: SampleDeliveryIndicator(e: e),
                        bottomSection: _AchatSection(
                          echantillon: e,
                          accentColor: accentColor,
                          isExpanded: achatExp,
                          onToggle: () => setState(
                            () => achatExp
                                ? _expandedAchat.remove(e.id)
                                : _expandedAchat.add(e.id),
                          ),
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
// ACHAT SECTION  — ✅ CHANGED: now collapsible with toggle row + chevron icon
// ─────────────────────────────────────────────────────────────────────────────
class _AchatSection extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final Color accentColor;
  // ✅ ADDED: collapse state props
  final bool isExpanded;
  final VoidCallback onToggle;

  const _AchatSection({
    required this.echantillon,
    required this.accentColor,
    // ✅ ADDED
    required this.isExpanded,
    // ✅ ADDED
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    // ✅ CHANGED: wrap content in Column with toggle row + AnimatedCrossFade
    return Column(
      children: [
        // ✅ ADDED: tappable toggle row (mirrors _PanelSection / _RapportSection)
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // ✅ ADDED: contextual icon based on stock status
                Icon(
                  e.stockArrive
                      ? Icons.inventory_2_outlined
                      : Icons.local_shipping_outlined,
                  size: 13,
                  color: accentColor,
                ),
                const SizedBox(width: 6),
                // ✅ ADDED: label
                Text(
                  'Détails de l\'achat',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                // ✅ ADDED: animated chevron
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

        // ✅ ADDED: collapsible content panel
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _AchatDetails(echantillon: e, accentColor: accentColor),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACHAT DETAILS  — ✅ ADDED: extracted content (was inline in _AchatSection)
// ─────────────────────────────────────────────────────────────────────────────
class _AchatDetails extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final Color accentColor;
  const _AchatDetails({required this.echantillon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails de l\'achat',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _olive,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 20,
            runSpacing: 10,
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
                  e.stockArrive
                      ? Icons.inventory_2_rounded
                      : Icons.local_shipping_outlined,
                  size: 14,
                  color: accentColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.stockArrive
                        ? 'Stock arrivé en entrepôt${e.dateLivraisonStock != null ? " — ${e.dateLivraisonStock}" : ""}'
                        : 'En transit${e.dateLivraisonStock != null ? " — Livraison prévue : ${e.dateLivraisonStock}" : ""}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
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
                Icon(
                  Icons.notes_outlined,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    e.noteInterne!,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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

// ─────────────────────────────────────────────────────────────────────────────
// STAT PILL  — unchanged
// ─────────────────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}
