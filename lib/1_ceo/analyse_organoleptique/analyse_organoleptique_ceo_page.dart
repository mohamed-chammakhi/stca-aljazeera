// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/analyse_organoleptique/analyse_organoleptique_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:async';
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
import '../../2_collecteur/mes_echantillons/widgets/dialogs/formulaire_sections.dart'
    show DateLivraisonSection, ModePlanificationUI;
import 'widgets/panel_section.dart';
import 'widgets/panel_widgets.dart';

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

    final budgetController = TextEditingController(
      text: e.budgetNegociation ?? '',
    );
    final noteController = TextEditingController(text: e.noteInterne ?? '');

    // Date souhaitée state
    ModePlanificationUI dateMode = ModePlanificationUI.dateExacte;
    DateTime? dateExacte;
    DateTime? periodeDebut;
    DateTime? periodeFin;

    // Pre-fill from existing stored value
    if (e.dateLivraisonStockSouhaitee != null) {
      // We store it as a formatted string; just show it pre-filled
    }

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.90,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Header ─────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9F4EE),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.handshake_outlined,
                        color: kDark,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit
                                  ? 'Modifier la négociation'
                                  : 'Approuver pour négociation',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: kDark,
                              ),
                            ),
                            Text(
                              e.referenceBouteille,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B8E7A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body ───────────────────────────────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Budget
                        _ceoDialogLabel('Budget proposé *'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: budgetController,
                          decoration: _ceoDeco(
                            'ex: 9.50',
                            Icons.payments_outlined,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),

                        // Date souhaitée (using same date picker logic as collector)
                        _ceoDialogLabel('Date souhaitée de livraison du stock'),
                        const SizedBox(height: 8),
                        DateLivraisonSection(
                          mode: dateMode,
                          onModeChanged: (m) =>
                              setDialogState(() => dateMode = m),
                          dateExacte: dateExacte,
                          periodeDebut: periodeDebut,
                          periodeFin: periodeFin,
                          onDateExacteChanged: (dt) =>
                              setDialogState(() => dateExacte = dt),
                          onPeriodeDebutChanged: (dt) =>
                              setDialogState(() => periodeDebut = dt),
                          onPeriodeFinChanged: (dt) =>
                              setDialogState(() => periodeFin = dt),
                        ),
                        const SizedBox(height: 16),

                        // Note interne
                        _ceoDialogLabel('Note interne (optionnelle)'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: noteController,
                          decoration: _ceoDeco(
                            'Remarques pour votre équipe…',
                            Icons.notes_outlined,
                          ),
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ─────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6EF),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            final budget = budgetController.text.trim();
                            if (budget.isEmpty) return;

                            // Build date string from picker selection
                            String? dateSouhaitee;
                            if (dateMode == ModePlanificationUI.dateExacte &&
                                dateExacte != null) {
                              dateSouhaitee =
                                  '${dateExacte!.day.toString().padLeft(2, '0')}/'
                                  '${dateExacte!.month.toString().padLeft(2, '0')}/'
                                  '${dateExacte!.year}';
                            } else if (dateMode ==
                                    ModePlanificationUI.periode &&
                                periodeDebut != null &&
                                periodeFin != null) {
                              final fmt = (DateTime d) =>
                                  '${d.day.toString().padLeft(2, '0')}/'
                                  '${d.month.toString().padLeft(2, '0')}/${d.year}';
                              dateSouhaitee =
                                  periodeDebut!.isAtSameMomentAs(periodeFin!)
                                  ? fmt(periodeDebut!)
                                  : '${fmt(periodeDebut!)} - ${fmt(periodeFin!)}';
                            }

                            setState(() {
                              e.statut = StatutCeo.enNegociation;
                              e.budgetNegociation = budget;
                              e.dateLivraisonStockSouhaitee = dateSouhaitee;
                              e.noteInterne = noteController.text.trim().isEmpty
                                  ? null
                                  : noteController.text.trim();
                              e.raisonRefus = null;
                            });
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            isEdit ? 'Modifier' : 'Approuver',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widgets for the approval dialog
  static Widget _ceoDialogLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6B8E7A),
    ),
  );

  static InputDecoration _ceoDeco(String hint, IconData icon) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6B8E7A)),
        filled: true,
        fillColor: const Color(0xFFF7F9F8),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kGreen, width: 1.5),
        ),
      );

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
                e.statut = StatutCeo.refuse;
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


