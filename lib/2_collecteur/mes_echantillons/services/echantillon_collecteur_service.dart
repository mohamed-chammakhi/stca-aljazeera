// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/services/echantillon_collecteur_service.dart
// ═════════════════════════════════════════════════════════════════════════════

import '../models/echantillon_collecteur.dart';
import '../../../../core/api_client.dart';
import '../../../../core/models/enums.dart' show StatutCollecteurX;
import 'echantillon_mock_data.dart';

class EchantillonCollecteurService {
  bool _usingMockData = false;
  // ── Field mapping: Django API → Flutter fromJson ───────────────────────────
  //
  // The Django API returns field names that differ from what fromJson() expects.
  // We build an intermediate map that satisfies the model's fromJson contract.
  //
  // Key renames:
  //   numero                   → ref
  //   statut_collecteur        → statut  (+ value conversion to Dart enum name)
  //   collecteur               → collecteur_id
  //   date_arrivee_echantillon → date_reception_echantillon  (actual receipt date)
  //   camion_reserve           → camion_livraison
  //   budget_negociation       → budget_negociation  (Decimal/null → String?/null)
  //   prix_final               → prix_final          (Decimal/null → String?/null)
  //
  // Fields always null (not in this endpoint):
  //   date_arrivee_echantillon → always null  (no scheduled arrival date in backend)
  //   livraison                → always null  (planification not in this endpoint)
  // ──────────────────────────────────────────────────────────────────────────

  /// Converts a Django `statut_collecteur` snake_case value to the Dart enum
  /// identifier name used by `StatutCollecteur.values.byName()`.
  ///
  /// Django   → Dart enum name
  /// receptionne    → receptionne
  /// en_negociation → enNegociation
  /// achat_confirme → achatConfirme
  String _mapStatut(String djangoStatut) {
    switch (djangoStatut) {
      case 'receptionne':
        return 'receptionne';
      case 'en_negociation':
        return 'enNegociation';
      case 'achat_confirme':
        return 'achatConfirme';
      default:
        return djangoStatut;
    }
  }

  /// Converts the Django API response map to the intermediate map that
  /// `EchantillonCollecteur.fromJson()` expects.
  Map<String, dynamic> _toFlutterMap(Map<String, dynamic> api) {
    final statutCollecteur =
        api['statut_collecteur'] as String? ?? 'receptionne';
    return {
      'id': api['id'],
      'numero': api['numero'],
      'gouvernorat': api['gouvernorat'] ?? '',
      'delegation': api['delegation'],
      'cite': api['cite'],
      'code_fournisseur': api['code_fournisseur'] ?? '',
      'reference_bouteille': api['reference_bouteille'] ?? '',
      'num_citerne': api['num_citerne'],
      'quantite_estimee': api['quantite_estimee'],
      'variete': api['variete'],
      'achat_confirme': statutCollecteur == 'achat_confirme',
      'livraison': null,
      // date_arrivee_echantillon (scheduled) is not in this endpoint — always null.
      'date_arrivee_echantillon': null,
      'recu_physiquement': api['recu_physiquement'] ?? false,
      // date_arrivee_echantillon from API = actual physical reception date.
      'date_reception_echantillon': api['date_arrivee_echantillon'],
      'budget_negociation': api['budget_negociation']?.toString(),
      'date_stock_souhaitee_debut': null,
      'date_stock_souhaitee_fin': null,
      'prix_final': api['prix_final']?.toString(),
      'camion_livraison': api['camion_reserve'],
      'remarques': api['remarques'],
      'date_ajout': api['date_ajout'],
      'image_url': api['image_url'],
      'collecteur_id': api['collecteur'] ?? '',
      'collecteur_nom': api['collecteur_nom'] ?? '',
      'statut_collecteur': _mapStatut(statutCollecteur),
      'statut': _mapStatut(statutCollecteur),
    };
  }

