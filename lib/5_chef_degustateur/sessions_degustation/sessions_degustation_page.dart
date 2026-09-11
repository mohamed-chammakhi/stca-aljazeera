// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/sessions_degustation_page.dart  (Chef de Dégustation)
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/widgets/messagerie/conversations_page.dart';

import 'package:project3/core/models/session_degustation.dart';
import 'package:project3/core/services/sessions_service.dart';
import '../widgets/statut_chip.dart';
import 'package:project3/core/widgets/sessions_degustation/session_card.dart';
import 'widgets/dialogs/formulaire_session_dialog.dart';
import 'package:project3/core/widgets/dialogs/suppression_session_dialog.dart';

import 'package:project3/core/widgets/search_date_filter_bar.dart'
    show DateFilterSheet;
import '../../../core/widgets/bandeau_demonstration.dart';

import '../profil.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../utilisateurs/utilisateurs_chef_page.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../../../main.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/chef_nav_mixin.dart';
import '../../../core/utils/date_utils.dart';

class SessionsDegustationPage extends StatefulWidget {
  const SessionsDegustationPage({super.key});

  @override
  State<SessionsDegustationPage> createState() =>
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

  final _service = const SessionsService(peutValider: true);
  List<SessionDegustation> _sessions = [];
  bool _estDemonstration = false;
  Object? _erreurChargement;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final resultat = await _service.fetchSessions();
      if (!mounted) return;
      setState(() {
        _sessions = resultat.donnees;
        _estDemonstration = resultat.estDemonstration;
        _erreurChargement = null;
      });
    } catch (erreur) {
      if (mounted) setState(() => _erreurChargement = erreur);
    }
  }

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

  Future<void> _onAjouter(SessionDegustation nouvelle) async {
    // Chef's sessions go directly to planifiee
    nouvelle.statut = StatutSession.planifiee;
    try {
      final saved = await _service.createSession(nouvelle);
      if (!mounted) return;
      setState(() => _sessions.add(saved));
      _showSuccess('Session créée et planifiée');
    } catch (_) {
      if (mounted) _showError();
    }
  }

  Future<void> _onModifier(SessionDegustation modifiee) async {
    try {
      final saved = await _service.updateSession(modifiee);
      if (!mounted) return;
      setState(() {
        final index = _sessions.indexWhere((s) => s.id == modifiee.id);
        if (index != -1) _sessions[index] = saved;
      });
      _showSuccess('Session modifiée avec succès');
    } catch (_) {
      if (mounted) _showError();
    }
  }

  Future<void> _onSupprimer(SessionDegustation s) async {
    try {
      await _service.deleteSession(s.id);
      if (!mounted) return;
      setState(() => _sessions.remove(s));
      _showSuccess('Session "${s.titre}" supprimée');
    } catch (_) {
      if (mounted) _showError();
    }
  }

  Future<void> _onApprouver(SessionDegustation s) async {
    try {
      await _service.approuverSession(s.id);
      if (!mounted) return;
      setState(() => s.statut = StatutSession.planifiee);
      _showSuccess('Session "${s.titre}" approuvée');
    } catch (_) {
      if (mounted) _showError();
    }
  }

  Future<void> _onRefuser(SessionDegustation s) async {
    try {
      await _service.refuserSession(s.id);
      if (!mounted) return;
      setState(() => _sessions.remove(s));
      _showSuccess('Session "${s.titre}" refusée et supprimée');
    } catch (_) {
      if (mounted) _showError();
    }
  }

  Future<void> _onConfirmerPresence(SessionDegustation s) async {
    try {
      final updated = await _service.confirmerPresence(s.id);
      if (!mounted || updated == null) return;
      setState(() {
        final index = _sessions.indexWhere((item) => item.id == s.id);
        if (index != -1) _sessions[index] = updated;
      });
    } catch (_) {
      if (mounted) _showError();
      rethrow;
    }
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
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('L’action n’a pas pu être enregistrée.')),
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
      backgroundColor: kBg,
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            goToPage(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => goToPage(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () =>
            goToPage(const SessionsDegustationPage()),
        onMembredupanel: () => goToPage(const MembresPanelPage()),
        onUtilisateurs: () => goToPage(const UtilisateursChefPage()),
        onVueEnsembleEvaluations: () =>
            goToPage(const VueEnsembleEvaluationsPage()),
        onMessagerie: () => goToPage(const ConversationsPage()),
        onProfil: () => goToPage(const ProfilePage()),
        onDeconnexion: goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Sessions de dégustation',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireSessionDialog(
          context,
          session: null,
          prochainNumero: _prochainNumero,
          onSave: _onAjouter,
        ),
        backgroundColor: const Color.fromARGB(255, 197, 206, 201),
        elevation: 2,
        icon: const Icon(Icons.add, color: kDark),
        label: const Text(
          'Nouvelle session',
          style: TextStyle(color: kDark, fontWeight: FontWeight.w700),
        ),
      ),
      body: VueResultatService(
        estDemonstration: _estDemonstration,
        erreur: _erreurChargement,
        onReessayer: _loadData,
        child: Column(
          children: [
            // ── HEADER ZONE ────────────────────────────────────────────────────
            Container(
              color: kHeaderBg,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _recherche = v.trim()),
                    style: const TextStyle(fontSize: 14, color: kDark),
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
                        borderSide: const BorderSide(color: kGreen, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
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
                          onTap: () =>
                              setState(() => _filtreStatutLabel = null),
                        ),
                        const SizedBox(width: 7),
                        StatutChip(
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
                          activeColor: kGreen,
                          inactiveColor: const Color(0xFFE6F4ED),
                          inactiveTextColor: kGreen,
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
              color: kBg,
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
                          color: kGreen,
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
                            onConfirmerPresence: () => _onConfirmerPresence(s),
                            onApprouver: isPending
                                ? () => _onApprouver(s)
                                : null,
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
      ),
    );
  }
}
