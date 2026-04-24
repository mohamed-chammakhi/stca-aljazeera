# Chef Dégustateur Dashboard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart` with a service-backed architecture and 6 new/adapted sections replacing the current hardcoded widget.

**Architecture:** Three-layer pattern — models → service (mock data, API-ready) → widget. `HomeBody` is a `StatefulWidget` that calls the service in `initState` and re-fetches filterable sections individually. No state management library; pure `setState`.

**Tech Stack:** Flutter, `fl_chart` (already in pubspec), `google_fonts` (already in pubspec), `DateFilterSheet` from `lib/5_chef_degustateur/gestion_echantillons/widgets/search_filter_bar.dart`.

---

## File Map

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `lib/5_chef_degustateur/tableau_de_bord/models/dashboard_chef_degustateur.dart` | All data models with `fromJson`/`toJson` |
| Create | `lib/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart` | Service returning mock data, API TODO markers |
| Rewrite | `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart` | Full widget: 6 sections, date filter state, scroll containers |

`homepage_page.dart` — **no changes**. It already calls `HomeBody(onSimulerNotification: ...)`.

---

## Task 1 — Models

**Files:**
- Create: `lib/5_chef_degustateur/tableau_de_bord/models/dashboard_chef_degustateur.dart`

- [ ] **Step 1.1 — Create the models file**

```dart
// lib/5_chef_degustateur/tableau_de_bord/models/dashboard_chef_degustateur.dart

class PipelineChefData {
  final int receptionne;
  final int enAttenteEval;
  final int enCours;
  final int soumis;

  const PipelineChefData({
    required this.receptionne,
    required this.enAttenteEval,
    required this.enCours,
    required this.soumis,
  });

  factory PipelineChefData.fromJson(Map<String, dynamic> json) => PipelineChefData(
    receptionne: json['receptionne'] as int,
    enAttenteEval: json['en_attente_eval'] as int,
    enCours: json['en_cours'] as int,
    soumis: json['soumis'] as int,
  );

  Map<String, dynamic> toJson() => {
    'receptionne': receptionne,
    'en_attente_eval': enAttenteEval,
    'en_cours': enCours,
    'soumis': soumis,
  };
}

class EvaluationUrgenteChef {
  final String id;
  final String reference;
  final String collecteurNom;
  final String fournisseurNom;
  final int joursEnAttente;

  const EvaluationUrgenteChef({
    required this.id,
    required this.reference,
    required this.collecteurNom,
    required this.fournisseurNom,
    required this.joursEnAttente,
  });

  factory EvaluationUrgenteChef.fromJson(Map<String, dynamic> json) => EvaluationUrgenteChef(
    id: json['id'] as String,
    reference: json['reference'] as String,
    collecteurNom: json['collecteur_nom'] as String,
    fournisseurNom: json['fournisseur_nom'] as String,
    joursEnAttente: json['jours_en_attente'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'collecteur_nom': collecteurNom,
    'fournisseur_nom': fournisseurNom,
    'jours_en_attente': joursEnAttente,
  };
}

class SessionEnAttente {
  final String id;
  final String titre;
  final String date;
  final String heure;
  final String lieu;
  final String proposePar;

  const SessionEnAttente({
    required this.id,
    required this.titre,
    required this.date,
    required this.heure,
    required this.lieu,
    required this.proposePar,
  });

  factory SessionEnAttente.fromJson(Map<String, dynamic> json) => SessionEnAttente(
    id: json['id'] as String,
    titre: json['titre'] as String,
    date: json['date'] as String,
    heure: json['heure'] as String,
    lieu: json['lieu'] as String,
    proposePar: json['propose_par'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'date': date,
    'heure': heure,
    'lieu': lieu,
    'propose_par': proposePar,
  };
}

class DelaiMembre {
  final String nom;
  final double delaiMoyen;
  final double panelMoyen;

  const DelaiMembre({
    required this.nom,
    required this.delaiMoyen,
    required this.panelMoyen,
  });

  factory DelaiMembre.fromJson(Map<String, dynamic> json) => DelaiMembre(
    nom: json['nom'] as String,
    delaiMoyen: (json['delai_moyen'] as num).toDouble(),
    panelMoyen: (json['panel_moyen'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => ({
    'nom': nom,
    'delai_moyen': delaiMoyen,
    'panel_moyen': panelMoyen,
  });
}

class DelaiPanelData {
  final List<DelaiMembre> membres;
  final double panelMoyen;

  const DelaiPanelData({required this.membres, required this.panelMoyen});

  factory DelaiPanelData.fromJson(Map<String, dynamic> json) => DelaiPanelData(
    membres: (json['membres'] as List).map((e) => DelaiMembre.fromJson(e)).toList(),
    panelMoyen: (json['panel_moyen'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'membres': membres.map((m) => m.toJson()).toList(),
    'panel_moyen': panelMoyen,
  };
}

class AlignementMembre {
  final String nom;
  final double divergencePct;

  const AlignementMembre({required this.nom, required this.divergencePct});

  factory AlignementMembre.fromJson(Map<String, dynamic> json) => AlignementMembre(
    nom: json['nom'] as String,
    divergencePct: (json['divergence_pct'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'divergence_pct': divergencePct,
  };
}

class AlignementPanelData {
  final List<AlignementMembre> membres;

  const AlignementPanelData({required this.membres});

  factory AlignementPanelData.fromJson(Map<String, dynamic> json) => AlignementPanelData(
    membres: (json['membres'] as List).map((e) => AlignementMembre.fromJson(e)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'membres': membres.map((m) => m.toJson()).toList(),
  };
}

class ClassificationPoint {
  final String label;
  final int extraVierge;
  final int vierge;
  final int lampante;

  const ClassificationPoint({
    required this.label,
    required this.extraVierge,
    required this.vierge,
    required this.lampante,
  });

  factory ClassificationPoint.fromJson(Map<String, dynamic> json) => ClassificationPoint(
    label: json['label'] as String,
    extraVierge: json['extra_vierge'] as int,
    vierge: json['vierge'] as int,
    lampante: json['lampante'] as int,
  );

  Map<String, dynamic> toJson() => {
    'label': label,
    'extra_vierge': extraVierge,
    'vierge': vierge,
    'lampante': lampante,
  };
}
```

