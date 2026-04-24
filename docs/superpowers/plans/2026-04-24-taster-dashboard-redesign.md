# Taster Dashboard Redesign — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the taster's dashboard with 6 focused sections: urgent evaluations, pipeline, classifications bar chart, session attendance, submission delay line chart, and recent activity — all with per-section date filters using the existing `DateFilterSheet`.

**Architecture:** `home_body.dart` is completely rewritten. Mock data lives in a new service class. All date filters reuse the existing `DateFilterSheet` widget from `search_filter_bar.dart`. The `homepage_page.dart` scaffold is simplified (removes `onSimulerNotification`).

**Tech Stack:** Flutter, `fl_chart` (already in pubspec), `google_fonts`, existing `DateFilterSheet` from `lib/3_degustateur/gestion_echantillons/widgets/search_filter_bar.dart`

---

## File Map

| File | Action | What changes |
|---|---|---|
| `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart` | **Rewrite** | All 6 new sections |
| `lib/3_degustateur/tableau_de_bord/homepage_page.dart` | **Modify** | Remove `onSimulerNotification`, simplify |
| `lib/3_degustateur/tableau_de_bord/models/dashboard_degustateur.dart` | **Create** | Data models for all sections |
| `lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart` | **Create** | Mock service returning all dashboard data |
| `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart` | **Modify** | Replace `_PeriodSheet` with `DateFilterSheet` |
| `CLAUDE.md` | **Modify** | Add urgency logic, délai formula, pagination rule |

---

## Task 1: Create data models

**Files:**
- Create: `lib/3_degustateur/tableau_de_bord/models/dashboard_degustateur.dart`

- [ ] **Create the models file with all needed types:**

```dart
// lib/3_degustateur/tableau_de_bord/models/dashboard_degustateur.dart

class EvaluationUrgente {
  final String id;
  final String reference;
  final String collecteurNom;
  final String fournisseurNom;
  final int joursEnAttente; // DateTime.now().difference(dateReceptionEchantillon).inDays

  const EvaluationUrgente({
    required this.id,
    required this.reference,
    required this.collecteurNom,
    required this.fournisseurNom,
    required this.joursEnAttente,
  });

  factory EvaluationUrgente.fromJson(Map<String, dynamic> json) => EvaluationUrgente(
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

class PipelineData {
  final int nonEvaluee;
  final int enCours;
  final int soumise;
  const PipelineData({required this.nonEvaluee, required this.enCours, required this.soumise});

  factory PipelineData.fromJson(Map<String, dynamic> json) => PipelineData(
    nonEvaluee: json['non_evaluee'] as int,
    enCours: json['en_cours'] as int,
    soumise: json['soumise'] as int,
  );

  Map<String, dynamic> toJson() => {
    'non_evaluee': nonEvaluee,
    'en_cours': enCours,
    'soumise': soumise,
  };
}

class ClassificationPoint {
  final String label;       // e.g. "Oct", "Nov"
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

class PresenceData {
  final int present;
  final int manquee;
  final String? prochaineTitre;
  final String? prochaineDate;
  final String? prochaineLieu;
  final String? prochaineCountdown; // e.g. "4j"
  const PresenceData({
    required this.present,
    required this.manquee,
    this.prochaineTitre,
    this.prochaineDate,
    this.prochaineLieu,
    this.prochaineCountdown,
  });

  int get total => present + manquee;
  double get taux => total == 0 ? 0 : present / total;

  factory PresenceData.fromJson(Map<String, dynamic> json) => PresenceData(
    present: json['present'] as int,
    manquee: json['manquee'] as int,
    prochaineTitre: json['prochaine_titre'] as String?,
    prochaineDate: json['prochaine_date'] as String?,
    prochaineLieu: json['prochaine_lieu'] as String?,
    prochaineCountdown: json['prochaine_countdown'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'present': present,
    'manquee': manquee,
    'prochaine_titre': prochaineTitre,
    'prochaine_date': prochaineDate,
    'prochaine_lieu': prochaineLieu,
    'prochaine_countdown': prochaineCountdown,
  };
}

class DelaiPoint {
  final DateTime date;
  final double monDelai;    // days
  final double panelMoyen;  // days
  const DelaiPoint({required this.date, required this.monDelai, required this.panelMoyen});

  factory DelaiPoint.fromJson(Map<String, dynamic> json) => DelaiPoint(
    date: DateTime.parse(json['date'] as String),
    monDelai: (json['mon_delai'] as num).toDouble(),
    panelMoyen: (json['panel_moyen'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mon_delai': monDelai,
    'panel_moyen': panelMoyen,
  };
}

class DelaiSummary {
  final double monDelaiMoyen;
  final double panelMoyen;
  final int nbEvals;
  final List<DelaiPoint> points;
  const DelaiSummary({
    required this.monDelaiMoyen,
    required this.panelMoyen,
    required this.nbEvals,
    required this.points,
  });

  factory DelaiSummary.fromJson(Map<String, dynamic> json) => DelaiSummary(
    monDelaiMoyen: (json['mon_delai_moyen'] as num).toDouble(),
    panelMoyen: (json['panel_moyen'] as num).toDouble(),
    nbEvals: json['nb_evals'] as int,
    points: (json['points'] as List).map((e) => DelaiPoint.fromJson(e)).toList(),
  );

  Map<String, dynamic> toJson() => {
    'mon_delai_moyen': monDelaiMoyen,
    'panel_moyen': panelMoyen,
    'nb_evals': nbEvals,
    'points': points.map((p) => p.toJson()).toList(),
  };
}

class ActiviteItem {
  final String id;
  final String action;       // e.g. "Évaluation soumise — CHEMLALI-C4"
  final String horodatage;   // e.g. "24 Avr · 10h32"
  final String type;         // "evaluation" | "seance_presente" | "seance_manquee" | "profil"
  const ActiviteItem({
    required this.id,
    required this.action,
    required this.horodatage,
    required this.type,
  });

  factory ActiviteItem.fromJson(Map<String, dynamic> json) => ActiviteItem(
    id: json['id'] as String,
    action: json['action'] as String,
    horodatage: json['horodatage'] as String,
    type: json['type'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'horodatage': horodatage,
    'type': type,
  };
}
```

