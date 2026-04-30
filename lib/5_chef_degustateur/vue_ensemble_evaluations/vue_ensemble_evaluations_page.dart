// ═════════════════════════════════════════════════════════════════════════════
// FILE : vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart
// PURPOSE : Chef de Panel — all tasters' submitted evaluations per sample,
//           read-only overview. "Voir" opens the shared CEO evaluation form sheet.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profil.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../tableau_de_bord/homepage_page.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../gestion_echantillons/widgets/search_filter_bar.dart'
    show DateFilterSheet;
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
// TODO(core): move shared_evaluation_form_sheet to lib/core/widgets/ — cross-module import from 1_ceo
import '../../../1_ceo/widgets/shared_evaluation_form_sheet.dart';
// TODO(core): create a shared EchantillonView model in lib/core/models/ — cross-module import from 1_ceo
import '../../../1_ceo/utilisateurs/models/echantillon_ceo_view.dart';
import '../../../main.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _bg = Color(0xFFFFFFFF);
const Color _olive = Color(0xFF6B8143);

// ── Models ────────────────────────────────────────────────────────────────────

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
  final String dateAjout;
  final bool recuPhysiquement;
  final String? dateReceptionPhysique;
  final List<_TasterEval> evaluations;

  const _SampleEvalGroup({
    required this.sampleId,
    required this.referenceBouteille,
    required this.gouvernorat,
    required this.variete,
    required this.dateAjout,
    required this.recuPhysiquement,
    this.dateReceptionPhysique,
    required this.evaluations,
  });

  int get submitted => evaluations.where((e) => e.statut == 'Soumis').length;
  int get total => evaluations.length;
  bool get isComplete => submitted == total && total > 0;
}

const _attrs = ['Fruité', 'Amer', 'Piquant', 'Doux', 'Floral'];

// ── Mock data ─────────────────────────────────────────────────────────────────

