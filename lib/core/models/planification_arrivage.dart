// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/planification_arrivage.dart
// PURPOSE : Collector's expected arrival window for the sample bottle.
//           Matches the `planifications_arrivage` table (1-to-1 with echantillon).
//           Either a single exact date OR an open date range — never both.
// ═════════════════════════════════════════════════════════════════════════════

import 'enums.dart';

class PlanificationArrivage {
  final String id;              // UUID PK
  final String echantillonId;   // UUID FK → echantillons (unique)
  final ModePlanification mode;

  /// Used when mode == dateExacte
  final DateTime? dateExacte;

  /// Used when mode == periode
  final DateTime? periodeDebut;
  final DateTime? periodeFin;

  const PlanificationArrivage({
    required this.id,
    required this.echantillonId,
    required this.mode,
    this.dateExacte,
    this.periodeDebut,
    this.periodeFin,
  });

  factory PlanificationArrivage.exact({
    required String id,
    required String echantillonId,
    required DateTime date,
  }) => PlanificationArrivage(
    id: id,
    echantillonId: echantillonId,
    mode: ModePlanification.dateExacte,
    dateExacte: date,
  );

  factory PlanificationArrivage.range({
    required String id,
    required String echantillonId,
    required DateTime debut,
    required DateTime fin,
  }) => PlanificationArrivage(
    id: id,
    echantillonId: echantillonId,
    mode: ModePlanification.periode,
    periodeDebut: debut,
    periodeFin: fin,
  );

  /// Human-readable summary for display in cards and snackbars.
  String get libelle {
    if (mode == ModePlanification.dateExacte) {
      return 'Arrivage prévu le ${_fmt(dateExacte!)}';
    }
    if (periodeDebut != null &&
        periodeFin != null &&
        periodeDebut!.isAtSameMomentAs(periodeFin!)) {
      return 'Arrivage prévu le ${_fmt(periodeDebut!)}';
    }
    return 'Arrivage prévu du ${_fmt(periodeDebut!)} au ${_fmt(periodeFin!)}';
  }

  static String _fmt(DateTime d) {
    final hour   = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year} '
        '$hour:$minute $period';
  }

  factory PlanificationArrivage.fromJson(Map<String, dynamic> json) =>
      PlanificationArrivage(
        id:            json['id']             as String,
        echantillonId: json['echantillon_id'] as String,
        mode:          ModePlanificationX.fromJson(json['mode'] as String),
        dateExacte:    json['date_exacte']    != null
                         ? DateTime.parse(json['date_exacte'] as String)
                         : null,
        periodeDebut:  json['periode_debut']  != null
                         ? DateTime.parse(json['periode_debut'] as String)
                         : null,
        periodeFin:    json['periode_fin']    != null
                         ? DateTime.parse(json['periode_fin'] as String)
                         : null,
      );

  Map<String, dynamic> toJson() => {
    'id':             id,
    'echantillon_id': echantillonId,
    'mode':           mode.toJson,
    'date_exacte':    dateExacte?.toIso8601String(),
    'periode_debut':  periodeDebut?.toIso8601String(),
    'periode_fin':    periodeFin?.toIso8601String(),
  };
}