- [ ] **Commit**

```bash
git add lib/3_degustateur/tableau_de_bord/models/dashboard_degustateur.dart
git commit -m "feat(degustateur): add dashboard data models"
```

---

## Task 2: Create the mock service

**Files:**
- Create: `lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart`

- [ ] **Create the service file:**

```dart
// lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart

import '../models/dashboard_degustateur.dart';

class DashboardDegustateurService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  // ── Urgent evaluations ──────────────────────────────────────────────────────
  Future<List<EvaluationUrgente>> fetchUrgentes() async {
    // TODO: replace with: return _api.get('/degustateur/dashboard/urgentes/');
    return _mockUrgentes();
  }

  // ── Pipeline ────────────────────────────────────────────────────────────────
  Future<PipelineData> fetchPipeline() async {
    // TODO: replace with: return _api.get('/degustateur/dashboard/pipeline/');
    return _mockPipeline();
  }

  // ── Classifications ─────────────────────────────────────────────────────────
  Future<List<ClassificationPoint>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    // TODO: replace with API call passing date params
    return _mockClassifications();
  }

  // ── Presence ────────────────────────────────────────────────────────────────
  Future<PresenceData> fetchPresence({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    // TODO: replace with API call passing date params
    return _mockPresence();
  }

  // ── Délai de soumission ─────────────────────────────────────────────────────
  Future<DelaiSummary> fetchDelai({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    // TODO: replace with: return _api.get('/degustateur/dashboard/delai/?date_debut=...&date_fin=...');
    return _mockDelai();
  }

  // ── Activité récente ────────────────────────────────────────────────────────
  // Returns up to [pageSize] items starting at [offset].
  // Backend: GET /api/activite/?date_debut=...&date_fin=...&offset=0&limit=5
  Future<({List<ActiviteItem> items, int total})> fetchActivite({
    DateTime? dateDebut,
    DateTime? dateFin,
    int offset = 0,
    int pageSize = 5,
  }) async {
    // TODO: replace with paginated API call
    final all = _mockActivite();
    final slice = all.skip(offset).take(pageSize).toList();
    return (items: slice, total: all.length);
  }

  // ── Mock data ───────────────────────────────────────────────────────────────
  // TODO: remove when backend is ready

  List<EvaluationUrgente> _mockUrgentes() => [
    const EvaluationUrgente(
      id: 'urg-1',
      reference: 'CHEMLALI-C1 · 2026/0001',
      collecteurNom: 'Ahmed Dridi',
      fournisseurNom: 'Domaine Bel-Air',
      joursEnAttente: 2,
    ),
    const EvaluationUrgente(
      id: 'urg-2',
      reference: 'CHETOUI-C3 · 2026/0003',
      collecteurNom: 'Rania Hammami',
      fournisseurNom: 'Ferme Al Jazira',
      joursEnAttente: 1,
    ),
  ];

  PipelineData _mockPipeline() => const PipelineData(nonEvaluee: 5, enCours: 3, soumise: 23);

  List<ClassificationPoint> _mockClassifications() => const [
    ClassificationPoint(label: 'Oct', extraVierge: 1, vierge: 0, lampante: 1),
    ClassificationPoint(label: 'Nov', extraVierge: 2, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Déc', extraVierge: 3, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Jan', extraVierge: 5, vierge: 2, lampante: 0),
    ClassificationPoint(label: 'Fév', extraVierge: 2, vierge: 1, lampante: 1),
    ClassificationPoint(label: 'Mar', extraVierge: 1, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Avr', extraVierge: 1, vierge: 0, lampante: 0),
  ];

  PresenceData _mockPresence() => const PresenceData(
    present: 13,
    manquee: 2,
    prochaineTitre: 'Prochaine séance : 28 Avr 2026',
    prochaineDate: '28 Avr 2026',
    prochaineLieu: 'Salle de dégustation A · 09h00',
    prochaineCountdown: '4j',
  );

  DelaiSummary _mockDelai() => DelaiSummary(
    monDelaiMoyen: 1.8,
    panelMoyen: 1.4,
    nbEvals: 23,
    points: [
      DelaiPoint(date: DateTime(2026, 1, 2),  monDelai: 1.0, panelMoyen: 1.2),
      DelaiPoint(date: DateTime(2026, 1, 9),  monDelai: 2.5, panelMoyen: 1.3),
      DelaiPoint(date: DateTime(2026, 1, 15), monDelai: 1.2, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 1, 22), monDelai: 3.0, panelMoyen: 1.5),
      DelaiPoint(date: DateTime(2026, 2, 5),  monDelai: 1.5, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 2, 12), monDelai: 0.8, panelMoyen: 1.3),
      DelaiPoint(date: DateTime(2026, 3, 1),  monDelai: 2.0, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 3, 14), monDelai: 1.8, panelMoyen: 1.5),
      DelaiPoint(date: DateTime(2026, 4, 2),  monDelai: 2.2, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 4, 10), monDelai: 1.0, panelMoyen: 1.3),
      DelaiPoint(date: DateTime(2026, 4, 19), monDelai: 1.5, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 4, 21), monDelai: 1.9, panelMoyen: 1.4),
    ],
  );

  List<ActiviteItem> _mockActivite() => const [
    ActiviteItem(id: 'a1', action: 'Évaluation soumise — CHEMLALI-C4', horodatage: '24 Avr · 10h32', type: 'evaluation'),
    ActiviteItem(id: 'a2', action: 'Séance de dégustation rejointe — Séance #14', horodatage: '23 Avr · 09h00', type: 'seance_presente'),
    ActiviteItem(id: 'a3', action: 'Évaluation soumise — OUESLATI-C2', horodatage: '21 Avr · 14h15', type: 'evaluation'),
    ActiviteItem(id: 'a4', action: 'Séance manquée — Séance #13', horodatage: '19 Avr · 09h00', type: 'seance_manquee'),
    ActiviteItem(id: 'a5', action: 'Évaluation soumise — CHETOUI-C2', horodatage: '19 Avr · 11h47', type: 'evaluation'),
    ActiviteItem(id: 'a6', action: 'Séance rejointe — Séance #12', horodatage: '15 Avr · 09h00', type: 'seance_presente'),
    ActiviteItem(id: 'a7', action: 'Évaluation soumise — ZALMATI-C1', horodatage: '14 Avr · 16h40', type: 'evaluation'),
    ActiviteItem(id: 'a8', action: 'Évaluation soumise — CHEMLALI-C2', horodatage: '12 Avr · 10h05', type: 'evaluation'),
    ActiviteItem(id: 'a9', action: 'Profil mis à jour', horodatage: '08 Avr · 08h30', type: 'profil'),
    ActiviteItem(id: 'a10', action: 'Évaluation soumise — OUESLATI-C1', horodatage: '05 Avr · 14h00', type: 'evaluation'),
  ];
}
```

