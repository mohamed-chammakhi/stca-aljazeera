import 'package:flutter/material.dart';

import '../models/dashboard_chef_degustateur.dart';
import '../services/dashboard_chef_degustateur_service.dart';
import '../../gestion_echantillons/widgets/search_filter_bar.dart';
import 'home_activite_section.dart';
import 'home_alignement_section.dart';
import 'home_classifications_section.dart';
import 'home_delai_section.dart';
import 'home_pipeline_section.dart';
import 'home_presence_section.dart';
import 'home_sessions_section.dart';
import 'home_urgentes_section.dart';
import 'home_shared.dart';

class HomeBody extends StatefulWidget {
  final VoidCallback onSimulerNotification;
  const HomeBody({super.key, required this.onSimulerNotification});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _service = DashboardChefDegustateurService();

  // ── State ─────────────────────────────────────────────────────────────────
  PipelineChefData? _pipeline;
  List<EvaluationUrgenteChef> _urgentes = [];
  List<EvaluationUrgenteCeoChef> _urgentesCeo = [];
  final Set<String> _ignoredUrgentes = {};
  final Set<String> _ignoredUrgentesCeo = {};

  List<SessionEnAttente> _sessions = [];
  PresenceChefData? _presence;
  DelaiPanelData? _delai;
  AlignementPanelData? _alignement;
  List<ClassificationPoint> _classifications = [];
  List<ActiviteItemChef> _activite = [];
  int _activiteTotal = 0;
  bool _activiteLoading = false;