- [ ] **Step 1.2 — Verify no analysis errors**

```bash
cd c:/flutterpfe/project3
flutter analyze lib/5_chef_degustateur/tableau_de_bord/models/dashboard_chef_degustateur.dart
```

Expected: `No issues found!`

- [ ] **Step 1.3 — Commit**

```bash
git add lib/5_chef_degustateur/tableau_de_bord/models/dashboard_chef_degustateur.dart
git commit -m "feat(chef): add dashboard models"
```

---

## Task 2 — Service

**Files:**
- Create: `lib/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart`

- [ ] **Step 2.1 — Create the service file**

```dart
// lib/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart

import '../models/dashboard_chef_degustateur.dart';

class DashboardChefDegustateurService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<PipelineChefData> fetchPipeline() async {
    // TODO: replace with: return _api.get('/chef/dashboard/pipeline/');
    return _mockPipeline();
  }

  Future<List<EvaluationUrgenteChef>> fetchUrgentes() async {
    // TODO: replace with: return _api.get('/chef/dashboard/urgentes/');
    return _mockUrgentes();
  }

  Future<List<SessionEnAttente>> fetchSessionsEnAttente() async {
    // TODO: replace with: return _api.get('/chef/dashboard/sessions-en-attente/');
    return _mockSessions();
  }

  Future<DelaiPanelData> fetchDelai({DateTime? dateDebut, DateTime? dateFin}) async {
    // TODO: replace with API call passing date_debut / date_fin params
    return _mockDelai();
  }

  Future<AlignementPanelData> fetchAlignement({DateTime? dateDebut, DateTime? dateFin}) async {
    // TODO: replace with API call passing date_debut / date_fin params
    return _mockAlignement();
  }

  Future<List<ClassificationPoint>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    // TODO: replace with API call passing date_debut / date_fin params
    return _mockClassifications();
  }

  // ── Mock data ──────────────────────────────────────────────────────────────
  // TODO: remove when backend is ready

  PipelineChefData _mockPipeline() => const PipelineChefData(
    receptionne: 2412,
    enAttenteEval: 187,
    enCours: 43,
    soumis: 1089,
  );

  List<EvaluationUrgenteChef> _mockUrgentes() => const [
    EvaluationUrgenteChef(
      id: 'u1',
      reference: 'CHEMLALI-C1 · 2026/0001',
      collecteurNom: 'Ahmed Dridi',
      fournisseurNom: 'Domaine Bel-Air',
      joursEnAttente: 2,
    ),
    EvaluationUrgenteChef(
      id: 'u2',
      reference: 'CHETOUI-C3 · 2026/0003',
      collecteurNom: 'Rania Hammami',
      fournisseurNom: 'Ferme Al Jazira',
      joursEnAttente: 1,
    ),
  ];

  List<SessionEnAttente> _mockSessions() => const [
    SessionEnAttente(
      id: 's1',
      titre: 'Session Oueslati — Lot C',
      date: '28/04/2026',
      heure: '09:00',
      lieu: 'Salle A',
      proposePar: 'Lobna E.',
    ),
    SessionEnAttente(
      id: 's2',
      titre: 'Session Rkhami — Sfax',
      date: '02/05/2026',
      heure: '11:00',
      lieu: 'Labo 1',
      proposePar: 'Ichrak C.',
    ),
  ];

  DelaiPanelData _mockDelai() => DelaiPanelData(
    panelMoyen: 1.86,
    membres: [
      const DelaiMembre(nom: 'Maha O.',    delaiMoyen: 3.8, panelMoyen: 1.86),
      const DelaiMembre(nom: 'Yosra S.',   delaiMoyen: 2.3, panelMoyen: 1.86),
      const DelaiMembre(nom: 'Lobna E.',   delaiMoyen: 1.6, panelMoyen: 1.86),
      const DelaiMembre(nom: 'Nayrouz F.', delaiMoyen: 1.4, panelMoyen: 1.86),
      const DelaiMembre(nom: 'Ichrak C.',  delaiMoyen: 1.2, panelMoyen: 1.86),
    ],
  );

  AlignementPanelData _mockAlignement() => AlignementPanelData(
    membres: [
      const AlignementMembre(nom: 'Maha O.',    divergencePct: 62.0),
      const AlignementMembre(nom: 'Yosra S.',   divergencePct: 28.0),
      const AlignementMembre(nom: 'Nayrouz F.', divergencePct: 12.0),
      const AlignementMembre(nom: 'Lobna E.',   divergencePct: 8.0),
      const AlignementMembre(nom: 'Ichrak C.',  divergencePct: 5.0),
    ],
  );

  List<ClassificationPoint> _mockClassifications() => const [
    ClassificationPoint(label: 'Oct', extraVierge: 1, vierge: 0, lampante: 1),
    ClassificationPoint(label: 'Nov', extraVierge: 2, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Déc', extraVierge: 3, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Jan', extraVierge: 5, vierge: 2, lampante: 0),
    ClassificationPoint(label: 'Fév', extraVierge: 2, vierge: 1, lampante: 1),
    ClassificationPoint(label: 'Mar', extraVierge: 1, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Avr', extraVierge: 1, vierge: 0, lampante: 0),
  ];
}
```

