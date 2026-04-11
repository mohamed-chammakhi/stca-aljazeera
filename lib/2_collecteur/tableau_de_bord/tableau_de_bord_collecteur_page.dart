import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/collecteur_drawer.dart';
import '../../../main.dart';
import '../profilcom.dart';
import '../mes_echantillons/mes_echantillons_page.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _green     = Color(0xFF38835A);
const Color _headerBg  = Color.fromARGB(255, 220, 233, 226);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText  = Color(0xFF1A2E1F);

// ── Local data model ──────────────────────────────────────────────────────────
class _Slice {
  final String label;
  final int value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

class TableauDeBordCollecteurPage extends StatelessWidget {
  const TableauDeBordCollecteurPage({super.key});

  void _goTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goToLogin(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CollecteurDrawer(
        onMesEchantillons: () => _goTo(context, const MesEchantillonsPage()),
        onCarte:           () => _goTo(context, const Placeholder()),
        onMessagerie:      () => _goTo(context, const Placeholder()),
        onTableauDeBord:   () => Navigator.pop(context),
        onProfil:          () => _goTo(context, const ProfileCollecteurPage()),
        onDeconnexion:     () => _goToLogin(context),
      ),
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        toolbarHeight: 65,
        title: Text(
          'Tableau de bord',
          style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: _darkText),
        ),
        iconTheme: const IconThemeData(color: _darkText),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Greeting ──────────────────────────────────────────────────
            Text(
              'Bonjour, Ahmed',
              style: GoogleFonts.domine(fontSize: 20, fontWeight: FontWeight.w700, color: _darkText),
            ),
            const SizedBox(height: 4),
            Text('Voici un résumé de votre activité', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            const SizedBox(height: 24),

            // ── KPI cards ─────────────────────────────────────────────────
            _SectionLabel(text: 'Aperçu global'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: const [
                _KpiCard(label: 'Total échantillons',    value: '24', icon: Icons.inventory_2_outlined,   color: Color(0xFF1565C0), bg: Color(0xFFE3F2FD)),
                _KpiCard(label: 'Achats confirmés',      value: '9',  icon: Icons.check_circle_outline,   color: Color(0xFF38835A), bg: Color(0xFFE8F5E9)),
                _KpiCard(label: 'En cours / négociation', value: '7', icon: Icons.hourglass_empty_outlined, color: Color(0xFFF57C00), bg: Color(0xFFFFF3E0)),
                _KpiCard(label: 'Refusés',               value: '5',  icon: Icons.cancel_outlined,        color: Color(0xFFC62828), bg: Color(0xFFFFEBEE)),
              ],
            ),
            const SizedBox(height: 28),

            // ── Pie chart — status breakdown ──────────────────────────────
            _SectionLabel(text: 'Répartition par statut'),
            const SizedBox(height: 12),
            const _StatusPieSection(),
            const SizedBox(height: 28),

            // ── Line chart — monthly activity ─────────────────────────────
            _SectionLabel(text: 'Activité mensuelle'),
            const SizedBox(height: 12),
            const _MonthlyLineSection(),
            const SizedBox(height: 28),

            // ── Top fournisseurs ──────────────────────────────────────────
            _SectionLabel(text: 'Fournisseurs les plus actifs'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _green.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: const Column(
                children: [
                  _FournisseurRow(nom: 'Ben Salah Huiles',   region: 'Sfax',  nbEch: 8, nbAchat: 4),
                  Divider(height: 1, color: Color(0xFFF1F1F1)),
                  _FournisseurRow(nom: 'Ferme Trabelsi',     region: 'Béja',  nbEch: 5, nbAchat: 2),
                  Divider(height: 1, color: Color(0xFFF1F1F1)),
                  _FournisseurRow(nom: 'Coopérative Gafsa',  region: 'Gafsa', nbEch: 4, nbAchat: 3),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
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

// ── Pie chart — status distribution ──────────────────────────────────────────
class _StatusPieSection extends StatelessWidget {
  const _StatusPieSection();

  static const List<_Slice> _slices = [
    _Slice('En traitement',  8, Color(0xFF1565C0)),
    _Slice('En négociation', 5, Color(0xFFF57C00)),
    _Slice('Achat confirmé', 9, Color(0xFF38835A)),
    _Slice('Refusés',        5, Color(0xFFC62828)),
    _Slice('Archivés',       3, Color(0xFF9E9E9E)),
  ];

  @override
  Widget build(BuildContext context) {
    const total = 30.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _green.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Donut
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                sections: _slices.map((s) => PieChartSectionData(
                  value: s.value.toDouble(),
                  color: s.color,
                  radius: 46,
                  title: '${s.value}',
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                )).toList(),
                centerSpaceRadius: 28,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(enabled: false),
              ),
            ),
          ),
          const SizedBox(width: 20),

          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _slices.map((s) {
                final pct = (s.value / total * 100).toStringAsFixed(0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(s.label,
                            style: const TextStyle(fontSize: 11, color: _darkText),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('$pct%',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: s.color)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Line chart — monthly échantillons submitted ───────────────────────────────
class _MonthlyLineSection extends StatelessWidget {
  const _MonthlyLineSection();

  static const List<String> _months  = ['Nov', 'Déc', 'Jan', 'Fév', 'Mar', 'Avr'];
  static const List<double>  _values = [3, 5, 4, 7, 6, 4];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _green.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Échantillons soumis par mois',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _darkText),
          ),
          const SizedBox(height: 4),
          Text('6 derniers mois', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(_values.length, (i) => FlSpot(i.toDouble(), _values[i])),
                    isCurved: true,
                    color: _green,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: _green,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_green.withOpacity(0.18), _green.withOpacity(0.0)],
                      ),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _months[v.toInt()],
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
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
        ],
      ),
    );
  }
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

// ── Fournisseur row ───────────────────────────────────────────────────────────
class _FournisseurRow extends StatelessWidget {
  final String nom, region;
  final int nbEch, nbAchat;
  const _FournisseurRow({required this.nom, required this.region, required this.nbEch, required this.nbAchat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.store_outlined, color: _green, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nom, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _darkText)),
                Text(region, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$nbEch échantillons', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              Text('$nbAchat achat(s)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _green)),
            ],
          ),
        ],
      ),
    );
  }
}
