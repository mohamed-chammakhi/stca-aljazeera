// lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart

import '../models/dashboard_degustateur.dart';
import '../../../core/api_client.dart';

class DashboardDegustateurService {
  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Formats an ISO 8601 date string to French short format: "24 Avr · 10h32".
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

  // ── Urgent evaluations (time-based) ─────────────────────────────────────────

  /// Fetches samples that have been waiting longest for evaluation.
  ///
  /// Backend: GET /api/chef/dashboard/urgentes/
  /// Returns: [{id, numero, variete, days_waiting, badge}, ...]
  /// Translation: builds a map that EvaluationUrgente.fromJson expects.
  Future<List<EvaluationUrgente>> fetchUrgentes() async {
    final items = await apiClient.getList('/api/chef/dashboard/urgentes/');
    return items.map((e) {
      final api = e as Map<String, dynamic>;
      return EvaluationUrgente.fromJson({
        'id':             api['id'],
        'reference':      '${api['variete'] ?? ''} · ${api['numero'] ?? ''}',
        'collecteur_nom': '',
        'fournisseur_nom': '',
        'jours_en_attente': api['days_waiting'] ?? 0,
      });
    }).toList();
  }

  // ── Urgent evaluations flagged by CEO ────────────────────────────────────────

  /// Fetches samples that the CEO has flagged as requiring priority evaluation.
  ///
  /// Backend: GET /api/chef/dashboard/urgentes-ceo/
  /// Returns: [{id, numero, variete, collecteur_nom, fournisseur_nom}, ...]
  /// Translation: builds reference from variete + numero.
  Future<List<EvaluationUrgenteCeo>> fetchUrgentesCeo() async {
    final items = await apiClient.getList('/api/chef/dashboard/urgentes-ceo/');
    return items.map((e) {
      final api = e as Map<String, dynamic>;
      return EvaluationUrgenteCeo.fromJson({
        'id':             api['id'],
        'reference':      '${api['variete'] ?? ''} · ${api['numero'] ?? ''}',
        'collecteur_nom': api['collecteur_nom'] ?? '',
        'fournisseur_nom': api['fournisseur_nom'] ?? '',
      });
    }).toList();
  }

  // ── Pipeline ─────────────────────────────────────────────────────────────────

  /// Fetches the evaluation pipeline counts.
  ///
  /// Backend: GET /api/chef/dashboard/pipeline/
  /// Returns: {receptionne, en_attente_eval, en_cours, soumis}
  /// Translation: en_attente_eval → non_evaluee, soumis → soumise
  Future<PipelineData> fetchPipeline() async {
    final raw = await apiClient.get('/api/chef/dashboard/pipeline/');
    return PipelineData.fromJson({
      'receptionne': raw['receptionne'] ?? 0,
      'non_evaluee': raw['en_attente_eval'] ?? 0,
      'en_cours':    raw['en_cours'] ?? 0,
      'soumise':     raw['soumis'] ?? 0,
    });
  }

  // ── Classifications ──────────────────────────────────────────────────────────