- [ ] **Step 2.2 — Verify no analysis errors**

```bash
flutter analyze lib/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart
```

Expected: `No issues found!`

- [ ] **Step 2.3 — Commit**

```bash
git add lib/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart
git commit -m "feat(chef): add dashboard service with mock data"
```

---

## Task 3 — home_body.dart: scaffold + constants + helpers

**Files:**
- Rewrite: `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Step 3.1 — Rewrite home_body.dart with scaffold, state, and helper methods**

Replace the entire file with:

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/dashboard_chef_degustateur.dart';
import '../services/dashboard_chef_degustateur_service.dart';
import '../../gestion_echantillons/widgets/search_filter_bar.dart';
import '../../evaluation_echantillons/evaluation_echantillons_page.dart';

const Color _green  = Color(0xFF38835A);
const Color _dark   = Color(0xFF1A2E1F);
const Color _white  = Color(0xFFFFFFFF);
const Color _amber  = Color(0xFFD07B2F);
const Color _red    = Color(0xFFC0392B);
const Color _blue   = Color(0xFF3A6EA5);
const Color _purple = Color(0xFF7B3FC4);
const Color _olive  = Color(0xFF6B8143);

class HomeBody extends StatefulWidget {
  final VoidCallback onSimulerNotification;
  const HomeBody({super.key, required this.onSimulerNotification});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _service = DashboardChefDegustateurService();

  PipelineChefData? _pipeline;
  List<EvaluationUrgenteChef> _urgentes = [];
  List<SessionEnAttente> _sessions = [];
  DelaiPanelData? _delai;
  AlignementPanelData? _alignement;
  List<ClassificationPoint> _classifications = [];

  DateTime? _delaiDateDebut;
  DateTime? _delaiDateFin;
  DateTime? _alignDateDebut;
  DateTime? _alignDateFin;
  DateTime? _classDateDebut;
  DateTime? _classDateFin;

  static const _moisAbr = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final pipeline        = await _service.fetchPipeline();
    final urgentes        = await _service.fetchUrgentes();
    final sessions        = await _service.fetchSessionsEnAttente();
    final delai           = await _service.fetchDelai(dateDebut: _delaiDateDebut, dateFin: _delaiDateFin);
    final alignement      = await _service.fetchAlignement(dateDebut: _alignDateDebut, dateFin: _alignDateFin);
    final classifications = await _service.fetchClassifications(dateDebut: _classDateDebut, dateFin: _classDateFin);
    if (!mounted) return;
    setState(() {
      _pipeline = pipeline;
      _urgentes = urgentes;
      _sessions = sessions;
      _delai = delai;
      _alignement = alignement;
      _classifications = classifications;
    });
  }

  Future<void> _reloadDelai() async {
    final data = await _service.fetchDelai(dateDebut: _delaiDateDebut, dateFin: _delaiDateFin);
    if (mounted) setState(() => _delai = data);
  }

  Future<void> _reloadAlignement() async {
    final data = await _service.fetchAlignement(dateDebut: _alignDateDebut, dateFin: _alignDateFin);
    if (mounted) setState(() => _alignement = data);
  }

  Future<void> _reloadClassifications() async {
    final data = await _service.fetchClassifications(dateDebut: _classDateDebut, dateFin: _classDateFin);
    if (mounted) setState(() => _classifications = data);
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _chipLabel({required DateTime? debut, required DateTime? fin}) {
    if (debut == null) return 'Filtrer';
    if (fin == null || (debut.year == fin.year && debut.month == fin.month && debut.day == fin.day)) {
      return _fmtDate(debut);
    }
    return '${debut.day} ${_moisAbr[debut.month - 1]} → ${fin.day} ${_moisAbr[fin.month - 1]}';
  }

  // Formats large numbers: 1089 → "1.1K", 2412 → "2.4K", 187 → "187"
  String _fmtN(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    return '$n';
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );

  Widget _sectionLabel(String text, IconData icon) => Row(children: [
    Container(width: 3, height: 16, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 7),
    Icon(icon, size: 13, color: _green),
    const SizedBox(width: 6),
    Flexible(child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark))),
  ]);

  Widget _dateChip({required String label, required bool active, required VoidCallback onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: active ? _green.withValues(alpha: 0.08) : const Color(0xFFF0F2F1),
          border: Border.all(color: active ? _green.withValues(alpha: 0.25) : const Color(0xFFE8EAE8)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_today_outlined, size: 11, color: active ? _green : const Color(0xFF6B8E7A)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: active ? _green : _dark)),
          if (active) ...[const SizedBox(width: 4), Container(width: 6, height: 6, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle))],
        ]),
      ),
    );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 52),
      children: [
        _buildPipeline(),        const SizedBox(height: 12),
        if (_urgentes.isNotEmpty) ...[_buildUrgentes(), const SizedBox(height: 12)],
        if (_sessions.isNotEmpty) ...[_buildSessions(), const SizedBox(height: 12)],
        _buildDelai(),           const SizedBox(height: 12),
        _buildAlignement(),      const SizedBox(height: 12),
        _buildClassifications(),
      ],
    );
  }

  // Section builders are added in subsequent tasks
  Widget _buildPipeline() => _card(child: const SizedBox(height: 40)); // placeholder
  Widget _buildUrgentes() => const SizedBox.shrink();
  Widget _buildSessions() => const SizedBox.shrink();
  Widget _buildDelai() => _card(child: const SizedBox(height: 40));
  Widget _buildAlignement() => _card(child: const SizedBox(height: 40));
  Widget _buildClassifications() => _card(child: const SizedBox(height: 40));
}
```

