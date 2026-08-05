// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/modification_champ.dart
// PURPOSE : One recorded change to a sample field — the unit of the edit trail.
//
//           Business rule: once a sample is `recuPhysiquement`, only the taster
//           and the head taster may edit it, and every edit must keep the
//           previous value. All roles see the old and the new value.
//
//           Changes are kept as a LIST and never overwritten. Storing only the
//           latest "previous value" would make the third edit erase the trace of
//           the first — the rule only holds if the whole chain is preserved.
// ═════════════════════════════════════════════════════════════════════════════

class ModificationChamp {
  /// Assigned by the backend. Null while the entry only exists on the device.
  final String? id;

  /// Machine name of the field that changed, e.g. `quantite`.
  final String champ;

  /// What the reader sees, e.g. `Quantité`. Kept alongside the machine name so
  /// the trail stays readable even if a field is later renamed in the code.
  final String libelleChamp;

  /// Values as they were displayed. Null means the field was empty.
  final String? ancienneValeur;
  final String? nouvelleValeur;

  /// ISO 8601.
  final String dateModification;

  final String? auteurNom;
  final String? auteurRole;

  const ModificationChamp({
    this.id,
    required this.champ,
    required this.libelleChamp,
    required this.ancienneValeur,
    required this.nouvelleValeur,
    required this.dateModification,
    this.auteurNom,
    this.auteurRole,
  });

  /// Records a change, stamped now. Returns null when nothing actually changed —
  /// so a form saved without edits does not pollute the trail with empty entries.
  static ModificationChamp? enregistrer({
    required String champ,
    required String libelleChamp,
    required String? avant,
    required String? apres,
    String? auteurNom,
    String? auteurRole,
  }) {
    final a = (avant ?? '').trim();
    final b = (apres ?? '').trim();
    if (a == b) return null;
    return ModificationChamp(
      champ: champ,
      libelleChamp: libelleChamp,
      ancienneValeur: a.isEmpty ? null : a,
      nouvelleValeur: b.isEmpty ? null : b,
      dateModification: DateTime.now().toIso8601String(),
      auteurNom: auteurNom,
      auteurRole: auteurRole,
    );
  }

  factory ModificationChamp.fromJson(Map<String, dynamic> json) =>
      ModificationChamp(
        id: json['id'] as String?,
        champ: json['champ'] as String,
        libelleChamp: json['libelle_champ'] as String? ?? json['champ'] as String,
        ancienneValeur: json['ancienne_valeur'] as String?,
        nouvelleValeur: json['nouvelle_valeur'] as String?,
        dateModification: json['date_modification'] as String,
        auteurNom: json['auteur_nom'] as String?,
        auteurRole: json['auteur_role'] as String?,
      );

  static List<ModificationChamp> listFromJson(List<dynamic>? raw) =>
      (raw ?? const [])
          .map((e) => ModificationChamp.fromJson(e as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'champ': champ,
        'libelle_champ': libelleChamp,
        'ancienne_valeur': ancienneValeur,
        'nouvelle_valeur': nouvelleValeur,
        'date_modification': dateModification,
        'auteur_nom': auteurNom,
        'auteur_role': auteurRole,
      };

  /// `40 T` — an empty previous value reads as "(vide)" rather than blank, so a
  /// field that was filled in for the first time is not mistaken for a display bug.
  String get ancienneValeurAffichee => ancienneValeur ?? '(vide)';
  String get nouvelleValeurAffichee => nouvelleValeur ?? '(vide)';

  /// `15/03/2026` — the trail is read, not computed on; day precision is enough
  /// to answer "when did this change".
  String get dateAffichee {
    final d = DateTime.tryParse(dateModification);
    if (d == null) return dateModification;
    final jj = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$jj/$mm/${d.year}';
  }
}
