import '../../../core/api_client.dart';

class EchantillonCeoService {
  Future<void> approuver(
    String id, {
    String? budgetNegociation,
    String? quantiteCibleT,
    String? noteInterne,
  }) async {
    final body = <String, dynamic>{};
    if (budgetNegociation != null) body['budget_negociation'] = budgetNegociation;
    if (quantiteCibleT != null) body['quantite_cible_t'] = quantiteCibleT;
    if (noteInterne != null) body['note_interne'] = noteInterne;
    await apiClient.patch('/api/echantillons/$id/approuver/', body);
  }

  Future<void> refuser(String id, String raisonRefus) async {
    await apiClient.patch('/api/echantillons/$id/refuser/', {'raison_refus': raisonRefus});
  }

  Future<List<dynamic>> fetchEchantillons() async {
    return await apiClient.getList('/api/echantillons/');
  }
}
