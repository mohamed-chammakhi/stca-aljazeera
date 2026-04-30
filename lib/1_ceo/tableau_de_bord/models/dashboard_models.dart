// Dashboard-specific data models.
// These are currently fed by mock constants in HomePageCeo.
// When the Django API is ready, replace the static const lists in
// _HomePageCeoState with service calls that return these same types.

const _moisAbr = [
  'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
  'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
];

/// Inclusive date range displayed on per-card date chips.
class CardDateRange {
  final DateTime from;
  final DateTime to;
  const CardDateRange(this.from, this.to);

  String get label {
    if (from.year == to.year && from.month == to.month && from.day == to.day) {
      return '${from.day} ${_moisAbr[from.month - 1]} ${from.year}';
    }
    if (from.year == to.year && from.month == to.month) {
      return '${_moisAbr[from.month - 1]} ${from.year}';
    }
    if (from.year == to.year) {
      return '${_moisAbr[from.month - 1]} – ${_moisAbr[to.month - 1]} ${from.year}';
    }
    return '${_moisAbr[from.month - 1]} ${from.year} – ${_moisAbr[to.month - 1]} ${to.year}';
  }
}

/// One row in the collector performance chart.
class CollecteurDashStat {
  final String name;
  final String initials;
  final int samples;
  final double approvalRate;
  final int totalValue;
  final int avgDaysToClose;

  const CollecteurDashStat(
    this.name,
    this.initials,
    this.samples,
    this.approvalRate,
    this.totalValue,
    this.avgDaysToClose,
  );
}

/// One row in the urgent-decisions panel.
class UrgentDecision {
  final String ref;
  final String collecteur;
  final String fournisseur;
  final int joursEnAttente;

  const UrgentDecision(
    this.ref,
    this.collecteur,
    this.fournisseur,
    this.joursEnAttente,
  );
}

/// One row in the supplier-frequency card.
class FournisseurStat {
  final String name;
  final String region;
  final int achats;
  final double valeur;

  const FournisseurStat(this.name, this.region, this.achats, this.valeur);
}
