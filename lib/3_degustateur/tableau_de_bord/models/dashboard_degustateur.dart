// lib/3_degustateur/tableau_de_bord/models/dashboard_degustateur.dart

class EvaluationUrgente {
  final String id;
  final String reference;
  final String collecteurNom;
  final String fournisseurNom;
  final int
  joursEnAttente; // DateTime.now().difference(dateReceptionEchantillon).inDays

  const EvaluationUrgente({
    required this.id,
    required this.reference,
    required this.collecteurNom,
    required this.fournisseurNom,
    required this.joursEnAttente,
  });

  factory EvaluationUrgente.fromJson(Map<String, dynamic> json) =>
      EvaluationUrgente(
        id: json['id'] as String,
        reference: json['reference'] as String,
        collecteurNom: json['collecteur_nom'] as String,
        fournisseurNom: json['fournisseur_nom'] as String,
        joursEnAttente: json['jours_en_attente'] as int,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'collecteur_nom': collecteurNom,
    'fournisseur_nom': fournisseurNom,
    'jours_en_attente': joursEnAttente,
  };
}

// CEO-flagged urgent evaluation (requires priority attention)
class EvaluationUrgenteCeo {
  final String id;
  final String reference;
  final String collecteurNom;
  final String fournisseurNom;

  const EvaluationUrgenteCeo({
    required this.id,
    required this.reference,
    required this.collecteurNom,
    required this.fournisseurNom,
  });

  factory EvaluationUrgenteCeo.fromJson(Map<String, dynamic> json) =>
      EvaluationUrgenteCeo(
        id: json['id'] as String,
        reference: json['reference'] as String,
        collecteurNom: json['collecteur_nom'] as String,
        fournisseurNom: json['fournisseur_nom'] as String,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'reference': reference,
    'collecteur_nom': collecteurNom,
    'fournisseur_nom': fournisseurNom,
  };
}

class PipelineData {
  final int receptionne;
  final int nonEvaluee;
  final int enCours;
  final int soumise;
  const PipelineData({
    required this.receptionne,
    required this.nonEvaluee,
    required this.enCours,
    required this.soumise,
  });

  factory PipelineData.fromJson(Map<String, dynamic> json) => PipelineData(
    receptionne: json['receptionne'] as int,
    nonEvaluee: json['non_evaluee'] as int,
    enCours: json['en_cours'] as int,
    soumise: json['soumise'] as int,
  );

  Map<String, dynamic> toJson() => {
    'receptionne': receptionne,
    'non_evaluee': nonEvaluee,
    'en_cours': enCours,
    'soumise': soumise,
  };
}

class ClassificationPoint {
  final String label;
  final int extraVierge;
  final int vierge;
  final int lampante;
  const ClassificationPoint({
    required this.label,
    required this.extraVierge,
    required this.vierge,
    required this.lampante,
  });

  factory ClassificationPoint.fromJson(Map<String, dynamic> json) =>
      ClassificationPoint(
        label: json['label'] as String,
        extraVierge: json['extra_vierge'] as int,
        vierge: json['vierge'] as int,
        lampante: json['lampante'] as int,
      );

  Map<String, dynamic> toJson() => {
    'label': label,
    'extra_vierge': extraVierge,
    'vierge': vierge,
    'lampante': lampante,
  };
}

class PresenceData {
  final int present;
  final int manquee;
  final String? prochaineTitre;
  final String? prochaineDate;
  final String? prochaineLieu;
  final String? prochaineCountdown;
  const PresenceData({
    required this.present,
    required this.manquee,
    this.prochaineTitre,
    this.prochaineDate,
    this.prochaineLieu,
    this.prochaineCountdown,
  });

  int get total => present + manquee;
  double get taux => total == 0 ? 0 : present / total;

  factory PresenceData.fromJson(Map<String, dynamic> json) => PresenceData(
    present: json['present'] as int,
    manquee: json['manquee'] as int,
    prochaineTitre: json['prochaine_titre'] as String?,
    prochaineDate: json['prochaine_date'] as String?,
    prochaineLieu: json['prochaine_lieu'] as String?,
    prochaineCountdown: json['prochaine_countdown'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'present': present,
    'manquee': manquee,
    'prochaine_titre': prochaineTitre,
    'prochaine_date': prochaineDate,
    'prochaine_lieu': prochaineLieu,
    'prochaine_countdown': prochaineCountdown,
  };
}

class DelaiPoint {
  final DateTime date;
  final double monDelai;
  final double panelMoyen;
  const DelaiPoint({
    required this.date,
    required this.monDelai,
    required this.panelMoyen,
  });

  factory DelaiPoint.fromJson(Map<String, dynamic> json) => DelaiPoint(
    date: DateTime.parse(json['date'] as String),
    monDelai: (json['mon_delai'] as num).toDouble(),
    panelMoyen: (json['panel_moyen'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'mon_delai': monDelai,
    'panel_moyen': panelMoyen,
  };
}

class DelaiSummary {
  final double monDelaiMoyen;
  final double panelMoyen;
  final int nbEvals;
  final List<DelaiPoint> points;
  const DelaiSummary({
    required this.monDelaiMoyen,
    required this.panelMoyen,
    required this.nbEvals,
    required this.points,
  });

  factory DelaiSummary.fromJson(Map<String, dynamic> json) => DelaiSummary(
    monDelaiMoyen: (json['mon_delai_moyen'] as num).toDouble(),
    panelMoyen: (json['panel_moyen'] as num).toDouble(),
    nbEvals: json['nb_evals'] as int,
    points: (json['points'] as List)
        .map((e) => DelaiPoint.fromJson({
          ...e as Map<String, dynamic>,
          'mon_delai': e['mon_delai'] ?? e['delai'],
          'panel_moyen': e['panel_moyen'] ?? json['panel_moyen'],
        }))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'mon_delai_moyen': monDelaiMoyen,
    'panel_moyen': panelMoyen,
    'nb_evals': nbEvals,
    'points': points.map((p) => p.toJson()).toList(),
  };
}

class ActiviteItem {
  final String id;
  final String action;
  final String horodatage;
  final String
  type; // "evaluation" | "seance_presente" | "seance_manquee" | "profil"
  const ActiviteItem({
    required this.id,
    required this.action,
    required this.horodatage,
    required this.type,
  });

  factory ActiviteItem.fromJson(Map<String, dynamic> json) => ActiviteItem(
    id: json['id'] as String? ?? '${json['type']}-${json['date']}',
    action: json['action'] as String? ?? json['description'] as String,
    horodatage: json['horodatage'] as String? ?? json['date'] as String,
    type: json['type'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'horodatage': horodatage,
    'type': type,
  };
}
