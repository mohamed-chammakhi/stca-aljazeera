// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:project3/core/utils/date_utils.dart';
import 'models/sample_status.dart';
import '../widgets/ceo_nav_mixin.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../3_degustateur/notifications/services/notification_degustateur_service.dart';
import '../widgets/ceo_drawer.dart';
import '../utilisateurs/models/echantillon_ceo_view.dart';
import '../widgets/shared_evaluation_form_sheet.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../profil_ceo_page.dart';
import '../../main.dart';
import '../utilisateurs/models/mock_data_patch.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../widgets/search_date_filter_bar.dart';
import '../widgets/sample_card_echantillon.dart';
import '../widgets/base_sample_card.dart'; // ← shared card
import 'widgets/approval_dialog.dart';
import 'widgets/refusal_dialog.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _bg = Color.fromARGB(255, 255, 255, 255);
const Color _olive = Color(0xFF6B8143);

const Color _statusGreen = Color(0xFF38835A);
const Color _statusBlue = Color(0xFF3A6EA5);
const Color _statusOrange = Color(0xFFD07B2F);
const Color _tintGreen = Color.fromARGB(255, 212, 225, 217);
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
    extends State<AnalyseOrganoleptiqueCeoPage> with CeoNavMixin {
  final Set<String> _expandedPanel = {};
  final Set<String> _urgentSent = {};

  DateTime? _dateDebut;
  DateTime? _dateFin;
  DateFilterType _dateType = DateFilterType.enregistrement;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EchantillonCeoView> get _allEchantillons =>
      mockEchantillonsOrganoleptique;


  String? _dateFieldFor(EchantillonCeoView e) {
    switch (_dateType) {
      case DateFilterType.enregistrement:
        return e.dateAjout;
      case DateFilterType.livraisonEchantillon:
        return e.dateArriveeEchantillon ?? e.dateLivraisonPrevue;
      case DateFilterType.arriveeStock:
        return e.dateLivraisonStock;
    }
  }

  List<EchantillonCeoView> get _filtered {
    var result = _allEchantillons;
    if (_dateDebut != null) {
      result = result.where((e) {
        final dateStr = _dateFieldFor(e);
        if (dateStr == null) return false;
        final d = DegDateUtils.parseDate(dateStr);
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
        availableTypes: const [
          DateFilterType.enregistrement,
          DateFilterType.livraisonEchantillon,
        ],
        initialType: _dateType,
        onApplyTyped: (d, f, type) => setState(() {
          _dateDebut = d;
          _dateFin = f;
          _dateType = type;
        }),
      ),
    );
  }


  SampleStatus _statusOf(EchantillonCeoView e) {
    if (e.evaluations.isEmpty) return SampleStatus.none;
    if (e.tousEvalue) return SampleStatus.complete;
    return SampleStatus.partial;
  }

  Color _cardAccent(EchantillonCeoView e) {
    if (e.statut == StatutCeo.refuse) return Colors.red.shade400;
    return _statusOf(e).color;
  }

  // ── Urgent notification ────────────────────────────────────────────────────
  Future<void> _confirmSendUrgent(EchantillonCeoView e) async {
    if (_urgentSent.contains(e.id)) return;

    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF3E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notification_important_outlined,
                    color: Color(0xFFD07B2F),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Marquer comme urgent',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: kDark,
                          ),
                        ),
                        Text(
                          e.referenceBouteille,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E7A4B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Text(
                'Tous les dégustateurs recevront une notification urgente pour soumettre leur évaluation de ${e.referenceBouteille} en priorité.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A4A4A),
                  height: 1.5,
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6EF),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD07B2F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await NotificationDegustateurService()
                            .sendUrgentDegustation(e.id, e.referenceBouteille);
                        setState(() => _urgentSent.add(e.id));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Notification urgente envoyée à tous les dégustateurs',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: const Color(0xFFD07B2F),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(20),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Notifier',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Decision dialogs ───────────────────────────────────────────────────────
  Future<void> _showApprouverDialog(EchantillonCeoView e) async {
    final isEdit = e.statut == StatutCeo.enNegociation;
    final isAchatConfirme = e.statut == StatutCeo.achatConfirme;

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

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => ApprovalDialog(
        reference: e.referenceBouteille,
        isEdit: isEdit,
        initialBudget: e.budgetNegociation,
        initialNote: e.noteInterne,
        onApprove: (budget, dateSouhaitee, note) {
          setState(() {
            e.statut = StatutCeo.enNegociation;
            e.budgetNegociation = budget;
            e.dateLivraisonStockSouhaitee = dateSouhaitee;
            e.noteInterne = note;
            e.raisonRefus = null;
          });
        },
      ),
    );
  }

  Future<void> _showRefuserDialog(EchantillonCeoView e) async {
    final isAchatConfirme = e.statut == StatutCeo.achatConfirme;

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

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => RefusalDialog(
        reference: e.referenceBouteille,
        initialRaison: e.raisonRefus,
        onRefuse: (raison) {
          setState(() {
            e.statut = StatutCeo.refuse;
            e.raisonRefus = raison;
            e.budgetNegociation = null;
            e.noteInterne = null;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final echantillons = _filtered;
    return Scaffold(
      backgroundColor: kBg,
      drawer: CeoDrawer(
        onEchantillons: () => goToPage(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () =>
            goToPage(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoireCeoPage()),
        onAchatsConfirmes: () => goToPage(const AchatsConfirmesCeoPage()),
        onTableauDeBord: () => Navigator.pop(context),
        onProfil: () => goToPage(const ProfilceoPage()),
        onutilisiateurs: () => goToPage(const UtilisateursCeoPage()),
        onDeconnexion: () => goToPage(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Analyse organoleptique',
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
                  color: (_dateDebut != null || _dateFin != null)
                      ? kGreen
                      : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: _dateDebut != null
                    ? 'Filtré par : ${_dateType.label}'
                    : 'Filtrer par date',
              ),
              if (_dateDebut != null || _dateFin != null)
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
      body: Column(
        children: [
          // ── Unified header zone ──────────────────────────────────────
          Container(
            color: kHeaderBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              style: const TextStyle(fontSize: 14, color: kDark),
              decoration: InputDecoration(
                hintText: 'Réf, fournisseur, gouvernorat, variété, collecteur…',
                hintStyle: const TextStyle(
                  color: Color(0xFF6B8E7A),
                  fontSize: 11,
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
                  borderSide: const BorderSide(color: kGreen, width: 1.5),
                ),
              ),
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          // Stats strip
          Container(
            color: kBg,
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
                      final panelExp = _expandedPanel.contains(e.id);

                      return BaseSampleCard(
                        referenceBouteille: e.referenceBouteille,
                        id: e.id,
                        tintColor: Colors.white,
                        accentColor: _cardAccent(e),
                        badge: CardBadgeRow(
                          badges: [
                            if (e.quantiteEstimee != null)
                              CardBadge(
                                label: 'Qté : ${e.quantiteEstimee}T',
                                color: kOlive,
                              ),
                            RecuPhysiqueIndicator(
                              recuPhysiquement: e.recuPhysiquement,
                            ),
                          ],
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
                        bottomSection: PanelSection(
                          echantillon: e,
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
                          isUrgent: _urgentSent.contains(e.id),
                          onUrgent: () => _confirmSendUrgent(e),
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


  const _PanelSection({
    required this.echantillon,
    required this.isExpanded,
    required this.onToggle,
    required this.onViewForm,
    required this.onApprouver,
    required this.onRefuser,
    required this.isUrgent,
    required this.onUrgent,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;

    // Active state for each action
    final approved =
        e.statut == StatutCeo.enNegociation ||
        e.statut == StatutCeo.achatConfirme;
    final refused = e.statut == StatutCeo.refuse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Row 1: decision buttons + classification badge + chevron ─────
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
            child: Row(
              children: [
                _DecisionButton(
                  label: 'Approuver',
                  active: approved,
                  dimmed: refused,
                  activeColor: _green,
                  onTap: onApprouver,
                ),
                const SizedBox(width: 6),
                _DecisionButton(
                  label: 'Refuser',
                  active: refused,
                  dimmed: approved,
                  activeColor: Colors.red.shade500,
                  onTap: onRefuser,
                ),
                const Spacer(),
                // ── Urgent notification button ────────────────────────
                GestureDetector(
                  onTap: onUrgent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? const Color(0xFFD07B2F).withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isUrgent
                            ? const Color(0xFFD07B2F).withValues(alpha: 0.40)
                            : Colors.grey.shade300,
                        width: isUrgent ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isUrgent
                              ? Icons.notification_important
                              : Icons.notification_important_outlined,
                          size: 12,
                          color: isUrgent
                              ? const Color(0xFFD07B2F)
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Urgent',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isUrgent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isUrgent
                                ? const Color(0xFFD07B2F)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
  final bool dimmed;
  final Color activeColor;

  final VoidCallback onTap;

  const _DecisionButton({
    required this.label,
    required this.active,
    required this.dimmed,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const inactiveGray = Color(0xFFB4B2A9);

    return Opacity(
      opacity: dimmed ? 0.38 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withValues(alpha: 0.09)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? activeColor.withValues(alpha: 0.35)
                  : inactiveGray.withValues(alpha: 0.45),
              width: active ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? activeColor : inactiveGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PANEL LIST
// ─────────────────────────────────────────────────────────────────────────────
class _PanelList extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final void Function(EvaluationOrganoleptique) onViewForm;
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
                      (ev.tasteurNom != null && ev.tasteurNom!.isNotEmpty)
                          ? ev.tasteurNom![0].toUpperCase()
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
                    ev.tasteurNom ?? ev.tasteurId,
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

// ─────────────────────────────────────────────────────────────────────────────
// RECU PHYSIQUE INDICATOR
// Static read-only indicator — icon + tooltip. Status detail is shown in the
// expanded card's detail items ("Reçu physiquement : Oui/Non").
// ─────────────────────────────────────────────────────────────────────────────
class _RecuPhysiqueIndicator extends StatelessWidget {
  final bool recuPhysiquement;
  const _RecuPhysiqueIndicator({required this.recuPhysiquement});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF38835A);
    return Tooltip(
      message: recuPhysiquement ? 'Présent dans la société' : 'Non encore livré',
      child: Icon(
        recuPhysiquement ? Icons.check_circle : Icons.check_circle_outline,
        size: 20,
        color: recuPhysiquement ? green : Colors.grey.shade400,
      ),
    );
  }
}
