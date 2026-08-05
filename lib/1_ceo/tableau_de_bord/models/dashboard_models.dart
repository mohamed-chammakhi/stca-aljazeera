// Dashboard-specific data models.

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

class PurchaseEvolutionPoint {
  final String label;
  final double value;

  const PurchaseEvolutionPoint(this.label, this.value);
}

class DashboardCeoSnapshot {
  final int totalSamples;
  final int selectedSamples;
  final int confirmedPurchases;
  final int arrivedStocks;
  final int pendingEvaluations;
  final int submittedAnalyses;
  final double totalInvestment;
  final int pipelineReceptionne;
  final int pipelineRecu;
  final int pipelineNegotiation;
  final int pipelineConfirmed;
  final int stockTransit;
  final int stockReceived;
  final Map<String, int> classifications;
  final List<CollecteurDashStat> collectors;
  final List<UrgentDecision> urgentItems;
  final List<FournisseurStat> suppliers;
  final List<PurchaseEvolutionPoint> purchaseEvolution;

  const DashboardCeoSnapshot({
    required this.totalSamples,
    required this.selectedSamples,
    required this.confirmedPurchases,
    required this.arrivedStocks,
    required this.pendingEvaluations,
    required this.submittedAnalyses,
    required this.totalInvestment,
    required this.pipelineReceptionne,
    required this.pipelineRecu,
    required this.pipelineNegotiation,
    required this.pipelineConfirmed,
    required this.stockTransit,
    required this.stockReceived,
    required this.classifications,
    required this.collectors,
    required this.urgentItems,
    required this.suppliers,
    required this.purchaseEvolution,
  });

  factory DashboardCeoSnapshot.fromJson(Map<String, dynamic> json) {
    final kpis = _map(json['kpis']);
    final pipeline = _map(json['pipeline']);
    final stock = _map(json['stock']);
    final classifications = _map(json['classifications']);

    return DashboardCeoSnapshot(
      totalSamples: _int(json['echantillons_total'] ?? kpis['total']),
      selectedSamples: _int(json['echantillons_selectionnes']),
      confirmedPurchases: _int(json['achats_confirmes'] ?? kpis['achat_confirme']),
      arrivedStocks: _int(json['stocks_arrives'] ?? kpis['stocks_arrives']),
      pendingEvaluations: _int(json['evaluations_en_attente'] ?? kpis['evaluations_en_attente']),
      submittedAnalyses: _int(json['analyses_soumises'] ?? kpis['analyses_soumises']),
      totalInvestment: _double(kpis['investissement_total']),
      pipelineReceptionne: _int(pipeline['receptionne']),
      pipelineRecu: _int(json['evaluations_en_attente'] ?? kpis['evaluations_en_attente']),
      pipelineNegotiation: _int(pipeline['en_negociation']),
      pipelineConfirmed: _int(pipeline['achat_confirme']),
      stockTransit: _int(stock['en_transit']),
      stockReceived: _int(stock['recu']),
      classifications: {
        'Extra Vierge': _int(classifications['extra_vierge']),
        'Vierge': _int(classifications['vierge']),
        'Ordinaire': _int(classifications['vierge_ordinaire']),
        'Lampante': _int(classifications['lampante']),
      },
      collectors: _list(json['performance_collecteurs'] ?? json['collecteurs'])
          .map((item) => _collector(_map(item)))
          .toList(),
      urgentItems: _list(json['decisions_urgentes'])
          .map((item) => _urgent(_map(item)))
          .toList(),
      suppliers: _list(json['fournisseurs'])
          .map((item) => _supplier(_map(item)))
          .toList(),
      purchaseEvolution: _list(json['evolution_achats'])
          .map((item) => _evolution(_map(item)))
          .toList(),
    );
  }

  static DashboardCeoSnapshot mock() => const DashboardCeoSnapshot(
        totalSamples: 11,
        selectedSamples: 4,
        confirmedPurchases: 5,
        arrivedStocks: 2,
        pendingEvaluations: 3,
        submittedAnalyses: 6,
        totalInvestment: 284500,
        pipelineReceptionne: 12,
        pipelineRecu: 8,
        pipelineNegotiation: 5,
        pipelineConfirmed: 9,
        stockTransit: 3,
        stockReceived: 6,
        classifications: {
          'Extra Vierge': 9,
          'Vierge': 4,
          'Ordinaire': 0,
          'Lampante': 2,
        },
        collectors: [
          CollecteurDashStat('Ahmed Dridi', 'AD', 8, 0.75, 92400, 6),
          CollecteurDashStat('Fatma Bouzid', 'FB', 5, 0.80, 68900, 4),
          CollecteurDashStat('Sami Kraiem', 'SK', 6, 0.67, 71200, 8),
          CollecteurDashStat('Khalil Maalej', 'KM', 4, 0.50, 38000, 11),
        ],
        urgentItems: [
          UrgentDecision('ECH-2026-031', 'Ahmed Dridi', 'Henchir Errouss', 3),
          UrgentDecision('ECH-2026-028', 'Sami Kraiem', 'Domaine Zitoun', 2),
        ],
        suppliers: [
          FournisseurStat('Henchir Errouss', 'Sfax', 7, 143200),
          FournisseurStat('Domaine Zitoun', 'Gafsa', 5, 98400),
          FournisseurStat('Ferme El Baraka', 'Sousse', 4, 76100),
          FournisseurStat('Agricole Ben Ali', 'Nabeul', 3, 55300),
          FournisseurStat('Coop. Nour', 'Sidi Bz', 2, 32000),
        ],
        purchaseEvolution: [
          PurchaseEvolutionPoint('Oct', 18000),
          PurchaseEvolutionPoint('Nov', 32000),
          PurchaseEvolutionPoint('Dec', 55000),
          PurchaseEvolutionPoint('Jan', 68000),
          PurchaseEvolutionPoint('Feb', 72000),
          PurchaseEvolutionPoint('Mar', 54000),
          PurchaseEvolutionPoint('Apr', 38000),
        ],
      );
}

Map<String, dynamic> _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((key, value) => MapEntry(key.toString(), value));
  return {};
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

int _int(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0;
  return 0;
}

double _double(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

CollecteurDashStat _collector(Map<String, dynamic> json) => CollecteurDashStat(
      (json['name'] ?? json['nom'] ?? 'Collecteur').toString(),
      (json['initials'] ?? '--').toString(),
      _int(json['samples'] ?? json['nb']),
      _double(json['approval_rate']),
      _int(json['total_value']),
      _int(json['avg_days_to_close']),
    );

UrgentDecision _urgent(Map<String, dynamic> json) => UrgentDecision(
      (json['ref'] ?? json['numero'] ?? json['reference_bouteille'] ?? '').toString(),
      (json['collecteur'] ?? json['collecteur_nom'] ?? '').toString(),
      (json['fournisseur'] ?? json['fournisseur_nom'] ?? '').toString(),
      _int(json['jours_en_attente']),
    );

FournisseurStat _supplier(Map<String, dynamic> json) => FournisseurStat(
      (json['name'] ?? json['nom'] ?? 'Fournisseur').toString(),
      (json['region'] ?? '').toString(),
      _int(json['achats']),
      _double(json['valeur']),
    );

PurchaseEvolutionPoint _evolution(Map<String, dynamic> json) =>
    PurchaseEvolutionPoint(
      (json['label'] ?? '').toString(),
      _double(json['valeur'] ?? json['value']),
    );
