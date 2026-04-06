// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/echantillons/echantillons_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../utilisateurs/models/echantillon_ceo_view.dart';
import 'echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../utilisateurs/models/mock_data_patch.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../../main.dart';
import '../profil_ceo_page.dart';
import '../homepage/homepage_ceo_page.dart';

// ── Reusable widget imports ──────────────────────────────────────────────────
import '../widgets/search_date_filter_bar.dart';
import '../widgets/sample_card_widgets.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _dark = Color(0xFF1A2E1F);

// ─────────────────────────────────────────────────────────────────────────────
// COLLECTEUR GROUP MODEL  (local to this page)
// ─────────────────────────────────────────────────────────────────────────────
class _CollecteurGroup {
  final String? collecteurNom;
  final String? collecteurId;
  final List<EchantillonCeoView> echantillons;

  _CollecteurGroup({
    this.collecteurNom,
    this.collecteurId,
    required this.echantillons,
  });

  bool get isInterne => collecteurNom == null;
  String get displayName => collecteurNom ?? 'Ajoutés en interne';
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────
class EchantillonsCeoPage extends StatefulWidget {
  const EchantillonsCeoPage({super.key});

  @override
  State<EchantillonsCeoPage> createState() => _EchantillonsCeoPageState();
}

class _EchantillonsCeoPageState extends State<EchantillonsCeoPage> {
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Set<String> _expandedCollecteurs = {};
  final Set<String> _expandedSamples = {};

