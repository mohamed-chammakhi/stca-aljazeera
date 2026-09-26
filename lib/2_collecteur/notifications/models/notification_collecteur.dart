import 'package:project3/core/utils/json_utils.dart';

class NotificationCollecteur {
  final String id;
  final String type;
  final String titre;
  final String message;
  final String? echantillonId;
  final String? echantillonReference;
  final String section; // MES_ECHANTILLONS
  final bool isRead;
  final DateTime dateCreation;

  // Negotiation payload — present only for ECHANTILLON_APPROUVE
  final double? budgetNegociation;
  final DateTime? dateLivraisonStockSouhaitee;

  const NotificationCollecteur({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    this.echantillonId,
    this.echantillonReference,
    required this.section,
    required this.isRead,
    required this.dateCreation,
    this.budgetNegociation,
    this.dateLivraisonStockSouhaitee,
  });

  factory NotificationCollecteur.fromJson(Map<String, dynamic> json) =>
      NotificationCollecteur(
        id: json['id'] as String,
        type: json['type'] as String,
        titre: json['titre'] as String,
        message: json['message'] as String,
        echantillonId: json['echantillon'] as String?,
        echantillonReference: json['echantillon_reference'] as String?,
        section: json['section'] as String,
        isRead: json['is_read'] as bool,
        dateCreation: DateTime.parse(json['date_creation'] as String),
        budgetNegociation: nombreDepuisJson(json['budget_negociation']),
        dateLivraisonStockSouhaitee:
            json['date_livraison_stock_souhaitee'] == null
            ? null
            : DateTime.parse(json['date_livraison_stock_souhaitee'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'titre': titre,
    'message': message,
    'echantillon': echantillonId,
    'echantillon_reference': echantillonReference,
    'section': section,
    'is_read': isRead,
    'date_creation': dateCreation.toIso8601String(),
    'budget_negociation': budgetNegociation,
    'date_livraison_stock_souhaitee': dateLivraisonStockSouhaitee
        ?.toIso8601String(),
  };

  NotificationCollecteur copyWith({bool? isRead}) => NotificationCollecteur(
    id: id,
    type: type,
    titre: titre,
    message: message,
    echantillonId: echantillonId,
    echantillonReference: echantillonReference,
    section: section,
    isRead: isRead ?? this.isRead,
    dateCreation: dateCreation,
    budgetNegociation: budgetNegociation,
    dateLivraisonStockSouhaitee: dateLivraisonStockSouhaitee,
  );
}
