// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/widgets/home_body.dart
// PURPOSE : Full dashboard for the tasting panel member
// ─────────────────────────────────────────────────────────────────────────────

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _green      = Color(0xFF38835A);
const Color _headerBg   = Color.fromARGB(255, 220, 233, 226);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);

class HomeBody extends StatelessWidget {
  final VoidCallback onSimulerNotification;
  const HomeBody({super.key, required this.onSimulerNotification});

  // ── Radar data — average sensory scores (out of 5) ───────────────────────
  static const List<String> _radarLabels = ['Fruité', 'Amer', 'Piquant', 'Doux', 'Floral', 'Terreux'];
  static const List<double> _radarScores = [4.2, 3.8, 3.5, 4.0, 3.9, 3.2];

  // ── Bar data — evaluations per day this week ──────────────────────────────
  static const List<String> _days    = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
  static const List<double>  _evals  = [3, 5, 2, 4, 6, 3, 1];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Greeting ──────────────────────────────────────────────────────
        Text(
          'Bonjour, Karim 👋',
          style: GoogleFonts.domine(fontSize: 20, fontWeight: FontWeight.w700, color: _darkText),
        ),
        const SizedBox(height: 4),
        Text('Voici votre activité de dégustateur', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        const SizedBox(height: 24),

        // ── KPI grid ──────────────────────────────────────────────────────
        _SectionLabel(text: 'Aperçu du mois'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: const [
            _KpiCard(label: 'Sessions ce mois',      value: '4',  icon: Icons.wine_bar_outlined,        color: Color(0xFF38835A), bg: Color(0xFFE8F5E9)),
            _KpiCard(label: 'Évaluations soumises',  value: '18', icon: Icons.rate_review_outlined,     color: Color(0xFF1565C0), bg: Color(0xFFE3F2FD)),
            _KpiCard(label: 'En attente',             value: '6',  icon: Icons.hourglass_empty_outlined, color: Color(0xFFF57C00), bg: Color(0xFFFFF3E0)),
            _KpiCard(label: 'Échantillons reçus',    value: '24', icon: Icons.inventory_2_outlined,     color: Color(0xFF6B8143), bg: Color(0xFFF1F5E8)),
          ],
        ),
        const SizedBox(height: 28),

        // ── Session active progress ────────────────────────────────────────
        _SectionLabel(text: 'Session en cours'),
        const SizedBox(height: 12),
        _buildSessionCard(),
        const SizedBox(height: 28),

        // ── Radar chart — sensory scores ──────────────────────────────────
        _SectionLabel(text: 'Scores sensoriels moyens'),
        const SizedBox(height: 12),
        _buildRadarChart(),
        const SizedBox(height: 28),

        // ── Bar chart — weekly evaluations ────────────────────────────────
        _SectionLabel(text: 'Évaluations cette semaine'),
        const SizedBox(height: 12),
        _buildWeeklyBarChart(),
        const SizedBox(height: 100),
      ],
    );
  }

  // ── Session active card ───────────────────────────────────────────────────
  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _green.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.wine_bar_outlined, color: _green, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Session S-08 — Chemlali Sfax',
                    style: GoogleFonts.domine(fontSize: 13, fontWeight: FontWeight.w700, color: _darkText)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text('EN COURS',
                    style: TextStyle(fontSize: 9, color: Colors.green.shade700, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress per taster
          ..._TasterProgress.samples.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t.name, style: const TextStyle(fontSize: 12, color: _darkText)),
                    Text('${t.done}/${t.total}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: t.done == t.total ? _green : _oliveGreen)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: t.done / t.total,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(t.done == t.total ? _green : Colors.orange.shade400),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('3/5 dégustateurs ont soumis', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text('Il y a 30 min', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Radar chart — average sensory evaluation scores ───────────────────────
  Widget _buildRadarChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _green.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.radar_outlined, color: _green, size: 17),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Profil sensoriel moyen',
                      style: GoogleFonts.domine(fontSize: 14, fontWeight: FontWeight.w700, color: _darkText)),
                  Text('Basé sur 18 évaluations soumises',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 240,
            child: RadarChart(
              RadarChartData(
                dataSets: [
                  RadarDataSet(
                    dataEntries: _radarScores.map((v) => RadarEntry(value: v)).toList(),
                    fillColor: _green.withOpacity(0.18),
                    borderColor: _green,
                    borderWidth: 2,
                    entryRadius: 4,
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                tickCount: 4,
                ticksTextStyle: TextStyle(color: Colors.transparent, fontSize: 8),
                tickBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
                gridBorderData: BorderSide(color: Colors.grey.shade200, width: 1),
                titleTextStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _darkText),
                titlePositionPercentageOffset: 0.2,
                getTitle: (index, angle) => RadarChartTitle(
                  text: _radarLabels[index],
                  angle: 0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          // Score legend
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: List.generate(_radarLabels.length, (i) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _green, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text('${_radarLabels[i]}: ${_radarScores[i]}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              ],
            )),
          ),
        ],
      ),
    );
  }

  // ── Bar chart — evaluations per day this week ─────────────────────────────
  Widget _buildWeeklyBarChart() {
    const todayIndex = 4; // vendredi

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _green.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.bar_chart_rounded, color: _green, size: 17),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Évaluations de la semaine',
                      style: GoogleFonts.domine(fontSize: 14, fontWeight: FontWeight.w700, color: _darkText)),
                  Text('Semaine du 7 au 13 Avr 2026',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 8,
                barGroups: List.generate(_days.length, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: _evals[i],
                      color: i == todayIndex ? _green : _green.withOpacity(0.35),
                      width: 22,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                    ),
                  ],
                )),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _days[idx],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: idx == todayIndex ? FontWeight.w700 : FontWeight.normal,
                              color: idx == todayIndex ? _green : Colors.grey.shade500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 2,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text("Aujourd'hui", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              const SizedBox(width: 16),
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: _green.withOpacity(0.35), borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 6),
              Text('Autres jours', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Taster progress data ───────────────────────────────────────────────────────
class _Taster {
  final String name;
  final int done, total;
  const _Taster(this.name, this.done, this.total);
}

class _TasterProgress {
  static const List<_Taster> samples = [
    _Taster('Karim B. (vous)', 5, 5),
    _Taster('Sana M.',         4, 5),
    _Taster('Hatem R.',        4, 5),
    _Taster('Ines T.',         0, 5),
    _Taster('Walid C.',        0, 5),
  ];
}

// ── KPI card ──────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _KpiCard({required this.label, required this.value, required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _green.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _oliveGreen),
  );
}
