// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/services/fournisseur_service.dart
// PURPOSE : The supplier reference list — read, create, and suggest names.
//
//           Why suppliers are an entity and not free text: the CEO dashboard
//           aggregates purchases per supplier. If the same supplier is typed
//           "Ben Ali", "ben ali" and "BenAli", the dashboard counts three
//           suppliers instead of one and every figure on that card is wrong.
//
//           The collector still types freely. The ID is internal plumbing; no
//           field is ever a closed dropdown here.
// ═════════════════════════════════════════════════════════════════════════════

import '../api_client.dart';
import '../models/fournisseur.dart';
import 'resultat_service.dart';

class FournisseurService {
  FournisseurService._();
  static final FournisseurService instance = FournisseurService._();

  bool _usingMockData = false;
  bool get usingMockData => _usingMockData;

  /// Cached so typing in the form does not fire a request per keystroke.
  Resultat<List<Fournisseur>>? _cache;

  Future<Resultat<List<Fournisseur>>> fetchAll({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache != null) return _cache!;
    _cache = await avecSecours(
      () async {
        final items = await apiClient.getList('/api/fournisseurs/');
        _usingMockData = false;
        return items
            .map((e) => Fournisseur.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      () {
        _usingMockData = true;
        return _mockFournisseurs();
      },
    );
    return _cache!;
  }

  /// Suggestions for what the user has typed so far, best match first.
  ///
  /// An empty query returns the first known suppliers so the user can pick
  /// from existing values as soon as the field opens.
  Future<Resultat<List<Fournisseur>>> suggest(
    String saisie, {
    int limite = 6,
  }) async {
    final q = _normaliser(saisie);
    final resultat = await fetchAll();
    if (q.isEmpty) {
      return Resultat(
        resultat.donnees.take(limite).toList(),
        estDemonstration: resultat.estDemonstration,
        messageErreur: resultat.messageErreur,
      );
    }

    final debut = <Fournisseur>[];
    final ailleurs = <Fournisseur>[];
    for (final f in resultat.donnees) {
      final n = _normaliser(f.nom);
      if (n == q) continue; // already typed in full - nothing to suggest
      if (n.startsWith(q)) {
        debut.add(f);
      } else if (n.contains(q)) {
        ailleurs.add(f);
      }
    }
    // A supplier whose name starts with what was typed is what the user meant.
    return Resultat(
      [...debut, ...ailleurs].take(limite).toList(),
      estDemonstration: resultat.estDemonstration,
      messageErreur: resultat.messageErreur,
    );
  }

  Future<Fournisseur> create({
    required String nom,
    String? region,
    String? telephone,
  }) async {
    final body = {
      'nom': nom.trim(),
      'code_fournisseur': _codeDepuisNom(nom),
      'region': region ?? '',
      'telephone': telephone ?? '',
    };
    final json = await apiClient.post('/api/fournisseurs/', body);
    final cree = Fournisseur.fromJson(json);
    _cache = Resultat([...?_cache?.donnees, cree]);
    return cree;
  }

  // ── Text matching ───────────────────────────────────────────────────────────

  /// Lowercase, unaccented, letters and digits only.
  ///
  /// This is what makes "Ben Ali", "ben-ali" and "BENALI" compare equal — which
  /// is exactly the duplication the dashboard suffers from.
  static String _normaliser(String s) {
    var t = s.toLowerCase().trim();
    const accents = 'àâäáãåçèéêëìíîïñòóôöõùúûüýÿ';
    const plats = 'aaaaaaceeeeiiiinooooouuuuyy';
    final buffer = StringBuffer();
    for (final ch in t.split('')) {
      final i = accents.indexOf(ch);
      final c = i == -1 ? ch : plats[i];
      if (RegExp(r'[a-z0-9]').hasMatch(c)) buffer.write(c);
    }
    return buffer.toString();
  }

  /// "Agricole Ben Ali" → "AGR-BEN". Only a fallback: the backend rejects an
  /// empty code, and the collector has no reason to invent one on the road.
  static String _codeDepuisNom(String nom) {
    final mots = nom
        .trim()
        .split(RegExp(r'\s+'))
        .where((m) => m.isNotEmpty)
        .toList();
    if (mots.isEmpty) return 'FRN';
    final tete = mots.first.toUpperCase();
    final code = mots.length == 1
        ? tete
        : '${tete.substring(0, tete.length < 3 ? tete.length : 3)}-'
              '${mots[1].toUpperCase()}';
    return code.length <= 20 ? code : code.substring(0, 20);
  }

  /// Used when the API is unreachable — the collector is often on the road.
  List<Fournisseur> _mockFournisseurs() => [
    Fournisseur(
      id: 'mock-frn-1',
      codeFournisseur: 'AGR-BEN',
      nom: 'Agricole Ben Ali',
      region: 'Sfax',
    ),
    Fournisseur(
      id: 'mock-frn-2',
      codeFournisseur: 'HUI-SUD',
      nom: 'Huilerie du Sud',
      region: 'Médenine',
    ),
    Fournisseur(
      id: 'mock-frn-3',
      codeFournisseur: 'DOM-OLI',
      nom: 'Domaine Olivia',
      region: 'Sousse',
    ),
    Fournisseur(
      id: 'mock-frn-4',
      codeFournisseur: 'COOP-MAH',
      nom: 'Coopérative de Mahdia',
      region: 'Mahdia',
    ),
  ];

  /// Test seam and cache reset after a create elsewhere.
  void invalidateCache() => _cache = null;
}
