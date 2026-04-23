// ═════════════════════════════════════════════════════════════════════════════
// FILE    : vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart
// PURPOSE : Chef de Panel — all tasters' submitted evaluations per sample,
//           side by side. Read-only overview for panel management.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profil.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../tableau_de_bord/homepage_page.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../../../main.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _bg       = Color(0xFFFFFFFF);
const Color _olive    = Color(0xFF6B8143);

// ── Mock data structures ──────────────────────────────────────────────────────

class _EvalEntry {
  final String attribut;
  final double score;
  const _EvalEntry(this.attribut, this.score);
}

class _TasterEval {
  final String tasterName;
  final String statut; // 'Soumis' | 'En attente'
  final String? dateEval;
  final String? classification;
  final List<_EvalEntry> scores;
  const _TasterEval({
    required this.tasterName,
    required this.statut,
    this.dateEval,
    this.classification,
    this.scores = const [],
  });
}

class _SampleEvalGroup {
  final String sampleId;
  final String referenceBouteille;
  final String gouvernorat;
  final String variete;
  final List<_TasterEval> evaluations;
  const _SampleEvalGroup({
    required this.sampleId,
    required this.referenceBouteille,
    required this.gouvernorat,
    required this.variete,
    required this.evaluations,
  });
}

const _attrs = ['Fruité', 'Amer', 'Piquant', 'Doux', 'Floral'];

