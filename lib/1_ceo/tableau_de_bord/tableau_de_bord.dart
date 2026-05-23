import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../profil_ceo_page.dart';
import '../../../main.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../validation_achats/validation_achats_ceo_page.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../notifications/models/notification_ceo.dart';
import '../notifications/services/notification_ceo_service.dart';
import '../notifications/notifications_ceo_page.dart';
import '../../core/widgets/search_filter_bar.dart';
import 'models/dashboard_models.dart';
import 'widgets/kpi_grid_card.dart';
import 'widgets/pipeline_card.dart';
import 'widgets/urgent_panel.dart';
import 'widgets/collector_section.dart';
import 'widgets/sales_evolution_card.dart';
import 'widgets/classification_card.dart';
import 'widgets/supplier_frequency_card.dart';
import 'widgets/stock_donut_card.dart';
import 'widgets/map_cta_card.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _pageBg = Color(0xFFF2F4F2);
const Color _white = Color(0xFFFFFFFF);
const Color _dark = Color(0xFF1A2E1F);
const Color _green = Color(0xFF38835A);

// ─────────────────────────────────────────────────────────────────────────────
class HomePageCeo extends StatefulWidget {
  const HomePageCeo({super.key});
  @override
  State<HomePageCeo> createState() => _HomePageCeoState();
}

class _HomePageCeoState extends State<HomePageCeo> with TickerProviderStateMixin {
  // ── Animations ──────────────────────────────────────────────────────────────
  late AnimationController _ctrl;
  late List<Animation<double>> _anims;

  // ── Per-card date ranges ───────────────────────────────────────────────────
  CardDateRange _collectorRange = CardDateRange(DateTime(2025, 11, 1), DateTime(2026, 4, 30));
  CardDateRange _classRange    = CardDateRange(DateTime(2025, 11, 1), DateTime(2026, 4, 30));
  CardDateRange _salesRange    = CardDateRange(DateTime(2025, 10, 1), DateTime(2026, 4, 30));

  // ── Collector metric: 0=Valeur 1=Échantillons 2=Approbation ───────────────
  int _collectorMetric = 0;

  // ── Notifications ──────────────────────────────────────────────────────────
  final _notifService = NotificationCeoService();
  int _unreadCount = 0;

  // ── Mock data — replace each list with a service call when API is ready ────
  static const _collectors = [
    CollecteurDashStat('Ahmed Dridi',   'AD', 8, 0.75, 92400, 6),
    CollecteurDashStat('Fatma Bouzid',  'FB', 5, 0.80, 68900, 4),
    CollecteurDashStat('Sami Kraiem',   'SK', 6, 0.67, 71200, 8),
    CollecteurDashStat('Khalil Maalej', 'KM', 4, 0.50, 38000, 11),
  ];

  static const _urgentItems = [
    UrgentDecision('ECH-2026-031', 'Ahmed Dridi',  'Henchir Errouss', 3),
    UrgentDecision('ECH-2026-028', 'Sami Kraiem',  'Domaine Zitoun',  2),
  ];

  static const _suppliers = [
    FournisseurStat('Henchir Errouss',   'Sfax',    7, 143200),
    FournisseurStat('Domaine Zitoun',    'Gafsa',   5, 98400),
    FournisseurStat('Ferme El Baraka',   'Sousse',  4, 76100),
    FournisseurStat('Agricole Ben Ali',  'Nabeul',  3, 55300),
    FournisseurStat('Coop. Nour',        'Sidi Bz', 2, 32000),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anims = List.generate(
      12,
      (i) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(i * 0.06, (i * 0.06 + 0.45).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );
    _ctrl.forward();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notifService.fetchUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────
  void _goTo(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsCeoPage(
          service: _notifService,
          onNavigate: _handleNotifNavigation,
        ),
      ),
    ).then((_) => _loadUnreadCount());
  }

