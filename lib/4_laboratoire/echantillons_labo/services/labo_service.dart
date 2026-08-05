import '../../../core/analyses/normes_coi.dart';
import '../../../core/api_client.dart';
import '../../../core/services/resultat_service.dart';
import '../../../core/models/enums.dart' show StatutLaboX;
import '../models/echantillon_labo.dart';
import '../models/mock_echantillons_labo.dart';
import '../../analyse_labo.dart';

class LaboService {
  bool _usingMockData = false;
  List<EchantillonLabo> _lastFetched = [];

  Future<Resultat<List<EchantillonLabo>>> fetchEchantillons() => avecSecours(
    () async {
      final items = await apiClient.getList('/api/analyses/echantillons/');
      _usingMockData = false;
      _lastFetched = items
          .map((item) => EchantillonLabo.fromJson(item as Map<String, dynamic>))
          .toList();
      return _lastFetched;
    },
    () {
      _usingMockData = true;
      _lastFetched = List.of(mockEchantillonsLabo);
      return _lastFetched;
    },
  );

  Future<AnalyseLabo> saveAnalyse(
    String echantillonId,
    AnalyseLabo analyse, {
    List<int>? photoBytes,
    String? photoName,
  }) async {
    if (_usingMockData) {
      throw StateError('Enregistrement indisponible avec les données de démonstration.');
    }

    final existing = _findCached(echantillonId)?.analyse;
    final analyseId = analyse.id ?? existing?.id;
    final payload = _toApiPayload(echantillonId, analyse);

    final Map<String, dynamic> data;
    if (analyseId == null && photoBytes != null) {
      // Create with a real lab-report photo → multipart so the backend
      // ImageField receives the file. All scalar fields are sent as
      // string-encoded form fields next to the `photo` file part.
      data = await apiClient.postMultipart(
        '/api/analyses/',
        bytes: photoBytes,
        filename: photoName ?? 'rapport.jpg',
        fileField: 'photo',
        fields: _payloadAsFormFields(payload),
      );
    } else if (analyseId == null) {
      data = await apiClient.post('/api/analyses/', payload);
    } else {
      data = await apiClient.patch('/api/analyses/$analyseId/', payload);
    }
    final saved = AnalyseLabo.fromJson(data);
    _replaceCachedAnalysis(echantillonId, saved);
    return saved;
  }

  /// Multipart accepts only string field values — convert the JSON-style
  /// payload, dropping nulls so the backend receives unset fields as
  /// "missing" rather than the literal string "null".
  Map<String, String> _payloadAsFormFields(Map<String, dynamic> payload) {
    final out = <String, String>{};
    payload.forEach((k, v) {
      if (v == null) return;
      out[k] = v.toString();
    });
    return out;
  }

  Future<void> deleteAnalyse(String echantillonId) async {
    if (_usingMockData) {
      throw StateError('Suppression indisponible avec les données de démonstration.');
    }

    final analyseId = _findCached(echantillonId)?.analyse?.id;
    if (analyseId == null) {
      throw StateError('Analyse introuvable pour cet echantillon.');
    }
    await apiClient.delete('/api/analyses/$analyseId/');
    _replaceCachedAnalysis(echantillonId, null);
  }

  Future<AnalyseLabo?> soumettre(String analyseId) async {
    if (_usingMockData) {
      throw StateError('Soumission indisponible avec les données de démonstration.');
    }

    final data = await apiClient.post(
      '/api/analyses/$analyseId/soumettre/',
      {},
    );
    final saved = AnalyseLabo.fromJson(data);
    _replaceCachedAnalysis(saved.echantillonId, saved);
    return saved;
  }

  String messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'Impossible de joindre le serveur. Les donnees de demonstration restent affichees.';
  }

  Map<String, dynamic> _toApiPayload(
    String echantillonId,
    AnalyseLabo analyse,
  ) {
    final statut = analyse.statut == StatutAnalyse.enAttente
        ? StatutAnalyse.enCours.toJson
        : analyse.statut.toJson;
    return {
      'echantillon': echantillonId,
      'statut': statut,
      // Les 28 valeurs partent depuis la même liste que celle qui les affiche.
      // Elles étaient énumérées à la main ici : les paramètres absents de cette
      // liste étaient saisis par le technicien puis perdus à l'envoi.
      for (final p in kTousParametres) p.cle: analyse.valeur(p.cle),
      'numero_certificat': analyse.numeroCertificat,
      'numero_lot': analyse.numeroLot,
      'date_debut_analyse': analyse.dateDebutAnalyse,
      'date_fin_analyse': analyse.dateFinAnalyse,
      'quantite_ml': analyse.quantiteMl,
      'notes': analyse.notes,
    };
  }

  EchantillonLabo? _findCached(String echantillonId) {
    for (final e in _lastFetched) {
      if (e.id == echantillonId) return e;
    }
    return null;
  }

  void _replaceCachedAnalysis(String echantillonId, AnalyseLabo? analyse) {
    final cached = _findCached(echantillonId);
    if (cached != null) cached.analyse = analyse;
  }
}