- [ ] **Step 3.2 — Analyze**

```bash
flutter analyze lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
```

Expected: `No issues found!`

- [ ] **Step 3.3 — Commit**

```bash
git add lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(chef): scaffold home_body with service wiring"
```

---

## Task 4 — Pipeline section

**Files:**
- Modify: `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Step 4.1 — Replace the `_buildPipeline` placeholder with the real implementation**

Replace `Widget _buildPipeline() => _card(child: const SizedBox(height: 40)); // placeholder` with:

```dart
Widget _buildPipeline() {
  final p = _pipeline;
  return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _sectionLabel('Pipeline des échantillons', Icons.timeline_outlined),
    const SizedBox(height: 14),
    Row(children: [
      _pipeCol(_fmtN(p?.receptionne ?? 0), p?.receptionne ?? 0, 'Réceptionné',    _blue),
      _pipeArrow(),
      _pipeCol(_fmtN(p?.enAttenteEval ?? 0), p?.enAttenteEval ?? 0, 'En attente\néval.', _amber),
      _pipeArrow(),
      _pipeCol(_fmtN(p?.enCours ?? 0), p?.enCours ?? 0, 'En\ncours',       _purple),
      _pipeArrow(),
      _pipeCol(_fmtN(p?.soumis ?? 0), p?.soumis ?? 0, 'Soumis',          _green),
    ]),
  ]));
}

Widget _pipeCol(String label, int exact, String subtitle, Color color) => Expanded(
  child: Column(children: [
    Text(label, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
    Text('$exact', style: const TextStyle(fontSize: 8, color: Color(0xFFAAAAAA))),
    Container(height: 2, margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(2))),
    Text(subtitle, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))),
  ]),
);

Widget _pipeArrow() => const Padding(
  padding: EdgeInsets.only(bottom: 28),
  child: Text('›', style: TextStyle(fontSize: 14, color: Color(0xFFEEEEEE))),
);
```