- [ ] **Commit**

```bash
git add lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart
git commit -m "feat(degustateur): add dashboard service with mock data"
```

---

## Task 3: Rewrite home_body.dart — skeleton + sections 1 & 2

**Files:**
- Modify: `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Replace the entire file with the new skeleton + first 2 sections (urgentes + pipeline):**

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/dashboard_degustateur.dart';
import '../services/dashboard_degustateur_service.dart';
import '../../gestion_echantillons/widgets/search_filter_bar.dart';
import '../../evaluation_echantillons/evaluation_echantillons_page.dart';

// ── Design tokens ──────────────────────────────────────────────────────────────
const Color _green   = Color(0xFF38835A);
const Color _dark    = Color(0xFF1A2E1F);
const Color _pageBg  = Color(0xFFF2F4F2);
const Color _white   = Color(0xFFFFFFFF);
const Color _amber   = Color(0xFFD07B2F);
const Color _blue    = Color(0xFF3A6EA5);
const Color _red     = Color(0xFFC0392B);
const Color _olive   = Color(0xFF6B8143);
const Color _hdrBg   = Color.fromARGB(255, 220, 233, 226);

// ─────────────────────────────────────────────────────────────────────────────
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _service = DashboardDegustateurService();

  // ── Data ───────────────────────────────────────────────────────────────────
  List<EvaluationUrgente> _urgentes = [];
  PipelineData? _pipeline;
  List<ClassificationPoint> _classifications = [];
  PresenceData? _presence;
  DelaiSummary? _delai;
  List<ActiviteItem> _activite = [];
  int _activiteTotal = 0;
  bool _activiteLoading = false;

  // ── Date filter state per section ──────────────────────────────────────────
  DateTime? _classDateDebut;
  DateTime? _classDateFin;
  DateTime? _presDateDebut;
  DateTime? _presDateFin;
  DateTime _delaiDateDebut = DateTime(DateTime.now().year, 1, 1);
  DateTime _delaiDateFin   = DateTime.now();
  DateTime? _actDateDebut;
  DateTime? _actDateFin;

  // ── Confirm-clear dialog (activité only) ───────────────────────────────────
  bool _showClearConfirm = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final urgentes       = await _service.fetchUrgentes();
    final pipeline       = await _service.fetchPipeline();
    final classifications = await _service.fetchClassifications(
        dateDebut: _classDateDebut, dateFin: _classDateFin);
    final presence       = await _service.fetchPresence(
        dateDebut: _presDateDebut, dateFin: _presDateFin);
    final delai          = await _service.fetchDelai(
        dateDebut: _delaiDateDebut, dateFin: _delaiDateFin);
    final act            = await _service.fetchActivite(
        dateDebut: _actDateDebut, dateFin: _actDateFin, offset: 0);
    if (!mounted) return;
    setState(() {
      _urgentes        = urgentes;
      _pipeline        = pipeline;
      _classifications = classifications;
      _presence        = presence;
      _delai           = delai;
      _activite        = act.items;
      _activiteTotal   = act.total;
    });
  }

  Future<void> _reloadClassifications() async {
    final data = await _service.fetchClassifications(
        dateDebut: _classDateDebut, dateFin: _classDateFin);
    if (mounted) setState(() => _classifications = data);
  }

  Future<void> _reloadPresence() async {
    final data = await _service.fetchPresence(
        dateDebut: _presDateDebut, dateFin: _presDateFin);
    if (mounted) setState(() => _presence = data);
  }

  Future<void> _reloadDelai() async {
    final data = await _service.fetchDelai(
        dateDebut: _delaiDateDebut, dateFin: _delaiDateFin);
    if (mounted) setState(() => _delai = data);
  }

  Future<void> _reloadActivite() async {
    final data = await _service.fetchActivite(
        dateDebut: _actDateDebut, dateFin: _actDateFin, offset: 0);
    if (mounted) setState(() {
      _activite      = data.items;
      _activiteTotal = data.total;
    });
  }

  Future<void> _loadMoreActivite() async {
    if (_activiteLoading || _activite.length >= _activiteTotal) return;
    setState(() => _activiteLoading = true);
    final data = await _service.fetchActivite(
        dateDebut: _actDateDebut, dateFin: _actDateFin, offset: _activite.length);
    if (mounted) setState(() {
      _activite.addAll(data.items);
      _activiteTotal  = data.total;
      _activiteLoading = false;
    });
  }

  // ── Date sheet helper ──────────────────────────────────────────────────────
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

  // ── Date chip format ───────────────────────────────────────────────────────
  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _chipLabel({required DateTime? debut, required DateTime? fin}) {
    if (debut == null) return 'Filtrer';
    if (fin == null || (debut.year == fin.year && debut.month == fin.month && debut.day == fin.day)) {
      return _fmtDate(debut);
    }
    return '${debut.day} ${_moisAbr[debut.month - 1]} → ${fin.day} ${_moisAbr[fin.month - 1]}';
  }

  static const _moisAbr = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 52),
          children: [
            if (_urgentes.isNotEmpty) ...[
              _buildUrgentes(),
              const SizedBox(height: 12),
            ],
            _buildPipeline(),
            const SizedBox(height: 12),
            _buildClassifications(),
            const SizedBox(height: 12),
            _buildPresence(),
            const SizedBox(height: 12),
            _buildDelai(),
            const SizedBox(height: 12),
            _buildActivite(),
          ],
        ),
        if (_showClearConfirm) _buildClearConfirmDialog(),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 1: URGENTES
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUrgentes() {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFFFDF4F3),
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: _red, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 2)],
                ),
              ),
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
          // Rows
          ..._urgentes.map((u) {
            final isCritique = u.joursEnAttente >= 2;
            return GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EvaluationEchantillonsPage())),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
                ),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(u.reference,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
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
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: isCritique ? _red : _amber),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 15, color: Colors.grey.shade300),
                ]),
              ),
            );
          }),
          // Hint
          Container(
            color: const Color(0xFFF8F8F8),
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
            child: SizedBox(width: double.infinity,
              child: Text("Appuyez pour ouvrir l'évaluation organoleptique",
                  textAlign: TextAlign.center, softWrap: true,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic))),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 2: PIPELINE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPipeline() {
    final p = _pipeline;
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Pipeline de mes évaluations', Icons.timeline_outlined),
        const SizedBox(height: 14),
        Row(children: [
          _pipeCol(p?.nonEvaluee ?? 0, 'Non\névaluée', _blue),
          _pipeArrow(),
          _pipeCol(p?.enCours ?? 0, 'En\ncours', _amber),
          _pipeArrow(),
          _pipeCol(p?.soumise ?? 0, 'Soumise', _green),
        ]),
      ]),
    );
  }

  Widget _pipeCol(int n, String label, Color color) => Expanded(
    child: Column(children: [
      Text('$n', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Container(height: 2, margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(2))),
      Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))),
    ]),
  );

  Widget _pipeArrow() => const Padding(
    padding: EdgeInsets.only(bottom: 20),
    child: Text('›', style: TextStyle(fontSize: 14, color: Color(0xFFEEEEEE))),
  );
```

