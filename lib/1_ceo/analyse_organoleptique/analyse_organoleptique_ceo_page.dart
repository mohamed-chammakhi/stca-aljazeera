// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../utilisateurs/models/echantillon_ceo_view.dart';
import '../widgets/shared_evaluation_form_sheet.dart';
import '../echantillons/echantillons_ceo_page.dart';
import 'analyse_organoleptique_ceo_page.dart';
import '../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../profil_ceo_page.dart';
import '../../main.dart';
import '../utilisateurs/models/mock_data_patch.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../widgets/search_date_filter_bar.dart';
import '../widgets/sample_card_widgets.dart';
import '../widgets/base_sample_card.dart'; // ← shared card

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _bg = Color.fromARGB(255, 255, 255, 255);
const Color _olive = Color(0xFF6B8143);

const Color _statusGreen = Color(0xFF38835A);
const Color _statusBlue = Color(0xFF3A6EA5);
const Color _statusOrange = Color(0xFFD07B2F);
const Color _tintGreen = Color(0xFFEAF4EE);
const Color _tintBlue = Color(0xFFEAF0F8);
const Color _tintOrange = Color(0xFFFAF0E6);

enum _SampleStatus { complete, partial, none }

extension _StatusStyle on _SampleStatus {
  Color get color {
    switch (this) {
      case _SampleStatus.complete:
        return _statusGreen;
      case _SampleStatus.partial:
        return _statusBlue;
      case _SampleStatus.none:
        return _statusOrange;
    }
  }