- [ ] **Step 4.2 — Analyze**

```bash
flutter analyze lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
```

Expected: `No issues found!`

- [ ] **Step 4.3 — Commit**

```bash
git add lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(chef): add pipeline section"
```

---

## Task 5 — Urgentes + Sessions sections

**Files:**
- Modify: `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Step 5.1 — Replace `_buildUrgentes` placeholder**

Replace `Widget _buildUrgentes() => const SizedBox.shrink();` with:

```dart
Widget _buildUrgentes() {
  return Container(
    decoration: BoxDecoration(
      color: _white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _red.withValues(alpha: 0.15)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    clipBehavior: Clip.hardEdge,
    child: Column(children: [
      Container(
        color: const Color(0xFFFDF4F3),
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(
            color: _red, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 2)],
          )),
          const SizedBox(width: 10),
          const Expanded(child: Text('Évaluations urgentes',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _red))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(6)),
            child: Text('${_urgentes.length}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ]),
      ),
      ..._urgentes.map((u) {
        final isCritique = u.joursEnAttente >= 2;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvaluationEchantillonsPage())),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade50))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u.reference, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
                const SizedBox(height: 3),
                Text('${u.collecteurNom}  ·  ${u.fournisseurNom}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isCritique ? _red : _amber).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: (isCritique ? _red : _amber).withValues(alpha: 0.18)),
                ),
                child: Text(
                  isCritique ? '${u.joursEnAttente}j — critique' : '${u.joursEnAttente}j en attente',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isCritique ? _red : _amber),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 15, color: Colors.grey.shade300),
            ]),
          ),
        );
      }),
      Container(
        color: const Color(0xFFF8F8F8),
        padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
        child: SizedBox(width: double.infinity, child: Text(
          "Appuyez pour ouvrir l'évaluation organoleptique",
          textAlign: TextAlign.center, softWrap: true,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
        )),
      ),
    ]),
  );
}
```

- [ ] **Step 5.2 — Replace `_buildSessions` placeholder**

Replace `Widget _buildSessions() => const SizedBox.shrink();` with:

```dart
Widget _buildSessions() {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _white, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _purple.withValues(alpha: 0.15)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 7),
        Icon(Icons.pending_actions_outlined, size: 13, color: _purple),
        const SizedBox(width: 6),
        const Expanded(child: Text("Sessions en attente d'approbation",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _purple.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(6)),
          child: Text('${_sessions.length}',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _purple)),
        ),
      ]),
      const SizedBox(height: 12),
      ..._sessions.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _purple.withValues(alpha: 0.20)),
          boxShadow: [BoxShadow(color: _purple.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 4, height: 36, decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.titre, style: GoogleFonts.domine(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
              const SizedBox(height: 2),
              Text('${s.date} · ${s.heure} · ${s.lieu}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text('Proposée par ${s.proposePar}',
                  style: TextStyle(fontSize: 10, color: _purple.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
            ])),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.close_rounded, size: 14, color: Colors.red.shade400),
              label: Text('Refuser', style: TextStyle(fontSize: 12, color: Colors.red.shade400)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              label: const Text('Approuver', style: TextStyle(fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            )),
          ]),
        ]),
      )),
    ]),
  );
}
```

- [ ] **Step 5.3 — Analyze**

```bash
flutter analyze lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
```

Expected: `No issues found!`

- [ ] **Step 5.4 — Commit**

```bash
git add lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(chef): add urgentes and sessions sections"
```

---

## Task 6 — Délai + Alignement sections

**Files:**
- Modify: `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Step 6.1 — Replace `_buildDelai` placeholder**

