// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/enums.dart
// PURPOSE : All shared enums used across roles.
//           JSON string values match the Django backend conventions (snake_case).
// ═════════════════════════════════════════════════════════════════════════════

// ── User roles ────────────────────────────────────────────────────────────────
enum RoleUtilisateur { direction, collecteur, degustateur, laboratoire }

extension RoleUtilisateurX on RoleUtilisateur {
  String get toJson {
    switch (this) {
      case RoleUtilisateur.direction:    return 'direction';
      case RoleUtilisateur.collecteur:   return 'collecteur';
      case RoleUtilisateur.degustateur:  return 'degustateur';
      case RoleUtilisateur.laboratoire:  return 'laboratoire';
    }
  }

  String get label {
    switch (this) {
      case RoleUtilisateur.direction:    return 'Direction';
      case RoleUtilisateur.collecteur:   return 'Collecteur';
      case RoleUtilisateur.degustateur:  return 'Dégustateur';
      case RoleUtilisateur.laboratoire:  return 'Technicien Labo';
    }
  }

  static RoleUtilisateur fromJson(String s) {
    switch (s) {
      case 'direction':    return RoleUtilisateur.direction;
      case 'collecteur':   return RoleUtilisateur.collecteur;
      case 'degustateur':  return RoleUtilisateur.degustateur;
      case 'laboratoire':  return RoleUtilisateur.laboratoire;
      default: throw ArgumentError('Unknown role: $s');
    }
  }
}

// ── Sample statuses — one per actor view ─────────────────────────────────────

/// Collector-facing sample status (statut_collecteur on echantillons table).
enum StatutCollecteur { receptionne, enNegociation, achatConfirme }

extension StatutCollecteurX on StatutCollecteur {
  String get toJson {
    switch (this) {
      case StatutCollecteur.receptionne:    return 'receptionne';
      case StatutCollecteur.enNegociation:  return 'en_negociation';
      case StatutCollecteur.achatConfirme:  return 'achat_confirme';
    }
  }

  String get label {
    switch (this) {
      case StatutCollecteur.receptionne:    return 'Réceptionné';
      case StatutCollecteur.enNegociation:  return 'En négociation';
      case StatutCollecteur.achatConfirme:  return 'Achat confirmé';
    }
  }

  static StatutCollecteur fromJson(String s) {
    switch (s) {
      case 'receptionne':    return StatutCollecteur.receptionne;
      case 'en_negociation': return StatutCollecteur.enNegociation;
      case 'achat_confirme': return StatutCollecteur.achatConfirme;
      default: throw ArgumentError('Unknown statut_collecteur: $s');
    }
  }
}

/// Taster-facing sample status (statut_degustateur on echantillons table).
enum StatutDegustateur { enAttente, enCours, soumis }

extension StatutDegustateurX on StatutDegustateur {
  String get toJson {
    switch (this) {
      case StatutDegustateur.enAttente: return 'en_attente';
      case StatutDegustateur.enCours:   return 'en_cours';
      case StatutDegustateur.soumis:    return 'soumis';
    }
  }

  String get label {
    switch (this) {
      case StatutDegustateur.enAttente: return 'En attente';
      case StatutDegustateur.enCours:   return 'En cours';
      case StatutDegustateur.soumis:    return 'Soumis';
    }
  }

  static StatutDegustateur fromJson(String s) {
    switch (s) {
      case 'en_attente': return StatutDegustateur.enAttente;
      case 'en_cours':   return StatutDegustateur.enCours;
      case 'soumis':     return StatutDegustateur.soumis;
      default: throw ArgumentError('Unknown statut_degustateur: $s');
    }
  }
}

/// Lab-facing sample status (statut_labo on echantillons table AND statut on
/// analyses_labo table — same values, same enum).
enum StatutLabo { enAttente, enCours, soumis }

extension StatutLaboX on StatutLabo {
  String get toJson {
    switch (this) {
      case StatutLabo.enAttente: return 'en_attente';
      case StatutLabo.enCours:   return 'en_cours';
      case StatutLabo.soumis:    return 'soumis';
    }
  }

  String get label {
    switch (this) {
      case StatutLabo.enAttente: return 'En attente';
      case StatutLabo.enCours:   return 'En cours';
      case StatutLabo.soumis:    return 'Soumis';
    }
  }

  static StatutLabo fromJson(String s) {
    switch (s) {
      case 'en_attente': return StatutLabo.enAttente;
      case 'en_cours':   return StatutLabo.enCours;
      case 'soumis':     return StatutLabo.soumis;
      default: throw ArgumentError('Unknown statut_labo: $s');
    }
  }
}

/// CEO-facing sample status (statut_ceo on echantillons table).
enum StatutCeo { selectionne, enNegociation, achatConfirme, refuse }

extension StatutCeoX on StatutCeo {
  String get toJson {
    switch (this) {
      case StatutCeo.selectionne:    return 'selectionne';
      case StatutCeo.enNegociation:  return 'en_negociation';
      case StatutCeo.achatConfirme:  return 'achat_confirme';
      case StatutCeo.refuse:         return 'refuse';
    }
  }

