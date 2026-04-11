// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/tableau_de_bord/tableau_de_bord.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import 'models/action_item_ceo.dart';
import 'widgets/kpi_card.dart';
import 'widgets/action_card_ceo.dart';
import '../profil_ceo_page.dart';
import '../../../main.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────
const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _darkText = Color(0xFF1A2E1F);
const Color _bg       = Color(0xFFFFFFFF);

// ── Pie section data ──────────────────────────────────────────────────────────
class _Slice {
  final String label;
  final double value;
  final Color color;
  const _Slice(this.label, this.value, this.color);
}

class HomePageCeo extends StatefulWidget {
  const HomePageCeo({super.key});

  @override
  State<HomePageCeo> createState() => _HomePageCeoState();
}

class _HomePageCeoState extends State<HomePageCeo> {

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static final List<ActionItemCeo> _actionsUrgentes = [
    ActionItemCeo(
      id: 'a1',
      type: ActionTypeCeo.approbationEchantillon,
      titre: 'Approbation requise',
      description: 'ECH-012 — Chemlali, Sfax — soumis par Ahmed D.',
      acteur: 'Ahmed D.',
      date: DateTime(2026, 3, 28),
    ),
    ActionItemCeo(
      id: 'a2',
      type: ActionTypeCeo.demandeSuppressionCollecteur,
      titre: 'Demande de suppression',
      description: 'ECH-009 — demande soumise par Sami K. avec justification.',
      acteur: 'Sami K.',
      date: DateTime(2026, 3, 28),
      urgent: true,
    ),
    ActionItemCeo(
      id: 'a3',
      type: ActionTypeCeo.sessionEnCours,
      titre: 'Session active',
      description: 'Session #S-08 — 3/5 dégustateurs ont soumis leurs évaluations.',
      date: DateTime(2026, 3, 28),
    ),
  ];

  // ── Pie chart data ────────────────────────────────────────────────────────
  static final List<_Slice> _statusSlices = [
    _Slice('En traitement',  8,  Color(0xFF1565C0)),
    _Slice('En négociation', 5,  Color(0xFFF57C00)),
    _Slice('Achat confirmé', 9,  _green),
    _Slice('Refusés',        5,  Color(0xFFC62828)),
    _Slice('Archivés',       3,  Color(0xFF9E9E9E)),
  ];

