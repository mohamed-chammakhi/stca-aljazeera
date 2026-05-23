import '../../../core/models/echantillon.dart';
import '../../../core/api_client.dart';

class GestionEchantillonsService {
  // ── Field mapping: Django API → Echantillon.fromJson ─────────────────────
  //
  // Django returns:   numero, fournisseur (UUID), collecteur (UUID), ...
  // fromJson expects: ref,    fournisseur_id,      collecteur_id, ...
  // ─────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> _toFlutterMap(Map<String, dynamic> api) {
    return {
      'id': api['id'],
      'ref': api['numero'] ?? '',
      'fournisseur_id': api['fournisseur'] ?? '',
      'collecteur_id': api['collecteur'] ?? '',
      'code_fournisseur': api['code_fournisseur'],
      'fournisseur_nom': api['fournisseur_nom'],
      'collecteur_nom': api['collecteur_nom'],
      'gouvernorat': api['gouvernorat'] ?? '',
      'delegation': api['delegation'],
      'cite': api['cite'],
      'reference_bouteille': api['reference_bouteille'] ?? '',
      'scellage': api['scellage'],
      'variete': api['variete'],
      'quantite_estimee': api['quantite_estimee'],
      'image_url': api['image_url'],
      'statut_collecteur': api['statut_collecteur'] ?? 'receptionne',
      'statut_degustateur': api['statut_degustateur'],
      'statut_labo': api['statut_labo'],
      'statut_ceo': api['statut_ceo'],
      'recu_physiquement': api['recu_physiquement'] ?? false,
      'date_arrivee_echantillon': api['date_arrivee_echantillon'],
      'budget_negociation': api['budget_negociation'],
      'quantite_cible_t': api['quantite_cible_t'],
      'camion_reserve': api['camion_reserve'],
      'note_interne': api['note_interne'],
      'raison_refus': api['raison_refus'],
      'stock_arrive': api['stock_arrive'] ?? false,
      'date_livraison_stock': api['date_livraison_stock'],
      'classification': api['classification'],
      'remarques': api['remarques'],
      'date_ajout': api['date_ajout'] ?? '',
      'updated_at': api['updated_at'],
    };
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches all physically received echantillons visible to the degustateur.
  Future<List<Echantillon>> fetchEchantillons() async {
    final items = await apiClient.getList(
      '/api/echantillons/?recu_physiquement=true',
    );
    return items
        .map(
          (e) => Echantillon.fromJson(_toFlutterMap(e as Map<String, dynamic>)),
        )
        .toList();
  }

  /// Creates a new echantillon (likely unused for degustateur but kept for API symmetry).
  Future<Echantillon> createEchantillon(Echantillon e) async {
    final response = await apiClient.post('/api/echantillons/', e.toJson());
    return Echantillon.fromJson(_toFlutterMap(response));
  }

  /// Updates an existing echantillon via PATCH and returns the updated record.
  Future<Echantillon> updateEchantillon(Echantillon e) async {
    final response = await apiClient.patch(
      '/api/echantillons/${e.id}/',
      e.toJson(),
    );
    return Echantillon.fromJson(_toFlutterMap(response));
  }

  /// Deletes an echantillon by ID.
  Future<void> deleteEchantillon(String id) async {
    await apiClient.delete('/api/echantillons/$id/');
  }

  /// Confirms physical reception of an echantillon at the company.
  ///
  /// Calls `PATCH /api/echantillons/<id>/confirmer_reception/` — the backend
  /// sets `recu_physiquement = true` and records the arrival timestamp.
  /// The [value] parameter is retained for API symmetry but is always true
  /// when calling this endpoint.
  Future<void> toggleRecuPhysiquement(String id, bool value) async {
    await apiClient.patch('/api/echantillons/$id/confirmer-reception/', {});
  }
}