final _mockGroups = [
  _SampleEvalGroup(
    sampleId: 'OL-2024-001',
    referenceBouteille: 'REF-2024-0341',
    gouvernorat: 'Sfax',
    variete: 'Chemlali',
    evaluations: [
      _TasterEval(
        tasterName: 'Ichrak C.',
        statut: 'Soumis',
        dateEval: '20/02/2026',
        classification: 'Extra Vierge',
        scores: [
          _EvalEntry('Fruité', 4.5),
          _EvalEntry('Amer',   3.8),
          _EvalEntry('Piquant',3.5),
          _EvalEntry('Doux',   4.2),
          _EvalEntry('Floral', 4.0),
        ],
      ),
      _TasterEval(
        tasterName: 'Lobna E.',
        statut: 'Soumis',
        dateEval: '20/02/2026',
        classification: 'Extra Vierge',
        scores: [
          _EvalEntry('Fruité', 4.2),
          _EvalEntry('Amer',   4.0),
          _EvalEntry('Piquant',3.8),
          _EvalEntry('Doux',   3.9),
          _EvalEntry('Floral', 3.7),
        ],
      ),
      _TasterEval(
        tasterName: 'Maha O.',
        statut: 'Soumis',
        dateEval: '21/02/2026',
        classification: 'Vierge',       // diverges from group
        scores: [
          _EvalEntry('Fruité', 2.5),    // outlier scores
          _EvalEntry('Amer',   2.0),
          _EvalEntry('Piquant',1.8),
          _EvalEntry('Doux',   2.5),
          _EvalEntry('Floral', 2.2),
        ],
      ),
      _TasterEval(
        tasterName: 'Nayrouz F.',
        statut: 'En attente',
        scores: [],
      ),
    ],
  ),
  _SampleEvalGroup(
    sampleId: 'OL-2024-002',
    referenceBouteille: 'REF-2024-0342',
    gouvernorat: 'Bizerte',
    variete: 'Chetoui',
    evaluations: [
      _TasterEval(
        tasterName: 'Nayrouz F.',
        statut: 'Soumis',
        dateEval: '21/02/2026',
        classification: 'Extra Vierge',
        scores: [
          _EvalEntry('Fruité', 3.9),
          _EvalEntry('Amer',   4.1),
          _EvalEntry('Piquant',3.7),
          _EvalEntry('Doux',   3.5),
          _EvalEntry('Floral', 3.8),
        ],
      ),
      _TasterEval(
        tasterName: 'Yosra S.',
        statut: 'Soumis',
        dateEval: '21/02/2026',
        classification: 'Extra Vierge',
        scores: [
          _EvalEntry('Fruité', 4.1),
          _EvalEntry('Amer',   3.9),
          _EvalEntry('Piquant',3.6),
          _EvalEntry('Doux',   3.7),
          _EvalEntry('Floral', 4.0),
        ],
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
class VueEnsembleEvaluationsPage extends StatefulWidget {
  const VueEnsembleEvaluationsPage({super.key});

  @override
  State<VueEnsembleEvaluationsPage> createState() =>
      _VueEnsembleEvaluationsPageState();
}

class _VueEnsembleEvaluationsPageState
    extends State<VueEnsembleEvaluationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeFilter; // null = all, 'complet', 'partiel'
  final Set<String> _expanded = {};

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

  List<_SampleEvalGroup> get _filtered {
    var list = _mockGroups;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((g) =>
        g.sampleId.toLowerCase().contains(q) ||
        g.referenceBouteille.toLowerCase().contains(q) ||
        g.gouvernorat.toLowerCase().contains(q) ||
        g.variete.toLowerCase().contains(q),
      ).toList();
    }
    if (_activeFilter == 'complet') {
      list = list
          .where((g) => g.evaluations.every((e) => e.statut == 'Soumis'))
          .toList();
    } else if (_activeFilter == 'partiel') {
      list = list
          .where((g) => g.evaluations.any((e) => e.statut == 'En attente'))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      drawer: AppDrawer(
        onaccueil: () => _goTo(const HomePage()),
        onEvaluationEchantillons: () => _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onVueEnsembleEvaluations: () => Navigator.pop(context),
        onProfil: () => _goTo(const ProfilePage()),
        onAPropos: () => Navigator.pop(context),
        onDeconnexion: _goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Vue d\'ensemble évaluations',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        iconTheme: const IconThemeData(color: _dark),
      ),
      body: Column(
        children: [
          // ── Header zone ────────────────────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  style: const TextStyle(fontSize: 14, color: _dark),
                  decoration: InputDecoration(
                    hintText: 'Rechercher échantillon, variété, gouvernorat…',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B8E7A),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B8E7A),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 17, color: Color(0xFF6B8E7A)),
                            onPressed: () => setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
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
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        active: _activeFilter == null,
                        activeColor: const Color(0xFF757575),
                        onTap: () => setState(() => _activeFilter = null),
                      ),
                      const SizedBox(width: 7),
                      _FilterChip(
                        label: 'Complet',
                        active: _activeFilter == 'complet',
                        activeColor: _green,
                        onTap: () => setState(() => _activeFilter = 'complet'),
                      ),
                      const SizedBox(width: 7),
                      _FilterChip(
                        label: 'En cours',
                        active: _activeFilter == 'partiel',
                        activeColor: const Color(0xFFD07B2F),
                        onTap: () => setState(() => _activeFilter = 'partiel'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                Icon(Icons.assessment_outlined, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  '${groups.length} échantillon${groups.length > 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: groups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assessment_outlined, size: 52, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun échantillon trouvé',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                    itemCount: groups.length,
                    itemBuilder: (_, i) => _SampleEvalCard(
                      group: groups[i],
                      isExpanded: _expanded.contains(groups[i].sampleId),
                      onToggle: () => setState(() {
                        if (_expanded.contains(groups[i].sampleId)) {
                          _expanded.remove(groups[i].sampleId);
                        } else {
                          _expanded.add(groups[i].sampleId);
                        }
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE EVAL CARD
// ─────────────────────────────────────────────────────────────────────────────
class _SampleEvalCard extends StatelessWidget {
  final _SampleEvalGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _SampleEvalCard({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
  });

  int get _submitted =>
      group.evaluations.where((e) => e.statut == 'Soumis').length;
  int get _total => group.evaluations.length;
  bool get _isComplete => _submitted == _total;
  bool get _hasOutlier => _detectOutlier();

  bool _detectOutlier() {
    final submitted = group.evaluations.where((e) => e.scores.isNotEmpty).toList();
    if (submitted.length < 3) return false;
    for (int a = 0; a < _attrs.length; a++) {
      final vals = submitted.map((e) {
        final entry = e.scores.where((s) => s.attribut == _attrs[a]);
        return entry.isEmpty ? 0.0 : entry.first.score;
      }).toList();
      final avg = vals.fold(0.0, (s, v) => s + v) / vals.length;
      for (final v in vals) {
        if ((v - avg).abs() > 1.5) return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = _isComplete ? _green : const Color(0xFFD07B2F);
    final tintColor   = _isComplete
        ? const Color(0xFFEAF4EE)
        : const Color(0xFFFFF3E0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: accentColor),
                  Expanded(
                    child: Container(
                      color: tintColor,
                      padding: const EdgeInsets.fromLTRB(13, 11, 12, 11),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.referenceBouteille,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${group.gouvernorat} · ${group.variete}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_hasOutlier)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.warning_amber_rounded, size: 10, color: Colors.orange.shade700),
                                const SizedBox(width: 3),
                                Text('Divergence', style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w700,
                                  color: Colors.orange.shade700,
                                )),
                              ]),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$_submitted / $_total',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Expanded evaluations ──────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _EvalGrid(evaluations: group.evaluations),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EVAL GRID — tasters side by side
// ─────────────────────────────────────────────────────────────────────────────
class _EvalGrid extends StatelessWidget {
  final List<_TasterEval> evaluations;
  const _EvalGrid({required this.evaluations});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFF9FAF8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: evaluations.map((e) => _TasterColumn(eval: e)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TASTER COLUMN — one column per taster
// ─────────────────────────────────────────────────────────────────────────────
class _TasterColumn extends StatelessWidget {
  final _TasterEval eval;
  const _TasterColumn({required this.eval});

  @override
  Widget build(BuildContext context) {
    final submitted = eval.statut == 'Soumis';

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: submitted ? Colors.grey.shade200 : Colors.grey.shade100,
        ),
        boxShadow: submitted
            ? [BoxShadow(color: _green.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Taster header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: submitted
                  ? _green.withValues(alpha: 0.06)
                  : Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                eval.tasterName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 3),
              Row(children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: submitted ? _green : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  eval.statut,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: submitted ? _green : Colors.grey.shade400,
                  ),
                ),
              ]),
              if (eval.dateEval != null)
                Text(
                  eval.dateEval!,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                ),
            ]),
          ),
          // ── Body ─────────────────────────────────────────────────────
          if (!submitted)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Évaluation non encore soumise',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else ...[
            if (eval.classification != null)
              Container(
                margin: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _classColor(eval.classification!).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  eval.classification!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _classColor(eval.classification!),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Column(
                children: eval.scores.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(s.attribut, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                      Text(s.score.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _dark)),
                    ]),
                    const SizedBox(height: 3),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: s.score / 5),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: v,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(s.score)),
                          minHeight: 4,
                        ),
                      ),
                    ),
                  ]),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _classColor(String c) {
    switch (c) {
      case 'Extra Vierge': return _green;
      case 'Vierge':       return Colors.orange.shade600;
      default:             return Colors.red.shade400;
    }
  }

  Color _scoreColor(double score) {
    if (score >= 4.0) return _green;
    if (score >= 3.0) return _olive;
    return Colors.orange.shade600;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const inactiveBg = Color(0xFFF0F0F0);
    const inactiveFg = Color(0xFF9E9E9E);
    const inactiveBorder = Color(0xFFE0E0E0);

    final bg     = active ? activeColor : inactiveBg;
    final fg     = active ? Colors.white : inactiveFg;
    final border = active ? activeColor.withValues(alpha: 0.4) : inactiveBorder;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.2),
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
