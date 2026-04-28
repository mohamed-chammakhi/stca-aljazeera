// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/echantillons/echantillons_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:project3/core/utils/date_utils.dart';
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
import '../tableau_de_bord/tableau_de_bord.dart';

// ── Reusable widget imports ──────────────────────────────────────────────────
import '../widgets/search_date_filter_bar.dart';
import '../widgets/sample_card_echantillon.dart';


String _initials(String name) {
  final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

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
  DateFilterType _dateType = DateFilterType.enregistrement;
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
  String? _dateFieldFor(EchantillonCeoView e) {
    switch (_dateType) {
      case DateFilterType.enregistrement:
        return e.dateAjout;
      case DateFilterType.livraisonEchantillon:
        return e.dateArriveeEchantillon ?? e.dateLivraisonPrevue;
      case DateFilterType.arriveeStock:
        return e.dateLivraisonStock;
    }
  }

  List<EchantillonCeoView> _applyFilters(List<EchantillonCeoView> list) {
    var result = list;

    if (_dateDebut != null) {
      result = result.where((e) {
        final raw = _dateFieldFor(e);
        if (raw == null) return false;
        final d = DegDateUtils.parseDate(raw);
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

  DateTime? DegDateUtils.parseDate(String s) {
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
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        availableTypes: DateFilterType.values,
        initialType: _dateType,
        onApply: (debut, fin) => setState(() {
          _dateDebut = debut;
          _dateFin = fin;
        }),
        onApplyTyped: (debut, fin, type) => setState(() {
          _dateDebut = debut;
          _dateFin = fin;
          _dateType = type;
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

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;
  bool get _anyFilter => _dateFilterActive || _searchQuery.isNotEmpty;

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final groups = _groups;

    return Scaffold(
      backgroundColor: kBg,
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
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Échantillons',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),
        iconTheme: const IconThemeData(color: kDark),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _dateFilterActive ? kGreen : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: _dateFilterActive
                    ? 'Filtré par : ${_dateType.label}'
                    : 'Filtrer par date',
              ),
              if (_dateFilterActive)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kGreen,
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
            color: kHeaderBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              style: const TextStyle(fontSize: 14, color: kDark),
              decoration: InputDecoration(
                hintText:
                    'Réf, fournisseur, gouvernorat, variété, collecteur…',
                hintStyle: const TextStyle(
                  color: Color(0xFF6B8E7A),
                  fontSize: 11,
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
                  borderSide: const BorderSide(color: kGreen, width: 1.5),
                ),
              ),
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── Stats strip ──────────────────────────────────────────────
          Container(
            color: kBg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 13,
                  color: Color.fromARGB(255, 156, 156, 156),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_totalFiltered échantillon${_totalFiltered > 1 ? "s" : ""}'
                  ' — ${groups.length} collecteur${groups.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 156, 156, 156),
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
            color: kGreen.withValues(alpha: 0.06),
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
                          : kGreen.withValues(alpha: 0.05),
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
                      color: group.isInterne ? Colors.purple.shade300 : kGreen,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: group.isInterne
                            ? Colors.purple.shade50
                            : kGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: group.isInterne
                            ? Icon(
                                Icons.business_outlined,
                                size: 16,
                                color: Colors.purple.shade400,
                              )
                            : Text(
                                _initials(group.displayName),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: kGreen,
                                ),
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
                              color: kDark,
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
    backgroundColor: kBg,
    appBar: AppBar(
      backgroundColor: kGreen,
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


