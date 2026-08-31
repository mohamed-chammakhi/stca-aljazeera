import 'rapport_labo.dart';

enum StatutAnalyse { enAttente, soumise }

/// Une ligne de la liste « Analyse de laboratoire », commune aux deux rôles
/// de dégustation. Elle ne contient aucun chemin d'écriture du rapport.
class LigneAnalyseLabo {
  final String id;
  final String echantillonId;
  final String numero;
  final String referenceBouteille;
  final String echantillonNom;
  final String technicienNom;
  final StatutAnalyse statut;
  final String? fournisseurNom;
  final String? gouvernorat;
  final String? delegation;
  final String? collecteurNom;
  final String? variete;
  final String? quantiteEstimee;
  final String? dateEnregistrement;
  final String? dateReceptionPhysique;
  final RapportLabo? rapport;

  const LigneAnalyseLabo({
    required this.id,
    required this.echantillonId,
    required this.numero,
    required this.referenceBouteille,
    required this.echantillonNom,
    required this.technicienNom,
    required this.statut,
    this.fournisseurNom,
    this.gouvernorat,
    this.delegation,
    this.collecteurNom,
    this.variete,
    this.quantiteEstimee,
    this.dateEnregistrement,
    this.dateReceptionPhysique,
    this.rapport,
  });

  factory LigneAnalyseLabo.fromJson(Map<String, dynamic> json) {
    final rapportJson = json['rapport'] as Map<String, dynamic>?;
    return LigneAnalyseLabo(
      id: json['id'] as String,
      echantillonId: json['echantillon_id'] as String,
      numero: (json['numero'] ?? '').toString(),
      referenceBouteille: (json['echantillon_ref'] ?? '').toString(),
      echantillonNom: json['echantillon_nom'] as String,
      technicienNom: json['technicien_nom'] as String,
      statut: json['statut'] == 'soumise'
          ? StatutAnalyse.soumise
          : StatutAnalyse.enAttente,
      fournisseurNom: json['fournisseur_nom'] as String?,
      gouvernorat: json['gouvernorat'] as String?,
      delegation: json['delegation'] as String?,
      collecteurNom: json['collecteur_nom'] as String?,
      variete: json['variete'] as String?,
      quantiteEstimee: json['quantite_estimee'] as String?,
      dateEnregistrement: json['date_enregistrement'] as String?,
      dateReceptionPhysique: json['date_reception_physique'] as String?,
      rapport: rapportJson == null ? null : RapportLabo.fromJson(rapportJson),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'echantillon_id': echantillonId,
    'numero': numero,
    'echantillon_ref': referenceBouteille,
    'echantillon_nom': echantillonNom,
    'technicien_nom': technicienNom,
    'statut': statut == StatutAnalyse.soumise ? 'soumise' : 'en_attente',
    'fournisseur_nom': fournisseurNom,
    'gouvernorat': gouvernorat,
    'delegation': delegation,
    'collecteur_nom': collecteurNom,
    'variete': variete,
    'quantite_estimee': quantiteEstimee,
    'date_enregistrement': dateEnregistrement,
    'date_reception_physique': dateReceptionPhysique,
    'rapport': rapport?.toJson(),
  };
}