  void _handleNotifNavigation(NotificationCeo n) {
    if (n.type == 'proposition_achat_attente') {
      _goTo(const ValidationAchatsCeoPage());
      return;
    }
    switch (n.section) {
      case 'EVALUATIONS':        _goTo(const AnalyseOrganoleptiqueCeoPage()); break;
      case 'ANALYSES':           _goTo(const AnalyseLaboratoireCeoPage());    break;
      case 'ACHATS_VALIDATION':  _goTo(const ValidationAchatsCeoPage());      break;
      case 'ACHATS':             _goTo(const AchatsConfirmesCeoPage());       break;
      default:                   _goTo(const EchantillonsCeoPage());          break;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Wraps a widget in a staggered fade+slide animation.
  Widget _fs(int i, Widget child) => AnimatedBuilder(
    animation: _anims[i],
    builder: (_, c) => Opacity(
      opacity: _anims[i].value,
      child: Transform.translate(offset: Offset(0, 18 * (1 - _anims[i].value)), child: c),
    ),
    child: child,
  );

  /// Shows the date-range bottom sheet and calls [onApply] with the result.
  Future<void> _pickRange(CardDateRange current, void Function(CardDateRange) onApply) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        dateDebut: current.from,
        dateFin: current.to,
        onApply: (debut, fin) => setState(() => onApply(CardDateRange(debut, fin ?? debut))),
        onClear: () => setState(() => onApply(CardDateRange(DateTime(2025, 11, 1), DateTime(2026, 4, 30)))),
      ),
    );
  }

  /// Small tappable date chip rendered on each dashboard card.
  Widget _dateChip(CardDateRange range, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8EAE8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 11, color: kGreen),
            const SizedBox(width: 5),
            Text(range.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _dark)),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: _green),
          ],
        ),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      drawer: CeoDrawer(
        onEchantillons:         () => _goTo(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () => _goTo(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire:   () => _goTo(const AnalyseLaboratoireCeoPage()),
        onValidationAchats:     () => _goTo(const ValidationAchatsCeoPage()),
        onAchatsConfirmes:      () => _goTo(const AchatsConfirmesCeoPage()),
        onTableauDeBord:        () => Navigator.pop(context),
        onProfil:               () => _goTo(const ProfilceoPage()),
        onutilisiateurs:        () => _goTo(const UtilisateursCeoPage()),
        onDeconnexion:          () => _goTo(const LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        toolbarHeight: 65,
        title: Text(
          'Tableau de Bord',
          style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: _dark),
        ),
        iconTheme: const IconThemeData(color: kDark),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: kDark),
                onPressed: _openNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: _unreadCount > 9 ? 18 : 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Container(height: 1, color: Colors.black.withValues(alpha: 0.07)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 52),
              children: [
                _fs(0, const KpiGridCard()),
                const SizedBox(height: 12),
                _fs(1, const PipelineCard()),
                const SizedBox(height: 12),
                if (_urgentItems.isNotEmpty) ...[
                  _fs(2, UrgentPanel(
                    items: _urgentItems,
                    onTap: () => _goTo(const AnalyseOrganoleptiqueCeoPage()),
                  )),
                  const SizedBox(height: 12),
                ],
                _fs(3, CollectorSection(
                  collectors: _collectors,
                  selectedMetric: _collectorMetric,
                  dateRange: _collectorRange,
                  onMetricChanged: (m) => setState(() => _collectorMetric = m),
                  dateChipBuilder: (range, _) => _dateChip(
                    range,
                    () => _pickRange(_collectorRange, (r) => _collectorRange = r),
                  ),
                  onRangeChanged: (r) => setState(() => _collectorRange = r),
                )),
                const SizedBox(height: 12),
                _fs(4, SalesEvolutionCard(
                  dateRange: _salesRange,
                  dateChipBuilder: (range, _) => _dateChip(
                    range,
                    () => _pickRange(_salesRange, (r) => setState(() => _salesRange = r)),
                  ),
                  onRangeChanged: (r) => setState(() => _salesRange = r),
                )),
                const SizedBox(height: 12),
                _fs(5, ClassificationCard(
                  dateRange: _classRange,
                  dateChipBuilder: (range, _) => _dateChip(
                    range,
                    () => _pickRange(_classRange, (r) => setState(() => _classRange = r)),
                  ),
                  onRangeChanged: (r) => setState(() => _classRange = r),
                )),
                const SizedBox(height: 12),
                _fs(6, SupplierFrequencyCard(
                  suppliers: _suppliers,
                  dateRange: _salesRange,
                  dateChipBuilder: (range, _) => _dateChip(
                    range,
                    () => _pickRange(_salesRange, (r) => setState(() => _salesRange = r)),
                  ),
                  onRangeChanged: (r) => setState(() => _salesRange = r),
                )),
                const SizedBox(height: 12),
                _fs(7, const StockDonutCard()),
                const SizedBox(height: 12),
                _fs(8, const MapCtaCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

