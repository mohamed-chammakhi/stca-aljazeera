import 'package:project3/core/api_client.dart';
import 'package:project3/core/models/echantillon.dart';
import 'package:project3/core/models/enums.dart';
import 'package:project3/core/models/mock_echantillons_gestion.dart';
import 'package:project3/core/services/resultat_service.dart';

class GestionEchantillonsService {
  final bool uniquementRecusPhysiquement;

  const GestionEchantillonsService({this.uniquementRecusPhysiquement = true});

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
      'num_citerne': api['num_citerne'],
      'variete': api['variete'],
      'quantite_estimee': api['quantite_estimee'],
      'image_url': api['image_url'],
      'statut_collecteur': api['statut_collecteur'] ?? 'receptionne',
      'statut_degustateur': api['statut_degustateur'],
      'statut_labo': api['statut_labo'],
      'statut_ceo': api['statut_ceo'],
      'recu_physiquement': api['recu_physiquement'] ?? false,
      'date_arrivee_echantillon': api['date_arrivee_echantillon'],
      'date_reception_echantillon': api['date_reception_echantillon'],
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

  /// Converts the shared Flutter sample model to the Django serializer payload.
  Map<String, dynamic> _toDjangoMap(Echantillon e) {
    final code = e.codeFournisseur?.trim() ?? '';
    final nom = e.fournisseurNom?.trim() ?? '';
    return {
      'gouvernorat': e.gouvernorat,
      'delegation': e.delegation,
      'cite': e.cite,
      if (nom.isEmpty && code.isNotEmpty) 'code_fournisseur': code,
      if (nom.isNotEmpty) 'fournisseur_nom': nom,
      'reference_bouteille': e.referenceBouteille,
      'num_citerne': e.numCiterne,
      'quantite_estimee': e.quantiteEstimee,
      'variete': e.variete,
      'date_arrivee_echantillon': e.dateArriveeEchantillon,
      'remarques': e.remarques,
      'image_url': e.imageUrl,
      'statut_collecteur': e.statutCollecteur.toJson,
    };
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Fetches all physically received echantillons visible to the degustateur.
  Future<Resultat<List<Echantillon>>> fetchEchantillons() => avecSecours(
    () async {
      final path = uniquementRecusPhysiquement
          ? '/api/echantillons/?recu_physiquement=true'
          : '/api/echantillons/';
      final items = await apiClient.getList(path);
      return items
          .map(
            (e) =>
                Echantillon.fromJson(_toFlutterMap(e as Map<String, dynamic>)),
          )
          .toList();
    },
    () => List.of(mockEchantillonsGestion),
  );

  /// Updates an existing echantillon via PATCH and returns the updated record.
  Future<Echantillon> updateEchantillon(Echantillon e) async {
    final response = await apiClient.patch(
      '/api/echantillons/${e.id}/',
      _toDjangoMap(e),
    );
    return Echantillon.fromJson(_toFlutterMap(response));
  }

  Future<Echantillon> createEchantillon(Echantillon e) async {
    final response = await apiClient.post(
      '/api/echantillons/',
      _toDjangoMap(e),
    );
    return Echantillon.fromJson(_toFlutterMap(response));
  }

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
