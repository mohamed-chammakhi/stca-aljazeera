// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/services/variete_service.dart
// PURPOSE : The varieties already used, for suggesting as the user types.
//
//           Unlike the supplier, the variety is NOT an entity and never will be
//           a closed dropdown: the collector writes it himself. Suggestions only
//           save keystrokes and keep spellings from drifting.
//
//           Why it is safe to leave free: the variety appears nowhere in
//           lib/1_ceo/tableau_de_bord/, so it enters no dashboard calculation.
//           It is used for display, filtering and search. If that ever changes,
//           this decision has to be reopened.
// ═════════════════════════════════════════════════════════════════════════════

import '../api_client.dart';
import 'resultat_service.dart';

class VarieteService {
  VarieteService._();
  static final VarieteService instance = VarieteService._();

  Resultat<List<String>>? _cache;

  /// Distinct varieties found on existing samples, alphabetical.
  Future<Resultat<List<String>>> fetchAll({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    _cache = await avecSecours(() async {
      final items = await apiClient.getList('/api/echantillons/');
      final vues = <String, String>{};
      for (final item in items) {
        final v = (item as Map<String, dynamic>)['variete'] as String?;
        if (v == null || v.trim().isEmpty) continue;
        vues.putIfAbsent(v.trim().toLowerCase(), () => v.trim());
      }
      final liste = vues.values.toList()..sort();
      return liste.isEmpty ? _varietesConnues : liste;
    }, () => _varietesConnues);
    return _cache!;
  }

  /// Suggestions for what has been typed so far, best match first.
  Future<Resultat<List<String>>> suggest(
    String saisie, {
    int limite = 6,
  }) async {
    final q = saisie.trim().toLowerCase();
    if (q.isEmpty) return const Resultat([]);
    final resultat = await fetchAll();

    final debut = <String>[];
    final ailleurs = <String>[];
    for (final v in resultat.donnees) {
      final n = v.toLowerCase();
      if (n == q) continue; // already typed in full — nothing to suggest
      if (n.startsWith(q)) {
        debut.add(v);
      } else if (n.contains(q)) {
        ailleurs.add(v);
      }
    }
    return Resultat(
      [...debut, ...ailleurs].take(limite).toList(),
      estDemonstration: resultat.estDemonstration,
      messageErreur: resultat.messageErreur,
    );
  }

  /// The main Tunisian olive varieties — a starting point, not a closed list.
  static const List<String> _varietesConnues = [
    'Chemlali',
    'Chetoui',
    'Gerboui',
    'Oueslati',
    'Sahli',
    'Zalmati',
    'Zarrazi',
  ];

  void invalidateCache() => _cache = null;
}
