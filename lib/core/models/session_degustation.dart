// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/session_degustation.dart
// PURPOSE : Tasting session model — matches `sessions_degustation` table.
//           M2M relationships (participants, echantillons) are represented as
//           lists of UUIDs; the junction tables are managed by the backend.
// ═════════════════════════════════════════════════════════════════════════════

import 'enums.dart';

class SessionDegustation {
  final String id;          // UUID PK
  String titre;
  String date;              // ISO 8601 date string
  String heure;             // "HH:MM" — 24h format
  String lieu;
  StatutSession statut;
  String? notes;
  final String createdBy;   // UUID FK → users (who created the session)
  final String createdAt;   // ISO 8601 timestamp

  /// Planned number of samples for this session (informational, set at creation).
  int? nombreEchantillonsPrevus;

  /// UUIDs of echantillons assigned to this session (from session_echantillons M2M).
  List<String> echantillonIds;

  /// UUIDs of taster participants (from session_participants M2M).
  List<String> participantIds;

  /// Denormalized display field — participant names (API annotation, not stored).
  final List<String>? participantNoms;

  SessionDegustation({
    required this.id,
    required this.titre,
    required this.date,
    required this.heure,
    required this.lieu,
    required this.statut,
    this.notes,
    this.nombreEchantillonsPrevus,
    required this.createdBy,
    required this.createdAt,
    this.echantillonIds  = const [],
    this.participantIds  = const [],
    this.participantNoms,
  });

  int get nbEchantillons => echantillonIds.length;
  int get nbParticipants => participantIds.length;

  factory SessionDegustation.fromJson(Map<String, dynamic> json) =>
      SessionDegustation(
        id:              json['id']              as String,
        titre:           json['titre']           as String,
        date:            json['date']            as String,
        heure:           json['heure']           as String,
        lieu:            json['lieu']            as String,
        statut:          StatutSessionX.fromJson(json['statut'] as String),
        notes:           json['notes']           as String?,
        createdBy:       json['created_by']      as String,
        createdAt:       json['created_at']      as String,
        nombreEchantillonsPrevus: json['nombre_echantillons_prevus'] as int?,
        echantillonIds:  (json['echantillon_ids'] as List?)
                             ?.map((e) => e as String).toList() ?? [],
        participantIds:  (json['participant_ids'] as List?)
                             ?.map((e) => e as String).toList() ?? [],
        participantNoms: (json['participant_noms'] as List?)
                             ?.map((e) => e as String).toList(),
      );

  /// For paginated Django list responses: { "count": N, "results": [...] }
  static List<SessionDegustation> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List)
          .map((e) => SessionDegustation.fromJson(e))
          .toList();

  Map<String, dynamic> toJson() => {
    'id':               id,
    'titre':            titre,
    'date':             date,
    'heure':            heure,
    'lieu':             lieu,
    'statut':           statut.toJson,
    'notes':            notes,
    'nombre_echantillons_prevus': nombreEchantillonsPrevus,
    'created_by':       createdBy,
    'created_at':       createdAt,
    'echantillon_ids':  echantillonIds,
    'participant_ids':  participantIds,
    // participant_noms is a read-only API annotation — not sent on POST/PUT.
  };
}
