import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _headerBg   = Color.fromARGB(255, 220, 233, 226);
const Color _green      = Color(0xFF38835A);
const Color _dark       = Color(0xFF1A2E1F);
const Color _bg         = Color(0xFFFFFFFF);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _purple     = Color(0xFF7B3FC4);

const _moisFr  = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre'];
const _moisAbr = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];
const _jourAbr = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];

// ── Mock taster data ──────────────────────────────────────────────────────────
class _TasterStat {
  final String nom;
  final int evals;
  final double accord; // agreement rate 0–100
  final bool outlier;
  const _TasterStat(this.nom, this.evals, this.accord, this.outlier);
}

const _tasters = [
  _TasterStat('Ichrak C.', 14, 91.0, false),
  _TasterStat('Lobna E.',   9, 88.0, false),
  _TasterStat('Maha O.',   12, 62.0, true),   // outlier
  _TasterStat('Nayrouz F.',11, 85.0, false),
  _TasterStat('Yosra S.',   7, 89.0, false),
];

// ─────────────────────────────────────────────────────────────────────────────
class HomeBody extends StatefulWidget {
  final VoidCallback onSimulerNotification;
  const HomeBody({super.key, required this.onSimulerNotification});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _anims;

  int _mode = 1; // 0=Jour 1=Semaine 2=Mois 3=Année
  DateTime _date = DateTime(2026, 4, 19);

  static const _kpiPending = [0, 2, 2, 2];
  static const _kpiEvals   = [3, 18, 53, 142];
  static const _kpiAccord  = ['87%', '85%', '86%', '87%'];
  static const _kpiAlertes = [0, 1, 1, 2];

  static const _barSubtitles = [
    "Aujourd'hui",
    '14 – 20 Avr 2026',
    'Avril 2026',
    '6 derniers mois',
  ];

  static const _radarLabels  = ['Fruité', 'Amer', 'Piquant', 'Doux', 'Floral', 'Terreux'];
  static const _radarConsensus = [4.0, 3.9, 3.6, 3.8, 3.7, 3.3];

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
      case 2: return '${_moisFr[_date.month - 1]} ${_date.year}';
      case 3: return '${_date.year}';
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

