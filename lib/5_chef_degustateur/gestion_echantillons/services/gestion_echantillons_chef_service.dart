import '../../../core/api_client.dart';
import '../../../core/models/echantillon.dart';
import '../../../core/services/resultat_service.dart';
import '../models/mock_echantillons.dart';

class GestionEchantillonsChefService {
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

  Future<Resultat<List<Echantillon>>> fetchEchantillons() => avecSecours(
    () async {
      final items = await apiClient.getList('/api/echantillons/');
      return items
          .map(
            (e) =>
                Echantillon.fromJson(_toFlutterMap(e as Map<String, dynamic>)),
          )
          .toList();
    },
    _mockEchantillons,
  );

  Future<void> toggleRecuPhysiquement(String id, bool value) async {
    await apiClient.patch('/api/echantillons/$id/confirmer-reception/', {});
  }

  List<Echantillon> _mockEchantillons() => List.from(mockEchantillonsGestion);
}
