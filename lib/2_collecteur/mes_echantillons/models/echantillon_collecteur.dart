// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/models/echantillon_collecteur.dart
// ═════════════════════════════════════════════════════════════════════════════

import '../widgets/dialogs/formulaire/planification_arrivage.dart';
import '../widgets/dialogs/formulaire/planification_livraison.dart';

enum StatutCollecteur { receptionne, enNegociation, achatConfirme }

class EchantillonCollecteur {
  String id;
  String ref;

  // Location
  String gouvernorat;
  String? delegation;
  String? cite;

  // Supplier
  String codeFournisseur;

  // Bottle
  String referenceBouteille;
  String? scellage;
  String? quantiteEstimee;
  String? variete;

  // Purchase
  bool achatConfirme;
  PlanificationLivraison? livraison;

  // Metadata
  String? remarques;
  String dateAjout;
  PlanificationArrivage? planificationArrivage;

  String? imageUrl;
  String collecteurId;
  String collecteurNom;

  // Status
  StatutCollecteur statut;

  EchantillonCollecteur({
    required this.id,
    required this.ref,
    required this.gouvernorat,
    this.delegation,
    this.cite,
    required this.codeFournisseur,
    required this.referenceBouteille,
    this.scellage,
    this.quantiteEstimee,
    this.variete,
    required this.achatConfirme,
    this.livraison,
    this.remarques,
    required this.dateAjout,
    this.planificationArrivage,
    this.imageUrl,
    required this.collecteurId,
    required this.collecteurNom,
    required this.statut,
  });

  bool get canModify => statut == StatutCollecteur.receptionne;
  bool get canDelete => statut == StatutCollecteur.receptionne;
  bool get canConfirm => statut == StatutCollecteur.enNegociation;
  bool get canPlanifier => statut == StatutCollecteur.achatConfirme;
}
