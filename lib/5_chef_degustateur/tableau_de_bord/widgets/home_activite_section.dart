import 'package:flutter/material.dart';

import '../models/dashboard_chef_degustateur.dart';
import 'home_shared.dart';

class ActiviteSection extends StatelessWidget {
  final List<ActiviteItemChef> activite;
  final int activiteTotal;
  final bool activiteLoading;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final VoidCallback onDateTap;
  final VoidCallback onLoadMore;
  final VoidCallback onClearFilterTap;

  const ActiviteSection({
    super.key,
    required this.activite,
    required this.activiteTotal,
    required this.activiteLoading,
    required this.dateDebut,
    required this.dateFin,
    required this.onDateTap,
    required this.onLoadMore,
    required this.onClearFilterTap,
  });

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      decoration: BoxDecoration(
        color: chefWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          sectionBar(
            title: 'Activité récente',
            icon: Icons.access_time_outlined,
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
          if (dateDebut != null)
            Container(
              color: chefHeaderBgLocal,
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: chefGreenLocal.withValues(alpha: 0.06),
                  border: Border.all(
                    color: chefGreenLocal.withValues(alpha: 0.15),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 11, color: chefGreenLocal),
                    const SizedBox(width: 6),
                    Text(
                      dateFin != null
                          ? '${_fmtDate(dateDebut!)} → ${_fmtDate(dateFin!)}'
                          : _fmtDate(dateDebut!),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: chefGreenLocal,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onClearFilterTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '✕ Effacer',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n is ScrollEndNotification &&
                    n.metrics.pixels >= n.metrics.maxScrollExtent - 40) {
                  onLoadMore();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                itemCount: activite.length,
                itemBuilder: (_, i) => _timelineItem(
                  activite[i],
                  isLast: i == activite.length - 1,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              border: Border(
                top: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  activite.length >= activiteTotal
                      ? '$activiteTotal sur $activiteTotal — tout chargé'
                      : '1–${activite.length} sur $activiteTotal',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
                if (activiteLoading) ...[
                  const SizedBox(width: 10),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: chefGreenLocal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineItem(ActiviteItemChef item, {required bool isLast}) {
    final Color dot;
    switch (item.type) {
      case 'seance_presente':
        dot = chefBlue;
        break;
      case 'seance_manquee':
        dot = chefRed;
        break;
      case 'approbation':
        dot = chefGreenLocal;
        break;
      case 'refus':
        dot = chefRed;
        break;
      default:
        dot = chefAmber;
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1, color: const Color(0xFFE5E7E5)),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.action,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: chefDarkLocal,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.horodatage,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFBBBBBB),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