  /// Converts `EchantillonCollecteur.toJson()` back to Django field names for
  /// POST/PATCH requests.
  Map<String, dynamic> _toDjangoMap(EchantillonCollecteur e) {
    final json = e.toJson();
    final nom = e.fournisseurNom?.trim() ?? '';
    return {
      'gouvernorat': json['gouvernorat'],
      'delegation': json['delegation'],
      'cite': json['cite'],
      'code_fournisseur': e.codeFournisseur,
      // Only sent when present so legacy edits don't accidentally override
      // the supplier match with an empty string.
      if (nom.isNotEmpty) 'fournisseur_nom': nom,
      'reference_bouteille': json['reference_bouteille'],
      'num_citerne': json['num_citerne'],
      'quantite_estimee': json['quantite_estimee'],
      'variete': json['variete'],
      'budget_negociation': json['budget_negociation'],
      'prix_final': json['prix_final'],
      'camion_reserve': json['camion_reserve'],
      'remarques': json['remarques'],
      'image_url': json['image_url'],
      'statut_collecteur': e.statut.toJson,
    };
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches all echantillons for the current collector.
  ///
  /// Optional filters:
  ///   [statut] — Django snake_case value ('receptionne', 'en_negociation', 'achat_confirme')
  ///   [search] — free-text search string
  Future<List<EchantillonCollecteur>> fetchEchantillons({
    String? statut,
    String? search,
  }) async {
    try {
      final params = <String, String>{};
      if (statut != null && statut.isNotEmpty) params['statut'] = statut;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final uri = Uri(
        path: '/api/echantillons/',
        queryParameters: params.isEmpty ? null : params,
      );
      final items = await apiClient.getList(uri.toString());
      _usingMockData = false;
      return items
          .map(
            (e) => EchantillonCollecteur.fromJson(
              _toFlutterMap(e as Map<String, dynamic>),
            ),
          )
          .toList();
    } catch (_) {
      _usingMockData = true;
      final all = mockEchantillons();
      return all.where((e) {
        if (statut != null && statut.isNotEmpty && e.statut.toJson != statut) {
          return false;
        }
        if (search != null && search.isNotEmpty) {
          final q = search.toLowerCase();
          if (!e.numero.toLowerCase().contains(q) &&
              !e.referenceBouteille.toLowerCase().contains(q) &&
              !e.codeFournisseur.toLowerCase().contains(q) &&
              !(e.variete?.toLowerCase().contains(q) ?? false)) {
            return false;
          }
        }
        return true;
      }).toList();
    }
  }

  /// Creates a new echantillon and returns the saved record from the server.
  Future<EchantillonCollecteur> createEchantillon(
    EchantillonCollecteur e,
  ) async {
    if (_usingMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return e;
    }
    final response = await apiClient.post(
      '/api/echantillons/',
      _toDjangoMap(e),
    );
    return EchantillonCollecteur.fromJson(_toFlutterMap(response));
  }

  /// Creates a new echantillon AND uploads its bottle photo in one request.
  /// The photo is stored on the on-premise server and shown to tasters later.
  Future<EchantillonCollecteur> createEchantillonWithImage(
    EchantillonCollecteur e, {
    required List<int> imageBytes,
    required String filename,
  }) async {
    if (_usingMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return e;
    }
    final dj = _toDjangoMap(e);
    final fields = <String, String>{};
    dj.forEach((k, v) {
      if (v != null && v.toString().isNotEmpty) fields[k] = v.toString();
    });
    final response = await apiClient.postMultipart(
      '/api/echantillons/',
      bytes: imageBytes,
      filename: filename,
      fields: fields,
    );
    return EchantillonCollecteur.fromJson(_toFlutterMap(response));
  }

  /// Updates an existing echantillon via PATCH and returns the updated record.
  Future<EchantillonCollecteur> updateEchantillon(
    EchantillonCollecteur e,
  ) async {
    if (_usingMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return e;
    }
    final response = await apiClient.patch(
      '/api/echantillons/${e.id}/',
      _toDjangoMap(e),
    );
    return EchantillonCollecteur.fromJson(_toFlutterMap(response));
  }

  /// Deletes an echantillon by ID.
  Future<void> deleteEchantillon(String id) async {
    if (_usingMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await apiClient.delete('/api/echantillons/$id/');
  }

  /// Confirms the purchase of an echantillon.
  ///
  /// Calls `PATCH /api/echantillons/<id>/confirmer_achat/` with optional
  /// [prixFinal] and [camionLivraison] values.
  Future<EchantillonCollecteur> confirmerAchat(
    String id, {
    String? prixFinal,
    String? camionLivraison,
  }) async {
    if (_usingMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final all = mockEchantillons();
      return all.firstWhere((e) => e.id == id, orElse: () => all.first);
    }
    final body = <String, dynamic>{};
    if (prixFinal != null) body['prix_final'] = prixFinal;
    if (camionLivraison != null) body['camion_reserve'] = camionLivraison;
    final response = await apiClient.patch(
      '/api/echantillons/$id/confirmer-achat/',
      body,
    );
    return EchantillonCollecteur.fromJson(_toFlutterMap(response));
  }

  String messageFor(Object error) {
    if (error is ApiException) return error.message;
    return 'Impossible de joindre le serveur. Les donnees de demonstration restent affichees.';
  }
}