- [ ] **Verify the file compiles (no red errors in IDE), then commit:**

```bash
git add lib/3_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(degustateur): dashboard skeleton + urgentes + pipeline sections"
```

---

## Task 4: Add section 3 — Classifications bar chart

**Files:**
- Modify: `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Add the import for fl_chart at the top of the file (after existing imports):**

```dart
import 'package:fl_chart/fl_chart.dart';
```

- [ ] **Add `_buildClassifications()` method to `_HomeBodyState` (before the closing `}`):**

```dart
  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 3: CLASSIFICATIONS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildClassifications() {
    final classActive = _classDateDebut != null;
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _sectionLabel('Mes classifications', Icons.check_box_outlined)),
          _dateChip(
            label: _chipLabel(debut: _classDateDebut, fin: _classDateFin),
            active: classActive,
            onTap: () => _openDateSheet(
              titre: 'Filtrer les classifications',
              dateDebut: _classDateDebut,
              dateFin: _classDateFin,
              periodOnly: false,
              onApply: (debut, fin) {
                setState(() { _classDateDebut = debut; _classDateFin = fin; });
                _reloadClassifications();
              },
              onClear: () {
                setState(() { _classDateDebut = null; _classDateFin = null; });
                _reloadClassifications();
              },
            ),
          ),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: _classifications.isEmpty
              ? const Center(child: Text('Aucune donnée', style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))))
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _classifications
                        .map((p) => (p.extraVierge + p.vierge + p.lampante).toDouble())
                        .fold(0.0, (a, b) => a > b ? a : b) + 1,
                    barGroups: List.generate(_classifications.length, (i) {
                      final p = _classifications[i];
                      return BarChartGroupData(x: i, barRods: [
                        BarChartRodData(toY: p.extraVierge.toDouble(), color: _green,
                            width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                        BarChartRodData(toY: p.vierge.toDouble(), color: _olive,
                            width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                        BarChartRodData(toY: p.lampante.toDouble(), color: _amber,
                            width: 10, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                      ]);
                    }),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 22,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= _classifications.length) return const SizedBox();
                          return Padding(padding: const EdgeInsets.only(top: 6),
                            child: Text(_classifications[i].label,
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))));
                        },
                      )),
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 18,
                        getTitlesWidget: (v, _) => v % 1 == 0
                            ? Text(v.toInt().toString(), style: const TextStyle(fontSize: 9, color: Color(0xFFCCCCCC)))
                            : const SizedBox(),
                      )),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true, drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(color: Color(0x0D000000), strokeWidth: 1),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        // Legend
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _legendDot(_green, 'Extra Vierge'),
          const SizedBox(width: 12),
          _legendDot(_olive, 'Vierge'),
          const SizedBox(width: 12),
          _legendDot(_amber, 'Lampante'),
        ]),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _dark)),
  ]);