final _mockGroups = [
  _SampleEvalGroup(
    sampleId: 'OL-2024-001',
    referenceBouteille: 'REF-2024-0341',
    gouvernorat: 'Sfax',
    variete: 'Chemlali',
    dateAjout: '20/02/2026',
    recuPhysiquement: true,
    dateReceptionPhysique: '18/02/2026',
    evaluations: [
      _TasterEval(
        tasterName: 'Ichrak C.',
        statut: 'Soumis',
        dateEval: '20/02/2026',
        classification: 'Extra Vierge',
        scores: [
          _EvalEntry('Fruité', 4.5),
          _EvalEntry('Amer', 3.8),
          _EvalEntry('Piquant', 3.5),
          _EvalEntry('Doux', 4.2),
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
          _EvalEntry('Amer', 4.0),
          _EvalEntry('Piquant', 3.8),
          _EvalEntry('Doux', 3.9),
          _EvalEntry('Floral', 3.7),
        ],
      ),
      _TasterEval(
        tasterName: 'Maha O.',
        statut: 'Soumis',
        dateEval: '21/02/2026',
        classification: 'Vierge',
        scores: [
          _EvalEntry('Fruité', 2.5),
          _EvalEntry('Amer', 2.0),
          _EvalEntry('Piquant', 1.8),
          _EvalEntry('Doux', 2.5),
          _EvalEntry('Floral', 2.2),
        ],
      ),
      _TasterEval(tasterName: 'Nayrouz F.', statut: 'En attente'),
    ],
  ),
  _SampleEvalGroup(
    sampleId: 'OL-2024-002',
    referenceBouteille: 'REF-2024-0342',
    gouvernorat: 'Bizerte',
    variete: 'Chetoui',
    dateAjout: '21/02/2026',
    recuPhysiquement: false,
    evaluations: [
      _TasterEval(
        tasterName: 'Nayrouz F.',
        statut: 'Soumis',
        dateEval: '21/02/2026',
        classification: 'Extra Vierge',
        scores: [
          _EvalEntry('Fruité', 3.9),
          _EvalEntry('Amer', 4.1),
          _EvalEntry('Piquant', 3.7),
          _EvalEntry('Doux', 3.5),
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
          _EvalEntry('Amer', 3.9),
          _EvalEntry('Piquant', 3.6),
          _EvalEntry('Doux', 3.7),
          _EvalEntry('Floral', 4.0),
        ],
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
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
  DateTime? _dateDebut;
  DateTime? _dateFin;
  final Set<String> _expandedPanel = {};

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;

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

  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  List<_SampleEvalGroup> get _filtered {
    var list = _mockGroups;
    if (_dateFilterActive) {
      list = list.where((g) {
        if (!g.recuPhysiquement || g.dateReceptionPhysique == null)
          return false;
        final d = _parseDate(g.dateReceptionPhysique!);
        if (d == null) return false;
        final day = DateTime(d.year, d.month, d.day);
        final debut = _dateDebut != null
            ? DateTime(_dateDebut!.year, _dateDebut!.month, _dateDebut!.day)
            : null;
        final fin = _dateFin != null
            ? DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day)
            : null;
        if (debut != null && fin != null)
          return !day.isBefore(debut) && !day.isAfter(fin);
        if (debut != null) return !day.isBefore(debut);
        if (fin != null) return !day.isAfter(fin);
        return true;
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (g) =>
                g.sampleId.toLowerCase().contains(q) ||
                g.referenceBouteille.toLowerCase().contains(q) ||
                g.gouvernorat.toLowerCase().contains(q) ||
                g.variete.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        onApply: (d, f) => setState(() {
          _dateDebut = d;
          _dateFin = f;
        }),
        onClear: () => setState(() {
          _dateDebut = null;
          _dateFin = null;
        }),
      ),
    );
  }

  // ── "Voir" handler — builds EvaluationOrganoleptique and opens CEO sheet ──
  void _onViewEval(_TasterEval eval, _SampleEvalGroup group) {
    if (eval.statut != 'Soumis' || eval.classification == null) return;

    final ev = EvaluationOrganoleptique(
      id: '${group.sampleId}_${eval.tasterName}',
      echantillonId: group.sampleId,
      tasteurId: eval.tasterName,
      tasteurNom: eval.tasterName,
      soumisLe: eval.dateEval != null
          ? _parseDateToIso(eval.dateEval!)
          : DateTime.now().toIso8601String(),
      classification: _classificationFromStr(eval.classification!),
      fruite: _scoreFor(eval.scores, 'Fruité'),
      fruiteVert: false,
      amertume: _scoreFor(eval.scores, 'Amer'),
      piquant: _scoreFor(eval.scores, 'Piquant'),
      chome: null,
      moisi: null,
      vinaigre: null,
      gele: null,
      rance: null,
      autresDefaut: null,
      autresDefautNom: null,
      commentaire: null,
    );

    showEvaluationFormSheet(
      context,
      evaluation: ev,
      sampleRef: group.referenceBouteille,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  double? _scoreFor(List<_EvalEntry> scores, String attribut) {
    final match = scores.where((s) => s.attribut == attribut);
    return match.isEmpty ? null : match.first.score;
  }

  String _parseDateToIso(String ddMMyyyy) {
    try {
      final p = ddMMyyyy.split('/');
      if (p.length != 3) return DateTime.now().toIso8601String();
      return DateTime(
        int.parse(p[2]),
        int.parse(p[1]),
        int.parse(p[0]),
      ).toIso8601String();
    } catch (_) {
      return DateTime.now().toIso8601String();
    }
  }

  ClassificationHuile _classificationFromStr(String s) {
    switch (s) {
      case 'Extra Vierge':
        return ClassificationHuile.extraVierge;
      case 'Vierge':
        return ClassificationHuile.vierge;
      case 'Vierge Ordinaire':
        return ClassificationHuile.viergeOrdinaire;
      default:
        return ClassificationHuile.lampante;
    }
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
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onVueEnsembleEvaluations: () => Navigator.pop(context),
        onProfil: () => _goTo(const ProfilePage()),
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
                tooltip: 'Filtrer par date de réception physique',
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
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
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
                        icon: const Icon(
                          Icons.close,
                          size: 17,
                          color: Color(0xFF6B8E7A),
                        ),
                        onPressed: () => setState(() {
                          _searchQuery = '';
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
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── Stats strip ───────────────────────────────────────────────────
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
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

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: groups.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assessment_outlined,
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun échantillon trouvé',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
                    itemCount: groups.length,
                    itemBuilder: (_, i) {
                      final g = groups[i];
                      return _EvalSampleCard(
                        group: g,
                        isPanelExpanded: _expandedPanel.contains(g.sampleId),
                        onPanelToggle: () => setState(() {
                          _expandedPanel.contains(g.sampleId)
                              ? _expandedPanel.remove(g.sampleId)
                              : _expandedPanel.add(g.sampleId);
                        }),
                        onViewEval: (eval) => _onViewEval(eval, g),
                      );
                    },
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
class _EvalSampleCard extends StatefulWidget {
  final _SampleEvalGroup group;
  final bool isPanelExpanded;
  final VoidCallback onPanelToggle;
  final void Function(_TasterEval) onViewEval;

  const _EvalSampleCard({
    required this.group,
    required this.isPanelExpanded,
    required this.onPanelToggle,
    required this.onViewEval,
  });

  @override
  State<_EvalSampleCard> createState() => _EvalSampleCardState();
}

class _EvalSampleCardState extends State<_EvalSampleCard> {
  bool _detailExpanded = false;

  bool _detectOutlier() {
    final submitted = widget.group.evaluations
        .where((e) => e.scores.isNotEmpty)
        .toList();
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
    final g = widget.group;
    final accentColor = g.isComplete ? _green : const Color(0xFFD07B2F);
    final hasOutlier = _detectOutlier();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _detailExpanded = !_detailExpanded),
            behavior: HitTestBehavior.opaque,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: accentColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  g.referenceBouteille,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${g.sampleId} · ${g.gouvernorat} · ${g.variete}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divergence badge
                          if (hasOutlier)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 10,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Divergence',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Réception physique icon
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: g.recuPhysiquement
                                  ? _green.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: g.recuPhysiquement
                                    ? _green.withValues(alpha: 0.4)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Icon(
                              g.recuPhysiquement
                                  ? Icons.check_circle
                                  : Icons.check_circle_outline,
                              size: 14,
                              color: g.recuPhysiquement
                                  ? _green
                                  : Colors.grey.shade400,
                            ),
                          ),
                          // Submission count badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              '${g.submitted} / ${g.total}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: _detailExpanded ? 0.5 : 0.0,
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

          // ── Expandable sample details ─────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Wrap(
                spacing: 60,
                runSpacing: 10,
                children: [
                  _DetailCell('N° échantillon', g.sampleId),
                  _DetailCell('Réf. bouteille', g.referenceBouteille),
                  _DetailCell('Gouvernorat', g.gouvernorat),
                  _DetailCell('Variété', g.variete),
                  _DetailCell(
                    'Évaluations',
                    '${g.submitted} / ${g.total} soumises',
                  ),
                  _ReceptionDetailCell(
                    recu: g.recuPhysiquement,
                    dateReception: g.dateReceptionPhysique,
                  ),
                ],
              ),
            ),
            crossFadeState: _detailExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),

          // ── Panel section ─────────────────────────────────────────────
          Divider(color: Colors.grey.shade100, height: 1),
          _EvalPanelSection(
            group: g,
            isExpanded: widget.isPanelExpanded,
            onToggle: widget.onPanelToggle,
            onViewEval: widget.onViewEval,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL CELL
// ─────────────────────────────────────────────────────────────────────────────
class _DetailCell extends StatelessWidget {
  final String label;
  final String value;
  const _DetailCell(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFAAAAAA),
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _dark,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// RECEPTION DETAIL CELL
// ─────────────────────────────────────────────────────────────────────────────
class _ReceptionDetailCell extends StatelessWidget {
  final bool recu;
  final String? dateReception;
  const _ReceptionDetailCell({required this.recu, this.dateReception});

  @override
  Widget build(BuildContext context) {
    final color = recu ? _green : Colors.grey.shade400;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Réception physique',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFFAAAAAA),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.35)),
              ),
              child: Icon(
                recu ? Icons.check_circle : Icons.check_circle_outline,
                size: 11,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              recu
                  ? (dateReception != null ? 'Oui — $dateReception' : 'Oui')
                  : 'Non',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: recu ? _dark : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EVAL PANEL SECTION — chevron only, no classification badge
// ─────────────────────────────────────────────────────────────────────────────
class _EvalPanelSection extends StatelessWidget {
  final _SampleEvalGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(_TasterEval) onViewEval;

  const _EvalPanelSection({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
    required this.onViewEval,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
            child: Row(
              children: [
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: _olive,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _EvalTasterList(group: group, onViewEval: onViewEval),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EVAL TASTER LIST
// ─────────────────────────────────────────────────────────────────────────────
class _EvalTasterList extends StatelessWidget {
  final _SampleEvalGroup group;
  final void Function(_TasterEval) onViewEval;
  const _EvalTasterList({required this.group, required this.onViewEval});

  @override
  Widget build(BuildContext context) {
    if (group.evaluations.isEmpty) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2EFE7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Center(
          child: Text(
            'Aucune évaluation soumise',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EFE7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: group.evaluations.map((eval) {
          final submitted = eval.statut == 'Soumis';
          final classColor = submitted && eval.classification != null
              ? _classColorForStr(eval.classification!)
              : Colors.grey.shade400;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: classColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      eval.tasterName.isNotEmpty
                          ? eval.tasterName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: classColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Name
                Expanded(
                  child: Text(
                    eval.tasterName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _dark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Badge or pending
                if (submitted && eval.classification != null)
                  _ClassBadge(eval.classification!)
                else
                  Text(
                    'En attente',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                // Voir button — only for submitted evals
                if (submitted) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => onViewEval(eval),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _green.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Text(
                        'Formulaire',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLASS BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _ClassBadge extends StatelessWidget {
  final String classification;
  const _ClassBadge(this.classification);

  @override
  Widget build(BuildContext context) {
    final color = _classColorForStr(classification);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        classification,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

Color _classColorForStr(String c) {
  switch (c) {
    case 'Extra Vierge':
      return _green;
    case 'Vierge':
      return const Color(0xFFD07B2F);
    default:
      return const Color(0xFFD32F2F);
  }
}
