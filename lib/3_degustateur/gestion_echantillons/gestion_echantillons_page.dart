// ═════════════════════════════════════════════════════════════════════════════
// FILE    : gestion_echantillons/gestion_echantillons_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, and actions
//
// SECTIONS :
//   1. COLORS
//   2. STATE        — search, statut filter, date range
//   3. NAVIGATION   — _goTo, _goToLogin
//   4. DATA         — from mock_echantillons.dart (replace with service later)
//   5. FILTER LOGIC — _filtres getter, _parseDate
//   6. ACTIONS      — add, edit, delete, snackbar
//   7. BUILD        — CEO-style appbar, header strip, chips, list
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/echantillon_gestion.dart';
import 'models/mock_echantillons.dart';
import 'widgets/echantillon_card.dart';
import 'widgets/empty_state.dart';
import 'widgets/dialogs/formulaire_dialog.dart';
import 'widgets/dialogs/suppression_dialog.dart';
import 'widgets/search_filter_bar.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../profil.dart';
import '../homepage/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../../../main.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';

class GestionEchantillonsPage extends StatefulWidget {
  const GestionEchantillonsPage({super.key});

  @override
  _GestionEchantillonsPageState createState() =>
      _GestionEchantillonsPageState();
}

class _GestionEchantillonsPageState extends State<GestionEchantillonsPage> {
  // ───────────────────────────────────────────────────────────────────────────
  // 1. COLORS
  // ───────────────────────────────────────────────────────────────────────────

  static const Color _green  = Color(0xFF38835A);
  static const Color _cream  = Color(0xFFF9F6EF);
  static const Color _dark   = Color(0xFF1A2E1F);

  // ───────────────────────────────────────────────────────────────────────────
  // 2. STATE
  // ───────────────────────────────────────────────────────────────────────────

  final TextEditingController _searchController = TextEditingController();
  String  _recherche   = '';
  String? _filtreStatut;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;
  bool get _anyFilter => _dateFilterActive || _recherche.isNotEmpty || _filtreStatut != null;

  // ───────────────────────────────────────────────────────────────────────────
  // 3. NAVIGATION
  // ───────────────────────────────────────────────────────────────────────────

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

  // ───────────────────────────────────────────────────────────────────────────
  // 4. DATA  — imported from mock_echantillons.dart
  //            TODO: replace with EchantillonService.fetch() when backend ready
  // ───────────────────────────────────────────────────────────────────────────

  // Use a copy so mutations (add/edit/delete) stay local to this widget
  late final List<EchantillonGestion> _echantillons =
      List.from(mockEchantillonsGestion);

  // ───────────────────────────────────────────────────────────────────────────
  // 5. FILTER LOGIC
  // ───────────────────────────────────────────────────────────────────────────

  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  List<EchantillonGestion> get _filtres {
    final liste = _echantillons.where((e) {
      final q = _recherche.toLowerCase();
      final matchRecherche = _recherche.isEmpty ||
          e.ref.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q) ||
          e.codeFournisseur.toLowerCase().contains(q) ||
          e.variete.toLowerCase().contains(q) ||
          e.gouvernorat.toLowerCase().contains(q) ||
          (e.delegation?.toLowerCase().contains(q) ?? false);

      final matchStatut = _filtreStatut == null || e.statut == _filtreStatut;

      bool matchDate = true;
      if (_dateFilterActive) {
        final raw = _parseDate(e.dateArrivee);
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

    return liste.reversed.toList();
  }

  int get _prochainNumero => _echantillons.length + 1;

  // ───────────────────────────────────────────────────────────────────────────
  // 6. ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  void _onAjouter(EchantillonGestion nouveau) {
    setState(() => _echantillons.add(nouveau));
    _showSuccess('Échantillon ajouté avec succès');
  }

  void _onModifier(EchantillonGestion modifie) {
    setState(() {});
    _showSuccess('Échantillon modifié avec succès');
  }

  void _onSupprimer(EchantillonGestion e) {
    setState(() => _echantillons.remove(e));
    _showSuccess('Échantillon ${e.id} supprimé');
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // ── Date filter sheet ──────────────────────────────────────────────────────

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

  // ───────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ───────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 7. BUILD
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final filtres = _filtres;

    return Scaffold(
      backgroundColor: _cream,

      // ── DRAWER ─────────────────────────────────────────────────────────────
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

      // ── APPBAR — CEO style: title + date filter button ──────────────────────
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Gestion des échantillons',
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

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireDialog(
          context,
          echantillon:    null,
          prochainNumero: _prochainNumero,
          onSave:         _onAjouter,
        ),
        backgroundColor: _green,
        icon:  const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [

          // ── GREEN HEADER STRIP: search only ──────────────────────────────
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

          // ── STATUT FILTER CHIPS (outside header, colored) ─────────────────
          Container(
            color:   Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _StatutChip(label: 'Tous',       color: _dark,                       selected: _filtreStatut == null,         onTap: () => setState(() => _filtreStatut = null)),
                  const SizedBox(width: 8),
                  _StatutChip(label: 'En attente', color: const Color(0xFF3A6EA5),     selected: _filtreStatut == 'En attente', onTap: () => setState(() => _filtreStatut = 'En attente')),
                  const SizedBox(width: 8),
                  _StatutChip(label: 'En cours',   color: const Color(0xFFD07B2F),     selected: _filtreStatut == 'En cours',   onTap: () => setState(() => _filtreStatut = 'En cours')),
                  const SizedBox(width: 8),
                  _StatutChip(label: 'Soumis',     color: const Color(0xFF38835A),     selected: _filtreStatut == 'Soumis',     onTap: () => setState(() => _filtreStatut = 'Soumis')),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade100, height: 1),

          // ── STATS STRIP ───────────────────────────────────────────────────
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
                      _recherche   = '';
                      _searchController.clear();
                      _filtreStatut = null;
                      _dateDebut    = null;
                      _dateFin      = null;
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

          // ── LIST ──────────────────────────────────────────────────────────
          Expanded(
            child: filtres.isEmpty
                ? const EmptyState()
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: filtres.length,
                      itemBuilder: (context, index) {
                        final e = filtres[index];
                        return EchantillonCard(
                          echantillon: e,
                          onModifier:  () => showFormulaireDialog(
                            context,
                            echantillon:    e,
                            prochainNumero: _prochainNumero,
                            onSave:         _onModifier,
                          ),
                          onSupprimer: () => showSuppressionDialog(
                            context,
                            echantillon: e,
                            onConfirmer: () => _onSupprimer(e),
                          ),
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
// STATUT CHIP  — colored pill on white background
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