```

- [ ] **Commit**

```bash
git add lib/3_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(degustateur): add classifications bar chart section"
```

---

## Task 5: Add section 4 — Présence aux séances

**Files:**
- Modify: `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Add `_buildPresence()` method to `_HomeBodyState`:**

```dart
  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 4: PRESENCE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPresence() {
    final p = _presence;
    final presActive = _presDateDebut != null;
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _sectionLabel('Présence aux séances', Icons.people_outline_rounded)),
          _dateChip(
            label: _chipLabel(debut: _presDateDebut, fin: _presDateFin),
            active: presActive,
            onTap: () => _openDateSheet(
              titre: 'Filtrer les séances',
              dateDebut: _presDateDebut,
              dateFin: _presDateFin,
              periodOnly: false,
              onApply: (debut, fin) {
                setState(() { _presDateDebut = debut; _presDateFin = fin; });
                _reloadPresence();
              },
              onClear: () {
                setState(() { _presDateDebut = null; _presDateFin = null; });
                _reloadPresence();
              },
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          // Donut
          SizedBox(
            width: 78, height: 78,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: p?.taux ?? 0,
                strokeWidth: 9,
                backgroundColor: const Color(0xFFF1F4F1),
                valueColor: const AlwaysStoppedAnimation<Color>(_green),
                strokeCap: StrokeCap.round,
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${((p?.taux ?? 0) * 100).toInt()}%',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _green)),
                const Text('présence', style: TextStyle(fontSize: 8, color: Color(0xFFAAAAAA))),
              ]),
            ]),
          ),
          const SizedBox(width: 16),
          // Stats
          Expanded(child: Column(children: [
            _attStat(const Color(0xFF38835A), 'Séances présent', '${p?.present ?? 0}', _green),
            const SizedBox(height: 7),
            _attStat(_red, 'Séances manquées', '${p?.manquee ?? 0}', _red),
            const SizedBox(height: 7),
            _attStat(const Color(0xFFE5E7E5), 'Total', '${p?.total ?? 0}', _dark),
          ])),
        ]),
        if (p?.prochaineDate != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _green.withValues(alpha: 0.12)),
            ),
            child: Row(children: [
              const Icon(Icons.access_time_outlined, size: 14, color: _green),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Prochaine séance : ${p!.prochaineDate}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _dark)),
                if (p.prochaineLieu != null)
                  Text(p.prochaineLieu!,
                      style: const TextStyle(fontSize: 10, color: Color(0xFFAAAAAA))),
              ])),
              if (p.prochaineCountdown != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(p.prochaineCountdown!,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _green)),
                ),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _attStat(Color dotColor, String label, String value, Color valueColor) =>
    Row(children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF777777)))),
      Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor)),
    ]);
```

- [ ] **Commit**

```bash
git add lib/3_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(degustateur): add presence aux seances section"
```

---

## Task 6: Add section 5 — Délai de soumission

