// ─────────────────────────────────────────────────────────────────────────────
// FILE : membres_panel/models/membre_panel.dart
// PURPOSE : data model for a panel member
// ─────────────────────────────────────────────────────────────────────────────

class MembrePanel {
  final String id;
  final String nom;
  final String prenom;
  final String role;
  final String membreDepuis;
  final bool estEnLigne;

  const MembrePanel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.role,
    required this.membreDepuis,
    this.estEnLigne = false,
  });

  String get nomComplet => '$prenom $nom';
  String get initiales => '${prenom[0]}${nom[0]}'.toUpperCase();

  factory MembrePanel.fromJson(Map<String, dynamic> json) => MembrePanel(
    id: json['id'] as String,
    nom: json['nom'] as String,
    prenom: json['prenom'] as String,
    role: json['role'] as String,
    membreDepuis: json['membre_depuis'] as String,
    estEnLigne: json['est_en_ligne'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'role': role,
    'membre_depuis': membreDepuis,
    'est_en_ligne': estEnLigne,
  };
}