Replace `Widget _buildDelai() => _card(child: const SizedBox(height: 40));` with:

```dart
Widget _buildDelai() {
  final delaiActive = _delaiDateDebut != null;
  return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(child: _sectionLabel('Délai de soumission', Icons.timer_outlined)),
      _dateChip(
        label: _chipLabel(debut: _delaiDateDebut, fin: _delaiDateFin),
        active: delaiActive,
        onTap: () => _openDateSheet(
          titre: 'Délai de soumission — période',
          dateDebut: _delaiDateDebut, dateFin: _delaiDateFin, periodOnly: false,
          onApply: (debut, fin) { setState(() { _delaiDateDebut = debut; _delaiDateFin = fin; }); _reloadDelai(); },
          onClear: () { setState(() { _delaiDateDebut = null; _delaiDateFin = null; }); _reloadDelai(); },
        ),
      ),
    ]),
    const SizedBox(height: 10),
    SizedBox(
      height: 114,
      child: _alignement == null
          ? const Center(child: Text('Aucune donnée', style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))))
          : _buildScrollableRows(
              items: _delai!.membres,
              getValue: (m) => m.delaiMoyen,
              getMax: (m) => _delai!.membres.first.delaiMoyen,
              getColor: (m) {
                if (m.delaiMoyen > _delai!.panelMoyen * 1.5) return _red;
                if (m.delaiMoyen > _delai!.panelMoyen * 1.1) return _amber;
                return _green;
              },
              getLabel: (m) => '${m.delaiMoyen.toStringAsFixed(1)}j',
              getName: (m) => m.nom,
            ),
    ),
    const SizedBox(height: 4),
    Center(child: Text('↕ défiler pour voir tous',
        style: TextStyle(fontSize: 9, color: Colors.grey.shade400))),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFF7FAF8), borderRadius: BorderRadius.circular(8), border: Border.all(color: _green.withValues(alpha: 0.12))),
      child: const Text("Délai moyen entre la réception d'un échantillon et la soumission de l'évaluation.",
          style: TextStyle(fontSize: 10, color: Color(0xFF6B8E7A))),
    ),
  ]));
}
```

