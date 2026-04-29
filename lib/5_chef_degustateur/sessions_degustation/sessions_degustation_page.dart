// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/sessions_degustation_page.dart  (Chef de Panel)
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/session_degustation.dart';
import 'widgets/session_card.dart';
import 'widgets/dialogs/formulaire_session_dialog.dart';
import 'widgets/dialogs/suppression_session_dialog.dart';

import '../gestion_echantillons/widgets/search_filter_bar.dart'
    show DateFilterSheet;

import '../profil.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../../../main.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart';
import '../widgets/chef_colors.dart';
import '../widgets/chef_nav_mixin.dart';
import '../../../core/utils/date_utils.dart';

class SessionsDegustationPage extends StatefulWidget {
  const SessionsDegustationPage({super.key});

  @override
  _SessionsDegustationPageState createState() =>
      _SessionsDegustationPageState();
}

class _SessionsDegustationPageState extends State<SessionsDegustationPage>
    with ChefNavMixin {
  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';
  String? _filtreStatutLabel;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;
  bool get _anyFilter =>
      _dateFilterActive || _recherche.isNotEmpty || _filtreStatutLabel != null;

  // ── Mock data — chef sees all sessions including pending ones ──────────────
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
    // Sessions suggested by normal dégustateurs — awaiting chef approval
    SessionDegustation(
      id: 'SES-005',
      titre: 'Session Oueslati - Lot C',
      date: '28/04/2026',
      heure: '09:00',
      lieu: 'Salle de dégustation A',
      statut: StatutSession.enAttenteValidation,
      echantillonIds: ['OL-2024-006'],
      participantIds: ['mock-lobna', 'mock-maha'],
      participantNoms: ['Lobna E.', 'Maha O.'],
      notes: 'Proposée par Lobna E.',
      createdBy: 'mock-lobna',
      createdAt: '2026-04-17T10:00:00Z',
    ),
    SessionDegustation(
      id: 'SES-006',
      titre: 'Session Rkhami - Sfax',
      date: '02/05/2026',
      heure: '11:00',
      lieu: 'Laboratoire 1',
      statut: StatutSession.enAttenteValidation,
      echantillonIds: ['OL-2024-007', 'OL-2024-008'],
      participantIds: ['mock-ichrak', 'mock-nayrouz', 'mock-yosra'],
      participantNoms: ['Ichrak C.', 'Nayrouz F.', 'Yosra S.'],
      createdBy: 'mock-ichrak',
      createdAt: '2026-04-18T14:30:00Z',
    ),
  ];

  StatutSession? _labelToStatut(String? label) {
    switch (label) {
      case 'En attente':
        return StatutSession.enAttenteValidation;
      case 'Planifiée':
        return StatutSession.planifiee;
      case 'Terminée':
        return StatutSession.terminee;
      default:
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
        final raw = DegDateUtils.parseDate(s.date);
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

  int get _pendingCount => _sessions
      .where((s) => s.statut == StatutSession.enAttenteValidation)
      .length;

  int get _prochainNumero => _sessions.length + 1;

  // ── Actions ────────────────────────────────────────────────────────────────

  void _onAjouter(SessionDegustation nouvelle) {
    // Chef's sessions go directly to planifiee
    nouvelle.statut = StatutSession.planifiee;
    setState(() => _sessions.add(nouvelle));
    _showSuccess('Session créée et planifiée');
  }

  void _onModifier(SessionDegustation modifiee) {
    setState(() {});
    _showSuccess('Session modifiée avec succès');
  }

  void _onSupprimer(SessionDegustation s) {
    setState(() => _sessions.remove(s));
    _showSuccess('Session "${s.titre}" supprimée');
  }

  void _onApprouver(SessionDegustation s) {
    setState(() => s.statut = StatutSession.planifiee);
    _showSuccess('Session "${s.titre}" approuvée');
  }

  void _onRefuser(SessionDegustation s) {
    setState(() => _sessions.remove(s));
    _showSuccess('Session "${s.titre}" refusée et supprimée');
  }

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
        backgroundColor: chefGreen,
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

  @override
  Widget build(BuildContext context) {
    final items = _filtres;

    return Scaffold(
      backgroundColor: chefBg,
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            goToPage(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => goToPage(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => goToPage(const SessionsDegustationPage()),
        onMembredupanel: () => goToPage(const MembresPanelPage()),
        onVueEnsembleEvaluations: () =>
            goToPage(const VueEnsembleEvaluationsPage()),
        onProfil: () => goToPage(const ProfilePage()),
        onDeconnexion: goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: chefHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Sessions de dégustation',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: chefDark,
          ),
        ),
        iconTheme: const IconThemeData(color: chefDark),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _dateFilterActive ? chefGreen : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: 'Filtrer par date de la session',
              ),
              if (_dateFilterActive)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: chefGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireSessionDialog(
          context,
          session: null,
          prochainNumero: _prochainNumero,
          onSave: _onAjouter,
        ),
        backgroundColor: const Color.fromARGB(255, 197, 206, 201),
        elevation: 2,
        icon: const Icon(Icons.add, color: chefDark),
        label: const Text(
          'Nouvelle session',
          style: TextStyle(color: chefDark, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // ── HEADER ZONE ────────────────────────────────────────────────────
          Container(
            color: chefHeaderBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _recherche = v.trim()),
                  style: const TextStyle(fontSize: 14, color: chefDark),
                  decoration: InputDecoration(
                    hintText: 'Rechercher titre, lieu, réf…',
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
                      borderSide: const BorderSide(color: chefGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
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
                        label: 'En attente',
                        activeColor: const Color(0xFF7B3FC4),
                        inactiveColor: const Color(0xFFF3E8FF),
                        inactiveTextColor: const Color(0xFF7B3FC4),
                        selected: _filtreStatutLabel == 'En attente',
                        hasActivity: _pendingCount > 0,
                        onTap: () =>
                            setState(() => _filtreStatutLabel = 'En attente'),
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
                        activeColor: chefGreen,
                        inactiveColor: const Color(0xFFE6F4ED),
                        inactiveTextColor: chefGreen,
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
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          Container(
            color: chefBg,
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
                if (_anyFilter) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _filtreStatutLabel = null;
                      _dateDebut = null;
                      _dateFin = null;
                      _recherche = '';
                      _searchController.clear();
                    }),
                    child: const Text(
                      'Effacer les filtres',
                      style: TextStyle(
                        fontSize: 12,
                        color: chefGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                        final isPending =
                            s.statut == StatutSession.enAttenteValidation;
                        final isTerminee = s.statut == StatutSession.terminee;
                        return SessionCard(
                          session: s,
                          onApprouver: isPending ? () => _onApprouver(s) : null,
                          onRefuser: isPending ? () => _onRefuser(s) : null,
                          onModifier: (!isPending && !isTerminee)
                              ? () => showFormulaireSessionDialog(
                                  context,
                                  session: s,
                                  prochainNumero: _prochainNumero,
                                  onSave: _onModifier,
                                )
                              : null,
                          onSupprimer: (!isPending && !isTerminee)
                              ? () => showSuppressionSessionDialog(
                                  context,
                                  session: s,
                                  onConfirmer: () => _onSupprimer(s),
                                )
                              : null,
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
class _StatutChip extends StatelessWidget {
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveTextColor;
  final bool selected;
  final bool hasActivity;
  final VoidCallback onTap;

  const _StatutChip({
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveTextColor,
    required this.selected,
    required this.onTap,
    this.hasActivity = false,
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
      if (hasActivity) {
        bg = inactiveColor;
        fg = inactiveTextColor;
        border = inactiveTextColor.withValues(alpha: 0.35);
      } else {
        bg = _inactiveBg;
        fg = _inactiveFg;
        border = _inactiveBorder;
      }
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
