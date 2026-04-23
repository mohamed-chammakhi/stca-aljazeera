import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../profil_ceo_page.dart';
import '../../../main.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../notifications/models/notification_ceo.dart';
import '../notifications/services/notification_ceo_service.dart';
import '../notifications/notifications_ceo_page.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _pageBg   = Color(0xFFF2F4F2);
const Color _white    = Color(0xFFFFFFFF);
const Color _amber    = Color(0xFFD07B2F);
const Color _blue     = Color(0xFF3A6EA5);
const Color _red      = Color(0xFFC0392B);

// ── French calendar helpers ───────────────────────────────────────────────────
const _moisFr  = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
const _moisAbr = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];

// ── Card date range ───────────────────────────────────────────────────────────
class _CardDateRange {
  final DateTime from;
  final DateTime to;
  const _CardDateRange(this.from, this.to);

  String get label {
    if (from.year == to.year && from.month == to.month && from.day == to.day) {
      return '${from.day} ${_moisAbr[from.month - 1]} ${from.year}';
    }
    if (from.year == to.year && from.month == to.month) {
      return '${_moisAbr[from.month - 1]} ${from.year}';
    }
    if (from.year == to.year) {
      return '${_moisAbr[from.month - 1]} – ${_moisAbr[to.month - 1]} ${from.year}';
    }
    return '${_moisAbr[from.month - 1]} ${from.year} – ${_moisAbr[to.month - 1]} ${to.year}';
  }
}

// ── Mock models ───────────────────────────────────────────────────────────────
class _Collector {
  final String name, initials;
  final int samples;
  final double approvalRate;
  final int totalValue;
  final int avgDaysToClose;
  const _Collector(this.name, this.initials, this.samples, this.approvalRate, this.totalValue, this.avgDaysToClose);
}

class _UrgentItem {
  final String ref, collecteur, fournisseur;
  final int joursEnAttente;
  const _UrgentItem(this.ref, this.collecteur, this.fournisseur, this.joursEnAttente);
}

