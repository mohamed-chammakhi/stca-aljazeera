// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/echantillons/models/echantillon_ceo.dart
// PURPOSE : Full sample model visible to the CEO — all fields from all actors
// ─────────────────────────────────────────────────────────────────────────────

import '../../widgets/statut_echantillon_badge.dart';

enum RefusMotif { panelRefus, accordNonAtteint }

class EchantillonCeo {
  final String id;
  final String ref;
  final String gouvernorat;
  final String? delegation;
  final String codeFournisseur;
  final String referenceBouteille;
  final String? scellage;
  final String? variete;
  final String? quantiteEstimee;
  final String? camion;
  final String? remarques;
  final String dateAjout;
  final String? imageUrl;

  // Collector info
  final String collecteurId;
  final String collecteurNom;

  // Status
  StatutEchantillonCeo statut;

  // Refusal
  final RefusMotif? refusMotif;
  final String? refusCommentaire;

  // CEO approval comment
  final String? commentaireCeo;
  final String? budgetNegociation;

  // Delivery
  final String? livraisonDate;
  final String? livraisonHeure;
  final String? livraisonLieu;

  EchantillonCeo({
    required this.id,
    required this.ref,
    required this.gouvernorat,
    this.delegation,
    required this.codeFournisseur,
    required this.referenceBouteille,
    this.scellage,
    this.variete,
    this.quantiteEstimee,
    this.camion,
    this.remarques,
    required this.dateAjout,
    this.imageUrl,
    required this.collecteurId,
    required this.collecteurNom,
    required this.statut,
    this.refusMotif,
    this.refusCommentaire,
    this.commentaireCeo,
    this.budgetNegociation,
    this.livraisonDate,
    this.livraisonHeure,
    this.livraisonLieu,
  });

  bool get hasLivraison =>
      livraisonDate != null && livraisonHeure != null && livraisonLieu != null;
}
