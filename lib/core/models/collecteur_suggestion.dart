class CollecteurSuggestion {
  final String id;
  final String nom;
  final String prenom;
  final String nomComplet;

  const CollecteurSuggestion({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.nomComplet,
  });

  factory CollecteurSuggestion.fromJson(Map<String, dynamic> json) {
    final nom = (json['nom'] as String?)?.trim() ?? '';
    final prenom = (json['prenom'] as String?)?.trim() ?? '';
    final nomComplet = (json['nom_complet'] as String?)?.trim();
    return CollecteurSuggestion(
      id: json['id'] as String,
      nom: nom,
      prenom: prenom,
      nomComplet: nomComplet?.isNotEmpty == true
          ? nomComplet!
          : '$prenom $nom'.trim(),
    );
  }
}
