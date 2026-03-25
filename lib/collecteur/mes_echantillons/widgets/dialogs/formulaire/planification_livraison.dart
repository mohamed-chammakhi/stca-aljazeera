// ─────────────────────────────────────────────────────────────────────────────
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire/planification_livraison.dart
//
// Confirmed delivery plan — created only after achatConfirme.
// Same date structure as PlanificationArrivage (exact or range) +
// time, location, and optional truck reference.
// ─────────────────────────────────────────────────────────────────────────────

enum ModeLivraison { dateExacte, periode }

class PlanificationLivraison {
  final ModeLivraison mode;

  // Date
  final DateTime? dateExacte;
  final DateTime? periodeDebut;
  final DateTime? periodeFin;

  // Logistics
  final String heure; // e.g. "09:30 AM"
  final String lieu;
  final String? camion; // e.g. "CAM-03" — optional

  const PlanificationLivraison.exact({
    required DateTime date,
    required this.heure,
    required this.lieu,
    this.camion,
  }) : mode = ModeLivraison.dateExacte,
       dateExacte = date,
       periodeDebut = null,
       periodeFin = null;

  const PlanificationLivraison.range({
    required DateTime debut,
    required DateTime fin,
    required this.heure,
    required this.lieu,
    this.camion,
  }) : mode = ModeLivraison.periode,
       dateExacte = null,
       periodeDebut = debut,
       periodeFin = fin;

  bool get isComplete => heure.trim().isNotEmpty && lieu.trim().isNotEmpty;

  /// Human-readable summary shown on the card
  String get libelle {
    final fmt = _fmtDate;
    final datePart = mode == ModeLivraison.dateExacte
        ? fmt(dateExacte!)
        : (periodeDebut!.isAtSameMomentAs(periodeFin!)
              ? fmt(periodeDebut!)
              : 'du ${fmt(periodeDebut!)} au ${fmt(periodeFin!)}');

    final camionPart = camion != null ? '  ·  $camion' : '';
    return '$datePart  ·  $heure  ·  $lieu$camionPart';
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}