  String get label {
    switch (this) {
      case StatutCeo.selectionne:    return 'Sélectionné';
      case StatutCeo.enNegociation:  return 'En négociation';
      case StatutCeo.achatConfirme:  return 'Achat confirmé';
      case StatutCeo.refuse:         return 'Refusé';
    }
  }

  static StatutCeo fromJson(String s) {
    switch (s) {
      case 'selectionne':    return StatutCeo.selectionne;
      case 'en_negociation': return StatutCeo.enNegociation;
      case 'achat_confirme': return StatutCeo.achatConfirme;
      case 'refuse':         return StatutCeo.refuse;
      default: throw ArgumentError('Unknown statut_ceo: $s');
    }
  }
}

// ── Oil classification (COI standard) ─────────────────────────────────────────
enum ClassificationHuile { extraVierge, vierge, viergeOrdinaire, lampante }

extension ClassificationHuileX on ClassificationHuile {
  String get toJson {
    switch (this) {
      case ClassificationHuile.extraVierge:     return 'extra_vierge';
      case ClassificationHuile.vierge:           return 'vierge';
      case ClassificationHuile.viergeOrdinaire:  return 'vierge_ordinaire';
      case ClassificationHuile.lampante:         return 'lampante';
    }
  }

  String get label {
    switch (this) {
      case ClassificationHuile.extraVierge:     return 'Extra Vierge';
      case ClassificationHuile.vierge:           return 'Vierge';
      case ClassificationHuile.viergeOrdinaire:  return 'Vierge Ordinaire';
      case ClassificationHuile.lampante:         return 'Lampante';
    }
  }

  /// Brand color for this classification tier.
  int get colorValue {
    switch (this) {
      case ClassificationHuile.extraVierge:     return 0xFF38835A;
      case ClassificationHuile.vierge:           return 0xFFF57C00;
      case ClassificationHuile.viergeOrdinaire:  return 0xFFE64A19;
      case ClassificationHuile.lampante:         return 0xFFD32F2F;
    }
  }

  static ClassificationHuile fromJson(String s) {
    switch (s) {
      case 'extra_vierge':     return ClassificationHuile.extraVierge;
      case 'vierge':           return ClassificationHuile.vierge;
      case 'vierge_ordinaire': return ClassificationHuile.viergeOrdinaire;
      case 'lampante':         return ClassificationHuile.lampante;
      default: throw ArgumentError('Unknown classification: $s');
    }
  }
}

// ── Planification mode (shared by arrivage + livraison) ──────────────────────
enum ModePlanification { dateExacte, periode }

extension ModePlanificationX on ModePlanification {
  String get toJson {
    switch (this) {
      case ModePlanification.dateExacte: return 'date_exacte';
      case ModePlanification.periode:    return 'periode';
    }
  }

  static ModePlanification fromJson(String s) {
    switch (s) {
      case 'date_exacte': return ModePlanification.dateExacte;
      case 'periode':     return ModePlanification.periode;
      default: throw ArgumentError('Unknown mode_planification: $s');
    }
  }
}

// ── Session status ────────────────────────────────────────────────────────────
enum StatutSession { planifiee, enCours, terminee }

extension StatutSessionX on StatutSession {
  String get toJson {
    switch (this) {
      case StatutSession.planifiee: return 'planifiee';
      case StatutSession.enCours:   return 'en_cours';
      case StatutSession.terminee:  return 'terminee';
    }
  }

  String get label {
    switch (this) {
      case StatutSession.planifiee: return 'Planifiée';
      case StatutSession.enCours:   return 'En cours';
      case StatutSession.terminee:  return 'Terminée';
    }
  }

  static StatutSession fromJson(String s) {
    switch (s) {
      case 'planifiee': return StatutSession.planifiee;
      case 'en_cours':  return StatutSession.enCours;
      case 'terminee':  return StatutSession.terminee;
      default: throw ArgumentError('Unknown statut_session: $s');
    }
  }
}

// ── Lab analysis priority ─────────────────────────────────────────────────────
enum PrioriteAnalyse { normale, urgente }

extension PrioriteAnalyseX on PrioriteAnalyse {
  String get toJson {
    switch (this) {
      case PrioriteAnalyse.normale:  return 'normale';
      case PrioriteAnalyse.urgente:  return 'urgente';
    }
  }

  String get label {
    switch (this) {
      case PrioriteAnalyse.normale:  return 'Normale';
      case PrioriteAnalyse.urgente:  return 'Urgente';
    }
  }

  static PrioriteAnalyse fromJson(String s) {
    switch (s) {
      case 'normale':  return PrioriteAnalyse.normale;
      case 'urgente':  return PrioriteAnalyse.urgente;
      default: throw ArgumentError('Unknown priorite_analyse: $s');
    }
  }
}
