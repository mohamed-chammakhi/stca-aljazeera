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

// ── Own model + widgets ───────────────────────────────────────────────────────
import 'models/session_degustation.dart';
import 'widgets/session_card.dart';
import 'widgets/dialogs/formulaire_session_dialog.dart';
import 'widgets/dialogs/suppression_session_dialog.dart';

// ── Shared date filter ────────────────────────────────────────────────────────
import '../gestion_echantillons/widgets/search_filter_bar.dart'
    show DateFilterSheet;

// ── App-wide imports ──────────────────────────────────────────────────────────
import '../profil.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../../../main.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';

class SessionsDegustationPage extends StatefulWidget {
  const SessionsDegustationPage({super.key});

  @override
  _SessionsDegustationPageState createState() =>
      _SessionsDegustationPageState();
}

class _SessionsDegustationPageState extends State<SessionsDegustationPage> {
  // ───────────────────────────────────────────────────────────────────────────
  // 1. COLORS
  // ───────────────────────────────────────────────────────────────────────────

  static const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
  static const Color _green = Color(0xFF38835A);
  static const Color _dark = Color(0xFF1A2E1F);
  static const Color _bg = Color(0xFFFFFFFF);

  // ───────────────────────────────────────────────────────────────────────────
  // 2. STATE
  // ───────────────────────────────────────────────────────────────────────────

  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';
  String? _filtreStatutLabel; // null = show all  |  'Planifiée' / 'Terminée'
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;
  bool get _anyFilter =>
      _dateFilterActive || _recherche.isNotEmpty || _filtreStatutLabel != null;

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
  // 4. MOCK DATA  —  replace with API call when backend is ready
  // ───────────────────────────────────────────────────────────────────────────

  final List<SessionDegustation> _sessions = [
    SessionDegustation(
      id: 'SES-001',
      titre: 'Session Chemlali - Lot A',
      date: '20/02/2026',
      heure: '09:00',
      lieu: 'Salle de dégustation A',
      statut: StatutSession.terminee,
      echantillonIds: ['OL-2024-001', 'OL-2024-005'],
      participantIds: ['mock-ichrak', 'mock-lobna', 'mock-maha'],
      participantNoms: ['Ichrak C.', 'Lobna E.', 'Maha O.'],
      notes: 'Apporter les fiches de notation',
      createdBy: 'mock-user-001',
      createdAt: '2026-02-01T08:00:00Z',
    ),
    SessionDegustation(
      id: 'SES-002',
      titre: 'Session Chetoui - Lot B',
      date: '21/02/2026',
      heure: '10:30',
      lieu: 'Laboratoire 2',
      statut: StatutSession.planifiee,
      echantillonIds: ['OL-2024-002'],
      participantIds: ['mock-nayrouz', 'mock-yosra'],
      participantNoms: ['Nayrouz F.', 'Yosra S.'],
      createdBy: 'mock-user-001',
      createdAt: '2026-02-05T08:00:00Z',
    ),
    SessionDegustation(
      id: 'SES-003',
      titre: 'Session Zalmati',
      date: '25/02/2026',
      heure: '14:00',
      lieu: 'Salle de dégustation B',
      statut: StatutSession.planifiee,
      echantillonIds: ['OL-2024-003', 'OL-2024-004'],
      participantIds: [
        'mock-ichrak',
        'mock-maha',
        'mock-nayrouz',
        'mock-yosra',
      ],
      participantNoms: ['Ichrak C.', 'Maha O.', 'Nayrouz F.', 'Yosra S.'],
      notes: 'Préparer les verres ISO 3591',
      createdBy: 'mock-user-001',
      createdAt: '2026-02-10T08:00:00Z',
    ),
    SessionDegustation(
      id: 'SES-004',
      titre: 'Session Oueslati - Kairouan',
      date: '01/03/2026',
      heure: '09:30',
      lieu: 'Salle de dégustation A',
      statut: StatutSession.planifiee,
      echantillonIds: ['OL-2024-004'],
      participantIds: ['mock-lobna', 'mock-yosra'],
      participantNoms: ['Lobna E.', 'Yosra S.'],
      createdBy: 'mock-user-001',
      createdAt: '2026-02-15T08:00:00Z',
    ),
  ];

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
        backgroundColor: _green,
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
      backgroundColor: _bg,

      // ── DRAWER ─────────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
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
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Sessions de dégustation',
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
        icon: const Icon(Icons.add, color: _dark),
        label: const Text(
          'Nouvelle session',
          style: TextStyle(color: _dark, fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        children: [
          // ── UNIFIED HEADER ZONE ─────────────────────────────────────────
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
                      borderSide: const BorderSide(color: _green, width: 1.5),
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
                      _StatutChip(
                        label: 'Tous',
                        activeColor: const Color(0xFF616161),
                        inactiveColor: const Color(0xFFF0F0F0),
                        inactiveTextColor: const Color(0xFF757575),
                        selected: _filtreStatutLabel == null,
                        onTap: () => setState(() => _filtreStatutLabel = null),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'Planifiée',
                        activeColor: const Color(0xFFD07B2F),
                        inactiveColor: const Color(0xFFFEF3E8),
                        inactiveTextColor: const Color(0xFFD07B2F),
                        selected: _filtreStatutLabel == 'Planifiée',
                        onTap: () =>
                            setState(() => _filtreStatutLabel = 'Planifiée'),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
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
            color: _bg,
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

// ─────────────────────────────────────────────────────────────────────────────
// STATUT CHIP — matches gestion_echantillons_page._StatutChip exactly
// ─────────────────────────────────────────────────────────────────────────────
class _StatutChip extends StatelessWidget {
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveTextColor;
  final bool selected;
  final VoidCallback onTap;

  const _StatutChip({
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveTextColor,
    required this.selected,
    required this.onTap,
  });

  static const Color _inactiveBg = Color(0xFFF0F0F0);
  static const Color _inactiveFg = Color(0xFF9E9E9E);
  static const Color _inactiveBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final bool isTous = label == 'Tous';
    final Color bg;
    final Color fg;
    final Color border;

    if (!selected) {
      bg = _inactiveBg;
      fg = _inactiveFg;
      border = _inactiveBorder;
    } else if (isTous) {
      bg = const Color(0xFF757575);
      fg = Colors.white;
      border = const Color(0xFF757575);
    } else {
      bg = inactiveColor;
      fg = inactiveTextColor;
      border = inactiveTextColor.withValues(alpha: 0.45);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        (isTous ? const Color(0xFF757575) : inactiveTextColor)
                            .withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
