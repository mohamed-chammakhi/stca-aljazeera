import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens — identical to gestion_echantillons_page ───────────────────
const Color _headerBg   = Color.fromARGB(255, 220, 233, 226);
const Color _green      = Color(0xFF38835A);
const Color _dark       = Color(0xFF1A2E1F);
const Color _bg         = Color(0xFFFFFFFF);
const Color _oliveGreen = Color(0xFF6B8143);

// ── French calendar helpers ────────────────────────────────────────────────────
const _moisFr  = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
const _moisAbr = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];
const _jourAbr = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];

// ─────────────────────────────────────────────────────────────────────────────
class HomeBody extends StatefulWidget {
  final VoidCallback onSimulerNotification;
  const HomeBody({super.key, required this.onSimulerNotification});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> with TickerProviderStateMixin {
  // ── Animations ──────────────────────────────────────────────────────────────
  late AnimationController _ctrl;
  late List<Animation<double>> _anims;

  // ── Period state ─────────────────────────────────────────────────────────────
  int _mode = 1; // 0=Jour 1=Semaine 2=Mois 3=Année
  DateTime _date = DateTime(2026, 4, 19);

  // ── Mock data per period mode [jour, semaine, mois, année] ───────────────────
  static const _kpiEvals  = [2,  6,  18,  48];
  static const _kpiExtra  = [1,  4,  11,  28];
  static const _kpiAccord = ['85%', '87%', '84%', '86%'];
  static const _kpiWait   = [3,  3,   3,   5];

  // Bar chart labels & data per mode
  static const _barLabels = [
    ['Mat.', 'Midi', 'A-M', 'Soir'],
    ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
    ['S1', 'S2', 'S3', 'S4'],
    ['Nov', 'Déc', 'Jan', 'Fév', 'Mar', 'Avr'],
  ];
  static const _barData = [
    [1.0, 2.0, 1.0, 0.0],
    [3.0, 5.0, 2.0, 4.0, 6.0, 3.0, 1.0],
    [7.0, 5.0, 4.0, 2.0],
    [8.0, 6.0, 9.0, 7.0, 12.0, 6.0],
  ];
  static const _barMaxY = [3.0, 8.0, 8.0, 14.0];
  // index of "current" bar to highlight per mode
  static const _barTodayIdx = [1, 4, 3, 5];

  // Bar chart subtitle per mode
  static const _barSubtitles = [
    "Aujourd'hui",
    '14 – 20 Avr 2026',
    'Avril 2026',
    '6 derniers mois',
  ];

  // Radar
  static const _radarLabels = ['Fruité', 'Amer', 'Piquant', 'Doux', 'Floral', 'Terreux'];
  static const _radarScores = [4.2, 3.8, 3.5, 4.0, 3.9, 3.2];

  // Classification this month
  static const _classLabels = ['Extra Vierge', 'Vierge', 'Lampante'];
  static const _classVals   = [11.0, 5.0, 2.0];
  static const _classColors = [Color(0xFF38835A), Color(0xFF6B8143), Color(0xFFD07B2F)];

  // Panel comparison
  static const _attrs    = ['Fruité', 'Amer', 'Piquant', 'Doux', 'Floral'];
  static const _myScores = [4.2, 3.8, 3.5, 4.0, 3.9];
  static const _panelAvg = [3.9, 4.1, 3.7, 3.8, 3.6];

  // ── Period helpers ────────────────────────────────────────────────────────────
  String _periodLabel() {
    switch (_mode) {
      case 0:
        return '${_jourAbr[_date.weekday - 1]} ${_date.day} ${_moisAbr[_date.month - 1]} ${_date.year}';
      case 1:
        final start = _date.subtract(Duration(days: _date.weekday - 1));
        final end   = start.add(const Duration(days: 6));
        if (start.month == end.month) {
          return '${start.day} – ${end.day} ${_moisAbr[start.month - 1]} ${start.year}';
        }
        return '${start.day} ${_moisAbr[start.month - 1]} – ${end.day} ${_moisAbr[end.month - 1]} ${end.year}';
      case 2:
        return '${_moisFr[_date.month - 1]} ${_date.year}';
      case 3:
        return '${_date.year}';
      default: return '';
    }
  }

  void _goBack() => setState(() {
    switch (_mode) {
      case 0: _date = _date.subtract(const Duration(days: 1)); break;
      case 1: _date = _date.subtract(const Duration(days: 7)); break;
      case 2:
        final m = _date.month == 1 ? 12 : _date.month - 1;
        final y = _date.month == 1 ? _date.year - 1 : _date.year;
        _date = DateTime(y, m, 1); break;
      case 3: _date = DateTime(_date.year - 1, _date.month, _date.day); break;
    }
  });

  void _goForward() => setState(() {
    switch (_mode) {
      case 0: _date = _date.add(const Duration(days: 1)); break;
      case 1: _date = _date.add(const Duration(days: 7)); break;
      case 2:
        final m = _date.month == 12 ? 1 : _date.month + 1;
        final y = _date.month == 12 ? _date.year + 1 : _date.year;
        _date = DateTime(y, m, 1); break;
      case 3: _date = DateTime(_date.year + 1, _date.month, _date.day); break;
    }
  });

  Future<void> _openPicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _green, onPrimary: Colors.white,
            surface: Colors.white, onSurface: _dark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _anims = List.generate(10, (i) => CurvedAnimation(
      parent: _ctrl,
      curve: Interval(i * 0.07, (i * 0.07 + 0.45).clamp(0.0, 1.0), curve: Curves.easeOutCubic),
    ));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Widget _fs(int i, Widget child) => AnimatedBuilder(
    animation: _anims[i],
    builder: (_, c) => Opacity(
      opacity: _anims[i].value,
      child: Transform.translate(offset: Offset(0, 20 * (1 - _anims[i].value)), child: c),
    ),
    child: child,
  );

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final evals  = _kpiEvals[_mode];
    final extra  = _kpiExtra[_mode];
    final accord = _kpiAccord[_mode];
    final wait   = _kpiWait[_mode];

    return Column(children: [
      // ── HEADER ZONE (headerBg, seamless with AppBar above) ─────────────────
      _buildHeaderZone(),
      // ── THIN DIVIDER ──────────────────────────────────────────────────────
      Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
      // ── STATS STRIP ──────────────────────────────────────────────────────
      Container(
        color: _bg,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Row(children: [
          Icon(Icons.rate_review_outlined, size: 13, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text('$evals évaluations · $extra Extra Vierge · $wait en attente',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
        ]),
      ),
      // ── SCROLLABLE CONTENT ────────────────────────────────────────────────
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // KPI grid
          _fs(0, _buildKpiGrid(evals, extra, accord, wait)),
          const SizedBox(height: 22),
          // Bar chart
          _fs(1, _sectionLabel('Mes évaluations', Icons.bar_chart_rounded)),
          const SizedBox(height: 10),
          _fs(1, _buildBarChart()),
          const SizedBox(height: 22),
          // Classification donut
          _fs(2, _sectionLabel('Mes classifications', Icons.donut_large_outlined)),
          const SizedBox(height: 10),
          _fs(2, _buildClassDonut()),
          const SizedBox(height: 22),
          // Radar
          _fs(3, _sectionLabel('Profil sensoriel moyen', Icons.radar_outlined)),
          const SizedBox(height: 10),
          _fs(3, _buildRadar()),
          const SizedBox(height: 22),
          // Panel comparison
          _fs(4, _sectionLabel('Comparaison avec le panel', Icons.compare_arrows_rounded)),
          const SizedBox(height: 10),
          _fs(4, _buildPanelComparison()),
          const SizedBox(height: 22),
          // Next session
          _fs(5, _sectionLabel('Prochaine session', Icons.event_outlined)),
          const SizedBox(height: 10),
          _fs(5, _buildNextSession()),
        ],
      )),
    ]);
  }

  // ── Header zone ───────────────────────────────────────────────────────────────
  Widget _buildHeaderZone() {
    return Container(
      color: _headerBg,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bonjour, Karim 👋',
            style: GoogleFonts.domine(fontSize: 17, fontWeight: FontWeight.w700, color: _dark)),
        Row(children: [
          Text("Voici votre activité de dégustateur",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5,
                  decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('S-08 en cours',
                  style: TextStyle(fontSize: 10, color: _green, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        _buildModeTabs(),
        const SizedBox(height: 10),
        _buildPeriodNavigator(),
      ]),
    );
  }

  Widget _buildModeTabs() {
    const modes = ['Jour', 'Semaine', 'Mois', 'Année'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: List.generate(4, (i) {
        final sel = _mode == i;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _mode = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: sel ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: sel
                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Text(modes[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                color: sel ? _green : Colors.grey.shade600,
              ),
            ),
          ),
        ));
      })),
    );
  }

  Widget _buildPeriodNavigator() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _navBtn(Icons.chevron_left, _goBack),
      GestureDetector(
        onTap: _openPicker,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_periodLabel(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _green),
        ]),
      ),
      _navBtn(Icons.chevron_right, _goForward),
    ]);
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: _dark),
      ),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text, IconData icon) => Row(children: [
    Container(width: 3, height: 16, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Icon(icon, size: 15, color: _green),
    const SizedBox(width: 6),
    Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
  ]);

  // ── KPI grid ──────────────────────────────────────────────────────────────────
  Widget _buildKpiGrid(int evals, int extra, String accord, int wait) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
      children: [
        _KpiCard(label: 'Évaluations soumises', value: '$evals',
            icon: Icons.rate_review_outlined, color: _green, bg: const Color(0xFFE8F5E9)),
        _KpiCard(label: 'Extra Vierge classifiés', value: '$extra',
            icon: Icons.workspace_premium_outlined, color: _oliveGreen, bg: const Color(0xFFF1F5E8)),
        _KpiCard(label: 'Accord avec panel', value: accord,
            icon: Icons.people_outline_rounded, color: const Color(0xFF1565C0), bg: const Color(0xFFE3F2FD)),
        _KpiCard(label: "En attente d'éval.", value: '$wait',
            icon: Icons.hourglass_empty_outlined, color: const Color(0xFFD07B2F), bg: const Color(0xFFFFF3E0)),
      ],
    );
  }

  // ── Bar chart (period-responsive) ─────────────────────────────────────────────
  Widget _buildBarChart() {
    final labels   = _barLabels[_mode];
    final data     = _barData[_mode];
    final maxY     = _barMaxY[_mode];
    final todayIdx = _barTodayIdx[_mode];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_barSubtitles[_mode], style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          Text('Total : ${data.fold(0.0, (s, e) => s + e).toInt()} évals',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _green)),
        ]),
        const SizedBox(height: 16),
        SizedBox(height: 130, child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: List.generate(data.length, (i) => BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: data[i],
              color: i == todayIdx ? _green : _green.withValues(alpha: 0.28),
              width: data.length > 6 ? 14 : 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
          ])),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                return Padding(padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[idx], style: TextStyle(
                    fontSize: 10,
                    fontWeight: idx == todayIdx ? FontWeight.w700 : FontWeight.normal,
                    color: idx == todayIdx ? _green : Colors.grey.shade400)));
              })),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, interval: maxY / 3,
              getTitlesWidget: (v, _) =>
                  Text(v.toInt().toString(), style: TextStyle(fontSize: 9, color: Colors.grey.shade400))))),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 3,
            getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1))))),
      ]),
    );
  }

  // ── Classification donut ──────────────────────────────────────────────────────
  Widget _buildClassDonut() {
    final total = _classVals.fold(0.0, (s, e) => s + e);
    return Container(padding: const EdgeInsets.all(16), decoration: _cardDeco(),
      child: Row(children: [
        SizedBox(width: 110, height: 110,
          child: PieChart(PieChartData(
            sections: List.generate(3, (i) => PieChartSectionData(
              value: _classVals[i], color: _classColors[i], radius: 38,
              title: '${_classVals[i].toInt()}',
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white))),
            centerSpaceRadius: 28, sectionsSpace: 2, pieTouchData: PieTouchData(enabled: false)))),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(3, (i) {
            final pct = (_classVals[i] / total * 100).toStringAsFixed(0);
            return Padding(padding: const EdgeInsets.only(bottom: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: _classColors[i], shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(_classLabels[i], style: const TextStyle(fontSize: 11, color: _dark)),
                  ]),
                  Text('$pct%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _classColors[i])),
                ]),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _classVals[i] / total),
                  duration: Duration(milliseconds: 900 + i * 100), curve: Curves.easeOutCubic,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(value: v,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(_classColors[i]), minHeight: 4))),
              ]));
          }))),
      ]),
    );
  }

  // ── Radar ─────────────────────────────────────────────────────────────────────
  Widget _buildRadar() {
    return Container(padding: const EdgeInsets.all(16), decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Basé sur ${_kpiEvals[_mode]} évaluations soumises',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        const SizedBox(height: 16),
        SizedBox(height: 220, child: RadarChart(RadarChartData(
          dataSets: [RadarDataSet(
            dataEntries: _radarScores.map((v) => RadarEntry(value: v)).toList(),
            fillColor: _green.withValues(alpha: 0.15),
            borderColor: _green, borderWidth: 2, entryRadius: 4)],
          radarBackgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          tickCount: 4,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 8),
          tickBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
          gridBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
          titleTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _dark),
          titlePositionPercentageOffset: 0.2,
          getTitle: (i, _) => RadarChartTitle(text: _radarLabels[i], angle: 0)))),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 6,
          children: List.generate(_radarLabels.length, (i) => Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(color: _green, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text('${_radarLabels[i]} ${_radarScores[i]}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ]))),
      ]),
    );
  }

  // ── Panel comparison ──────────────────────────────────────────────────────────
  Widget _buildPanelComparison() {
    return Container(padding: const EdgeInsets.all(16), decoration: _cardDeco(),
      child: Column(children: [
        Row(children: [
          const Expanded(flex: 3, child: SizedBox()),
          Expanded(flex: 2, child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: _green, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            const Text('Moi', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _green)),
          ]))),
          Expanded(flex: 2, child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF9E9E9E), shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text('Panel', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey.shade500)),
          ]))),
          const Expanded(flex: 1, child: SizedBox()),
        ]),
        const SizedBox(height: 10), const Divider(height: 1), const SizedBox(height: 8),
        ...List.generate(_attrs.length, (i) {
          final up = _myScores[i] > _panelAvg[i];
          return Padding(padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(flex: 3, child: Text(_attrs[i], style: const TextStyle(fontSize: 12, color: _dark))),
              Expanded(flex: 2, child: Text(_myScores[i].toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _green))),
              Expanded(flex: 2, child: Text(_panelAvg[i].toStringAsFixed(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey.shade500))),
              Expanded(flex: 1, child: Icon(
                up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 14, color: up ? _green : Colors.orange.shade400)),
            ]));
        }),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.info_outline, size: 12, color: _green),
            SizedBox(width: 6),
            Text("Taux d'accord global avec le panel : 87%",
                style: TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  // ── Next session ──────────────────────────────────────────────────────────────
  Widget _buildNextSession() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: _green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            Text('20', style: GoogleFonts.domine(fontSize: 20, fontWeight: FontWeight.w800, color: _green)),
            Text('AVR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _green.withValues(alpha: 0.7))),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Session S-09',
              style: GoogleFonts.domine(fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text('09:00 · Salle B', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.people_outline, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text('5 dégustateurs invités', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
          child: const Text('Planifiée', style: TextStyle(fontSize: 10, color: _green, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
  );
}

// ── KPI Card ───────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _KpiCard({required this.label, required this.value, required this.icon,
      required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(14),
      boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 17)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      ],
    ),
  );
}
