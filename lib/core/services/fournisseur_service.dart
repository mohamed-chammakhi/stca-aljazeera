// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/services/fournisseur_service.dart
// PURPOSE : The supplier reference list — read, create, and catch near-duplicates.
//
//           Why suppliers are an entity and not free text: the CEO dashboard
//           aggregates purchases per supplier. If the same supplier is typed
//           "Ben Ali", "ben ali" and "BenAli", the dashboard counts three
//           suppliers instead of one and every figure on that card is wrong.
//
//           The collector still types freely — see findNearDuplicates. The ID is
//           internal plumbing; no field is ever a closed dropdown here.
// ═════════════════════════════════════════════════════════════════════════════

import '../api_client.dart';
import '../models/fournisseur.dart';

class FournisseurService {
  FournisseurService._();
  static final FournisseurService instance = FournisseurService._();

  bool _usingMockData = false;
  bool get usingMockData => _usingMockData;

  /// Cached so typing in the form does not fire a request per keystroke.
  List<Fournisseur>? _cache;

  Future<List<Fournisseur>> fetchAll({bool forceRefresh = false}) async {
    if (!forceRefresh && _cache != null) return _cache!;
    try {
      final items = await apiClient.getList('/api/fournisseurs/');
      _usingMockData = false;
      _cache = items
          .map((e) => Fournisseur.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _usingMockData = true;
      _cache = _mockFournisseurs();
    }
    return _cache!;
  }

  /// Suggestions for what the user has typed so far, best match first.
  ///
  /// An empty query returns nothing rather than the whole list: a suggestion
  /// panel that opens before the user types anything is in the way, not helpful.
  Future<List<Fournisseur>> suggest(String saisie, {int limite = 6}) async {
    final q = _normaliser(saisie);
    if (q.isEmpty) return const [];
    final tous = await fetchAll();

    final debut = <Fournisseur>[];
    final ailleurs = <Fournisseur>[];
    for (final f in tous) {
      final n = _normaliser(f.nom);
      if (n.startsWith(q)) {
        debut.add(f);
      } else if (n.contains(q)) {
        ailleurs.add(f);
      }
    }
    // A supplier whose name starts with what was typed is what the user meant.
    return [...debut, ...ailleurs].take(limite).toList();
  }

  /// Suppliers close enough to [nom] that creating a new one is probably a typo.
  ///
  /// Called just before creating, so the collector can be asked
  /// "Agricole Ben Ali already exists — is that the one?" instead of silently
  /// producing a second record for the same company.
  Future<List<Fournisseur>> findNearDuplicates(String nom) async {
    final cible = _normaliser(nom);
    if (cible.isEmpty) return const [];
    final tous = await fetchAll();

    return tous.where((f) {
      final n = _normaliser(f.nom);
      if (n == cible) return true;
      // "Ben Ali" vs "Agricole Ben Ali" — same company, longer label.
      if (n.contains(cible) || cible.contains(n)) return true;
      // Two typos apart at most; the threshold grows with the name length so
      // short names are not matched to everything.
      final seuil = cible.length <= 6 ? 1 : 2;
      return _distance(n, cible) <= seuil;
    }).toList();
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
    _cache = [...?_cache, cree];
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

  /// Levenshtein distance — how many single-character edits separate two strings.
  static int _distance(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    var precedente = List<int>.generate(b.length + 1, (i) => i);
    var courante = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      courante[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cout = a[i] == b[j] ? 0 : 1;
        courante[j + 1] = [
          courante[j] + 1, // insertion
          precedente[j + 1] + 1, // suppression
          precedente[j] + cout, // substitution
        ].reduce((x, y) => x < y ? x : y);
      }
      final tmp = precedente;
      precedente = courante;
      courante = tmp;
    }
    return precedente[b.length];
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
