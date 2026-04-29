import 'package:flutter/material.dart';

import '../models/dashboard_chef_degustateur.dart';
import 'home_shared.dart';

class DelaiSection extends StatelessWidget {
  final DelaiPanelData? delai;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final VoidCallback onDateTap;

  const DelaiSection({
    super.key,
    required this.delai,
    required this.dateDebut,
    required this.dateFin,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return fixedCard(
      height: 270,
      header: sectionBar(
        title: 'Délai de soumission — panel',
        icon: Icons.timer_outlined,
        dateDebut: dateDebut,
        dateFin: dateFin,
        onDateTap: onDateTap,
        chipLabel: ({required debut, required fin}) {
          if (debut == null) return '';
          final mois = [
            'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
            'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
          ];
          if (fin == null ||
              (debut.year == fin.year &&
                  debut.month == fin.month &&
                  debut.day == fin.day)) {
            return '${debut.day.toString().padLeft(2, '0')}/${debut.month.toString().padLeft(2, '0')}/${debut.year}';
          }
          return '${debut.day} ${mois[debut.month - 1]} → ${fin.day} ${mois[fin.month - 1]}';
        },
      ),
      body: Column(
        children: [
          if (delai != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: chefGreenLocal.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  _delaiStat(
                    'MOY. PANEL',
                    '${delai!.panelMoyen.toStringAsFixed(1)}j',
                    chefGreenLocal,
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                  _delaiStat('MEMBRES', '${delai!.membres.length}', chefDarkLocal),
                ],
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: delai == null
                ? const Center(
                    child: Text(
                      'Aucune donnée',
                      style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                    ),
                  )
                : buildScrollableRows(
                    items: delai!.membres,
                    getValue: (m) => m.delaiMoyen,
                    getMax: (m) => delai!.membres.first.delaiMoyen,
                    getColor: (m) {
                      if (m.delaiMoyen > delai!.panelMoyen * 1.5) {
                        return chefRed;
                      }
                      if (m.delaiMoyen > delai!.panelMoyen * 1.1) {
                        return chefAmber;
                      }
                      return chefGreenLocal;
                    },
                    getLabel: (m) => '${m.delaiMoyen.toStringAsFixed(1)}j',
                    getName: (m) => m.nom,
                  ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '↕ défiler pour voir tous',
              style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _delaiStat(String label, String value, Color color) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFFAAAAAA),
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    ),
  );
}
