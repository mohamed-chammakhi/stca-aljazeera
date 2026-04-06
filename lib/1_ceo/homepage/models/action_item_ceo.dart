// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/homepage/models/action_item_ceo.dart
// PURPOSE : Model for urgent action items shown on the CEO homepage
// ─────────────────────────────────────────────────────────────────────────────

enum ActionTypeCeo {
  approbationEchantillon,
  demandeSuppressionCollecteur,
  sessionEnCours,
  livraisonNonPlanifiee,
}

class ActionItemCeo {
  final String id;
  final ActionTypeCeo type;
  final String titre;
  final String description;
  final String? acteur;       // collector name, taster name, etc.
  final DateTime date;
  final bool urgent;

  const ActionItemCeo({
    required this.id,
    required this.type,
    required this.titre,
    required this.description,
    this.acteur,
    required this.date,
    this.urgent = false,
  });
}
