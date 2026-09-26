import 'enums.dart';

class UserProfile {
  final String id;
  final String email;
  final RoleUtilisateur role;

  String nom;
  String prenom;
  String? telephone;
  String? photoUrl;

  final bool isActive;
  final String dateCreation;
  final String? dateSuppression;
  final String statut;
  final bool doitChangerMotDePasse;
  String? lastLogin;

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
    this.dateSuppression,
    this.statut = 'actif',
    this.doitChangerMotDePasse = false,
    this.lastLogin,
  });

  String get nomComplet => '$prenom $nom';
  String get initiales => '${prenom[0]}${nom[0]}'.toUpperCase();
  bool get estSupprime => statut == 'supprime';

  String get statutLabel {
    switch (statut) {
      case 'supprime':
        return 'Utilisateur supprimé';
      case 'desactive':
        return 'Désactivé';
      default:
        return 'Actif';
    }
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    email: json['email'] as String,
    role: RoleUtilisateurX.fromJson(json['role'] as String),
    nom: json['nom'] as String,
    prenom: json['prenom'] as String,
    telephone: json['telephone'] as String?,
    photoUrl: json['photo_url'] as String?,
    isActive: (json['is_active'] as bool?) ?? true,
    dateCreation: json['date_creation'] as String,
    dateSuppression: json['date_suppression'] as String?,
    statut:
        (json['statut'] as String?) ??
        (((json['is_active'] as bool?) ?? true) ? 'actif' : 'desactive'),
    doitChangerMotDePasse:
        (json['doit_changer_mot_de_passe'] as bool?) ?? false,
    lastLogin: json['last_login'] as String?,
  );

  static List<UserProfile> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List).map((e) => UserProfile.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role.toJson,
    'nom': nom,
    'prenom': prenom,
    'telephone': telephone,
    'photo_url': photoUrl,
    'is_active': isActive,
    'statut': statut,
    'doit_changer_mot_de_passe': doitChangerMotDePasse,
    'date_creation': dateCreation,
    'date_suppression': dateSuppression,
    'last_login': lastLogin,
  };
}