class _SupplierStat {
  final String name, region;
  final int achats;
  final double valeur;
  const _SupplierStat(this.name, this.region, this.achats, this.valeur);
}

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
  _CardDateRange _collectorRange = _CardDateRange(DateTime(2025, 11, 1), DateTime(2026, 4, 30));
  _CardDateRange _classRange     = _CardDateRange(DateTime(2025, 11, 1), DateTime(2026, 4, 30));
  _CardDateRange _salesRange     = _CardDateRange(DateTime(2025, 10, 1), DateTime(2026, 4, 30));

  // ── Collector metric: 0=Valeur 1=Échantillons 2=Approbation ───────────────
  int _collectorMetric = 0;

  // ── Notifications ─────────────────────────────────────────────────────────
  final _notifService = NotificationCeoService();
  int _unreadCount = 0;

  // ── Mock data ──────────────────────────────────────────────────────────────
  static const _collectors = [
    _Collector('Ahmed Dridi',   'AD', 8, 0.75, 92400, 6),
    _Collector('Fatma Bouzid',  'FB', 5, 0.80, 68900, 4),
    _Collector('Sami Kraiem',   'SK', 6, 0.67, 71200, 8),
    _Collector('Khalil Maalej', 'KM', 4, 0.50, 38000, 11),
  ];

  static const _urgentItems = [
    _UrgentItem('ECH-2026-031', 'Ahmed Dridi', 'Henchir Errouss', 3),
    _UrgentItem('ECH-2026-028', 'Sami Kraiem',  'Domaine Zitoun',   2),
  ];

  static const _suppliers = [
    _SupplierStat('Henchir Errouss',  'Sfax',    7, 143200),
    _SupplierStat('Domaine Zitoun',   'Gafsa',   5,  98400),
    _SupplierStat('Ferme El Baraka',  'Sousse',  4,  76100),
    _SupplierStat('Agricole Ben Ali', 'Nabeul',  3,  55300),
    _SupplierStat('Coop. Nour',       'Sidi Bz', 2,  32000),
  ];

  static const _classLabels = ['Extra Vierge', 'Vierge', 'Lampante'];
  static const _classValues = [9.0, 4.0, 2.0];
  static const _classColors = [_green, Color(0xFF6B8143), _amber];

  // ── Sales evolution mock data (monthly TND totals) ─────────────────────────
  static const _salesMonths       = ['Oct', 'Nov', 'Déc', 'Jan', 'Fév', 'Mar', 'Avr'];
  static const _salesCurrent      = [18000.0, 32000.0, 55000.0, 68000.0, 72000.0, 54000.0, 38000.0];
  static const _salesPrev         = [12000.0, 25000.0, 42000.0, 55000.0, 60000.0, 48000.0, 30000.0];

  // ── Number formatter for the pipeline (handles up to millions) ─────────────
  static String _fmtPipe(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    if (n >= 10000)   return '${(n / 1000).toStringAsFixed(0)}k';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }


  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _anims = List.generate(12, (i) => CurvedAnimation(
      parent: _ctrl,
      curve: Interval(i * 0.06, (i * 0.06 + 0.45).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    ));
    _ctrl.forward();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notifService.fetchUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _goTo(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationsCeoPage(
        service: _notifService,
        onNavigate: _handleNotifNavigation,
      )),
    ).then((_) => _loadUnreadCount());
  }

  void _handleNotifNavigation(NotificationCeo n) {
    switch (n.section) {
      case 'EVALUATIONS': _goTo(const AnalyseOrganoleptiqueCeoPage()); break;
      case 'ANALYSES':    _goTo(const AnalyseLaboratoireCeoPage()); break;
      case 'ACHATS':      _goTo(const AchatsConfirmesCeoPage()); break;
      default:            _goTo(const EchantillonsCeoPage()); break;
    }
  }

  Widget _fs(int i, Widget child) => AnimatedBuilder(
    animation: _anims[i],
    builder: (_, c) => Opacity(
      opacity: _anims[i].value,
      child: Transform.translate(offset: Offset(0, 18 * (1 - _anims[i].value)), child: c),
    ),
    child: child,
  );

  // ── Period picker (compact preset chips + native range picker) ─────────────
  Future<void> _pickRange(
    _CardDateRange current,
    void Function(_CardDateRange) onApply,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PeriodSheet(
        current: current,
        onApply: (r) => setState(() => onApply(r)),
        onCustom: () async {
          Navigator.pop(ctx);
          await Future.delayed(const Duration(milliseconds: 150));
          if (!mounted) return;
          final result = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialDateRange: DateTimeRange(start: current.from, end: current.to),
            builder: (ctx2, child) => Theme(
              data: Theme.of(ctx2).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: _green, onPrimary: Colors.white,
                  surface: Colors.white, onSurface: _dark,
                ),
              ),
              child: child!,
            ),
          );
          if (result != null) setState(() => onApply(_CardDateRange(result.start, result.end)));
        },
      ),
    );
  }

  // ── Date chip widget ───────────────────────────────────────────────────────
  Widget _dateChip(_CardDateRange range, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8EAE8)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_today_outlined, size: 11, color: _green),
          const SizedBox(width: 5),
          Text(range.label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: _green),
        ]),
      ),
    );
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      drawer: CeoDrawer(
        onEchantillons:          () => _goTo(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () => _goTo(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire:    () => _goTo(const AnalyseLaboratoireCeoPage()),
        onAchatsConfirmes:       () => _goTo(const AchatsConfirmesCeoPage()),
        onTableauDeBord:         () => Navigator.pop(context),
        onProfil:                () => _goTo(const ProfilceoPage()),
        onutilisiateurs:         () => _goTo(const UtilisateursCeoPage()),
        onDeconnexion:           () => _goTo(const LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        toolbarHeight: 65,
        title: Text('Tableau de Bord',
            style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: _dark)),
        iconTheme: const IconThemeData(color: _dark),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: _dark),
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
          ]),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(children: [
        Container(height: 1, color: Colors.black.withValues(alpha: 0.07)),
        // Scrollable content
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 52),
          children: [
            _fs(0, _buildKpiGrid()),
            const SizedBox(height: 12),
            _fs(1, _buildPipeline()),
            const SizedBox(height: 12),
            if (_urgentItems.isNotEmpty) ...[
              _fs(2, _buildUrgentPanel()),
              const SizedBox(height: 12),
            ],
            _fs(3, _buildCollectorSection()),
            const SizedBox(height: 12),
            _fs(4, _buildSalesEvolution()),
            const SizedBox(height: 12),
            _fs(5, _buildClassificationCard()),
            const SizedBox(height: 12),
            _fs(6, _buildSupplierFrequency()),
            const SizedBox(height: 12),
            _fs(7, _buildStockDonut()),
            const SizedBox(height: 12),
            _fs(8, _buildMapCTA()),
          ],
        )),
      ]),
    );
  }

  // ── KPI grid ───────────────────────────────────────────────────────────────
  Widget _buildKpiGrid() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5C49),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('INVESTISSEMENTS SAISON', style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.50),
              letterSpacing: 0.7)),
          const SizedBox(height: 8),
          RichText(text: const TextSpan(children: [
            TextSpan(text: '284 500', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.5)),
            TextSpan(text: ' TND', style: TextStyle(fontSize: 11, color: Color(0xFF9DCBB3))),
          ])),
          const SizedBox(height: 6),
          Text('+12% vs saison précédente',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.60))),
        ])),
        Container(width: 1, height: 52, color: Colors.white.withValues(alpha: 0.12),
            margin: const EdgeInsets.symmetric(horizontal: 18)),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PRIX MOYEN PAR LITRE', style: TextStyle(
              fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.50),
              letterSpacing: 0.7)),
          const SizedBox(height: 8),
          RichText(text: const TextSpan(children: [
            TextSpan(text: '8.4', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.5)),
            TextSpan(text: ' TND/L', style: TextStyle(fontSize: 11, color: Color(0xFF9DCBB3))),
          ])),
          const SizedBox(height: 6),
          Text('Moyenne de la saison 2025/2026',
              style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.58))),
        ])),
      ]),
    );
  }

  // ── Urgent decisions panel ─────────────────────────────────────────────────
  Widget _buildUrgentPanel() {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
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
            const Expanded(
              child: Text('Décisions en attente',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _red)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(6)),
              child: Text('${_urgentItems.length}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ),
        // Rows — each is tappable → AnalyseOrganoleptiqueCeoPage
        ...List.generate(_urgentItems.length, (i) {
          final u = _urgentItems[i];
          final isLate = u.joursEnAttente >= 3;
          return GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AnalyseOrganoleptiqueCeoPage())),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade50),
                  bottom: i < _urgentItems.length - 1
                      ? BorderSide(color: Colors.grey.shade50)
                      : BorderSide.none,
                ),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.ref,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
                  const SizedBox(height: 3),
                  Text('${u.collecteur}  ·  ${u.fournisseur}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLate ? _red.withValues(alpha: 0.08) : _amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isLate ? _red.withValues(alpha: 0.18) : _amber.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    isLate ? '${u.joursEnAttente}j — urgent' : '${u.joursEnAttente}j en attente',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700,
                      color: isLate ? _red : _amber,
                    ),
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
          child: Text('Appuyez pour voir l\'évaluation organoleptique',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
        ),
      ]),
    );
  }

  // ── Pipeline ───────────────────────────────────────────────────────────────
  Widget _buildPipeline() {
    const labels = ['Réceptionné', 'Reçu', 'En négoc.', 'Confirmé'];
    const counts = [12, 8, 5, 9];
    const colors = [_blue, Color(0xFF6B8143), _amber, _green];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('Pipeline des échantillons', Icons.timeline_outlined),
        const SizedBox(height: 14),
        Row(children: List.generate(4, (i) => Expanded(child: Row(children: [
          Expanded(child: Column(children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: counts[i].toDouble()),
              duration: Duration(milliseconds: 900 + i * 100),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => Column(children: [
                Text(_fmtPipe(v.toInt()),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: colors[i])),
                // exact count shown only when abbreviated
                if (counts[i] >= 1000)
                  Text(_fmtNum(v.toInt()),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 7.5, color: Colors.grey.shade400)),
              ]),
            ),
            const SizedBox(height: 4),
            Text(labels[i], textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(height: 2, decoration: BoxDecoration(
                color: colors[i].withValues(alpha: 0.25), borderRadius: BorderRadius.circular(2))),
          ])),
          if (i < 3)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade200),
            ),
        ])))),
      ]),
    );
  }

  // ── Consolidated collector section ─────────────────────────────────────────
  Widget _buildCollectorSection() {
    return Container(
      decoration: _cardDeco(),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            Expanded(child: _sectionLabel('Performance collecteurs', Icons.leaderboard_outlined)),
            _dateChip(_collectorRange, () => _pickRange(_collectorRange, (r) => _collectorRange = r)),
          ]),
        ),
        // Metric tabs
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
          child: Row(children: List.generate(3, (i) {
            const tabLabels = ['Valeur', 'Échantillons', 'Approbation'];
            final sel = _collectorMetric == i;
            return GestureDetector(
              onTap: () => setState(() => _collectorMetric = i),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  border: Border(bottom: sel
                      ? const BorderSide(color: _dark, width: 2)
                      : BorderSide.none),
                ),
                child: Text(tabLabels[i], style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: sel ? _dark : Colors.grey.shade400,
                )),
              ),
            );
          })),
        ),
        const SizedBox(height: 12),
        _buildScrollableCollectorChart(_collectorMetric),
        const SizedBox(height: 16),
      ]),
    );
  }

  String _metricDesc(int metric) {
    switch (metric) {
      case 0:  return 'Montant total (TND) des achats négociés par collecteur cette saison';
      case 1:  return 'Nombre d\'échantillons collectés et soumis à l\'évaluation qualité';
      case 2:  return 'Taux d\'approbation : part des échantillons acceptés pour l\'achat par la direction';
      default: return '';
    }
  }

  List<_Collector> _sortedCollectors(int metric) {
    final list = List<_Collector>.from(_collectors);
    if (metric == 0) {
      list.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    } else if (metric == 1) {
      list.sort((a, b) => b.samples.compareTo(a.samples));
    } else {
      list.sort((a, b) => b.approvalRate.compareTo(a.approvalRate));
    }
    return list;
  }

  Widget _buildScrollableCollectorChart(int metric) {
    const double barAreaH   = 110.0;
    const double labelAreaH = 16.0;
    const double bottomAreaH = 44.0;
    const double totalH     = labelAreaH + barAreaH + bottomAreaH;
    const double colW       = 64.0;
    const double yAxisW     = 36.0;
    const double barW       = 36.0;

    final sorted = _sortedCollectors(metric);

    final double maxRaw;
    if (metric == 0) {
      maxRaw = sorted.first.totalValue.toDouble();
    } else if (metric == 1) {
      maxRaw = sorted.first.samples.toDouble();
    } else {
      maxRaw = 1.0;
    }

    String yLabel(double frac) {
      final val = maxRaw * frac;
      if (metric == 0) return '${(val / 1000).toStringAsFixed(0)}k';
      if (metric == 1) return val.toInt().toString();
      return '${(val * 100).toInt()}%';
    }

    double barFraction(_Collector c) {
      if (metric == 0) return c.totalValue / maxRaw;
      if (metric == 1) return c.samples / maxRaw;
      return c.approvalRate;
    }

    Color barColor(_Collector c) {
      if (metric == 2) {
        if (c.approvalRate >= 0.75) return _green;
        if (c.approvalRate >= 0.50) return _amber;
        return _red;
      }
      return metric == 0 ? _green : _blue;
    }

    String barTopLabel(_Collector c) {
      if (metric == 0) return '${(c.totalValue / 1000).toStringAsFixed(0)}k TND';
      if (metric == 1) return '${c.samples} éch.';
      return '${(c.approvalRate * 100).toInt()}%';
    }

    final yTop = yLabel(1.0);
    final yMid = yLabel(0.5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Metric description
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            _metricDesc(metric),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
          ),
        ),
        // Chart
        SizedBox(
          height: totalH,
          child: Row(children: [
            // Fixed Y-axis
            SizedBox(
              width: yAxisW,
              child: Stack(children: [
                Positioned(
                  top: labelAreaH - 8, right: 2,
                  child: Text(yTop, style: TextStyle(fontSize: 9, color: Colors.grey.shade400))),
                Positioned(
                  top: labelAreaH + barAreaH * 0.5 - 8, right: 2,
                  child: Text(yMid, style: TextStyle(fontSize: 9, color: Colors.grey.shade400))),
                Positioned(
                  top: labelAreaH + barAreaH - 8, right: 2,
                  child: Text('0', style: TextStyle(fontSize: 9, color: Colors.grey.shade400))),
              ]),
            ),
            const SizedBox(width: 2),
            Container(
              width: 1,
              margin: EdgeInsets.only(top: labelAreaH, bottom: bottomAreaH),
              color: Colors.grey.shade200,
            ),
            const SizedBox(width: 4),
            // Horizontally scrollable bars — scale stays fixed on left
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(width: 4),
                    ...sorted.map((c) {
                      final f     = barFraction(c);
                      final color = barColor(c);
                      final label = barTopLabel(c);
                      return SizedBox(
                        width: colW,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Value label (fixed height above bar)
                            SizedBox(
                              height: labelAreaH,
                              child: Center(
                                child: Text(label,
                                    style: TextStyle(
                                        fontSize: 9, fontWeight: FontWeight.w700, color: color),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                            // Bar area with subtle grid lines
                            SizedBox(
                              height: barAreaH,
                              child: Stack(children: [
                                Positioned(top: 0, left: 0, right: 0,
                                    child: Container(height: 1, color: Colors.grey.shade50)),
                                Positioned(top: barAreaH * 0.5, left: 0, right: 0,
                                    child: Container(height: 1, color: Colors.grey.shade50)),
                                Positioned.fill(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0, end: f),
                                      duration: const Duration(milliseconds: 900),
                                      curve: Curves.easeOutCubic,
                                      builder: (_, v, _) => Container(
                                        width: barW,
                                        height: barAreaH * v.clamp(0.0, 1.0),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: const BorderRadius.vertical(
                                              top: Radius.circular(6)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                            // Collector info below bar
                            SizedBox(
                              height: bottomAreaH,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Text(c.initials,
                                      style: const TextStyle(
                                          fontSize: 10, fontWeight: FontWeight.w800, color: _dark)),
                                  Text(c.name.split(' ').first,
                                      style: TextStyle(fontSize: 8, color: Colors.grey.shade400),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                  if (metric == 2) ...[
                                    const SizedBox(height: 3),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        c.approvalRate >= 0.75
                                            ? 'Bon'
                                            : c.approvalRate >= 0.50 ? 'Moyen' : 'Faible',
                                        style: TextStyle(
                                            fontSize: 8, fontWeight: FontWeight.w700, color: color),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ]),
        ),
        // Scroll hint
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.arrow_forward_rounded, size: 13, color: const Color(0xFF7A8A7E)),
          const SizedBox(width: 5),
          const Text(
            'Faites glisser pour voir tous les collecteurs',
            style: TextStyle(fontSize: 10.5, color: Color(0xFF7A8A7E), fontStyle: FontStyle.italic),
          ),
        ]),
      ]),
    );
  }

  // ── Classification donut ───────────────────────────────────────────────────
  Widget _buildClassificationCard() {
    final total = _classValues.fold(0.0, (s, e) => s + e);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _sectionLabel('Classification de l\'huile', Icons.donut_large_outlined)),
          _dateChip(_classRange, () => _pickRange(_classRange, (r) => _classRange = r)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          SizedBox(width: 110, height: 110,
            child: PieChart(PieChartData(
              sections: List.generate(3, (i) => PieChartSectionData(
                value: _classValues[i], color: _classColors[i], radius: 38,
                title: '${_classValues[i].toInt()}',
                titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
              centerSpaceRadius: 28, sectionsSpace: 2,
              pieTouchData: PieTouchData(enabled: false)))),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(3, (i) {
              final pct = (_classValues[i] / total * 100).toStringAsFixed(0);
              return Padding(padding: const EdgeInsets.only(bottom: 10),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Container(width: 8, height: 8,
                          decoration: BoxDecoration(color: _classColors[i], borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 6),
                      Text(_classLabels[i], style: const TextStyle(fontSize: 11, color: _dark)),
                    ]),
                    Text('$pct%',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _classColors[i])),
                  ]),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _classValues[i] / total),
                    duration: Duration(milliseconds: 900 + i * 100), curve: Curves.easeOutCubic,
                    builder: (_, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(value: v,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(_classColors[i]), minHeight: 4))),
                ]));
            }))),
        ]),
      ]),
    );
  }

  // ── Supplier frequency — single green intensity ────────────────────────────
  // Green darkens for top supplier and lightens progressively down the list.
  // Scales cleanly regardless of how many suppliers exist.
  static const _supplierGreenStops = [
    Color(0xFF38835A), Color(0xFF4E9A72), Color(0xFF62AD88),
    Color(0xFF84C4A0), Color(0xFFA8D6BC),
  ];

  Widget _buildSupplierFrequency() {
    final totalAchats = _suppliers.fold(0, (s, e) => s + e.achats);
    return Container(
      decoration: _cardDeco(),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header: title + date chip ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(children: [
            Expanded(child: _sectionLabel('Fournisseurs', Icons.storefront_outlined)),
            _dateChip(_salesRange, () => _pickRange(_salesRange, (r) => setState(() => _salesRange = r))),
          ]),
        ),
        // ── Sub-label + total badge ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            Expanded(child: Text('Part des achats par fournisseur',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w500))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${_suppliers.length} au total',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _green)),
            ),
          ]),
        ),
        // ── Fixed-height scrollable list (~3 rows visible) ─────────────────
        SizedBox(
          height: 138,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: _suppliers.length,
            itemBuilder: (_, i) {
              final s = _suppliers[i];
              final share = s.achats / totalAchats;
              final pct = (share * 100).toStringAsFixed(1);
              final color = _supplierGreenStops[i.clamp(0, _supplierGreenStops.length - 1)];
              return Padding(
                padding: EdgeInsets.only(bottom: i < _suppliers.length - 1 ? 12 : 0),
                child: Row(children: [
                  SizedBox(width: 80, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _dark),
                        overflow: TextOverflow.ellipsis, maxLines: 1),
                    Text(s.region, style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                  ])),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 24,
                        color: const Color(0xFFEEF4F0),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: share),
                          duration: Duration(milliseconds: 800 + i * 120),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, _) => FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: v.clamp(0.05, 1.0),
                            child: Container(
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 8),
                              child: v > 0.3 ? Text('$pct%',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))
                                  : const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 36, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('$pct%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
                    Text('${s.achats} ach.', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
                  ])),
                ]),
              );
            },
          ),
        ),
        // ── Scroll hint ────────────────────────────────────────────────────
        Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text('Faites défiler pour voir tous les fournisseurs',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
          ]),
        ),
      ]),
    );
  }

  // ── Sales evolution — line chart comparing two seasons ─────────────────────
  Widget _buildSalesEvolution() {
    final maxVal = _salesCurrent.fold(0.0, (a, b) => a > b ? a : b) * 1.25;

    Widget legendLine({required Color color, bool dashed = false}) => SizedBox(
      width: 20, height: 12,
      child: CustomPaint(painter: _DashLinePainter(color: color, dashed: dashed)),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _sectionLabel('Évolution des achats', Icons.show_chart_outlined)),
          _dateChip(_salesRange, () => _pickRange(_salesRange, (r) => setState(() => _salesRange = r))),
        ]),
        const SizedBox(height: 12),
        // Legend
        Row(children: [
          legendLine(color: _green),
          const SizedBox(width: 6),
          const Text('Saison 25/26',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _dark)),
          const SizedBox(width: 14),
          legendLine(color: Color(0xFFB8DCC8), dashed: true),
          const SizedBox(width: 6),
          Text('Saison 24/25',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
        ]),
        const SizedBox(height: 16),
        // Line chart
        SizedBox(
          height: 140,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxVal / 3,
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 22,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= _salesMonths.length) return const SizedBox();
                    return Text(_salesMonths[i],
                        style: TextStyle(fontSize: 8, color: Colors.grey.shade400,
                            fontWeight: FontWeight.w600));
                  },
                )),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (_salesCurrent.length - 1).toDouble(),
              minY: 0,
              maxY: maxVal,
              lineBarsData: [
                // Current season — solid green with area fill
                LineChartBarData(
                  spots: List.generate(_salesCurrent.length,
                          (i) => FlSpot(i.toDouble(), _salesCurrent[i])),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: _green,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (p, x, bar, i) => FlDotCirclePainter(
                      radius: 3.5, color: _green,
                      strokeColor: Colors.white, strokeWidth: 1.5,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [_green.withValues(alpha: 0.18), _green.withValues(alpha: 0)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                // Previous season — dashed muted
                LineChartBarData(
                  spots: List.generate(_salesPrev.length,
                          (i) => FlSpot(i.toDouble(), _salesPrev[i])),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: const Color(0xFFB8DCC8),
                  barWidth: 2,
                  dashArray: [5, 3],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // KPI strip: price/L current · price/L previous · total quantity
        Container(
          padding: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
          child: Row(children: [
            Expanded(child: Column(children: [
              const Text('8.4',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _green)),
              const SizedBox(height: 2),
              Text('TND/L · en cours',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
            ])),
            Container(width: 1, height: 32, color: Colors.grey.shade100),
            Expanded(child: Column(children: [
              const Text('7.1',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                      color: Color(0xFFB8DCC8))),
              const SizedBox(height: 2),
              Text('TND/L · saison préc.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
            ])),
            Container(width: 1, height: 32, color: Colors.grey.shade100),
            Expanded(child: Column(children: [
              const Text('432k L',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _dark)),
              const SizedBox(height: 2),
              Text('Qté totale achetée',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
            ])),
          ]),
        ),
      ]),
    );
  }

  // ── Stock state — donut only ───────────────────────────────────────────────
  Widget _buildStockDonut() {
    const transitL = 145000;
    const recuL    = 287000;
    const total    = transitL + recuL;
    const transitPct = transitL / total;
    const recuPct    = recuL   / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionLabel('État du stock', Icons.warehouse_outlined),
        const SizedBox(height: 16),
        Row(children: [
          // Donut
          SizedBox(width: 120, height: 120,
            child: PieChart(PieChartData(
              sections: [
                PieChartSectionData(
                  value: transitL.toDouble(), color: _amber, radius: 42,
                  title: '${(transitPct * 100).toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                PieChartSectionData(
                  value: recuL.toDouble(), color: _green, radius: 42,
                  title: '${(recuPct * 100).toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
              centerSpaceRadius: 30,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(enabled: false),
            ))),
          const SizedBox(width: 24),
          // Legend
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _stockLegendItem('En transit', _amber, '3 lots', _fmtNum(transitL)),
            const SizedBox(height: 16),
            _stockLegendItem('Stock reçu', _green, '6 lots', _fmtNum(recuL)),
          ])),
        ]),
      ]),
    );
  }

  Widget _stockLegendItem(String label, Color color, String lots, String liters) {
    return Row(children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _dark)),
        const SizedBox(height: 2),
        Text('$lots  ·  $liters L',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
      ])),
    ]);
  }

  // ── Map CTA ────────────────────────────────────────────────────────────────
  Widget _buildMapCTA() {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Carte de couverture — en cours de développement'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 64,
          child: Stack(fit: StackFit.expand, children: [
            Container(color: _dark),
            Image.asset(
              'assets/img/continents.png',
              fit: BoxFit.cover,
              color: Colors.white.withValues(alpha: 0.14),
              colorBlendMode: BlendMode.srcIn,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Carte de couverture',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 3),
                    Text('Délégations visitées par vos collecteurs',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65))),
                  ],
                )),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white.withValues(alpha: 0.45)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text, IconData icon) => Row(children: [
    Container(width: 3, height: 16, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Icon(icon, size: 14, color: _green),
    const SizedBox(width: 6),
    Flexible(child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark))),
  ]);

  BoxDecoration _cardDeco() => BoxDecoration(
    color: _white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
  );

  String _fmtNum(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
}