**Files:**
- Modify: `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Add `_buildDelai()` method to `_HomeBodyState`:**

```dart
  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 5: DÉLAI DE SOUMISSION
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDelai() {
    final d = _delai;
    final diff = d != null ? d.monDelaiMoyen - d.panelMoyen : 0.0;
    final isBetter = diff <= 0;

    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _sectionLabel('Délai de soumission', Icons.timer_outlined)),
          _dateChip(
            label: '${_fmtDate(_delaiDateDebut)} → ${_fmtDate(_delaiDateFin)}',
            active: true,
            onTap: () => _openDateSheet(
              titre: 'Délai de soumission — période',
              dateDebut: _delaiDateDebut,
              dateFin: _delaiDateFin,
              periodOnly: true,
              onApply: (debut, fin) {
                setState(() {
                  _delaiDateDebut = debut;
                  _delaiDateFin   = fin ?? debut;
                });
                _reloadDelai();
              },
              onClear: () {
                setState(() {
                  _delaiDateDebut = DateTime(DateTime.now().year, 1, 1);
                  _delaiDateFin   = DateTime.now();
                });
                _reloadDelai();
              },
            ),
          ),
        ]),
        const SizedBox(height: 10),
        // Summary strip
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAF8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            _summaryItem(
              label: 'Mon délai moy.',
              value: d != null ? '${d.monDelaiMoyen.toStringAsFixed(1)}j' : '—',
              valueColor: _amber,
              sub: diff == 0 ? null : (isBetter ? '↑ −${diff.abs().toStringAsFixed(1)}j vs panel' : '↓ +${diff.toStringAsFixed(1)}j vs panel'),
              subColor: isBetter ? _green : _red,
            ),
            Container(width: 1, height: 40, color: Colors.black.withValues(alpha: 0.07)),
            _summaryItem(label: 'Moy. panel', value: d != null ? '${d.panelMoyen.toStringAsFixed(1)}j' : '—', valueColor: _green, sub: 'sur la période'),
            Container(width: 1, height: 40, color: Colors.black.withValues(alpha: 0.07)),
            _summaryItem(label: 'Évals.', value: '${d?.nbEvals ?? 0}', valueColor: _dark, sub: 'comptées'),
          ]),
        ),
        const SizedBox(height: 10),
        // Line chart
        SizedBox(
          height: 120,
          child: d == null || d.points.isEmpty
              ? const Center(child: Text('Aucune donnée', style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA))))
              : LineChart(LineChartData(
                  minY: 0, maxY: 4,
                  gridData: FlGridData(
                    show: true, drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => const FlLine(color: Color(0x0D000000), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 24,
                      getTitlesWidget: (v, _) => v % 1 == 0
                          ? Text('${v.toInt()}j', style: const TextStyle(fontSize: 8, color: Color(0xFFCCCCCC)))
                          : const SizedBox(),
                    )),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true, reservedSize: 20,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= d.points.length || i % (d.points.length > 6 ? 2 : 1) != 0) return const SizedBox();
                        final dt = d.points[i].date;
                        return Padding(padding: const EdgeInsets.only(top: 4),
                          child: Text('${dt.day} ${_moisAbr[dt.month - 1]}',
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))));
                      },
                    )),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // My delay — amber solid
                    LineChartBarData(
                      spots: List.generate(d.points.length,
                          (i) => FlSpot(i.toDouble(), d.points[i].monDelai)),
                      isCurved: true, curveSmoothness: 0.3,
                      color: _amber, barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (p, x, bar, i) => FlDotCirclePainter(
                            radius: 3, color: _amber, strokeColor: Colors.white, strokeWidth: 1.5),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(colors: [
                          _amber.withValues(alpha: 0.12), _amber.withValues(alpha: 0),
                        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                    // Panel average — dashed green
                    LineChartBarData(
                      spots: List.generate(d.points.length,
                          (i) => FlSpot(i.toDouble(), d.points[i].panelMoyen)),
                      isCurved: true, curveSmoothness: 0.3,
                      color: const Color(0xFFB8DCC8), barWidth: 1.5,
                      dashArray: [5, 4],
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) => spots.map((s) =>
                        LineTooltipItem('${s.y.toStringAsFixed(1)}j',
                          TextStyle(color: s.bar.color, fontWeight: FontWeight.w700, fontSize: 11))
                      ).toList(),
                    ),
                  ),
                )),
        ),
        const SizedBox(height: 8),
        // Legend
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 16, height: 2, color: _amber),
          const SizedBox(width: 5),
          const Text('Mon délai', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _dark)),
          const SizedBox(width: 14),
          _dashedLegendLine(),
          const SizedBox(width: 5),
          const Text('Moy. panel', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _dark)),
        ]),
      ]),
    );
  }

  Widget _summaryItem({required String label, required String value, required Color valueColor, String? sub, Color? subColor}) =>
    Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFAAAAAA), letterSpacing: 0.4), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor, height: 1)),
        if (sub != null) ...[
          const SizedBox(height: 3),
          Text(sub, style: TextStyle(fontSize: 9, color: subColor ?? const Color(0xFFAAAAAA)), textAlign: TextAlign.center),
        ],
      ]),
    ));

  Widget _dashedLegendLine() => SizedBox(
    width: 16, height: 12,
    child: CustomPaint(painter: _DashPainter()),
  );
