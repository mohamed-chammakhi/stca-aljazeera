import 'enums.dart';

class ContactMessagerie {
  final String id;
  final String nom;
  final String prenom;
  final RoleUtilisateur role;

  const ContactMessagerie({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.role,
  });

  String get nomComplet => '$prenom $nom'.trim();
  String get roleLabel => role.label;

  factory ContactMessagerie.fromJson(Map<String, dynamic> json) =>
      ContactMessagerie(
        id: json['id'] as String,
        nom: (json['nom'] as String?) ?? '',
        prenom: (json['prenom'] as String?) ?? '',
        role: RoleUtilisateurX.fromJson(json['role'] as String),
      );

  static List<ContactMessagerie> fromJsonList(List<dynamic> json) => json
      .map((e) => ContactMessagerie.fromJson(e as Map<String, dynamic>))
      .toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'role': role.toJson,
  };
}