  @override
  Widget build(BuildContext context) {
    final pending = _kpiPending[_mode];
    final evals   = _kpiEvals[_mode];
    final accord  = _kpiAccord[_mode];
    final alertes = _kpiAlertes[_mode];

    return Column(children: [
      _buildHeaderZone(),
      Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
      Container(
        color: _bg,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Row(children: [
          Icon(Icons.groups_outlined, size: 13, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text('$evals évaluations · ${_tasters.length} dégustateurs actifs · $alertes alerte${alertes > 1 ? "s" : ""}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
        ]),
      ),
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _fs(0, _buildKpiGrid(pending, evals, accord, alertes)),
          const SizedBox(height: 22),
          _fs(1, _sectionLabel("Activité du panel", Icons.bar_chart_rounded)),
          const SizedBox(height: 10),
          _fs(1, _buildPanelBarChart()),
          const SizedBox(height: 22),
          _fs(2, _sectionLabel('Cohérence des dégustateurs', Icons.radar_outlined)),
          const SizedBox(height: 10),
          _fs(2, _buildOutlierTable()),
          const SizedBox(height: 22),
          _fs(3, _sectionLabel('Profil sensoriel consensus', Icons.radar_outlined)),
          const SizedBox(height: 10),
          _fs(3, _buildRadar()),
          const SizedBox(height: 22),
          _fs(4, _sectionLabel('Sessions en attente d\'approbation', Icons.pending_actions_outlined)),
          const SizedBox(height: 10),
          _fs(4, _buildPendingSessions()),
        ],
      )),
    ]);
  }

  Widget _buildHeaderZone() {
    return Container(
      color: _headerBg,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bonjour, Chef 👋',
            style: GoogleFonts.domine(fontSize: 17, fontWeight: FontWeight.w700, color: _dark)),
        Row(children: [
          Text("Voici l'activité de votre panel",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 5,
                  decoration: const BoxDecoration(color: _purple, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('2 en attente',
                  style: TextStyle(fontSize: 10, color: _purple, fontWeight: FontWeight.w600)),
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

  Widget _sectionLabel(String text, IconData icon) => Row(children: [
    Container(width: 3, height: 16, decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 8),
    Icon(icon, size: 15, color: _green),
    const SizedBox(width: 6),
    Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
  ]);

  // ── KPI grid ──────────────────────────────────────────────────────────────────
  Widget _buildKpiGrid(int pending, int evals, String accord, int alertes) {
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
      children: [
        _KpiCard(
          label: 'Sessions en attente',
          value: '$pending',
          icon: Icons.pending_actions_outlined,
          color: pending > 0 ? _purple : Colors.grey.shade400,
          bg: pending > 0 ? const Color(0xFFF3E8FF) : const Color(0xFFF5F5F5),
        ),
        _KpiCard(
          label: 'Évaluations du panel',
          value: '$evals',
          icon: Icons.rate_review_outlined,
          color: _green,
          bg: const Color(0xFFE8F5E9),
        ),
        _KpiCard(
          label: 'Accord moyen panel',
          value: accord,
          icon: Icons.groups_outlined,
          color: const Color(0xFF1565C0),
          bg: const Color(0xFFE3F2FD),
        ),
        _KpiCard(
          label: 'Alertes cohérence',
          value: '$alertes',
          icon: Icons.warning_amber_outlined,
          color: alertes > 0 ? Colors.orange.shade700 : Colors.grey.shade400,
          bg: alertes > 0 ? const Color(0xFFFFF3E0) : const Color(0xFFF5F5F5),
        ),
      ],
    );
  }

  // ── Bar chart: évaluations par dégustateur ────────────────────────────────────
  Widget _buildPanelBarChart() {
    final maxEval = _tasters.map((t) => t.evals).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(_barSubtitles[_mode], style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          Text('Total : ${_tasters.fold(0, (s, t) => s + t.evals)} évals',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _green)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxEval + 2).toDouble(),
            barGroups: List.generate(_tasters.length, (i) {
              final t = _tasters[i];
              return BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: t.evals.toDouble(),
                  color: t.outlier ? Colors.orange.shade600 : _green.withValues(alpha: 0.75),
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                ),
              ]);
            }),
            titlesData: FlTitlesData(
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  final shortName = _tasters[idx].nom.split(' ')[0];
                  return Padding(padding: const EdgeInsets.only(top: 6),
                    child: Text(shortName, style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _tasters[idx].outlier ? Colors.orange.shade600 : Colors.grey.shade500,
                    )));
                })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                getTitlesWidget: (v, _) =>
                    Text(v.toInt().toString(), style: TextStyle(fontSize: 9, color: Colors.grey.shade400)))),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true, drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1)),
          )),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.75), borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 5),
          Text('Cohérent', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          const SizedBox(width: 14),
          Container(width: 10, height: 10, decoration: BoxDecoration(
              color: Colors.orange.shade600, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 5),
          Text('Hors consensus', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ]),
      ]),
    );
  }

  // ── Outlier / cohérence table ─────────────────────────────────────────────────
  Widget _buildOutlierTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Taux d\'accord avec la médiane du panel',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        const SizedBox(height: 12),
        ..._tasters.map((t) {
          final barColor = t.outlier ? Colors.orange.shade600 : _green;
          final bgColor  = t.outlier ? const Color(0xFFFFF3E0) : Colors.white;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: t.outlier ? Colors.orange.shade200 : Colors.grey.shade100,
              ),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Text(t.nom, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _dark,
                  )),
                  if (t.outlier) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.warning_amber_rounded, size: 10, color: Colors.orange.shade700),
                        const SizedBox(width: 3),
                        Text('Hors consensus', style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w700, color: Colors.orange.shade700,
                        )),
                      ]),
                    ),
                  ],
                ]),
                Text('${t.accord.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: barColor)),
              ]),
              const SizedBox(height: 6),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: t.accord / 100),
                duration: const Duration(milliseconds: 900), curve: Curves.easeOutCubic,
                builder: (_, v, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: v,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 5,
                  ),
                ),
              ),
            ]),
          );
        }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(Icons.info_outline, size: 12, color: Colors.orange.shade700),
            const SizedBox(width: 6),
            Expanded(child: Text(
              'Un taux d\'accord < 75% indique une divergence significative par rapport au panel.',
              style: TextStyle(fontSize: 10, color: Colors.orange.shade800, fontWeight: FontWeight.w500),
            )),
          ]),
        ),
      ]),
    );
  }

  // ── Radar: consensus sensoriel du panel ──────────────────────────────────────
  Widget _buildRadar() {
    return Container(padding: const EdgeInsets.all(16), decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Scores moyens pondérés sur toutes les évaluations soumises',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        const SizedBox(height: 16),
        SizedBox(height: 220, child: RadarChart(RadarChartData(
          dataSets: [RadarDataSet(
            dataEntries: _radarConsensus.map((v) => RadarEntry(value: v)).toList(),
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
            Text('${_radarLabels[i]} ${_radarConsensus[i]}',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ]))),
      ]),
    );
  }

  // ── Pending sessions ──────────────────────────────────────────────────────────
  Widget _buildPendingSessions() {
    final sessions = [
      {'titre': 'Session Oueslati - Lot C', 'date': '28/04/2026', 'heure': '09:00', 'lieu': 'Salle A', 'par': 'Lobna E.'},
      {'titre': 'Session Rkhami - Sfax',    'date': '02/05/2026', 'heure': '11:00', 'lieu': 'Labo 1',   'par': 'Ichrak C.'},
    ];

    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDeco(),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.check_circle_outline, size: 18, color: Colors.grey.shade300),
          const SizedBox(width: 8),
          Text('Aucune session en attente', style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
        ]),
      );
    }

    return Column(
      children: sessions.map((s) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _purple.withValues(alpha: 0.25)),
          boxShadow: [BoxShadow(color: _purple.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 4, height: 36,
              decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['titre']!,
                  style: GoogleFonts.domine(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
              const SizedBox(height: 2),
              Text('${s['date']} · ${s['heure']} · ${s['lieu']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text('Proposée par ${s['par']}',
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
      )).toList(),
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
