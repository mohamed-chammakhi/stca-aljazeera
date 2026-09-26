// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/session_degustation.dart
// PURPOSE : Tasting session model — matches `sessions_degustation` table.
//           M2M relationships (participants, echantillons) are represented as
//           lists of UUIDs; the junction tables are managed by the backend.
// ═════════════════════════════════════════════════════════════════════════════

import 'enums.dart';
export 'enums.dart' show StatutSession, StatutSessionX;

String _stringValue(dynamic value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

String _dateFromJson(dynamic value) {
  final raw = _stringValue(value);
  final datePart = raw.split('T').first.split(' ').first;
  final iso = datePart.split('-');
  if (iso.length == 3) {
    return '${iso[2].padLeft(2, '0')}/${iso[1].padLeft(2, '0')}/${iso[0]}';
  }
  return raw;
}

String _dateToJson(String value) {
  final parts = value.split('/');
  if (parts.length == 3) {
    return '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
  }
  return value.split('T').first;
}

String _timeFromJson(dynamic value) {
  final raw = _stringValue(value);
  if (raw.length >= 5) return raw.substring(0, 5);
  return raw;
}

String _dateHeureAffichage(String date, String heure) {
  final d = _dateFromJson(date);
  final h = _timeFromJson(heure);
  if (d.isEmpty) return h;
  if (h.isEmpty) return d;
  return '$d à $h';
}

List<String> _stringList(dynamic value) =>
    (value as List?)?.map((e) => e.toString()).toList() ?? [];

int? _intValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

class SessionDegustation {
  final String id; // UUID PK
  String titre;
  String date; // ISO 8601 date string
  String heure; // "HH:MM" — 24h format
  String lieu;
  StatutSession statut;
  String? notes;
  final String createdBy; // UUID FK → users (who created the session)
  final String? createdByNom; // what the screens show — never the UUID
  final String createdAt; // ISO 8601 timestamp

  /// Planned number of samples for this session (informational, set at creation).
  int? nombreEchantillonsPrevus;

  /// UUIDs of echantillons assigned to this session (from session_echantillons M2M).
  List<String> echantillonIds;

  /// UUIDs of taster participants (from session_participants M2M).
  List<String> participantIds;

  /// Denormalized display field — participant names (API annotation, not stored).
  final List<String>? participantNoms;

  /// UUIDs of participants who confirmed their presence.
  List<String> confirmedParticipantIds;

  /// Denormalized display field — confirmed participant names (API annotation, not stored).
  final List<String>? confirmedParticipantNoms;

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
    this.createdByNom,
    required this.createdAt,
    this.echantillonIds = const [],
    this.participantIds = const [],
    this.participantNoms,
    this.confirmedParticipantIds = const [],
    this.confirmedParticipantNoms,
  });

  int get nbEchantillons => echantillonIds.length;
  int get nbParticipants => participantIds.length;
  String get dateHeureAffichage => _dateHeureAffichage(date, heure);

  factory SessionDegustation.fromJson(Map<String, dynamic> json) =>
      SessionDegustation(
        id: _stringValue(json['id']),
        titre: _stringValue(json['titre']),
        date: _dateFromJson(json['date']),
        heure: _timeFromJson(json['heure']),
        lieu: _stringValue(json['lieu']),
        statut: StatutSessionX.fromJson(_stringValue(json['statut'])),
        notes: json['notes'] as String?,
        createdBy: _stringValue(json['created_by'] ?? json['cree_par']),
        createdByNom: json['created_by_nom'] as String?,
        createdAt: _stringValue(json['created_at'] ?? json['date_creation']),
        nombreEchantillonsPrevus: _intValue(json['nombre_echantillons_prevus']),
        echantillonIds: _stringList(
          json['echantillon_ids'] ?? json['echantillons'],
        ),
        participantIds: _stringList(
          json['participant_ids'] ?? json['participants'],
        ),
        participantNoms: json['participant_noms'] == null
            ? null
            : _stringList(json['participant_noms']),
        confirmedParticipantIds: _stringList(json['confirmed_participant_ids']),
        confirmedParticipantNoms: json['confirmed_participant_noms'] == null
            ? null
            : _stringList(json['confirmed_participant_noms']),
      );

  /// For paginated Django list responses: { "count": N, "results": [...] }
  static List<SessionDegustation> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List)
          .map((e) => SessionDegustation.fromJson(e))
          .toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': titre,
    'date': _dateToJson(date),
    'heure': heure,
    'lieu': lieu,
    'statut': statut.toJson,
    'notes': notes,
    'nombre_echantillons_prevus': nombreEchantillonsPrevus,
    'created_by': createdBy,
    'created_at': createdAt,
    'echantillon_ids': echantillonIds,
    'participant_ids': participantIds,
    'confirmed_participant_ids': confirmedParticipantIds,
    // participant_noms and confirmed_participant_noms are read-only API annotations — not sent on POST/PUT.
  };
}
