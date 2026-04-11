// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/user_profile.dart
// PURPOSE : Unified user model — matches the `users` table in Django/PostgreSQL.
//           All four roles (direction, collecteur, degustateur, laboratoire)
//           share this exact model. Role-specific UI logic lives in the pages.
// ═════════════════════════════════════════════════════════════════════════════

import 'enums.dart';

class UserProfile {
  // ── Identity (matches `users` DB table) ──────────────────────────────────────
  final String id;          // UUID PK — assigned by the backend
  final String email;       // unique, used for login
  final RoleUtilisateur role;

  // ── Personal info ─────────────────────────────────────────────────────────────
  String nom;
  String prenom;
  String? telephone;
  String? photoUrl;

  // ── Account state ─────────────────────────────────────────────────────────────
  final bool isActive;
  final String dateCreation;  // ISO 8601 — set by the server
  String? lastLogin;          // ISO 8601 — set by the server on each login

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.nom,
    required this.prenom,
    this.telephone,
    this.photoUrl,
    this.isActive = true,
    required this.dateCreation,
    this.lastLogin,
  });

  // ── Convenience getters ───────────────────────────────────────────────────────
  String get nomComplet => '$prenom $nom';
  String get initiales  => '${prenom[0]}${nom[0]}'.toUpperCase();

  // ── Serialization ─────────────────────────────────────────────────────────────
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id:            json['id']             as String,
    email:         json['email']          as String,
    role:          RoleUtilisateurX.fromJson(json['role'] as String),
    nom:           json['nom']            as String,
    prenom:        json['prenom']         as String,
    telephone:     json['telephone']      as String?,
    photoUrl:      json['photo_url']      as String?,
    isActive:      (json['is_active'] as bool?) ?? true,
    dateCreation:  json['date_creation']  as String,
    lastLogin:     json['last_login']     as String?,
  );

  /// For paginated Django list responses: { "count": N, "results": [...] }
  static List<UserProfile> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List).map((e) => UserProfile.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
    'id':            id,
    'email':         email,
    'role':          role.toJson,
    'nom':           nom,
    'prenom':        prenom,
    'telephone':     telephone,
    'photo_url':     photoUrl,
    'is_active':     isActive,
    'date_creation': dateCreation,
    'last_login':    lastLogin,
  };
}
