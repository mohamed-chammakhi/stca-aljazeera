import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_models.dart';

const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _amber = Color(0xFFD07B2F);
const Color _white = Color(0xFFFFFFFF);

class ClassificationCard extends StatelessWidget {
  final CardDateRange dateRange;
  final Map<String, int> values;
  final Widget Function(CardDateRange, VoidCallback) dateChipBuilder;
  final void Function(CardDateRange) onRangeChanged;

  const ClassificationCard({
    super.key,
    required this.dateRange,
    required this.values,
    required this.dateChipBuilder,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = values.keys.where((label) => values[label]! > 0).toList();
    final effectiveLabels = labels.isEmpty ? const ['Aucune'] : labels;
    final chartValues = labels.isEmpty
        ? const [1.0]
        : effectiveLabels.map((label) => values[label]!.toDouble()).toList();
    final colors = const [_green, Color(0xFF6B8143), Color(0xFF3A6EA5), _amber];
    final total = chartValues.fold(0.0, (s, e) => s + e);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _sectionLabel('Classification de l\'huile', Icons.donut_large_outlined)),
              dateChipBuilder(dateRange, () {}),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: PieChart(
                  PieChartData(
                    sections: List.generate(
                      effectiveLabels.length,
                      (i) => PieChartSectionData(
                        value: chartValues[i],
                        color: labels.isEmpty ? Colors.grey.shade300 : colors[i.clamp(0, colors.length - 1)],
                        radius: 38,
                        title: labels.isEmpty ? '0' : chartValues[i].toInt().toString(),
                        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    centerSpaceRadius: 28,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(enabled: false),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(effectiveLabels.length, (i) {
                    final label = effectiveLabels[i];
                    final value = labels.isEmpty ? 0.0 : chartValues[i];
                    final pct = total == 0 ? '0' : (value / total * 100).toStringAsFixed(0);
                    final color = labels.isEmpty ? Colors.grey : colors[i.clamp(0, colors.length - 1)];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(label, style: const TextStyle(fontSize: 11, color: _dark)),
                                ],
                              ),
                              Text('$pct%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: total == 0 ? 0 : value / total),
                            duration: Duration(milliseconds: 900 + i * 100),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, _) => ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: v,
                                backgroundColor: Colors.grey.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _sectionLabel(String text, IconData icon) => Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 14, color: _green),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark))),
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
