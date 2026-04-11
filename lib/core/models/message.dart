// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/message.dart
// PURPOSE : Chat message model — matches the `messages` table.
//           Used for collector ↔ direction messaging.
// ═════════════════════════════════════════════════════════════════════════════

class Message {
  final String id;              // UUID PK
  final String expediteurId;    // UUID FK → users
  final String destinataireId;  // UUID FK → users

  // ── Denormalized display fields (API annotations — not sent on POST/PUT) ────
  final String? expediteurNom;
  final String? destinataireNom;

  final String contenu;
  bool lu;
  String? luLe;            // ISO 8601 — set when message is read
  final String createdAt;  // ISO 8601

  Message({
    required this.id,
    required this.expediteurId,
    required this.destinataireId,
    this.expediteurNom,
    this.destinataireNom,
    required this.contenu,
    this.lu = false,
    this.luLe,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id:               json['id']                as String,
    expediteurId:     json['expediteur_id']     as String,
    destinataireId:   json['destinataire_id']   as String,
    expediteurNom:    json['expediteur_nom']    as String?,
    destinataireNom:  json['destinataire_nom']  as String?,
    contenu:          json['contenu']           as String,
    lu:               (json['lu'] as bool?) ?? false,
    luLe:             json['lu_le']             as String?,
    createdAt:        json['created_at']        as String,
  );

  /// For paginated Django list responses: { "count": N, "results": [...] }
  static List<Message> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List).map((e) => Message.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
    'id':              id,
    'expediteur_id':   expediteurId,
    'destinataire_id': destinataireId,
    'contenu':         contenu,
    'lu':              lu,
    'lu_le':           luLe,
    'created_at':      createdAt,
    // expediteur_nom and destinataire_nom are read-only API annotations.
  };
}
