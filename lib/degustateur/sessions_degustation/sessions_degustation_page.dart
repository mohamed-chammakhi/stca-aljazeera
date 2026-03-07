// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/sessions_degustation_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, and actions
//
// SECTIONS :
//   1. COLORS
//   2. STATE         — search, statut filter, date range
//   3. NAVIGATION    — _goTo, _goToLogin
//   4. MOCK DATA     — replace with API call later
//   5. FILTER LOGIC  — _filtres getter, _parseDate, _labelToStatut
//   6. ACTIONS       — add, edit, delete, snackbar
//   7. BUILD         — appbar, drawer, FAB, SearchFilterBar, list
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ── Own model + widgets ───────────────────────────────────────────────────────
import 'models/session_degustation.dart';
import 'widgets/session_card.dart';
import 'widgets/dialogs/formulaire_session_dialog.dart';
import 'widgets/dialogs/suppression_session_dialog.dart';

// ── Shared widget — same SearchFilterBar used by gestion + evaluation pages ───
// imported directly — no copy needed ✅
import '../gestion_echantillons/widgets/search_filter_bar.dart';

// ── App-wide imports ──────────────────────────────────────────────────────────
import '../../../profil.dart';
import '../homepage/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../../../main.dart';

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

  static const Color green = Color(0xFF38835A);
  static const Color cream = Color(0xFFF9F6EF);
  static const Color gray = Color.fromARGB(255, 81, 82, 81);

  // ───────────────────────────────────────────────────────────────────────────
  // 2. STATE
  // ───────────────────────────────────────────────────────────────────────────

  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';
  String?
  _filtreStatutLabel; // null = show all  |  'Planifiée' / 'En cours' / 'Terminée'
  DateTime? _dateDebut; // null = no lower date bound
  DateTime? _dateFin; // null = no upper date bound

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;

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
      MaterialPageRoute(builder: (_) => const LoginPage()),
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
      participants: ['Ichrak C.', 'Lobna E.', 'Maha O.'],
      notes: 'Apporter les fiches de notation',
    ),
    SessionDegustation(
      id: 'SES-002',
      titre: 'Session Chetoui - Lot B',
      date: '21/02/2026',
      heure: '10:30',
      lieu: 'Laboratoire 2',
      statut: StatutSession.enCours,
      echantillonIds: ['OL-2024-002'],
      participants: ['Nayrouz F.', 'Yosra S.'],
    ),
    SessionDegustation(
      id: 'SES-003',
      titre: 'Session Zalmati',
      date: '25/02/2026',
      heure: '14:00',
      lieu: 'Salle de dégustation B',
      statut: StatutSession.planifiee,
      echantillonIds: ['OL-2024-003', 'OL-2024-004'],
      participants: ['Ichrak C.', 'Maha O.', 'Nayrouz F.', 'Yosra S.'],
      notes: 'Préparer les verres ISO 3591',
    ),
    SessionDegustation(
      id: 'SES-004',
      titre: 'Session Oueslati - Kairouan',
      date: '01/03/2026',
      heure: '09:30',
      lieu: 'Salle de dégustation A',
      statut: StatutSession.planifiee,
      echantillonIds: ['OL-2024-004'],
      participants: ['Lobna E.', 'Yosra S.'],
    ),
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // 5. FILTER LOGIC
  // ───────────────────────────────────────────────────────────────────────────

  // label → enum  (SearchFilterBar gives us a String, we need StatutSession)
  StatutSession? _labelToStatut(String? label) {
    switch (label) {
      case 'Planifiée':
        return StatutSession.planifiee;
      case 'En cours':
        return StatutSession.enCours;
      case 'Terminée':
        return StatutSession.terminee;
      default:
        return null;
    }
  }

  // converts "DD/MM/YYYY" → DateTime for date comparison
  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  // combines text + statut + date into one filtered list
  List<SessionDegustation> get _filtres {
    return _sessions.where((s) {
      // text search across titre, lieu, id
      final matchRecherche =
          _recherche.isEmpty ||
          s.titre.toLowerCase().contains(_recherche.toLowerCase()) ||
          s.lieu.toLowerCase().contains(_recherche.toLowerCase()) ||
          s.id.toLowerCase().contains(_recherche.toLowerCase());

      // statut filter
      final filtreEnum = _labelToStatut(_filtreStatutLabel);
      final matchStatut = filtreEnum == null || s.statut == filtreEnum;

      // date range filter
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
  // 6. ACTIONS  —  setState always called here, never inside widgets/dialogs
  // ───────────────────────────────────────────────────────────────────────────

  void _onAjouter(SessionDegustation nouvelle) {
    setState(() => _sessions.add(nouvelle));
    _showSuccess('Session créée avec succès');
  }

  void _onModifier(SessionDegustation modifiee) {
    setState(() {}); // object already mutated inside formulaire_session_dialog
    _showSuccess('Session modifiée avec succès');
  }

  void _onSupprimer(SessionDegustation s) {
    setState(() => _sessions.remove(s));
    _showSuccess('Session "${s.titre}" supprimée');
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
        backgroundColor: green,
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
    return Scaffold(
      backgroundColor: cream,

      // ── DRAWER ───────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => Navigator.pop(context),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        // current page
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),
        onAPropos: () => Navigator.pop(context),
        onDeconnexion: _goToLogin,
      ),

      // ── APPBAR ───────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_sessions.length} session(s)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      // ── FAB — opens formulaire in ADD mode ───────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireSessionDialog(
          context,
          session: null,
          prochainNumero: _prochainNumero,
          onSave: _onAjouter,
        ),
        backgroundColor: green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle session',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          // ── SEARCH + FILTERS ─────────────────────────────────────────────
          // same SearchFilterBar used by gestion + evaluation pages
          // chip labels match StatutSession via _labelToStatut in section 5
          SearchFilterBar(
            recherche: _recherche,
            controller: _searchController,
            filtreStatut: _filtreStatutLabel,
            dateDebut: _dateDebut,
            dateFin: _dateFin,
            // chip labels for sessions (different from gestion/evaluation)
            statutLabels: const ['Planifiée', 'En cours', 'Terminée'],
            onRechercheChanged: (v) => setState(() => _recherche = v),
            onRechercheClear: () => setState(() {
              _recherche = '';
              _searchController.clear();
            }),
            onStatutChanged: (v) => setState(() => _filtreStatutLabel = v),
            onDateChanged: (debut, fin) => setState(() {
              _dateDebut = debut;
              _dateFin = fin;
            }),
            onDateClear: () => setState(() {
              _dateDebut = null;
              _dateFin = null;
            }),
          ),

          // ── LIST ─────────────────────────────────────────────────────────
          Expanded(
            child: _filtres.isEmpty
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
                : Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(gray),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _filtres.length,
                        itemBuilder: (context, index) {
                          final s = _filtres[index];
                          return SessionCard(
                            session: s,
                            // opens formulaire in EDIT mode
                            onModifier: () => showFormulaireSessionDialog(
                              context,
                              session: s,
                              prochainNumero: _prochainNumero,
                              onSave: _onModifier,
                            ),
                            // opens confirmation dialog before deleting
                            onSupprimer: () => showSuppressionSessionDialog(
                              context,
                              session: s,
                              onConfirmer: () => _onSupprimer(s),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
