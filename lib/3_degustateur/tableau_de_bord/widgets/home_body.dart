import 'package:flutter/material.dart';

import '../models/dashboard_degustateur.dart';
import '../services/dashboard_degustateur_service.dart';
import '../../../../core/widgets/search_filter_bar.dart';
import 'home_activite_section.dart';
import 'home_classifications_section.dart';
import 'home_delai_section.dart';
import 'home_presence_section.dart';
import 'home_pipeline_section.dart';
import 'home_urgentes_section.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});
  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _service = DashboardDegustateurService();

  List<EvaluationUrgente> _urgentes = [];
  List<EvaluationUrgenteCeo> _urgentesCeo = [];
  final Set<String> _ignoredUrgentes = {};
  final Set<String> _ignoredUrgentesCeo = {};

  PipelineData? _pipeline;
  List<ClassificationPoint> _classifications = [];
  PresenceData? _presence;
  DelaiSummary? _delai;
  List<ActiviteItem> _activite = [];
  int _activiteTotal = 0;
  bool _activiteLoading = false;

  DateTime? _classDateDebut;
  DateTime? _classDateFin;
  DateTime? _presDateDebut;
  DateTime? _presDateFin;
  DateTime _delaiDateDebut = DateTime(DateTime.now().year, 1, 1);
  DateTime _delaiDateFin = DateTime.now();
  DateTime? _actDateDebut;
  DateTime? _actDateFin;
  bool _showClearConfirm = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final urgentes = await _service.fetchUrgentes();
    final urgentesCeo = await _service.fetchUrgentesCeo();
    final pipeline = await _service.fetchPipeline();
    final cls = await _service.fetchClassifications(
      dateDebut: _classDateDebut,
      dateFin: _classDateFin,
    );
    final presence = await _service.fetchPresence(
      dateDebut: _presDateDebut,
      dateFin: _presDateFin,
    );
    final delai = await _service.fetchDelai(
      dateDebut: _delaiDateDebut,
      dateFin: _delaiDateFin,
    );
    final act = await _service.fetchActivite(
      dateDebut: _actDateDebut,
      dateFin: _actDateFin,
      offset: 0,
    );
    if (!mounted) return;
    setState(() {
      _urgentes = urgentes;
      _urgentesCeo = urgentesCeo;
      _pipeline = pipeline;
      _classifications = cls;
      _presence = presence;
      _delai = delai;
      _activite = act.items;
      _activiteTotal = act.total;
    });
  }

  Future<void> _reloadClassifications() async {
    final data = await _service.fetchClassifications(
      dateDebut: _classDateDebut,
      dateFin: _classDateFin,
    );
    if (mounted) setState(() => _classifications = data);
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
    required String titre,
    required DateTime? dateDebut,
    required DateTime? dateFin,
    required bool periodOnly,
    required void Function(DateTime debut, DateTime? fin) onApply,
    required VoidCallback onClear,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        titre: titre,
        dateDebut: dateDebut,
        dateFin: periodOnly ? dateFin : null,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }

  void _openPresenceDateSheet() => _openDateSheet(
    titre: 'Filtrer les séances',
    dateDebut: _presDateDebut,
    dateFin: _presDateFin,
    periodOnly: false,
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
  );

  void _openDelaiDateSheet() => _openDateSheet(
    titre: 'Délai de soumission — période',
    dateDebut: _delaiDateDebut,
    dateFin: _delaiDateFin,
    periodOnly: true,
    onApply: (debut, fin) {
      setState(() {
        _delaiDateDebut = debut;
        _delaiDateFin = fin ?? debut;
      });
      _reloadDelai();
    },
    onClear: () {
      setState(() {
        _delaiDateDebut = DateTime(DateTime.now().year, 1, 1);
        _delaiDateFin = DateTime.now();
      });
      _reloadDelai();
    },
  );

  void _openClassDateSheet() => _openDateSheet(
    titre: 'Filtrer les classifications',
    dateDebut: _classDateDebut,
    dateFin: _classDateFin,
    periodOnly: false,
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
  );

  void _openActDateSheet() => _openDateSheet(
    titre: "Filtrer l'activité",
    dateDebut: _actDateDebut,
    dateFin: _actDateFin,
    periodOnly: false,
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
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 52),
          children: [
            HomePipelineSection(pipeline: _pipeline),
            const SizedBox(height: 12),
            HomeUrgentesSection(
              urgentes: _urgentes,
              urgentesCeo: _urgentesCeo,
              ignoredUrgentes: _ignoredUrgentes,
              ignoredUrgentesCeo: _ignoredUrgentesCeo,
              onIgnore: (id) => setState(() => _ignoredUrgentes.add(id)),
              onIgnoreCeo: (id) => setState(() => _ignoredUrgentesCeo.add(id)),
            ),
            const SizedBox(height: 12),
            HomePresenceSection(
              presence: _presence,
              dateDebut: _presDateDebut,
              dateFin: _presDateFin,
              onDateTap: _openPresenceDateSheet,
            ),
            const SizedBox(height: 12),
            HomeDelaiSection(
              delai: _delai,
              dateDebut: _delaiDateDebut,
              dateFin: _delaiDateFin,
              onDateTap: _openDelaiDateSheet,
            ),
            const SizedBox(height: 12),
            HomeClassificationsSection(
              classifications: _classifications,
              dateDebut: _classDateDebut,
              dateFin: _classDateFin,
              onDateTap: _openClassDateSheet,
            ),
            const SizedBox(height: 12),
            HomeActiviteSection(
              activite: _activite,
              activiteTotal: _activiteTotal,
              activiteLoading: _activiteLoading,
              dateDebut: _actDateDebut,
              dateFin: _actDateFin,
              showClearConfirm: _showClearConfirm,
              onDateTap: _openActDateSheet,
              onLoadMore: _loadMoreActivite,
              onRequestClearConfirm: () =>
                  setState(() => _showClearConfirm = true),
              onClearConfirm: () {
                setState(() {
                  _actDateDebut = null;
                  _actDateFin = null;
                  _showClearConfirm = false;
                });
                _reloadActivite();
              },
              onDismissClearConfirm: () =>
                  setState(() => _showClearConfirm = false),
            ),
          ],
        ),
        if (_showClearConfirm)
          HomeActiviteClearConfirmDialog(
            onCancel: () => setState(() => _showClearConfirm = false),
            onConfirm: () {
              setState(() {
                _actDateDebut = null;
                _actDateFin = null;
                _showClearConfirm = false;
              });
              _reloadActivite();
            },
          ),
      ],
    );
  }
}
