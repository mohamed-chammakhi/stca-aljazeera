import 'package:flutter/material.dart';

import '../models/dashboard_degustateur.dart';
import 'home_shared.dart';

class HomePipelineSection extends StatelessWidget {
  const HomePipelineSection({super.key, required this.pipeline});
  final PipelineData? pipeline;

  @override
  Widget build(BuildContext context) {
    return homeFixedCard(
      height: 142,
      header: homeSectionBar(
        title: 'Pipeline de mes évaluations',
        icon: Icons.timeline_outlined,
      ),
      body: _buildPipelineGrid(pipeline),
    );
  }

  Widget _buildPipelineGrid(PipelineData? p) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _pipeCell(p?.receptionne ?? 0, 'Réceptionné', homeBlue),
          _pipeArrow(),
          _pipeCell(p?.nonEvaluee ?? 0, 'Non évaluée', homeAmber),
          _pipeArrow(),
          _pipeCell(p?.enCours ?? 0, 'En cours', homePurple),
          _pipeArrow(),
          _pipeCell(p?.soumise ?? 0, 'Soumise', homeGreen),
        ],
      ),
    );
  }

  Widget _pipeCell(int n, String label, Color color) => Expanded(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$n',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
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
          label,
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
