// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/models/session_degustation.dart
// PURPOSE : data model for one dégustation session
// ═════════════════════════════════════════════════════════════════════════════

// ── Statut enum ───────────────────────────────────────────────────────────────
enum StatutSession { planifiee, enCours, terminee }

class SessionDegustation {
  final String id;
  String titre;
  String date;           // format DD/MM/YYYY
  String heure;          // format HH:MM
  String lieu;
  StatutSession statut;

  // list of echantillon IDs assigned to this session
  List<String> echantillonIds;

  // list of participant names/IDs
  List<String> participants;

  // optional notes
  String? notes;

  SessionDegustation({
    required this.id,
    required this.titre,
    required this.date,
    required this.heure,
    required this.lieu,
    required this.statut,
    this.echantillonIds = const [],
    this.participants   = const [],
    this.notes,
  });

  // convenience getters
  int get nbEchantillons => echantillonIds.length;
  int get nbParticipants => participants.length;
}