  List<EchantillonCeoView> get _allEchantillons => mockEchantillons;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Filtering ──────────────────────────────────────────────────────────────
  List<EchantillonCeoView> _applyFilters(List<EchantillonCeoView> list) {
    var result = list;

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
      result = result.where((e) {
        return e.referenceBouteille.toLowerCase().contains(q) ||
            e.codeFournisseur.toLowerCase().contains(q) ||
            e.id.toLowerCase().contains(q) ||
            e.gouvernorat.toLowerCase().contains(q) ||
            (e.variete?.toLowerCase().contains(q) ?? false) ||
            (e.collecteurNom?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  List<_CollecteurGroup> get _groups {
    final filtered = _applyFilters(_allEchantillons);
    final Map<String, List<EchantillonCeoView>> byCollecteur = {};

    for (final e in filtered) {
      final key = e.collecteurNom ?? '__interne__';
      byCollecteur.putIfAbsent(key, () => []).add(e);
    }

    final List<_CollecteurGroup> groups = [];
    final collecteurKeys =
        byCollecteur.keys.where((k) => k != '__interne__').toList()..sort();

    for (final key in collecteurKeys) {
      groups.add(
        _CollecteurGroup(
          collecteurNom: key,
          collecteurId: key.replaceAll(' ', '_').toLowerCase(),
          echantillons: byCollecteur[key]!,
        ),
      );
    }

    if (byCollecteur.containsKey('__interne__')) {
      groups.add(
        _CollecteurGroup(
          collecteurNom: null,
          echantillons: byCollecteur['__interne__']!,
        ),
      );
    }

    return groups;
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

  // ── Date filter sheet ──────────────────────────────────────────────────────
  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        // ← from search_date_filter_bar.dart
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        onApply: (debut, fin) => setState(() {
          _dateDebut = debut;
          _dateFin = fin;
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

  int get _totalFiltered =>
      _groups.fold(0, (sum, g) => sum + g.echantillons.length);

  bool get _dateActive => _dateDebut != null;
  bool get _anyFilter => _dateActive || _searchQuery.isNotEmpty;

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final groups = _groups;

    return Scaffold(
      backgroundColor: _cream,
      drawer: CeoDrawer(
        onEchantillons: () => _goTo(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () =>
            _goTo(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoireCeoPage()),
        onAchatsConfirmes: () => _goTo(const AchatsConfirmesCeoPage()),
        onTableauDeBord: () => _goTo(const HomePageCeo()),
        onProfil: () => _goTo(const ProfilceoPage()),
        onutilisiateurs: () => _goTo(const UtilisateursCeoPage()),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Échantillons',
          style: GoogleFonts.domine(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          DateFilterButton(
            // ← from search_date_filter_bar.dart
            dateDebut: _dateDebut,
            dateFin: _dateFin,
            onTap: _showDateFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────
          SearchBarWidget(
            // ← from search_date_filter_bar.dart
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (v) => setState(() => _searchQuery = v),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),

          // ── Stats strip ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_totalFiltered échantillon${_totalFiltered > 1 ? "s" : ""}'
                  ' — ${groups.length} collecteur${groups.length > 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
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
                            fontSize: 11,
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

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: groups.isEmpty
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
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                    itemCount: groups.length,
                    itemBuilder: (_, i) => _CollecteurSection(
                      group: groups[i],
                      isExpanded: _expandedCollecteurs.contains(
                        groups[i].displayName,
                      ),
                      expandedSamples: _expandedSamples,
                      onToggleCollecteur: () => setState(() {
                        final key = groups[i].displayName;
                        _expandedCollecteurs.contains(key)
                            ? _expandedCollecteurs.remove(key)
                            : _expandedCollecteurs.add(key);
                      }),
                      onToggleSample: (id) => setState(() {
                        _expandedSamples.contains(id)
                            ? _expandedSamples.remove(id)
                            : _expandedSamples.add(id);
                      }),
                      onViewMap: groups[i].isInterne
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _CarteGeoPlaceholder(
                                  collecteurNom: groups[i].displayName,
                                ),
                              ),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLLECTEUR SECTION  (page-specific, not extracted)
// ─────────────────────────────────────────────────────────────────────────────
class _CollecteurSection extends StatelessWidget {
  final _CollecteurGroup group;
  final bool isExpanded;
  final Set<String> expandedSamples;
  final VoidCallback onToggleCollecteur;
  final void Function(String id) onToggleSample;
  final VoidCallback? onViewMap;

  const _CollecteurSection({
    required this.group,
    required this.isExpanded,
    required this.expandedSamples,
    required this.onToggleCollecteur,
    required this.onToggleSample,
    this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          GestureDetector(
            onTap: onToggleCollecteur,
            behavior: HitTestBehavior.opaque,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(14),
                bottom: isExpanded ? Radius.zero : const Radius.circular(14),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      group.isInterne
                          ? Colors.purple.shade50.withValues(alpha: 0.5)
                          : _green.withValues(alpha: 0.05),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 58,
                      color: group.isInterne ? Colors.purple.shade300 : _green,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: group.isInterne
                            ? Colors.purple.shade50
                            : _green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          group.isInterne
                              ? Icons.business_outlined
                              : Icons.person_outline,
                          size: 16,
                          color: group.isInterne
                              ? Colors.purple.shade400
                              : _green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.displayName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _dark,
                            ),
                          ),
                          Text(
                            '${group.echantillons.length} échantillon${group.echantillons.length > 1 ? "s" : ""}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onViewMap != null) ...[
                      GestureDetector(
                        onTap: onViewMap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 12,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Carte',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          ),

          // Expandable sample list
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(color: Colors.grey.shade100, height: 1),
                ...group.echantillons.asMap().entries.map(
                  (entry) => SampleRow(
                    // ← from sample_card_widgets.dart
                    echantillon: entry.value,
                    isExpanded: expandedSamples.contains(entry.value.id),
                    isOdd: entry.key.isOdd,
                    isLast: entry.key == group.echantillons.length - 1,
                    onToggle: () => onToggleSample(entry.value.id),
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARTE GEO PLACEHOLDER
// ─────────────────────────────────────────────────────────────────────────────
class _CarteGeoPlaceholder extends StatelessWidget {
  final String collecteurNom;
  const _CarteGeoPlaceholder({required this.collecteurNom});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _cream,
    appBar: AppBar(
      backgroundColor: _green,
      elevation: 0,
      title: Text(
        collecteurNom,
        style: GoogleFonts.domine(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(
            'Carte géographique',
            style: GoogleFonts.domine(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Connecter CarteGeoPage ici',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    ),
  );
}
