class Message {
  final String id;
  final String expediteur;
  final String destinataire;
  final String expediteurNom;
  final String destinataireNom;
  final String contenu;
  bool lu;
  String? luLe;
  final String dateEnvoi;

  Message({
    required this.id,
    required this.expediteur,
    required this.destinataire,
    required this.expediteurNom,
    required this.destinataireNom,
    required this.contenu,
    this.lu = false,
    this.luLe,
    required this.dateEnvoi,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as String,
    expediteur: json['expediteur'] as String,
    destinataire: json['destinataire'] as String,
    expediteurNom: (json['expediteur_nom'] as String?) ?? '',
    destinataireNom: (json['destinataire_nom'] as String?) ?? '',
    contenu: json['contenu'] as String,
    lu: (json['lu'] as bool?) ?? (json['is_read'] as bool?) ?? false,
    luLe: json['lu_le'] as String?,
    dateEnvoi:
        (json['date_envoi'] as String?) ??
        (json['horodatage'] as String?) ??
        '',
  );

  static List<Message> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> toJson() => toCreateJson();

  Map<String, dynamic> toCreateJson() => {
    'destinataire': destinataire,
    'contenu': contenu,
  };
}