```

- [ ] **Add `_DashPainter` class at the bottom of the file (after `_HomeBodyState`):**

```dart
class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB8DCC8)..strokeWidth = 2..strokeCap = StrokeCap.round;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset((x + 4).clamp(0, size.width), size.height / 2), paint);
      x += 7;
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
```

- [ ] **Commit**

```bash
git add lib/3_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(degustateur): add delai de soumission line chart section"
```

---

## Task 7: Add section 6 — Activité récente

**Files:**
- Modify: `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Add `_buildActivite()` and `_buildClearConfirmDialog()` methods to `_HomeBodyState`:**

```dart
  // ─────────────────────────────────────────────────────────────────────────
  // SECTION 6: ACTIVITÉ RÉCENTE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActivite() {
    final actActive = _actDateDebut != null;
    return Container(
      decoration: BoxDecoration(
        color: _white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _sectionLabel('Activité récente', Icons.access_time_outlined)),
              _dateChip(
                label: _chipLabel(debut: _actDateDebut, fin: _actDateFin),
                active: actActive,
                onTap: () => _openDateSheet(
                  titre: "Filtrer l'activité",
                  dateDebut: _actDateDebut,
                  dateFin: _actDateFin,
                  periodOnly: false,
                  onApply: (debut, fin) {
                    setState(() { _actDateDebut = debut; _actDateFin = fin; });
                    _reloadActivite();
                  },
                  onClear: () {
                    setState(() { _actDateDebut = null; _actDateFin = null; });
                    _reloadActivite();
                  },
                ),
              ),
            ]),
            if (actActive) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.06),
                  border: Border.all(color: _green.withValues(alpha: 0.15)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  Icon(Icons.filter_list, size: 11, color: _green),
                  const SizedBox(width: 6),
                  Text(
                    _actDateFin != null
                        ? '${_fmtDate(_actDateDebut!)} → ${_fmtDate(_actDateFin!)}'
                        : _fmtDate(_actDateDebut!),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _green),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _showClearConfirm = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('✕ Effacer',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA))),
                    ),
                  ),
                ]),
              ),
            ],
            const SizedBox(height: 10),
          ]),
        ),
        // Scrollable timeline
        SizedBox(
          height: 210,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification && n.metrics.pixels >= n.metrics.maxScrollExtent - 40) {
                _loadMoreActivite();
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              itemCount: _activite.length,
              itemBuilder: (_, i) => _timelineItem(_activite[i], isLast: i == _activite.length - 1),
            ),
          ),
        ),
        // Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAF8),
            border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          ),
          child: Row(children: [
            Text(
              _activite.length >= _activiteTotal
                  ? '$_activiteTotal sur $_activiteTotal — tout chargé'
                  : '1–${_activite.length} sur $_activiteTotal',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFAAAAAA)),
            ),
            if (_activiteLoading) ...[
              const SizedBox(width: 10),
              const SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: _green)),
            ],
          ]),
        ),
      ]),
    );
  }

  Widget _timelineItem(ActiviteItem item, {required bool isLast}) {
    final Color dotColor;
    switch (item.type) {
      case 'seance_presente': dotColor = _blue; break;
      case 'seance_manquee':  dotColor = _red; break;
      case 'profil':          dotColor = _amber; break;
      default:                dotColor = _green;
    }
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 12, height: 12, margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: dotColor, shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 2)],
            ),
          ),
          if (!isLast)
            Expanded(child: Container(width: 1, color: const Color(0xFFE5E7E5))),
        ]),
        const SizedBox(width: 10),
        Expanded(child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.action,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _dark, height: 1.3)),
            const SizedBox(height: 2),
            Text(item.horodatage,
                style: const TextStyle(fontSize: 10, color: Color(0xFFBBBBBB))),
          ]),
        )),
      ]),
    );
  }

  // ── Confirm clear dialog (overlay) ────────────────────────────────────────
  Widget _buildClearConfirmDialog() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Effacer le filtre ?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
            const SizedBox(height: 8),
            const Text('Le filtre de date sera supprimé et toute l\'activité sera visible.',
                style: TextStyle(fontSize: 12, color: Color(0xFF666666), height: 1.5),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _showClearConfirm = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F1), borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE8EAE8)),
                  ),
                  child: const Text('Annuler', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _dark)),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
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
                    color: _red, borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Effacer', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              )),
            ]),
          ]),
        ),
      ),
    );
  }
```

- [ ] **Commit**

```bash
git add lib/3_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(degustateur): add activite recente section with pagination"
```

---

## Task 8: Add shared helper methods and card widget

**Files:**
- Modify: `lib/3_degustateur/tableau_de_bord/widgets/home_body.dart`

- [ ] **Add these shared helpers to `_HomeBodyState` (before the first section build method):**

```dart
  // ── Shared helpers ─────────────────────────────────────────────────────────

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
          Text(label, style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: active ? _green : _dark,
          )),
          if (active) ...[
            const SizedBox(width: 4),
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
          ],
        ]),
      ),
    );
```

- [ ] **Commit**

