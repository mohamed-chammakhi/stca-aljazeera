// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/sessions_degustation_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, and actions
//
// SECTIONS :
//   1. COLORS
//   2. STATE         — search, statut filter, date range
//   3. NAVIGATION    — _goTo, _goToLogin
//   4. MOCK DATA     — replace with API call later
//   5. FILTER LOGIC  — _filtres getter, _parseDate
//   6. ACTIONS       — add, edit, delete, snackbar
//   7. BUILD         — appbar, drawer, header zone, stats strip, list
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tableau_de_bord/homepage_page.dart';

// ── Own model + widgets ───────────────────────────────────────────────────────
import 'models/session_degustation.dart';
import 'services/sessions_service.dart';
import 'widgets/session_card.dart';
import 'widgets/dialogs/formulaire_session_dialog.dart';
import 'widgets/dialogs/suppression_session_dialog.dart';

// ── Shared date filter ────────────────────────────────────────────────────────
import '../gestion_echantillons/widgets/search_filter_bar.dart'
    show DateFilterSheet;

// ── App-wide imports ──────────────────────────────────────────────────────────
import '../profil/profil_page.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../../../main.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../widgets/statut_chip.dart';
import '../widgets/deg_colors.dart';

class SessionsDegustationPage extends StatefulWidget {
  const SessionsDegustationPage({super.key});

  @override
  _SessionsDegustationPageState createState() =>
      _SessionsDegustationPageState();
}

class _SessionsDegustationPageState extends State<SessionsDegustationPage> {
  final _service = SessionsService();

  // ───────────────────────────────────────────────────────────────────────────
  // 1. COLORS — see lib/3_degustateur/widgets/deg_colors.dart
  // ───────────────────────────────────────────────────────────────────────────

  // ───────────────────────────────────────────────────────────────────────────
  // 2. STATE
  // ───────────────────────────────────────────────────────────────────────────

  List<SessionDegustation> _sessions = [];
  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';
  String? _filtreStatutLabel; // null = show all  |  'Planifiée' / 'Terminée'
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;
  bool get _anyFilter =>
      _dateFilterActive || _recherche.isNotEmpty || _filtreStatutLabel != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.fetchSessions();
    setState(() => _sessions = List.from(data));
  }

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
  // 5. FILTER LOGIC
  // ───────────────────────────────────────────────────────────────────────────

  StatutSession? _labelToStatut(String? label) {
    switch (label) {
      case 'Planifiée':
        return StatutSession.planifiee;
      case 'Terminée':
        return StatutSession.terminee;
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

  List<SessionDegustation> get _filtres {
    return _sessions.where((s) {
      final matchRecherche =
          _recherche.isEmpty ||
          s.titre.toLowerCase().contains(_recherche.toLowerCase()) ||
          s.lieu.toLowerCase().contains(_recherche.toLowerCase()) ||
          s.id.toLowerCase().contains(_recherche.toLowerCase());

      final filtreEnum = _labelToStatut(_filtreStatutLabel);
      final matchStatut = filtreEnum == null || s.statut == filtreEnum;

      bool matchDate = true;
      if (_dateFilterActive) {
        final raw = _parseDate(s.date);
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

  int get _prochainNumero => _sessions.length + 1;

  // ───────────────────────────────────────────────────────────────────────────
  // 6. ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  void _onAjouter(SessionDegustation nouvelle) {
    setState(() => _sessions.add(nouvelle));
    _showSuccess('Session créée avec succès');
  }

  void _onModifier(SessionDegustation modifiee) {
    setState(() {});
    _showSuccess('Session modifiée avec succès');
  }

  void _onSupprimer(SessionDegustation s) {
    setState(() => _sessions.remove(s));
    _showSuccess('Session "${s.titre}" supprimée');
  }

  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        titre: 'Filtrer par date de séance',
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

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: degGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

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
    final items = _filtres;

    return Scaffold(
      backgroundColor: degBg,

      // ── DRAWER ─────────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil: () => _goTo(const HomePage()),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),
        onDeconnexion: _goToLogin,
      ),

      // ── APPBAR ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: degHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Sessions de dégustation',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: degDark,
          ),
        ),
        iconTheme: const IconThemeData(color: degDark),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _dateFilterActive ? degGreen : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: 'Filtrer par date de séance',
              ),
              if (_dateFilterActive)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: degGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireSessionDialog(
          context,
          session: null,
          prochainNumero: _prochainNumero,
          onSave: _onAjouter,
        ),
        backgroundColor: const Color.fromARGB(255, 197, 206, 201),
        elevation: 2,
        icon: const Icon(Icons.add, color: degDark),
        label: const Text(
          'Nouvelle session',
          style: TextStyle(color: degDark, fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        children: [
          // ── UNIFIED HEADER ZONE ─────────────────────────────────────────
          Container(
            color: degHeaderBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _recherche = v.trim()),
                  style: const TextStyle(fontSize: 14, color: degDark),
                  decoration: InputDecoration(
                    hintText: 'Titre · lieu · réf · organisateur…',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B8E7A),
                      fontSize: 11,
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
                      borderSide: const BorderSide(color: degGreen, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // ── Statut filter chips ─────────────────────────────────
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
                        label: 'Planifiée',
                        activeColor: const Color(0xFFD07B2F),
                        inactiveColor: const Color(0xFFFEF3E8),
                        inactiveTextColor: const Color(0xFFD07B2F),
                        selected: _filtreStatutLabel == 'Planifiée',
                        onTap: () =>
                            setState(() => _filtreStatutLabel = 'Planifiée'),
                      ),
                      const SizedBox(width: 7),
                      StatutChip(
                        label: 'Terminée',
                        activeColor: const Color(0xFF38835A),
                        inactiveColor: const Color(0xFFE6F4ED),
                        inactiveTextColor: const Color(0xFF38835A),
                        selected: _filtreStatutLabel == 'Terminée',
                        onTap: () =>
                            setState(() => _filtreStatutLabel = 'Terminée'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Thin separator shadow
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── STATS STRIP ───────────────────────────────────────────────────
          Container(
            color: degBg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                Icon(
                  Icons.event_note_outlined,
                  size: 13,
                  color: const Color.fromARGB(255, 156, 156, 156),
                ),
                const SizedBox(width: 6),
                Text(
                  '${items.length} session${items.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 156, 156, 156),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── LIST ─────────────────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune session trouvée',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final s = items[i];
                        final isPlanifiee = s.statut == StatutSession.planifiee;
                        return SessionCard(
                          session: s,
                          onModifier: isPlanifiee
                              ? null
                              : () => showFormulaireSessionDialog(
                                  context,
                                  session: s,
                                  prochainNumero: _prochainNumero,
                                  onSave: _onModifier,
                                ),
                          onSupprimer: isPlanifiee
                              ? null
                              : () => showSuppressionSessionDialog(
                                  context,
                                  session: s,
                                  onConfirmer: () => _onSupprimer(s),
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