- [ ] **Step 6.2 — Replace `_buildAlignement` placeholder**

Replace `Widget _buildAlignement() => _card(child: const SizedBox(height: 40));` with:

```dart
Widget _buildAlignement() {
  final alignActive = _alignDateDebut != null;
  return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(child: _sectionLabel('Alignement avec le panel', Icons.check_box_outlined)),
      _dateChip(
        label: _chipLabel(debut: _alignDateDebut, fin: _alignDateFin),
        active: alignActive,
        onTap: () => _openDateSheet(
          titre: 'Alignement — période',
          dateDebut: _alignDateDebut, dateFin: _alignDateFin, periodOnly: false,
          onApply: (debut, fin) { setState(() { _alignDateDebut = debut; _alignDateFin = fin; }); _reloadAlignement(); },
          onClear: () { setState(() { _alignDateDebut = null; _alignDateFin = null; }); _reloadAlignement(); },
        ),
      ),
    ]),
    const SizedBox(height: 10),
    SizedBox(
      height: 114,
      child: _alignement == null
          ? const Center(child: Text('Aucune donnée', style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))))
          : _buildScrollableRows(
              items: _alignement!.membres,
              getValue: (m) => m.divergencePct,
              getMax: (_) => 100.0,
              getColor: (m) {
                if (m.divergencePct >= 40) return _red;
                if (m.divergencePct >= 20) return _amber;
                return _green;
              },
              getLabel: (m) => '${m.divergencePct.toStringAsFixed(0)}%',
              getName: (m) => m.nom,
            ),
    ),
    const SizedBox(height: 4),
    Center(child: Text('↕ défiler pour voir tous',
        style: TextStyle(fontSize: 9, color: Colors.grey.shade400))),
    const SizedBox(height: 8),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFF7FAF8), borderRadius: BorderRadius.circular(8), border: Border.all(color: _green.withValues(alpha: 0.12))),
      child: const Text('Plus le % est élevé, plus le dégustateur classe différemment du reste du panel.',
          style: TextStyle(fontSize: 10, color: Color(0xFF6B8E7A))),
    ),
  ]));
}
```

- [ ] **Step 6.3 — Add the shared `_buildScrollableRows` helper (generic, used by both délai and alignement)**

Add this method to `_HomeBodyState` (before `build`):

```dart
Widget _buildScrollableRows<T>({
  required List<T> items,
  required double Function(T) getValue,
  required double Function(T) getMax,
  required Color Function(T) getColor,
  required String Function(T) getLabel,
  required String Function(T) getName,
}) {
  final maxVal = getMax(items.first);
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, i) {
      final item = items[i];
      final val   = getValue(item);
      final color = getColor(item);
      final ratio = maxVal == 0 ? 0.0 : (val / maxVal).clamp(0.0, 1.0);
      final isRed    = color == _red;
      final isOrange = color == _amber;
      return Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: isRed ? const Color(0xFFFFF8F6) : isOrange ? const Color(0xFFFFFAF5) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isRed ? const Color(0xFFFFD5CC) : isOrange ? const Color(0xFFFFE8CC) : const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(children: [
          SizedBox(
            width: 72,
            child: Text(getName(item),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: const Color(0xFFEEEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          )),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(getLabel(item),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
          ),
        ]),
      );
    },
  );
}
```

