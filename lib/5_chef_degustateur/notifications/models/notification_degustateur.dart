class NotificationDegustateur {
  final String id;
  final String type;
  final String titre;
  final String message;
  final String? echantillonId;
  final String? echantillonReference;
  final String section; // ECHANTILLONS | EVALUATIONS | ANALYSES
  final bool isRead;
  final DateTime dateCreation;

  const NotificationDegustateur({
    required this.id,
    required this.type,
    required this.titre,
    required this.message,
    this.echantillonId,
    this.echantillonReference,
    required this.section,
    required this.isRead,
    required this.dateCreation,
  });

  // Types exclusive to the panel chief (super taster)
  static bool isSuperTasterOnly(String type) =>
      type == 'EVALUATION_SOUMISE' || type == 'TOUTES_EVALUATIONS';

  factory NotificationDegustateur.fromJson(Map<String, dynamic> json) =>
      NotificationDegustateur(
        id: json['id'] as String,
        type: json['type'] as String,
        titre: json['titre'] as String,
        message: json['message'] as String,
        echantillonId: json['echantillon'] as String?,
        echantillonReference: json['echantillon_reference'] as String?,
        section: json['section'] as String,
        isRead: json['is_read'] as bool,
        dateCreation: DateTime.parse(json['date_creation'] as String),
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
      };

  NotificationDegustateur copyWith({bool? isRead}) => NotificationDegustateur(
        id: id,
        type: type,
        titre: titre,
        message: message,
        echantillonId: echantillonId,
        echantillonReference: echantillonReference,
        section: section,
        isRead: isRead ?? this.isRead,
        dateCreation: dateCreation,
      );
}
