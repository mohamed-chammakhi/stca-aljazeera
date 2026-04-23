// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../utilisateurs/models/echantillon_ceo_view.dart';
import '../utilisateurs/widgets/analyse_labo_sheet.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import 'analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../profil_ceo_page.dart';
import '../../main.dart';
import '../utilisateurs/models/mock_data_patch.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../widgets/search_date_filter_bar.dart';
import '../widgets/sample_card_echantillon.dart';
import '../widgets/base_sample_card.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _bg = Color.fromARGB(255, 255, 255, 255);
const Color _teal = Color(0xFF00796B);
const Color _olive = Color(0xFF6B8143);

// ─────────────────────────────────────────────────────────────────────────────
class AnalyseLaboratoireCeoPage extends StatefulWidget {
  const AnalyseLaboratoireCeoPage({super.key});
  @override
  State<AnalyseLaboratoireCeoPage> createState() =>
      _AnalyseLaboratoireCeoPageState();
}

class _AnalyseLaboratoireCeoPageState extends State<AnalyseLaboratoireCeoPage> {
  final Set<String> _expandedRapport = {};

  // ── ADDED: active filter state (mirrors achats confirmes pattern) ──────────
  String _activeFilter = 'tout';

  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<EchantillonCeoView> get _allSamples => mockEchantillonsLabo;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EchantillonCeoView> get _samples {
    var result = _allSamples;
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
                (e.collecteurNom?.toLowerCase().contains(q) ?? false) ||
                (e.analyse?.classificationAuto.toLowerCase().contains(q) ??
                    false),
          )
          .toList();
    }
    // ── ADDED: apply status filter ────────────────────────────────────────────
    if (_activeFilter == 'Analyse soumise') {
      result = result.where((e) => e.analyse != null).toList();
    } else if (_activeFilter == 'Analyse en attente') {
      result = result.where((e) => e.analyse == null).toList();
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

  Color _classifColor(String c) {
    if (c == 'Extra Vierge') return _green;
    if (c == 'Vierge') return Colors.orange.shade700;
    if (c == 'Lampante') return Colors.red.shade600;
    return Colors.grey.shade500;
  }

  Color _headerTint(bool hasAnalyse, String classif) {
    if (!hasAnalyse) return const Color(0xFFFAF0E6);
    if (classif == 'Extra Vierge') return const Color(0xFFEAF4EE);
    if (classif == 'Vierge') return const Color(0xFFFFF3E0);
    if (classif == 'Lampante') return const Color(0xFFFFEBEE);
    return const Color(0xFFF5F5F5);
  }

  @override
  Widget build(BuildContext context) {
    final samples = _samples;
    return Scaffold(
      backgroundColor: _bg,
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
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Analyse laboratoire',
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
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // ── Unified header zone ──────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              style: const TextStyle(fontSize: 14, color: _dark),
              decoration: InputDecoration(
                hintText: 'Rechercher réf, fournisseur, gouvernorat…',
                hintStyle: const TextStyle(
                  color: Color(0xFF6B8E7A),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF6B8E7A),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 17,
                          color: Color(0xFF6B8E7A),
                        ),
                        onPressed: () => setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _green, width: 1.5),
                ),
              ),
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── CHANGED: filter chips strip (replaces old stats strip) ───────────
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
                  label: 'Analyse soumise',
                  isActive: _activeFilter == 'Analyse soumise',
                  activeBg: _green.withValues(alpha: 0.12),
                  activeFg: _green,
                  onTap: () =>
                      setState(() => _activeFilter = 'Analyse soumise'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Analyse en attente',
                  isActive: _activeFilter == 'Analyse en attente',
                  activeBg: Colors.orange.shade700.withValues(alpha: 0.12),
                  activeFg: Colors.orange.shade700,
                  onTap: () =>
                      setState(() => _activeFilter = 'Analyse en attente'),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: samples.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Aucun échantillon trouvé',
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
                    itemCount: samples.length,
                    itemBuilder: (_, i) {
                      final e = samples[i];
                      final hasAnalyse = e.analyse != null;
                      final classif = e.analyse?.classificationAuto ?? '—';
                      final classifColor = _classifColor(classif);
                      final rapportExp = _expandedRapport.contains(e.id);

                      return BaseSampleCard(
                        referenceBouteille: e.referenceBouteille,
                        id: e.id,
                        tintColor: _headerTint(hasAnalyse, classif),
                        accentColor: _teal,
                        badge: CardBadgeRow(
                          badges: [
                            if (e.quantiteEstimee != null)
                              CardBadge(
                                label: 'Qté : ${e.quantiteEstimee}T',
                                color: _olive,
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
                          if (e.quantiteEstimee != null)
                            DetailItem('Quantité', '${e.quantiteEstimee} T'),
                          DetailItem('Date ajout', e.dateAjout),
                          if (e.collecteurNom != null)
                            DetailItem('Collecteur', e.collecteurNom!),
                          DetailItem(
                            'Reçu physiquement',
                            e.recuPhysiquement ? 'Oui' : 'Non',
                          ),
                        ],
                        deliveryWidget: SampleDeliveryIndicator(e: e),
                        bottomSection: _RapportSection(
                          echantillon: e,
                          hasAnalyse: hasAnalyse,
                          isExpanded: rapportExp,
                          onToggle: () => setState(
                            () => rapportExp
                                ? _expandedRapport.remove(e.id)
                                : _expandedRapport.add(e.id),
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
// FILTER CHIP  — shared pattern across pages
// Active "Tout"    → solid gray (#757575) bg + white text
// Active status    → tinted bg + colored text
// Inactive any     → light gray bg + gray text
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBg;
  final Color activeFg;
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

    final bg = isActive ? activeBg : inactiveBg;
    final fg = isActive ? activeFg : inactiveFg;
    final borderColor = isActive
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
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RAPPORT SECTION  — bottom slot for labo cards
// ─────────────────────────────────────────────────────────────────────────────
class _RapportSection extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final bool hasAnalyse;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _RapportSection({
    required this.echantillon,
    required this.hasAnalyse,
    required this.isExpanded,
    required this.onToggle,
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
                  Icons.biotech_outlined,
                  size: 13,
                  color: hasAnalyse ? _teal : Colors.grey.shade300,
                ),
                const SizedBox(width: 6),
                Text(
                  'Rapport laboratoire',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasAnalyse ? _teal : Colors.grey.shade300,
                  ),
                ),
                const Spacer(),
                if (hasAnalyse && e.analyse!.dateAnalyse != null)
                  Text(
                    e.analyse!.dateAnalyse!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: hasAnalyse ? _teal : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: hasAnalyse
              ? _RapportBlock(analyse: e.analyse!)
              : _EnAttenteHint(),
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
// RAPPORT BLOCK
// ─────────────────────────────────────────────────────────────────────────────
class _RapportBlock extends StatelessWidget {
  final AnalyseLaboCeoView analyse;
  const _RapportBlock({required this.analyse});

  Color _classifColor(String c) {
    if (c == 'Extra Vierge') return const Color(0xFF38835A);
    if (c == 'Vierge') return Colors.orange.shade700;
    if (c == 'Lampante') return Colors.red.shade600;
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final a = analyse;
    final classifColor = _classifColor(a.classificationAuto);
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
          Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 13,
                color: classifColor,
              ),
              const SizedBox(width: 5),
              Text(
                a.classificationAuto,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: classifColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 8),
          if (a.aciditeLibre != null)
            _AnalRow(
              'Acidité libre',
              '${a.aciditeLibre!.toStringAsFixed(2)} %',
              norm: '≤ 0.80',
              warn: a.aciditeLibre! > 0.8,
            ),
          if (a.indicePeroxyde != null)
            _AnalRow(
              'Indice de peroxyde',
              '${a.indicePeroxyde!.toStringAsFixed(1)} meqO₂/kg',
              norm: '≤ 20',
              warn: a.indicePeroxyde! > 20,
            ),
          if (a.k232 != null)
            _AnalRow(
              'K₂₃₂',
              a.k232!.toStringAsFixed(2),
              norm: '≤ 2.50',
              warn: a.k232! > 2.50,
            ),
          if (a.k270 != null)
            _AnalRow(
              'K₂₇₀',
              a.k270!.toStringAsFixed(2),
              norm: '≤ 0.22',
              warn: a.k270! > 0.22,
            ),
          if (a.deltaK != null)
            _AnalRow(
              'ΔK',
              a.deltaK!.toStringAsFixed(3),
              norm: '≤ 0.01',
              warn: a.deltaK! > 0.01,
            ),
          if (a.polyphenolsTotaux != null)
            _AnalRow(
              'Polyphénols totaux',
              '${a.polyphenolsTotaux!.toStringAsFixed(0)} mg/kg',
            ),
          if (a.humidite != null)
            _AnalRow(
              'Humidité',
              '${a.humidite!.toStringAsFixed(2)} %',
              norm: '≤ 0.20',
              warn: a.humidite! > 0.2,
            ),
          if (a.acideOleique != null)
            _AnalRow(
              'Acide oléique',
              '${a.acideOleique!.toStringAsFixed(1)} %',
            ),
          if (a.notes != null && a.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Notes : ${a.notes}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalRow extends StatelessWidget {
  final String label, value;
  final String? norm;
  final bool warn;
  const _AnalRow(this.label, this.value, {this.norm, this.warn = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              if (norm != null)
                Text(
                  'Norme : $norm',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
            ],
          ),
        ),
        if (warn)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 13,
              color: Colors.red.shade400,
            ),
          ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: warn ? Colors.red.shade600 : _dark,
          ),
        ),
      ],
    ),
  );
}

class _EnAttenteHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange.shade100),
    ),
    child: Row(
      children: [
        Text(
          'Analyse non encore soumise',
          style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
        ),
      ],
    ),
  );
}
