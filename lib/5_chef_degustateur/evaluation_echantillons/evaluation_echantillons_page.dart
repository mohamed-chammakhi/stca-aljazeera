// ═════════════════════════════════════════════════════════════════════════════
// FILE    : evaluation_echantillons/evaluation_echantillons_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, navigation
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Page imports ──────────────────────────────────────────────────────────────
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../widgets/statut_chip.dart';
import '../membres_panel/membres_panel_page.dart';
import '../../../main.dart';
import '../profil.dart';

import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../formulaire_evaluation.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart';

// ── Own model ─────────────────────────────────────────────────────────────────
import 'navigation/models/echantillon.dart';
import 'navigation/models/mock_echantillons.dart';

// ── Own widgets ───────────────────────────────────────────────────────────────
import 'navigation/widgets/echantillon_card.dart';
import 'navigation/widgets/empty_state.dart';
import '../gestion_echantillons/widgets/search_filter_bar.dart';

class EvaluationEchantillonsPage extends StatefulWidget {
  const EvaluationEchantillonsPage({super.key});

  @override
  _EvaluationEchantillonsPageState createState() =>
      _EvaluationEchantillonsPageState();
}

class _EvaluationEchantillonsPageState
    extends State<EvaluationEchantillonsPage> {
  // ── COLORS ──────────────────────────────────────────────────────────────────
  static const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
  static const Color _green = Color(0xFF38835A);
  static const Color _dark = Color(0xFF1A2E1F);
  static const Color _bg = Color.fromARGB(255, 255, 255, 255);

  // ── STATE ────────────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';
  String? _filtreStatutLabel;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;
  bool get _anyFilter =>
      _dateFilterActive || _recherche.isNotEmpty || _filtreStatutLabel != null;

  // ── DATA ──────────────────────────────────────────────────────────────────────
  late final List<Echantillon> _echantillons = List.from(
    mockEchantillonsEvaluation,
  );

  // ── NAVIGATION ───────────────────────────────────────────────────────────────
  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  // ── FILTER LOGIC ─────────────────────────────────────────────────────────────
  StatutEchantillon? _labelToStatut(String? label) {
    switch (label) {
      case 'Non évaluée':
        return StatutEchantillon.enAttente;
      case 'Évaluation en cours':
        return StatutEchantillon.enCours;
      case 'Évaluation soumise':
        return StatutEchantillon.soumis;
      default:
        return null;
    }
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

  List<Echantillon> get _echantillonsFiltres {
    return _echantillons.where((e) {
      final q = _recherche.toLowerCase();
      final matchRecherche =
          _recherche.isEmpty ||
          e.id.toLowerCase().contains(q) ||
          e.ref.toLowerCase().contains(q) ||
          e.fournisseur.toLowerCase().contains(q) ||
          e.variete.toLowerCase().contains(q) ||
          (e.gouvernorat?.toLowerCase().contains(q) ?? false) ||
          (e.delegation?.toLowerCase().contains(q) ?? false) ||
          (e.collecteur?.toLowerCase().contains(q) ?? false);

      final filtreEnum = _labelToStatut(_filtreStatutLabel);
      final matchStatut = filtreEnum == null || e.statut == filtreEnum;

      bool matchDate = true;
      if (_dateFilterActive) {
        final raw = _parseDate(e.date);
        if (raw == null) {
          matchDate = false;
        } else {
          final d = DateTime(raw.year, raw.month, raw.day);
          final debut = _dateDebut != null
              ? DateTime(_dateDebut!.year, _dateDebut!.month, _dateDebut!.day)
              : null;
          final fin = _dateFin != null
              ? DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day)
              : null;
          if (debut != null && fin != null) {
            matchDate = !d.isBefore(debut) && !d.isAfter(fin);
          } else if (debut != null) {
            matchDate = !d.isBefore(debut);
          } else if (fin != null) {
            matchDate = !d.isAfter(fin);
          }
        }
      }

      return matchRecherche && matchStatut && matchDate;
    }).toList();
  }

  // ── ACTION ────────────────────────────────────────────────────────────────────

  Future<void> _onActionEchantillon(Echantillon e) async {
    if (e.statut == StatutEchantillon.enAttente) {
      setState(() => e.statut = StatutEchantillon.enCours);
    }

    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FormulaireEvaluationPage(
          echantillonId: e.id,
          fournisseur: e.fournisseur,
          variete: e.variete,
          origine: e.gouvernorat ?? 'Non spécifiée',
          dateArrivee: e.date,
          photoUrl: e.photoUrl,
        ),
      ),
    );

    // result is classification label when submitted, null if just navigated back
    if (result != null && mounted) {
      setState(() {
        e.statut = StatutEchantillon.soumis;
        e.classification = result;
      });
    }
  }

  void _onVoir(Echantillon e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormulaireEvaluationPage(
          echantillonId: e.id,
          fournisseur: e.fournisseur,
          variete: e.variete,
          origine: e.gouvernorat ?? 'Non spécifiée',
          dateArrivee: e.date,
          photoUrl: e.photoUrl,
          readOnly: true,
          classification: e.classification,
        ),
      ),
    );
  }

  // ── Date filter sheet ─────────────────────────────────────────────────────────
  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtres = _echantillonsFiltres;

    return Scaffold(
      backgroundColor: _bg,

      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onVueEnsembleEvaluations: () =>
            _goTo(const VueEnsembleEvaluationsPage()),
        onProfil: () => _goTo(const ProfilePage()),
        onDeconnexion: _goToLogin,
      ),

      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Évaluation des échantillons',
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
                  color: _dateFilterActive ? _green : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: 'Filtrer par date',
              ),
              if (_dateFilterActive)
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
          // ── UNIFIED HEADER ZONE ────────────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _recherche = v.trim()),
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
                    suffixIcon: _recherche.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 17,
                              color: Color(0xFF6B8E7A),
                            ),
                            onPressed: () => setState(() {
                              _recherche = '';
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

                const SizedBox(height: 11),

                // ── Statut filter chips ─────────────────────────────────────
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      StatutChip(
                        label: 'Tous',
                        activeColor: const Color(0xFF616161),
                        inactiveColor: const Color(0xFFF0F0F0),
                        inactiveTextColor: const Color(0xFF757575),
                        selected: _filtreStatutLabel == null,
                        onTap: () => setState(() => _filtreStatutLabel = null),
                      ),
                      const SizedBox(width: 7),
                      StatutChip(
                        label: 'Non évaluée',
                        activeColor: const Color(0xFF3A6EA5),
                        inactiveColor: const Color(0xFFE8F1FB),
                        inactiveTextColor: const Color(0xFF3A6EA5),
                        selected: _filtreStatutLabel == 'Non évaluée',
                        onTap: () =>
                            setState(() => _filtreStatutLabel = 'Non évaluée'),
                      ),
                      const SizedBox(width: 7),
                      StatutChip(
                        label: 'Évaluation en cours',
                        activeColor: const Color(0xFFD07B2F),
                        inactiveColor: const Color(0xFFFEF3E8),
                        inactiveTextColor: const Color(0xFFD07B2F),
                        selected: _filtreStatutLabel == 'Évaluation en cours',
                        onTap: () => setState(
                          () => _filtreStatutLabel = 'Évaluation en cours',
                        ),
                      ),
                      const SizedBox(width: 7),
                      StatutChip(
                        label: 'Évaluation soumise',
                        activeColor: const Color(0xFF38835A),
                        inactiveColor: const Color(0xFFE6F4ED),
                        inactiveTextColor: const Color(0xFF38835A),
                        selected: _filtreStatutLabel == 'Évaluation soumise',
                        onTap: () => setState(
                          () => _filtreStatutLabel = 'Évaluation soumise',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Thin separator shadow
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── STATS STRIP ────────────────────────────────────────────────────
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 13,
                  color: const Color.fromARGB(255, 156, 156, 156),
                ),
                const SizedBox(width: 6),
                Text(
                  '${filtres.length} échantillon${filtres.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 156, 156, 156),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── LIST ────────────────────────────────────────────────────────────
          Expanded(
            child: filtres.isEmpty
                ? const EmptyState()
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: filtres.length,
                      itemBuilder: (context, index) {
                        final e = filtres[index];
                        return EchantillonCard(
                          echantillon: e,
                          onAction: () => _onActionEchantillon(e),
                          onVoir: () => _onVoir(e),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUT CHIP — soft pastel inactive, solid color active
