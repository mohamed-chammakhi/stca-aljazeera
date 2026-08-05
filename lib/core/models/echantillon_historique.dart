// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/echantillon_historique.dart
// PURPOSE : Records what changed on a sample once it is physically received.
//
//           Business rule: after `recuPhysiquement`, only the taster and the
//           head taster may edit a sample, and every edit keeps the previous
//           value so all roles see both.
//
//           Used by the taster's and the head taster's edit forms. One file,
//           not one per module: the rule is identical on both sides, so a fix
//           here reaches both screens.
// ═════════════════════════════════════════════════════════════════════════════

import 'echantillon.dart';
import 'modification_champ.dart';

/// Fields the two forms let you edit, with the label the reader sees.
/// A field absent from this map is simply not tracked.
const Map<String, String> _libelles = {
  'reference_bouteille': 'Référence bouteille',
  'variete': 'Variété',
  'num_citerne': 'N° citerne',
  'quantite_estimee': 'Quantité estimée',
  'gouvernorat': 'Gouvernorat',
  'delegation': 'Délégation',
  'remarques': 'Remarques',
};

extension EchantillonHistorique on Echantillon {
  /// Values as they stand right now. Call this **before** the form writes its
  /// changes, then pass the result to [enregistrerModifications].
  Map<String, String?> capturerAvantModification() => {
    'reference_bouteille': referenceBouteille,
    'variete': variete,
    'num_citerne': numCiterne,
    'quantite_estimee': quantiteEstimee,
    'gouvernorat': gouvernorat,
    'delegation': delegation,
    'remarques': remarques,
  };

  /// Compares [avant] with the current values and appends one entry per field
  /// that actually changed.
  ///
  /// Does nothing when the sample is not yet physically received: before that
  /// point the collector still owns the sample and edits are ordinary
  /// corrections, not a trail to keep.
  void enregistrerModifications(
    Map<String, String?> avant, {
    String? auteurNom,
    String? auteurRole,
  }) {
    if (!recuPhysiquement) return;

    final apres = capturerAvantModification();
    final nouvelles = <ModificationChamp>[];

    for (final champ in _libelles.keys) {
      final entree = ModificationChamp.enregistrer(
        champ: champ,
        libelleChamp: _libelles[champ]!,
        avant: avant[champ],
        apres: apres[champ],
        auteurNom: auteurNom,
        auteurRole: auteurRole,
      );
      if (entree != null) nouvelles.add(entree);
    }

    if (nouvelles.isEmpty) return;

    // Rebuilt rather than mutated: `historique` defaults to a const empty list,
    // which cannot be appended to.
    historique = [...historique, ...nouvelles];
  }
}