  Color get tint {
    switch (this) {
      case _SampleStatus.complete:
        return _tintGreen;
      case _SampleStatus.partial:
        return _tintBlue;
      case _SampleStatus.none:
        return _tintOrange;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class AnalyseOrganoleptiqueCeoPage extends StatefulWidget {
  const AnalyseOrganoleptiqueCeoPage({super.key});
  @override
  State<AnalyseOrganoleptiqueCeoPage> createState() =>
      _AnalyseOrganoleptiqueCeoPageState();
}

class _AnalyseOrganoleptiqueCeoPageState
    extends State<AnalyseOrganoleptiqueCeoPage> {
  final Set<String> _expandedPanel = {};

  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EchantillonCeoView> get _allEchantillons =>
      mockEchantillonsOrganoleptique;

  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  List<EchantillonCeoView> get _filtered {
    var result = _allEchantillons;
    if (_dateDebut != null) {
      result = result.where((e) {
        final d = _parseDate(e.dateAjout);
        if (d == null) return false;
        final day = DateTime(d.year, d.month, d.day);
        final debut = DateTime(
          _dateDebut!.year,
          _dateDebut!.month,
          _dateDebut!.day,
        );
        if (_dateFin != null) {
          final fin = DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day);
          return !day.isBefore(debut) && !day.isAfter(fin);
        }
        return day == debut;
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (e) =>
                e.referenceBouteille.toLowerCase().contains(q) ||
                e.codeFournisseur.toLowerCase().contains(q) ||
                e.id.toLowerCase().contains(q) ||
                e.gouvernorat.toLowerCase().contains(q) ||
                (e.variete?.toLowerCase().contains(q) ?? false) ||
                (e.collecteurNom?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }
    return result;
  }

  bool get _anyFilter => _dateDebut != null || _searchQuery.isNotEmpty;

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

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  _SampleStatus _statusOf(EchantillonCeoView e) {
    if (e.evaluations.isEmpty) return _SampleStatus.none;
    if (e.tousEvalue) return _SampleStatus.complete;
    return _SampleStatus.partial;
  }

  Color _cardTint(EchantillonCeoView e) {
    if (e.statut == StatutCeoView.refuse) return Colors.red.shade50;
    return _statusOf(e).tint;
  }

  // ── Decision dialogs ───────────────────────────────────────────────────────
  Future<void> _showApprouverDialog(EchantillonCeoView e) async {
    final isEdit = e.statut == StatutCeoView.enNegociation;
    final isAchatConfirme = e.statut == StatutCeoView.achatConfirme;

    if (isAchatConfirme) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Achat déjà confirmé'),
          content: const Text(
            'Cet échantillon a un achat confirmé. Voulez-vous vraiment modifier la décision ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final budgetController = TextEditingController(
      text: e.budgetNegociation ?? '',
    );
    final noteController = TextEditingController(text: e.noteInterne ?? '');

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isEdit ? 'Modifier la négociation' : 'Approuver pour négociation',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.referenceBouteille,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: budgetController,
              decoration: const InputDecoration(
                labelText: 'Budget (ex: 9.50 TND/L) *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note interne (optionnelle)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _green),
            onPressed: () {
              final budget = budgetController.text.trim();
              if (budget.isEmpty) return;
              setState(() {
                e.statut = StatutCeoView.enNegociation;
                e.budgetNegociation = budget;
                e.noteInterne = noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim();
                e.raisonRefus = null;
              });
              Navigator.pop(context);
            },
            child: Text(
              isEdit ? 'Modifier' : 'Approuver',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRefuserDialog(EchantillonCeoView e) async {
    final isAchatConfirme = e.statut == StatutCeoView.achatConfirme;

    if (isAchatConfirme) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Achat déjà confirmé'),
          content: const Text(
            'Cet échantillon a un achat confirmé. Voulez-vous vraiment le refuser ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Refuser quand même',
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final raisonController = TextEditingController(text: e.raisonRefus ?? '');

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Refuser l\'échantillon',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.referenceBouteille,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: raisonController,
              decoration: InputDecoration(
                labelText: 'Raison du refus (optionnelle)',
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: 'Ex: Acidité trop élevée',
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
            ),
            onPressed: () {
              setState(() {
                e.statut = StatutCeoView.refuse;
                e.raisonRefus = raisonController.text.trim().isEmpty
                    ? null
                    : raisonController.text.trim();
                e.budgetNegociation = null;
                e.noteInterne = null;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Confirmer le refus',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final echantillons = _filtered;
    return Scaffold(
      backgroundColor: _bg,
      drawer: CeoDrawer(
        onEchantillons: () => _goTo(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () =>
            _goTo(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoireCeoPage()),
        onAchatsConfirmes: () => _goTo(const AchatsConfirmesCeoPage()),
        onTableauDeBord: () => Navigator.pop(context),
        onProfil: () => _goTo(const ProfilceoPage()),
        onutilisiateurs: () => _goTo(const UtilisateursCeoPage()),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Analyse organoleptique',
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
                  color: (_dateDebut != null || _dateFin != null)
                      ? _green
                      : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: 'Filtrer par date',
              ),
              if (_dateDebut != null || _dateFin != null)
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
          // ── Unified header zone ──────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              style: const TextStyle(fontSize: 14, color: _dark),
              decoration: InputDecoration(
                hintText: 'Rechercher réf, fournisseur, gouvernorat…',
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
          // Stats strip
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.science_outlined,
                  size: 13,
                  color: Color.fromARGB(255, 156, 156, 156),
                ),
                const SizedBox(width: 6),
                Text(
                  '${echantillons.length} échantillon${echantillons.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 156, 156, 156),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_anyFilter) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _dateDebut = null;
                        _dateFin = null;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_off_outlined,
                          size: 13,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Effacer filtres',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // List
          Expanded(
            child: echantillons.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
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
                    itemCount: echantillons.length,
                    itemBuilder: (_, i) {
                      final e = echantillons[i];
                      final status = _statusOf(e);
                      final majority = e.classificationMajoritaire;
                      final panelExp = _expandedPanel.contains(e.id);

                      return BaseSampleCard(
                        referenceBouteille: e.referenceBouteille,
                        id: e.id,
                        tintColor: _cardTint(e),
                        badge: CardBadge(
                          label: '${e.nombreEvaluations}/${e.totalTasteurs}',
                          color: status.color,
                        ),
                        detailItems: [
                          DetailItem('N° échantillon', e.id),
                          DetailItem('Ref. bouteille', e.referenceBouteille),
                          DetailItem(
                            'Gouvernorat',
                            '${e.gouvernorat}${e.delegation != null ? " — ${e.delegation}" : ""}',
                          ),
                          DetailItem('Fournisseur', e.codeFournisseur),
                          if (e.variete != null)
                            DetailItem('Variété', e.variete!),
                          if (e.quantiteEstimee != null)
                            DetailItem('Quantité', '${e.quantiteEstimee} T'),
                          DetailItem('Date ajout', e.dateAjout),
                          if (e.collecteurNom != null)
                            DetailItem('Collecteur', e.collecteurNom!),
                          DetailItem(
                            'Reçu physiquement',
                            e.recuPhysiquement ? 'Oui' : 'Non',
                          ),
                        ],
                        deliveryWidget: SampleDeliveryIndicator(e: e),
                        bottomSection: _PanelSection(
                          echantillon: e,
                          majority: majority,
                          isExpanded: panelExp,
                          onToggle: () => setState(
                            () => panelExp
                                ? _expandedPanel.remove(e.id)
                                : _expandedPanel.add(e.id),
                          ),
                          onViewForm: (ev) => showEvaluationFormSheet(
                            context,
                            evaluation: ev,
                            sampleRef: e.id,
                          ),
                          onApprouver: () => _showApprouverDialog(e),
                          onRefuser: () => _showRefuserDialog(e),
                        ),
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
// PANEL SECTION  — bottom slot for organoleptique cards
// ─────────────────────────────────────────────────────────────────────────────
class _PanelSection extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final ClassificationHuile? majority;
  final bool isExpanded;
  final VoidCallback onToggle;
  final void Function(EvaluationTasteur) onViewForm;
  final VoidCallback onApprouver;
  final VoidCallback onRefuser;

  const _PanelSection({
    required this.echantillon,
    required this.majority,
    required this.isExpanded,
    required this.onToggle,
    required this.onViewForm,
    required this.onApprouver,
    required this.onRefuser,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;

    // Active state for each action
    final approved =
        e.statut == StatutCeoView.enNegociation ||
        e.statut == StatutCeoView.achatConfirme;
    final refused = e.statut == StatutCeoView.refuse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: panel label + classification badge + chevron ──────────
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 6),
            child: Row(
              children: [
                Text(
                  'Panel de dégustation',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _olive,
                  ),
                ),
                const Spacer(),
                if (majority != null) ...[
                  CardBadge(
                    label: majority!.label,
                    color: Color(majority!.colorValue),
                  ),
                  const SizedBox(width: 8),
                ] else if (e.evaluations.isNotEmpty) ...[
                  Text(
                    'En cours',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                  const SizedBox(width: 8),
                ],
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

        // ── Row 2: decision action buttons ───────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
          child: Row(
            children: [
              _DecisionButton(
                label: approved ? 'Approuvé' : 'Approuver',
                active: approved,
                activeColor: _green,
                onTap: onApprouver,
              ),
              const SizedBox(width: 8),
              _DecisionButton(
                label: refused ? 'Refusé' : 'Refuser',
                active: refused,
                activeColor: Colors.red.shade500,
                onTap: onRefuser,
              ),
            ],
          ),
        ),

        // ── Expandable taster list ────────────────────────────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _PanelList(echantillon: e, onViewForm: onViewForm),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// Small pill-shaped decision button
class _DecisionButton extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _DecisionButton({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // inactive = muted version of the real color (not grey)
    // active   = solid filled button
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? activeColor : activeColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? activeColor : activeColor.withValues(alpha: 0.3),
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.white : activeColor,
          ),
        ),
      ),
    );
  }
}

class _PanelList extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final void Function(EvaluationTasteur) onViewForm;
  const _PanelList({required this.echantillon, required this.onViewForm});

  @override
  Widget build(BuildContext context) {
    final e = echantillon;

    // Empty state — always show the panel box, just with a message
    if (e.evaluations.isEmpty) {
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
        children: e.evaluations.map((ev) {
          final classColor = Color(ev.classification.colorValue);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: classColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      ev.tasteurNom.isNotEmpty
                          ? ev.tasteurNom[0].toUpperCase()
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
                Expanded(
                  child: Text(
                    ev.tasteurNom,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _dark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CardBadge(label: ev.classification.label, color: classColor),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => onViewForm(ev),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: _green.withValues(alpha: 0.2)),
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
