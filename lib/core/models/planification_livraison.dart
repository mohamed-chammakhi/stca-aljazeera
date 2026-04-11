// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/planification_livraison.dart
// PURPOSE : Full-stock delivery plan — created only after achat_confirme.
//           Matches the `planifications_livraison` table (1-to-1 with echantillon).
//           Same date structure as PlanificationArrivage + time, location,
//           and optional truck reference.
// ═════════════════════════════════════════════════════════════════════════════

import 'enums.dart';

class PlanificationLivraison {
  final String id;              // UUID PK
  final String echantillonId;   // UUID FK → echantillons (unique)
  final ModePlanification mode;

  final DateTime? dateExacte;
  final DateTime? periodeDebut;
  final DateTime? periodeFin;

  String heure;    // e.g. "09:30 AM"
  String lieu;
  String? camion;  // e.g. "CAM-03" — optional

  PlanificationLivraison({
    required this.id,
    required this.echantillonId,
    required this.mode,
    this.dateExacte,
    this.periodeDebut,
    this.periodeFin,
    required this.heure,
    required this.lieu,
    this.camion,
  });

  factory PlanificationLivraison.exact({
    required String id,
    required String echantillonId,
    required DateTime date,
    required String heure,
    required String lieu,
    String? camion,
  }) => PlanificationLivraison(
    id: id,
    echantillonId: echantillonId,
    mode: ModePlanification.dateExacte,
    dateExacte: date,
    heure: heure,
    lieu: lieu,
    camion: camion,
  );

  factory PlanificationLivraison.range({
    required String id,
    required String echantillonId,
    required DateTime debut,
    required DateTime fin,
    required String heure,
    required String lieu,
    String? camion,
  }) => PlanificationLivraison(
    id: id,
    echantillonId: echantillonId,
    mode: ModePlanification.periode,
    periodeDebut: debut,
    periodeFin: fin,
    heure: heure,
    lieu: lieu,
    camion: camion,
  );

  bool get isComplete => heure.trim().isNotEmpty && lieu.trim().isNotEmpty;

  /// Human-readable summary for display in cards.
  String get libelle {
    final datePart = mode == ModePlanification.dateExacte
        ? _fmtDate(dateExacte!)
        : (periodeDebut!.isAtSameMomentAs(periodeFin!)
              ? _fmtDate(periodeDebut!)
              : 'du ${_fmtDate(periodeDebut!)} au ${_fmtDate(periodeFin!)}');

    final camionPart = camion != null ? '  ·  $camion' : '';
    return '$datePart  ·  $heure  ·  $lieu$camionPart';
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  factory PlanificationLivraison.fromJson(Map<String, dynamic> json) =>
      PlanificationLivraison(
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
        heure:         json['heure']          as String,
        lieu:          json['lieu']           as String,
        camion:        json['camion']         as String?,
      );

  Map<String, dynamic> toJson() => {
    'id':             id,
    'echantillon_id': echantillonId,
    'mode':           mode.toJson,
    'date_exacte':    dateExacte?.toIso8601String(),
    'periode_debut':  periodeDebut?.toIso8601String(),
    'periode_fin':    periodeFin?.toIso8601String(),
    'heure':          heure,
    'lieu':           lieu,
    'camion':         camion,
  };
}
