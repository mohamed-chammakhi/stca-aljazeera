import '../api_client.dart';
import '../models/fournisseur.dart';
import 'resultat_service.dart';

class FournisseurService {
  FournisseurService._();
  static final FournisseurService instance = FournisseurService._();

  bool _usingMockData = false;
  bool get usingMockData => _usingMockData;

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
      final lieu = _normaliser('${f.region ?? ''} ${f.delegation ?? ''}');
      if (n.startsWith(q)) {
        debut.add(f);
      } else if (n.contains(q) || lieu.contains(q)) {
        ailleurs.add(f);
      }
    }

    return Resultat(
      [...debut, ...ailleurs].take(limite).toList(),
      estDemonstration: resultat.estDemonstration,
      messageErreur: resultat.messageErreur,
    );
  }

  Future<Fournisseur> create({
    required String nom,
    String? region,
    String? delegation,
    String? telephone,
  }) async {
    final body = {
      'nom': nom.trim(),
      'region': region ?? '',
      'delegation': delegation ?? '',
      'telephone': telephone ?? '',
    };
    final json = await apiClient.post('/api/fournisseurs/', body);
    final cree = Fournisseur.fromJson(json);
    _cache = Resultat([...?_cache?.donnees, cree]);
    return cree;
  }

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

  List<Fournisseur> _mockFournisseurs() => [
    Fournisseur(
      id: 'mock-frn-1',
      nom: 'Agricole Ben Ali',
      region: 'Sfax',
      delegation: 'Sfax Sud',
    ),
    Fournisseur(
      id: 'mock-frn-2',
      nom: 'Huilerie du Sud',
      region: 'Medenine',
      delegation: 'Ben Gardane',
    ),
    Fournisseur(
      id: 'mock-frn-3',
      nom: 'Domaine Olivia',
      region: 'Sousse',
      delegation: 'Akouda',
    ),
    Fournisseur(
      id: 'mock-frn-4',
      nom: 'Cooperative de Mahdia',
      region: 'Mahdia',
    ),
  ];

  void invalidateCache() => _cache = null;
}
