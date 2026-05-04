import '../models/dashboard_chef_degustateur.dart';
import '../../../core/api_client.dart';

class DashboardChefDegustateurService {
  // ── Private helpers ────────────────────────────────────────────────────────

  /// Formats an ISO 8601 datetime string to French short format: "24 Avr · 10h32".
  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = [
        'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month · ${hour}h$minute';
    } catch (_) {
      return isoDate;
    }
  }

  /// Formats a [DateTime] to ISO date string "YYYY-MM-DD".
  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Builds a URL path with optional date range query parameters.
  String _pathWithDates(
    String basePath, {
    DateTime? dateDebut,
    DateTime? dateFin,
    Map<String, String>? extra,
  }) {
    final params = <String, String>{
      if (extra != null) ...extra,
      if (dateDebut != null) 'date_debut': _fmtDate(dateDebut),
      if (dateFin != null) 'date_fin': _fmtDate(dateFin),
    };
    return Uri(
      path: basePath,
      queryParameters: params.isEmpty ? null : params,
    ).toString();
  }

  // ── Pipeline ───────────────────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/pipeline/
  /// Returns: {receptionne, en_attente_eval, en_cours, soumis}
  Future<PipelineChefData> fetchPipeline() async {
    final raw = await apiClient.get('/api/chef/dashboard/pipeline/');
    return PipelineChefData.fromJson(raw);
  }

  // ── Urgentes (time-based) ──────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/urgentes/
  /// Returns: [{id, numero, variete, days_waiting, badge}, ...]
  /// Translation: reference = '$variete · $numero', jours_en_attente = days_waiting.
  Future<List<EvaluationUrgenteChef>> fetchUrgentes() async {
    final items = await apiClient.getList('/api/chef/dashboard/urgentes/');
    return items.map((e) {
      final api = e as Map<String, dynamic>;
      return EvaluationUrgenteChef.fromJson({
        'id':              api['id'],
        'reference':       '${api['variete'] ?? ''} · ${api['numero'] ?? ''}',
        'collecteur_nom':  '',
        'fournisseur_nom': '',
        'jours_en_attente': api['days_waiting'] ?? 0,
      });
    }).toList();
  }

  // ── Sessions en attente ────────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/sessions-en-attente/
  /// Returns: [{id, titre, date, heure, lieu, cree_par}, ...]
  /// Translation: propose_par = cree_par.
  Future<List<SessionEnAttente>> fetchSessionsEnAttente() async {
    final items = await apiClient.getList('/api/chef/dashboard/sessions-en-attente/');
    return items.map((e) {
      final api = e as Map<String, dynamic>;
      return SessionEnAttente.fromJson({
        'id':          api['id'],
        'titre':       api['titre'] ?? '',
        'date':        api['date'] ?? '',
        'heure':       api['heure'] ?? '',
        'lieu':        api['lieu'] ?? '',
        'propose_par': api['cree_par'] ?? '',
      });
    }).toList();
  }

  // ── Délai de soumission ────────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/delai/?date_debut=...&date_fin=...
  /// Returns: {membres: [{nom, delai_moyen, panel_moyen}], panel_moyen}
  Future<DelaiPanelData> fetchDelai({DateTime? dateDebut, DateTime? dateFin}) async {
    final path = _pathWithDates(
      '/api/chef/dashboard/delai/',
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
    final raw = await apiClient.get(path);
    return DelaiPanelData.fromJson(raw);
  }

  // ── Alignement du panel ────────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/alignement/?date_debut=...&date_fin=...
  /// Returns: {membres: [{nom, divergence_pct}]}
  Future<AlignementPanelData> fetchAlignement({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final path = _pathWithDates(
      '/api/chef/dashboard/alignement/',
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
    final raw = await apiClient.get(path);
    return AlignementPanelData.fromJson(raw);
  }

  // ── Classifications ────────────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/classifications/?date_debut=...&date_fin=...
  /// Returns: [{label, extra_vierge, vierge, lampante}] — matches model directly.
  Future<List<ClassificationPoint>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final path = _pathWithDates(
      '/api/chef/dashboard/classifications/',
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
    final items = await apiClient.getList(path);
    return items
        .map((e) => ClassificationPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Urgentes CEO ───────────────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/urgentes-ceo/
  /// Returns: [{id, numero, variete, collecteur_nom, fournisseur_nom}, ...]
  /// Translation: reference = '$variete · $numero'.
  Future<List<EvaluationUrgenteCeoChef>> fetchUrgentesCeo() async {
    final items = await apiClient.getList('/api/chef/dashboard/urgentes-ceo/');
    return items.map((e) {
      final api = e as Map<String, dynamic>;
      return EvaluationUrgenteCeoChef.fromJson({
        'id':              api['id'],
        'reference':       '${api['variete'] ?? ''} · ${api['numero'] ?? ''}',
        'collecteur_nom':  api['collecteur_nom'] ?? '',
        'fournisseur_nom': api['fournisseur_nom'] ?? '',
      });
    }).toList();
  }

  // ── Présence ───────────────────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/presence/?date_debut=...&date_fin=...
  /// Returns: {present, manquee, prochaine_titre, prochaine_date, prochaine_lieu, prochaine_countdown}
  /// — matches PresenceChefData.fromJson directly.
  Future<PresenceChefData> fetchPresence({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final path = _pathWithDates(
      '/api/chef/dashboard/presence/',
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
    final raw = await apiClient.get(path);
    return PresenceChefData.fromJson(raw);
  }

  // ── Activité (paginated) ───────────────────────────────────────────────────

  /// Backend: GET /api/chef/dashboard/activite/?offset=<n>&limit=<n>&date_debut=...&date_fin=...
  /// Returns: {count, results: [{type, date, description}]}
  /// Translation:
  ///   id         = (offset + index).toString()
  ///   action     = item['description']
  ///   horodatage = _formatDate(item['date'])
  ///   type       = item['type']
  Future<({List<ActiviteItemChef> items, int total})> fetchActivite({
    DateTime? dateDebut,
    DateTime? dateFin,
    int offset = 0,
    int pageSize = 5,
  }) async {
    final path = _pathWithDates(
      '/api/chef/dashboard/activite/',
      dateDebut: dateDebut,
      dateFin: dateFin,
      extra: {
        'offset': offset.toString(),
        'limit':  pageSize.toString(),
      },
    );
    final raw = await apiClient.get(path);
    final results = (raw['results'] as List? ?? []);
    final total = (raw['count'] as int?) ?? results.length;
    final items = results.asMap().entries.map((entry) {
      final index = entry.key;
      final api = entry.value as Map<String, dynamic>;
      return ActiviteItemChef(
        id:          (offset + index).toString(),
        action:      (api['description'] as String?) ?? '',
        horodatage:  _formatDate((api['date'] as String?) ?? ''),
        type:        (api['type'] as String?) ?? '',
      );
    }).toList();
    return (items: items, total: total);
  }
}
