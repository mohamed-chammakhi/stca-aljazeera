// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/panel_degustation/models/session_ceo.dart
// PURPOSE : Session model for CEO view — includes real-time submission progress
// ─────────────────────────────────────────────────────────────────────────────

enum StatutSessionCeo { planifiee, active, cloturee }

class SessionCeo {
  final String id;
  final String titre;
  final String date;
  final String heure;
  final String lieu;
  final List<String> echantillonIds;
  final List<String> membreIds;
  final List<String> membreNoms;
  final int soumissions; // how many have submitted
  StatutSessionCeo statut;
  final String? rapportAi; // generated after closure
  final DateTime createdAt;

  SessionCeo({
    required this.id,
    required this.titre,
    required this.date,
    required this.heure,
    required this.lieu,
    required this.echantillonIds,
    required this.membreIds,
    required this.membreNoms,
    required this.soumissions,
    required this.statut,
    this.rapportAi,
    required this.createdAt,
  });

  int get totalMembres => membreIds.length;
  bool get tousSoumis => soumissions >= totalMembres;
}
