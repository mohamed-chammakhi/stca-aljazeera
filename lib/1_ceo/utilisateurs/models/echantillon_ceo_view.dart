// ═════════════════════════════════════════════════════════════════════════════
// FILE    : ceo/utilisateurs/models/echantillon_ceo_view.dart
// PURPOSE : CEO-specific view model — aggregates sample + evaluations + analysis
//           into one object for the CEO pages. All enums/types come from core.
// ═════════════════════════════════════════════════════════════════════════════

// Re-export core types so CEO pages only need to import this one file.
export '../../../../core/models/enums.dart'
    show
        ClassificationHuile,
        ClassificationHuileX,
        StatutCeo,
        StatutCeoX;

export '../../../../core/models/evaluation_organoleptique.dart';
export '../../../../core/widgets/analyse_labo_sheet_adapter.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/evaluation_organoleptique.dart';
import '../../../../core/widgets/analyse_labo_sheet_adapter.dart';

// ── Sample view model ─────────────────────────────────────────────────────────
class EchantillonCeoView {
  final String id;
  final String referenceBouteille;
  final String gouvernorat;
  final String? delegation;
  final String codeFournisseur;
  final String? scellage;
  final String? variete;
  final String? quantiteEstimee;
  final String dateAjout;
  final String? dateLivraisonPrevue;
  final String? dateArriveeEchantillon;
  final String? collecteurNom;
  bool recuPhysiquement;
  StatutCeo statut;
  final int totalTasteurs;
  final List<EvaluationOrganoleptique> evaluations;
  final AnalyseLaboCeoView? analyse;
  String? raisonRefus;
  String? budgetNegociation;
  String? dateLivraisonStockSouhaitee; // CEO's desired delivery date for stock
  String? quantiteCibleT;
  String? camionReserve;
  String? noteInterne;
  bool stockArrive;
  String? dateLivraisonStock;
  String? remarques;

  EchantillonCeoView({
    required this.id,
    required this.referenceBouteille,
    required this.gouvernorat,
    this.delegation,
    required this.codeFournisseur,
    this.scellage,
    this.variete,
    this.quantiteEstimee,
    required this.dateAjout,
    this.dateLivraisonPrevue,
    this.dateArriveeEchantillon,
    this.collecteurNom,
    this.recuPhysiquement = false,
    required this.statut,
    required this.totalTasteurs,
    this.evaluations = const [],
    this.analyse,
    this.raisonRefus,
    this.budgetNegociation,
    this.dateLivraisonStockSouhaitee,
    this.quantiteCibleT,
    this.camionReserve,
    this.noteInterne,
    this.stockArrive = false,
    this.dateLivraisonStock,
    this.remarques,
  });

  int get nombreEvaluations => evaluations.length;
  bool get tousEvalue => evaluations.length >= totalTasteurs;

  ClassificationHuile? get classificationMajoritaire {
    if (evaluations.isEmpty) return null;
    final counts = <ClassificationHuile, int>{};
    for (final e in evaluations) {
      counts[e.classification] = (counts[e.classification] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
