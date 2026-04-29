import 'package:flutter/material.dart';

import '../models/dashboard_chef_degustateur.dart';
import 'home_shared.dart';

class PipelineSection extends StatelessWidget {
  final PipelineChefData? pipeline;

  const PipelineSection({super.key, required this.pipeline});

  String _fmtN(int n) {
    if (n >= 1000) {
      final k = n / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final p = pipeline;
    return fixedCard(
      height: 160,
      header: sectionBar(
        title: 'Pipeline des échantillons',
        icon: Icons.timeline_outlined,
        chipLabel: ({required debut, required fin}) => '',
      ),
      body: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pipeCell(
              _fmtN(p?.receptionne ?? 0),
              p?.receptionne ?? 0,
              'Réceptionné',
              chefBlue,
            ),
            _pipeArrow(),
            _pipeCell(
              _fmtN(p?.enAttenteEval ?? 0),
              p?.enAttenteEval ?? 0,
              'Non évaluée',
              chefAmber,
            ),
            _pipeArrow(),
            _pipeCell(
              _fmtN(p?.enCours ?? 0),
              p?.enCours ?? 0,
              'En cours',
              chefPurple,
            ),
            _pipeArrow(),
            _pipeCell(
              _fmtN(p?.soumis ?? 0),
              p?.soumis ?? 0,
              'Soumise',
              chefGreenLocal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pipeCell(String label, int exact, String subtitle, Color color) =>
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              '$exact',
              style: const TextStyle(fontSize: 8, color: Color(0xFFAAAAAA)),
            ),
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      );

  Widget _pipeArrow() => const Padding(
    padding: EdgeInsets.only(bottom: 24),
    child: Text('›', style: TextStyle(fontSize: 14, color: Color(0xFFEEEEEE))),
  );
}