```bash
git add lib/3_degustateur/tableau_de_bord/widgets/home_body.dart
git commit -m "feat(degustateur): add shared card/label/chip helpers to home_body"
```

---

## Task 9: Update homepage_page.dart

**Files:**
- Modify: `lib/3_degustateur/tableau_de_bord/homepage_page.dart`

- [ ] **Remove `onSimulerNotification` from `HomeBody` call and simplify `HomeBody` constructor. In `homepage_page.dart`, change:**

```dart
// OLD:
body: HomeBody(
  onSimulerNotification: () =>
      _addNotification('Nouveau rapport disponible'),
),
```

```dart
// NEW:
body: const HomeBody(),
```

- [ ] **Also remove the `_addNotification` and `_markAllAsRead` methods from `_HomePageState` if they are no longer called by anything else (keep the notification bell and `_notificationCount` if still used in the AppBar).**

- [ ] **Commit**

```bash
git add lib/3_degustateur/tableau_de_bord/homepage_page.dart
git commit -m "refactor(degustateur): simplify homepage_page, remove simuler notification"
```

---

## Task 10: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Add the following section to CLAUDE.md before the "Key Conventions" section:**

```markdown
## Taster Dashboard — Business Logic

### Urgency rule (Évaluations urgentes)
A sample appears in the urgent panel if ALL of the following are true:
- `recuPhysiquement == true` (sample physically at company)
- The taster has NOT yet submitted their evaluation for this sample
- Days waiting = `DateTime.now().difference(sample.dateReceptionEchantillon).inDays`
  - 1 day  → amber badge: `"1j en attente"`
  - 2+ days → red badge: `"Xj — critique"`

### Délai de soumission formula
- **Per evaluation:** `delai = date_evaluation_soumise − date_reception_echantillon` (in fractional days)
- **Mon délai moy.:** AVG of all my delays for evaluations submitted within the chosen period
- **Moy. panel:** AVG of all delays for ALL active tasters on the same period
- Backend endpoints:
  - `GET /api/degustateur/dashboard/delai/?date_debut=YYYY-MM-DD&date_fin=YYYY-MM-DD`
  - Returns: `{ "mon_delai_moyen": 1.8, "panel_moyen": 1.4, "nb_evals": 23, "points": [...] }`

### Activité récente — pagination
- Page size: **5 items per load**
- Auto-loads next batch when user scrolls to bottom (no explicit button)
- Backend: `GET /api/activite/?date_debut=...&date_fin=...&offset=0&limit=5`
- Follows Django paginated format: `{ "count": N, "results": [...] }`
- Clearing the filter badge requires a confirmation dialog to prevent accidental clear
```

- [ ] **Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add taster dashboard business logic to CLAUDE.md"
```

---

## Task 11: Replace CEO dashboard date filter

**Files:**
- Modify: `lib/1_ceo/tableau_de_bord/tableau_de_bord.dart`

- [ ] **Add import for `DateFilterSheet` at the top:**

```dart
import '../../3_degustateur/gestion_echantillons/widgets/search_filter_bar.dart';
```

- [ ] **Replace the `_pickRange` method with a new one that uses `DateFilterSheet`:**

```dart
  Future<void> _pickRange(
    _CardDateRange current,
    void Function(_CardDateRange) onApply,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        titre: 'Filtrer par période',
        dateDebut: current.from,
        dateFin: current.to,
        onApply: (debut, fin) => setState(
          () => onApply(_CardDateRange(debut, fin ?? debut)),
        ),
        onClear: () => setState(
          () => onApply(_CardDateRange(
            DateTime(2025, 11, 1),
            DateTime(2026, 4, 30),
          )),
        ),
      ),
    );
  }
```

- [ ] **Delete the `_PeriodSheet` class and its `_presets()` method** (search for `class _PeriodSheet` at the bottom of `tableau_de_bord.dart` and remove it entirely — it is replaced by `DateFilterSheet`).

- [ ] **Remove the `onCustom` call inside the old `_pickRange`** (already done by the replacement above).

- [ ] **Run `flutter analyze` and fix any warnings:**

```bash
flutter analyze lib/1_ceo/tableau_de_bord/tableau_de_bord.dart
```

- [ ] **Commit**

```bash
git add lib/1_ceo/tableau_de_bord/tableau_de_bord.dart
git commit -m "refactor(ceo): replace _PeriodSheet with DateFilterSheet for consistency"
```

---

## Task 12: Final check

- [ ] **Run `flutter analyze`:**

```bash
flutter analyze lib/
```

Expected: no errors. Warnings about unused imports are acceptable (linter allows them per `analysis_options.yaml`).

- [ ] **Run the app and verify each section renders:**

```bash
flutter run
```

Navigate to the taster dashboard and confirm:
1. Urgent evaluations show with correct badge colors (amber = 1j, red = 2j+)
2. Pipeline shows 3 counters
3. Classifications bar chart renders with legend
4. Présence donut + next session teaser shows
5. Délai line chart renders with summary strip
6. Activité récente loads 5 items, scrolling loads 5 more, filter chip opens DateFilterSheet, ✕ Effacer triggers confirmation dialog

- [ ] **Final commit**

```bash
git add -A
git commit -m "feat(degustateur): complete taster dashboard redesign"
```