  DateTime? _presDateDebut;
  DateTime? _presDateFin;
  DateTime? _delaiDateDebut;
  DateTime? _delaiDateFin;
  DateTime? _alignDateDebut;
  DateTime? _alignDateFin;
  DateTime? _classDateDebut;
  DateTime? _classDateFin;
  DateTime? _actDateDebut;
  DateTime? _actDateFin;
  bool _showClearConfirm = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final pipeline = await _service.fetchPipeline();
    final urgentes = await _service.fetchUrgentes();
    final urgentesCeo = await _service.fetchUrgentesCeo();
    final sessions = await _service.fetchSessionsEnAttente();
    final presence = await _service.fetchPresence(
      dateDebut: _presDateDebut,
      dateFin: _presDateFin,
    );
    final delai = await _service.fetchDelai(
      dateDebut: _delaiDateDebut,
      dateFin: _delaiDateFin,
    );
    final alignement = await _service.fetchAlignement(
      dateDebut: _alignDateDebut,
      dateFin: _alignDateFin,
    );
    final classifications = await _service.fetchClassifications(
      dateDebut: _classDateDebut,
      dateFin: _classDateFin,
    );
    final act = await _service.fetchActivite(
      dateDebut: _actDateDebut,
      dateFin: _actDateFin,
      offset: 0,
    );
    if (!mounted) return;
    setState(() {
      _pipeline = pipeline;
      _urgentes = urgentes;
      _urgentesCeo = urgentesCeo;
      _sessions = sessions;
      _presence = presence;
      _delai = delai;
      _alignement = alignement;
      _classifications = classifications;
      _activite = act.items;
      _activiteTotal = act.total;
    });
  }

  Future<void> _reloadPresence() async {
    final data = await _service.fetchPresence(
      dateDebut: _presDateDebut,
      dateFin: _presDateFin,
    );
    if (mounted) setState(() => _presence = data);
  }

  Future<void> _reloadDelai() async {
    final data = await _service.fetchDelai(
      dateDebut: _delaiDateDebut,
      dateFin: _delaiDateFin,
    );
    if (mounted) setState(() => _delai = data);
  }

  Future<void> _reloadAlignement() async {
    final data = await _service.fetchAlignement(
      dateDebut: _alignDateDebut,
      dateFin: _alignDateFin,
    );
    if (mounted) setState(() => _alignement = data);
  }

  Future<void> _reloadClassifications() async {
    final data = await _service.fetchClassifications(
      dateDebut: _classDateDebut,
      dateFin: _classDateFin,
    );
    if (mounted) setState(() => _classifications = data);
  }

  Future<void> _reloadActivite() async {
    final data = await _service.fetchActivite(
      dateDebut: _actDateDebut,
      dateFin: _actDateFin,
      offset: 0,
    );
    if (mounted) {
      setState(() {
        _activite = data.items;
        _activiteTotal = data.total;
      });
    }
  }

  Future<void> _loadMoreActivite() async {
    if (_activiteLoading || _activite.length >= _activiteTotal) return;
    setState(() => _activiteLoading = true);
    final data = await _service.fetchActivite(
      dateDebut: _actDateDebut,
      dateFin: _actDateFin,
      offset: _activite.length,
    );
    if (mounted) {
      setState(() {
        _activite.addAll(data.items);
        _activiteTotal = data.total;
        _activiteLoading = false;
      });
    }
  }

  Future<void> _openDateSheet({
    required DateTime? dateDebut,
    required DateTime? dateFin,
    required void Function(DateTime debut, DateTime? fin) onApply,
    required VoidCallback onClear,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        dateDebut: dateDebut,
        dateFin: dateFin,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 52),
          children: [
            PipelineSection(pipeline: _pipeline),
            const SizedBox(height: 12),
            UrgentesSection(
              urgentes: _urgentes,
              urgentesCeo: _urgentesCeo,
              ignoredUrgentes: _ignoredUrgentes,
              ignoredUrgentesCeo: _ignoredUrgentesCeo,
              onIgnoreUrgente: (id) => setState(() => _ignoredUrgentes.add(id)),
              onIgnoreUrgenteCeo: (id) =>
                  setState(() => _ignoredUrgentesCeo.add(id)),
            ),
            const SizedBox(height: 12),
            if (_sessions.isNotEmpty) ...[
              SessionsSection(sessions: _sessions),
              const SizedBox(height: 12),
            ],
            PresenceSection(
              presence: _presence,
              dateDebut: _presDateDebut,
              dateFin: _presDateFin,
              onDateTap: () => _openDateSheet(
                dateDebut: _presDateDebut,
                dateFin: _presDateFin,
                onApply: (d, f) {
                  setState(() {
                    _presDateDebut = d;
                    _presDateFin = f;
                  });
                  _reloadPresence();
                },
                onClear: () {
                  setState(() {
                    _presDateDebut = null;
                    _presDateFin = null;
                  });
                  _reloadPresence();
                },
              ),
            ),
            const SizedBox(height: 12),
            DelaiSection(
              delai: _delai,
              dateDebut: _delaiDateDebut,
              dateFin: _delaiDateFin,
              onDateTap: () => _openDateSheet(
                dateDebut: _delaiDateDebut,
                dateFin: _delaiDateFin,
                onApply: (debut, fin) {
                  setState(() {
                    _delaiDateDebut = debut;
                    _delaiDateFin = fin;
                  });
                  _reloadDelai();
                },
                onClear: () {
                  setState(() {
                    _delaiDateDebut = null;
                    _delaiDateFin = null;
                  });
                  _reloadDelai();
                },
              ),
            ),
            const SizedBox(height: 12),
            AlignementSection(
              alignement: _alignement,
              dateDebut: _alignDateDebut,
              dateFin: _alignDateFin,
              onDateTap: () => _openDateSheet(
                dateDebut: _alignDateDebut,
                dateFin: _alignDateFin,
                onApply: (debut, fin) {
                  setState(() {
                    _alignDateDebut = debut;
                    _alignDateFin = fin;
                  });
                  _reloadAlignement();
                },
                onClear: () {
                  setState(() {
                    _alignDateDebut = null;
                    _alignDateFin = null;
                  });
                  _reloadAlignement();
                },
              ),
            ),
            const SizedBox(height: 12),
            ClassificationsSection(
              classifications: _classifications,
              dateDebut: _classDateDebut,
              dateFin: _classDateFin,
              onDateTap: () => _openDateSheet(
                dateDebut: _classDateDebut,
                dateFin: _classDateFin,
                onApply: (d, f) {
                  setState(() {
                    _classDateDebut = d;
                    _classDateFin = f;
                  });
                  _reloadClassifications();
                },
                onClear: () {
                  setState(() {
                    _classDateDebut = null;
                    _classDateFin = null;
                  });
                  _reloadClassifications();
                },
              ),
            ),
            const SizedBox(height: 12),
            ActiviteSection(
              activite: _activite,
              activiteTotal: _activiteTotal,
              activiteLoading: _activiteLoading,
              dateDebut: _actDateDebut,
              dateFin: _actDateFin,
              onDateTap: () => _openDateSheet(
                dateDebut: _actDateDebut,
                dateFin: _actDateFin,
                onApply: (d, f) {
                  setState(() {
                    _actDateDebut = d;
                    _actDateFin = f;
                  });
                  _reloadActivite();
                },
                onClear: () {
                  setState(() {
                    _actDateDebut = null;
                    _actDateFin = null;
                  });
                  _reloadActivite();
                },
              ),
              onLoadMore: _loadMoreActivite,
              onClearFilterTap: () =>
                  setState(() => _showClearConfirm = true),
            ),
          ],
        ),
        if (_showClearConfirm) _buildClearConfirmDialog(),
      ],
    );
  }

  Widget _buildClearConfirmDialog() => Container(
    color: Colors.black.withValues(alpha: 0.4),
    child: Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 40,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Effacer le filtre ?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: chefDarkLocal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Le filtre de date sera supprimé et toute l'activité sera visible.",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showClearConfirm = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE8EAE8)),
                      ),
                      child: const Text(
                        'Annuler',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: chefDarkLocal,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _actDateDebut = null;
                        _actDateFin = null;
                        _showClearConfirm = false;
                      });
                      _reloadActivite();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: chefRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Effacer',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