// ── Dash line painter for chart legend ───────────────────────────────────────
class _DashLinePainter extends CustomPainter {
  final Color color;
  final bool dashed;
  const _DashLinePainter({required this.color, this.dashed = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    if (!dashed) {
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
      return;
    }
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset((x + 5).clamp(0, size.width), size.height / 2), paint);
      x += 8;
    }
  }

  @override
  bool shouldRepaint(_DashLinePainter old) => old.color != color || old.dashed != dashed;
}

// ── Period picker bottom sheet — preset chips only ────────────────────────────
class _PeriodSheet extends StatelessWidget {
  final _CardDateRange current;
  final void Function(_CardDateRange) onApply;
  final VoidCallback onCustom;

  const _PeriodSheet({
    required this.current,
    required this.onApply,
    required this.onCustom,
  });

  static List<(String label, _CardDateRange range)> _presets() {
    final now = DateTime(2026, 4, 23); // TODO: replace with DateTime.now()
    return [
      ('7 derniers jours',  _CardDateRange(now.subtract(const Duration(days: 6)), now)),
      ('Ce mois',           _CardDateRange(DateTime(now.year, now.month, 1), now)),
      ('3 mois',            _CardDateRange(DateTime(now.year, now.month - 2, 1), now)),
      ('6 mois',            _CardDateRange(DateTime(now.year, now.month - 5, 1), now)),
      ('Cette année',       _CardDateRange(DateTime(now.year, 1, 1), now)),
      ('Saison 2025/2026',  _CardDateRange(DateTime(2025, 9, 1), DateTime(2026, 8, 31))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final presets = _presets();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Handle
        Center(child: Container(
          width: 32, height: 3,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2)),
        )),
        const SizedBox(height: 14),
        const Text('Période', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
        const SizedBox(height: 12),
        // Preset chips
        Wrap(spacing: 8, runSpacing: 8, children: presets.map((p) {
          final isActive = current.from == p.$2.from && current.to == p.$2.to;
          return GestureDetector(
            onTap: () { onApply(p.$2); Navigator.pop(context); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? _dark : const Color(0xFFF0F2F1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? _dark : const Color(0xFFE4E8E4)),
              ),
              child: Text(p.$1, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : _dark,
              )),
            ),
          );
        }).toList()),
        const SizedBox(height: 10),
        // Custom range button
        GestureDetector(
          onTap: onCustom,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE4E8E4)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: _green),
              const SizedBox(width: 7),
              const Text('Plage personnalisée',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _dark)),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: _green),
            ]),
          ),
        ),
      ]),
    );
  }
}
