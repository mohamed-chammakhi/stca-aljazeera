// ─────────────────────────────────────────────────────────────────────────────
// PLANIFICATION ARRIVAGE MODEL
// Represents the collector's estimated delivery window for the sample.
// Either a single precise date OR an open date range — never both.
// ─────────────────────────────────────────────────────────────────────────────
enum ModePlanification { dateExacte, periode }

class PlanificationArrivage {
  final ModePlanification mode;

  /// Used when mode == dateExacte
  final DateTime? dateExacte;

  /// Used when mode == periode
  final DateTime? periodeDebut;
  final DateTime? periodeFin;

  const PlanificationArrivage.exact(DateTime date)
    : mode = ModePlanification.dateExacte,
      dateExacte = date,
      periodeDebut = null,
      periodeFin = null;

  const PlanificationArrivage.range({
    required DateTime debut,
    required DateTime fin,
  }) : mode = ModePlanification.periode,
       dateExacte = null,
       periodeDebut = debut,
       periodeFin = fin;

  /// Human-readable summary shown on the card / snackbar
  String get libelle {
    final fmt = _fmt;
    if (mode == ModePlanification.dateExacte) {
      return 'Arrivage prévu le ${fmt(dateExacte!)}';
    }
    if (periodeDebut != null &&
        periodeFin != null &&
        periodeDebut!.isAtSameMomentAs(periodeFin!)) {
      return 'Arrivage prévu le ${fmt(periodeDebut!)}';
    }
    return 'Arrivage prévu du ${fmt(periodeDebut!)} au ${fmt(periodeFin!)}';
  }

  static String Function(DateTime) get _fmt => (d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year} ' // ← espace ici
        '$hour:$minute $period';
  };
}
