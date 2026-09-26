import '../api_client.dart';
import '../models/collecteur_suggestion.dart';
import 'resultat_service.dart';

class CollecteurSuggestionService {
  CollecteurSuggestionService._();
  static final CollecteurSuggestionService instance =
      CollecteurSuggestionService._();

  Resultat<List<CollecteurSuggestion>>? _cache;

  Future<Resultat<List<CollecteurSuggestion>>> fetchAll({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache != null) return _cache!;
    _cache = await avecSecours(() async {
      final items = await apiClient.getList('/api/users/collecteurs/');
      return items
          .map(
            (item) =>
                CollecteurSuggestion.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }, () => const <CollecteurSuggestion>[]);
    return _cache!;
  }

  Future<Resultat<List<CollecteurSuggestion>>> suggest(
    String saisie, {
    int limite = 6,
  }) async {
    final q = _normaliser(saisie);
    final resultat = await fetchAll();
    final source = resultat.donnees;
    if (q.isEmpty) {
      return Resultat(
        source.take(limite).toList(),
        estDemonstration: resultat.estDemonstration,
        messageErreur: resultat.messageErreur,
      );
    }

    final debut = <CollecteurSuggestion>[];
    final ailleurs = <CollecteurSuggestion>[];
    for (final collecteur in source) {
      final nom = _normaliser(collecteur.nomComplet);
      if (nom.startsWith(q)) {
        debut.add(collecteur);
      } else if (nom.contains(q)) {
        ailleurs.add(collecteur);
      }
    }
    return Resultat(
      [...debut, ...ailleurs].take(limite).toList(),
      estDemonstration: resultat.estDemonstration,
      messageErreur: resultat.messageErreur,
    );
  }

  static String _normaliser(String s) {
    var texte = s.toLowerCase().trim();
    const accents = 'àâäáãåçèéêëìíîïñòóôöõùúûüýÿ';
    const plats = 'aaaaaaceeeeiiiinooooouuuuyy';
    final buffer = StringBuffer();
    for (final ch in texte.split('')) {
      final i = accents.indexOf(ch);
      final c = i == -1 ? ch : plats[i];
      if (RegExp(r'[a-z0-9]').hasMatch(c)) buffer.write(c);
    }
    return buffer.toString();
  }

  void invalidateCache() => _cache = null;
}