  // ── Bar chart data (monthly confirmed purchases) ─────────────────────────
  static const List<String> _months  = ['Nov', 'Déc', 'Jan', 'Fév', 'Mar', 'Avr'];
  static const List<double>  _monthly = [2, 4, 3, 6, 5, 2];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
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
        title: Text(
          'Tableau de Bord',
          style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: _darkText),
        ),
        iconTheme: const IconThemeData(color: _darkText),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: _darkText),
                onPressed: () {},
              ),
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 9, height: 9,
                  decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting ───────────────────────────────────────────────────
            Text(
              'Bonjour, Directeur 👋',
              style: GoogleFonts.domine(fontSize: 20, fontWeight: FontWeight.w700, color: _darkText),
            ),
            const SizedBox(height: 2),
            Text(
              'Voici l\'état de la pipeline en temps réel.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),

            // ── KPI Strip ──────────────────────────────────────────────────
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  KpiCard(label: 'En traitement', value: '8',  icon: Icons.hourglass_empty_rounded,   color: Colors.blue.shade600),
                  const SizedBox(width: 10),
                  KpiCard(label: 'À approuver',   value: '3',  icon: Icons.pending_actions_outlined,  color: Colors.orange.shade700),
                  const SizedBox(width: 10),
                  KpiCard(label: 'Sessions aujourd\'hui', value: '2', icon: Icons.wine_bar_outlined,  color: _green),
                  const SizedBox(width: 10),
                  KpiCard(label: 'Conformité labo', value: '94%', icon: Icons.biotech_outlined,       color: Colors.teal.shade600),
                  const SizedBox(width: 10),
                  KpiCard(label: 'Refusés (30j)',  value: '5',  icon: Icons.cancel_outlined,          color: Colors.red.shade500),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Session Active ─────────────────────────────────────────────
            _buildSessionProgressCard(),
            const SizedBox(height: 24),

            // ── Répartition des échantillons (Donut chart) ─────────────────
            _buildStatusPieChart(),
            const SizedBox(height: 24),

            // ── Acquisitions mensuelles (Bar chart) ────────────────────────
            _buildMonthlyAcquisitionsChart(),
            const SizedBox(height: 24),

            // ── Actions requises ───────────────────────────────────────────
            Row(
              children: [
                Text(
                  'Actions requises',
                  style: GoogleFonts.domine(fontSize: 17, fontWeight: FontWeight.w700, color: _darkText),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    '${_actionsUrgentes.length}',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade600, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._actionsUrgentes.map(
              (item) => ActionCardCeo(
                item: item,
                primaryLabel: _primaryLabel(item.type),
                secondaryLabel: 'Voir détails',
                onPrimaryAction: () {},
                onSecondaryAction: () {},
              ),
            ),

            const SizedBox(height: 24),
            _buildUpcomingDeliveriesSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Session progress card ─────────────────────────────────────────────────
  Widget _buildSessionProgressCard() {
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
              Text(
                'Session Active — S-08',
                style: GoogleFonts.domine(fontSize: 14, fontWeight: FontWeight.w700, color: _darkText),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'EN COURS',
                  style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('3 / 5', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _green)),
              const SizedBox(width: 6),
              Text('dégustateurs ont soumis', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 3 / 5,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.close, size: 14),
                label: const Text('Clôturer la session', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: Colors.red.shade500, padding: EdgeInsets.zero),
              ),
              const Spacer(),
              Text('Mise à jour il y a 30s', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Donut chart — sample status distribution ──────────────────────────────
  Widget _buildStatusPieChart() {
    final total = _statusSlices.fold(0.0, (s, e) => s + e.value);

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
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: _green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.donut_large_outlined, color: _green, size: 17),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Répartition des échantillons',
                      style: GoogleFonts.domine(fontSize: 14, fontWeight: FontWeight.w700, color: _darkText)),
                  Text('${total.toInt()} échantillons au total',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Chart + Legend ──
          Row(
            children: [
              // Donut
              SizedBox(
                height: 150,
                width: 150,
                child: PieChart(
                  PieChartData(
                    sections: _statusSlices.map((s) => PieChartSectionData(
                      value: s.value,
                      color: s.color,
                      radius: 48,
                      title: '${s.value.toInt()}',
                      titleStyle: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white,
                      ),
                    )).toList(),
                    centerSpaceRadius: 30,
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
                  children: _statusSlices.map((s) {
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
        ],
      ),
    );
  }

  // ── Bar chart — monthly confirmed acquisitions ────────────────────────────
  Widget _buildMonthlyAcquisitionsChart() {
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
          // ── Header ──
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
                  Text('Acquisitions mensuelles',
                      style: GoogleFonts.domine(fontSize: 14, fontWeight: FontWeight.w700, color: _darkText)),
                  Text('Achats confirmés — 6 derniers mois',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Bar chart ──
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 8,
                barGroups: List.generate(_months.length, (i) {
                  final isLast = i == _months.length - 1;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: _monthly[i],
                        color: isLast ? _green.withOpacity(0.35) : _green,
                        width: 26,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
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
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 6),
              Text('Achats confirmés', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Upcoming deliveries ───────────────────────────────────────────────────
  Widget _buildUpcomingDeliveriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livraisons à venir',
          style: GoogleFonts.domine(fontSize: 17, fontWeight: FontWeight.w700, color: _darkText),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: _green.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              _deliveryRow(ref: 'ECH-003', date: '15/03/2026', heure: '9:00',  lieu: 'Entrepôt Sfax',    collecteur: 'Ahmed D.'),
              const Divider(height: 20),
              _deliveryRow(ref: 'ECH-007', date: '18/03/2026', heure: '14:00', lieu: 'Dépôt Tunis Nord', collecteur: 'Sami K.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deliveryRow({
    required String ref, required String date,
    required String heure, required String lieu, required String collecteur,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: _green.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.local_shipping_outlined, color: _green, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ref, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _darkText)),
              Text('$date à $heure — $lieu', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
        Text(collecteur, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
      ],
    );
  }

  String _primaryLabel(ActionTypeCeo type) {
    switch (type) {
      case ActionTypeCeo.approbationEchantillon:         return 'Approuver';
      case ActionTypeCeo.demandeSuppressionCollecteur:   return 'Examiner';
      case ActionTypeCeo.sessionEnCours:                 return 'Voir session';
      case ActionTypeCeo.livraisonNonPlanifiee:          return 'Alerter';
    }
  }
}