- [ ] **Step 6.4 — Analyze**

```bash
flutter analyze lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
```

Expected: `No issues found!`

- [ ] **Step 6.5 — Commit**

```bash
git add lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(chef): add délai and alignement sections"
```

---

## Task 7 — Classifications section with Y-axis scale

**Files:**
- Modify: `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Step 7.1 — Replace `_buildClassifications` placeholder**

Replace `Widget _buildClassifications() => _card(child: const SizedBox(height: 40));` with:

```dart
Widget _buildClassifications() {
  final classActive = _classDateDebut != null;
  return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Expanded(child: _sectionLabel('Mes classifications', Icons.check_box_outlined)),
      _dateChip(
        label: _chipLabel(debut: _classDateDebut, fin: _classDateFin),
        active: classActive,
        onTap: () => _openDateSheet(
          titre: 'Filtrer les classifications',
          dateDebut: _classDateDebut, dateFin: _classDateFin, periodOnly: false,
          onApply: (debut, fin) { setState(() { _classDateDebut = debut; _classDateFin = fin; }); _reloadClassifications(); },
          onClear: () { setState(() { _classDateDebut = null; _classDateFin = null; }); _reloadClassifications(); },
        ),
      ),
    ]),
    const SizedBox(height: 12),
    SizedBox(
      height: 150,
      child: _classifications.isEmpty
          ? const Center(child: Text('Aucune donnée', style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))))
          : BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _classifications
                  .map((p) => (p.extraVierge + p.vierge + p.lampante).toDouble())
                  .fold(0.0, (a, b) => a > b ? a : b) + 1,
              barGroups: List.generate(_classifications.length, (i) {
                final p = _classifications[i];
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(toY: p.extraVierge.toDouble(), color: _green, width: 10,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  BarChartRodData(toY: p.vierge.toDouble(), color: _olive, width: 10,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  BarChartRodData(toY: p.lampante.toDouble(), color: _amber, width: 10,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                ]);
              }),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 22,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= _classifications.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_classifications[i].label,
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))),
                    );
                  },
                )),
                leftTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true, reservedSize: 22,
                  getTitlesWidget: (v, _) => v % 1 == 0
                      ? Text(v.toInt().toString(),
                            style: const TextStyle(fontSize: 9, color: Color(0xFFCCCCCC)))
                      : const SizedBox(),
                )),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true, drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => const FlLine(color: Color(0x0D000000), strokeWidth: 1),
              ),
            )),
    ),
    const SizedBox(height: 10),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _legendDot(_green, 'Extra Vierge'), const SizedBox(width: 12),
      _legendDot(_olive, 'Vierge'),        const SizedBox(width: 12),
      _legendDot(_amber, 'Lampante'),
    ]),
  ]));
}

Widget _legendDot(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
  const SizedBox(width: 4),
  Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _dark)),
]);
```

- [ ] **Step 7.2 — Analyze**

```bash
flutter analyze lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
```

Expected: `No issues found!`

- [ ] **Step 7.3 — Commit**

```bash
git add lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(chef): add classifications section with Y-axis scale"
```

---

## Task 8 — Fix DelaiData null guard + final analyze

The délai section uses `_alignement == null` as the null guard instead of `_delai == null` (copy-paste error to fix).

**Files:**
- Modify: `lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Step 8.1 — Fix null guard in `_buildDelai`**

In `_buildDelai`, find this line:
```dart
child: _alignement == null
```
Replace it with:
```dart
child: _delai == null
```

- [ ] **Step 8.2 — Full project analyze**

```bash
flutter analyze lib/5_chef_degustateur/
```

Expected: `No issues found!`

- [ ] **Step 8.3 — Final commit**

```bash
git add lib/5_chef_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "fix(chef): correct null guard in délai section"
```