  /// Fetches classification distribution over time, optionally filtered by date range.
  ///
  /// Backend: GET /api/chef/dashboard/classifications/?date_debut=...&date_fin=...
  /// Returns: [{label, extra_vierge, vierge, lampante}, ...] — matches Flutter model directly.
  Future<List<ClassificationPoint>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final params = <String, String>{};
    if (dateDebut != null) {
      params['date_debut'] = '${dateDebut.year}-${dateDebut.month.toString().padLeft(2, '0')}-${dateDebut.day.toString().padLeft(2, '0')}';
    }
    if (dateFin != null) {
      params['date_fin'] = '${dateFin.year}-${dateFin.month.toString().padLeft(2, '0')}-${dateFin.day.toString().padLeft(2, '0')}';
    }
    final path = Uri(
      path: '/api/chef/dashboard/classifications/',
      queryParameters: params.isEmpty ? null : params,
    ).toString();
    final items = await apiClient.getList(path);
    return items
        .map((e) => ClassificationPoint.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Presence ──────────────────────────────────────────────────────────────────

  /// Fetches the degustateur's session attendance summary.
  ///
  /// Backend: GET /api/chef/dashboard/presence/?date_debut=...&date_fin=...
  /// Returns: {present, manquee, prochaine_titre, prochaine_date, prochaine_lieu, prochaine_countdown}
  /// — matches PresenceData.fromJson directly.
  Future<PresenceData> fetchPresence({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final params = <String, String>{};
    if (dateDebut != null) {
      params['date_debut'] = '${dateDebut.year}-${dateDebut.month.toString().padLeft(2, '0')}-${dateDebut.day.toString().padLeft(2, '0')}';
    }
    if (dateFin != null) {
      params['date_fin'] = '${dateFin.year}-${dateFin.month.toString().padLeft(2, '0')}-${dateFin.day.toString().padLeft(2, '0')}';
    }
    final path = Uri(
      path: '/api/chef/dashboard/presence/',
      queryParameters: params.isEmpty ? null : params,
    ).toString();
    final raw = await apiClient.get(path);
    return PresenceData.fromJson(raw);
  }

  // ── Délai de soumission ──────────────────────────────────────────────────────

  /// Fetches the degustateur's submission delay summary over a date range.
  ///
  /// Backend: GET /api/degustateur/dashboard/delai/?date_debut=...&date_fin=...
  /// Returns: {mon_delai_moyen, panel_moyen, nb_evals, points: [{date, delai}]}
  /// Translation: each point maps delai → mon_delai, adds panel_moyen from root.
  Future<DelaiSummary> fetchDelai({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    String _fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final path = Uri(
      path: '/api/degustateur/dashboard/delai/',
      queryParameters: {
        'date_debut': _fmt(dateDebut),
        'date_fin':   _fmt(dateFin),
      },
    ).toString();
    final raw = await apiClient.get(path);
    final panelMoyen = (raw['panel_moyen'] as num?)?.toDouble() ?? 0.0;
    final points = (raw['points'] as List? ?? []).map((p) {
      final point = p as Map<String, dynamic>;
      return DelaiPoint.fromJson({
        'date':        point['date'],
        'mon_delai':   point['delai'],
        'panel_moyen': panelMoyen,
      });
    }).toList();
    return DelaiSummary(
      monDelaiMoyen: (raw['mon_delai_moyen'] as num?)?.toDouble() ?? 0.0,
      panelMoyen:    panelMoyen,
      nbEvals:       (raw['nb_evals'] as int?) ?? 0,
      points:        points,
    );
  }

  // ── Activité récente ─────────────────────────────────────────────────────────

  /// Fetches paginated recent activity for the degustateur.
  ///
  /// Backend: GET /api/degustateur/activite/?offset=<n>&limit=<n>
  /// Returns: {count: N, results: [{type, date, description}, ...]}
  /// Translation: maps description → action, date → horodatage (French format).
  Future<({List<ActiviteItem> items, int total})> fetchActivite({
    DateTime? dateDebut,
    DateTime? dateFin,
    int offset = 0,
    int pageSize = 5,
  }) async {
    final params = <String, String>{
      'offset': offset.toString(),
      'limit':  pageSize.toString(),
    };
    if (dateDebut != null) {
      params['date_debut'] = '${dateDebut.year}-${dateDebut.month.toString().padLeft(2, '0')}-${dateDebut.day.toString().padLeft(2, '0')}';
    }
    if (dateFin != null) {
      params['date_fin'] = '${dateFin.year}-${dateFin.month.toString().padLeft(2, '0')}-${dateFin.day.toString().padLeft(2, '0')}';
    }
    final path = Uri(
      path: '/api/degustateur/activite/',
      queryParameters: params,
    ).toString();
    // Use get() (not getList()) so we can read the top-level `count` field.
    final raw = await apiClient.get(path);
    final total = (raw['count'] as int?) ?? 0;
    final results = raw['results'] as List? ?? [];
    final items = results.asMap().entries.map((entry) {
      final index = offset + entry.key;
      final item = entry.value as Map<String, dynamic>;
      return ActiviteItem.fromJson({
        'id':         index.toString(),
        'action':     item['description'] ?? '',
        'horodatage': _formatDate(item['date'] as String? ?? ''),
        'type':       item['type'] ?? '',
      });
    }).toList();
    return (items: items, total: total);
  }
}
