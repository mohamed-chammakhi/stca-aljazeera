// ═════════════════════════════════════════════════════════════════════════════
// FILE    : evaluation_echantillons/evaluation_echantillons_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, navigation
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Page imports ──────────────────────────────────────────────────────────────
import '../homepage/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../../../main.dart';
import '../profil.dart';

import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../formulaire_evaluation.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';

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
  static const Color _green = Color(0xFF38835A);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _dark  = Color(0xFF1A2E1F);

  // ── STATE ────────────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String  _recherche        = '';
  String? _filtreStatutLabel;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;
  bool get _anyFilter =>
      _dateFilterActive || _recherche.isNotEmpty || _filtreStatutLabel != null;

  // ── DATA ──────────────────────────────────────────────────────────────────────
  late final List<Echantillon> _echantillons =
      List.from(mockEchantillonsEvaluation);

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
      case 'En attente': return StatutEchantillon.enAttente;
      case 'En cours':   return StatutEchantillon.enCours;
      case 'Soumis':     return StatutEchantillon.soumis;
      default:           return null;
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
      final matchRecherche = _recherche.isEmpty ||
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
          final d     = DateTime(raw.year, raw.month, raw.day);
          final debut = _dateDebut != null
              ? DateTime(_dateDebut!.year, _dateDebut!.month, _dateDebut!.day)
              : null;
          final fin   = _dateFin != null
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
          fournisseur:   e.fournisseur,
          variete:       e.variete,
          origine:       e.gouvernorat ?? 'Non spécifiée',
          dateArrivee:   e.date,
          photoUrl:      e.photoUrl,
        ),
      ),
    );

    // result is classification label when submitted, null if just navigated back
    if (result != null && mounted) {
      setState(() {
        e.statut         = StatutEchantillon.soumis;
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
          fournisseur:   e.fournisseur,
          variete:       e.variete,
          origine:       e.gouvernorat ?? 'Non spécifiée',
          dateArrivee:   e.date,
          photoUrl:      e.photoUrl,
          readOnly:      true,
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
        dateFin:   _dateFin,
        onApply: (debut, fin) => setState(() {
          _dateDebut = debut;
          _dateFin   = fin;
        }),
        onClear: () => setState(() {
          _dateDebut = null;
          _dateFin   = null;
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
      backgroundColor: _cream,

      drawer: AppDrawer(
        onaccueil:                 () => Navigator.pop(context),
        onEvaluationEchantillons:  () => _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons:     () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire:      () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel:           () => _goTo(const MembresPanelPage()),
        onProfil:                  () => _goTo(const ProfilePage()),
        onAPropos:                 () => Navigator.pop(context),
        onDeconnexion:             _goToLogin,
      ),

      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Évaluation des échantillons',
          style: GoogleFonts.domine(
            fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
          ),
        ),
        actions: [
          DateFilterButton(
            dateDebut: _dateDebut,
            dateFin:   _dateFin,
            onTap:     _showDateFilter,
          ),
        ],
      ),

      body: Column(
        children: [

          // ── GREEN HEADER STRIP: search only ────────────────────────────────
          Container(
            color:   _green,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color:      _dark.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset:     const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _recherche = v.trim()),
                style: const TextStyle(fontSize: 13, color: _dark),
                decoration: InputDecoration(
                  hintText:  'Rechercher réf, fournisseur, gouvernorat…',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 150, 149, 149),
                  ),
                  prefixIcon: Icon(Icons.search, size: 17, color: Colors.grey.shade400),
                  suffixIcon: _recherche.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _recherche = '';
                            _searchController.clear();
                          }),
                          child: Icon(Icons.close, size: 17, color: Colors.grey.shade400),
                        )
                      : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
              ),
            ),
          ),

          // ── STATUT FILTER CHIPS (colored, outside header) ─────────────────
          Container(
            color:   Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _StatutChip(label: 'Tous',       color: _dark,                       selected: _filtreStatutLabel == null,         onTap: () => setState(() => _filtreStatutLabel = null)),
                  const SizedBox(width: 8),
                  _StatutChip(label: 'En attente', color: const Color(0xFF3A6EA5),     selected: _filtreStatutLabel == 'En attente', onTap: () => setState(() => _filtreStatutLabel = 'En attente')),
                  const SizedBox(width: 8),
                  _StatutChip(label: 'En cours',   color: const Color(0xFFD07B2F),     selected: _filtreStatutLabel == 'En cours',   onTap: () => setState(() => _filtreStatutLabel = 'En cours')),
                  const SizedBox(width: 8),
                  _StatutChip(label: 'Soumis',     color: const Color(0xFF38835A),     selected: _filtreStatutLabel == 'Soumis',     onTap: () => setState(() => _filtreStatutLabel = 'Soumis')),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade100, height: 1),

          // ── STATS STRIP ────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  '${filtres.length} échantillon${filtres.length > 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize:   12,
                    color:      Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_anyFilter) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _recherche        = '';
                      _searchController.clear();
                      _filtreStatutLabel = null;
                      _dateDebut         = null;
                      _dateFin           = null;
                    }),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_alt_off_outlined, size: 13, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Effacer filtres',
                          style: TextStyle(
                            fontSize:   11,
                            color:      Colors.red.shade500,
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
                          onVoir:   () => _onVoir(e),
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
// STATUT CHIP — colored pill on white background
// ─────────────────────────────────────────────────────────────────────────────
class _StatutChip extends StatelessWidget {
  final String       label;
  final Color        color;
  final bool         selected;
  final VoidCallback onTap;
  const _StatutChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:        selected ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(
          color: selected ? color : color.withValues(alpha: 0.3),
          width: selected ? 1.5 : 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      selected ? Colors.white : color,
        ),
      ),
    ),
  );
}
