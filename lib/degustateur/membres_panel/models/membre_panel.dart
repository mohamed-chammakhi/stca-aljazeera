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
}