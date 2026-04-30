import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _amber = Color(0xFFD07B2F);
const Color _white = Color(0xFFFFFFFF);

/// Donut chart: stock en transit vs stock reçu.
/// Data is hardcoded here until the Django API endpoint is wired.
class StockDonutCard extends StatelessWidget {
  const StockDonutCard({super.key});

  static String _fmtNum(int n) =>
      n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');

  @override
  Widget build(BuildContext context) {
    const transitL = 145000;
    const recuL = 287000;
    const total = transitL + recuL;
    const transitPct = transitL / total;
    const recuPct = recuL / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('État du stock', Icons.warehouse_outlined),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 120, height: 120,
                child: PieChart(PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: transitL.toDouble(), color: _amber, radius: 42,
                      title: '${(transitPct * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    PieChartSectionData(
                      value: recuL.toDouble(), color: _green, radius: 42,
                      title: '${(recuPct * 100).toStringAsFixed(0)}%',
                      titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                  centerSpaceRadius: 30,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(enabled: false),
                )),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendItem('En transit', _amber, '3 lots', _fmtNum(transitL)),
                    const SizedBox(height: 16),
                    _legendItem('Stock reçu', _green, '6 lots', _fmtNum(recuL)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, String lots, String liters) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _dark)),
              const SizedBox(height: 2),
              Text('$lots  ·  $liters L', style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _sectionLabel(String text, IconData icon) => Row(
  children: [
    Container(
      width: 3, height: 16,
      decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2)),
    ),
    const SizedBox(width: 8),
    Icon(icon, size: 14, color: _green),
    const SizedBox(width: 6),
    Flexible(
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
    ),
  ],
);

BoxDecoration _cardDeco() => BoxDecoration(
  color: _white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
  boxShadow: [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
  ],
);
