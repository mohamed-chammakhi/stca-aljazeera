import 'package:flutter/material.dart';

const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _amber = Color(0xFFD07B2F);
const Color _blue = Color(0xFF3A6EA5);
const Color _white = Color(0xFFFFFFFF);

class PipelineCard extends StatelessWidget {
  final List<int> counts;

  const PipelineCard({super.key, required this.counts});

  static String _fmtPipe(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}k';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Receptionne', 'Recu', 'En negoc.', 'Confirme'];
    const colors = [_blue, Color(0xFF6B8143), _amber, _green];
    final values = counts.length >= 4 ? counts : const [0, 0, 0, 0];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Pipeline des echantillons', Icons.timeline_outlined),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: values[i].toDouble()),
                            duration: Duration(milliseconds: 900 + i * 100),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, _) => Column(
                              children: [
                                Text(
                                  _fmtPipe(v.toInt()),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: colors[i],
                                  ),
                                ),
                                if (values[i] >= 1000)
                                  Text(
                                    v.toInt().toString().replaceAllMapped(
                                          RegExp(r'\B(?=(\d{3})+(?!\d))'),
                                          (_) => ' ',
                                        ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: colors[i].withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < 3)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Icon(Icons.chevron_right, size: 14, color: Colors.grey.shade200),
                      ),
                  ],
                ),
              ),
            ),
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
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark),
          ),
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
