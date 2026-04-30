import '../../../../core/models/echantillon.dart';
import '../models/mock_echantillons.dart';

class GestionEchantillonsChefService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<List<Echantillon>> fetchEchantillons() async {
    // TODO: replace with: return _api.get('/echantillons/?role=chef_degustateur');
    return _mockEchantillons();
  }

  Future<Echantillon> createEchantillon(Echantillon e) async {
    // TODO: replace with: return _api.post('/echantillons/', e.toJson());
    return e;
  }

  Future<Echantillon> updateEchantillon(Echantillon e) async {
    // TODO: replace with: return _api.put('/echantillons/${e.id}/', e.toJson());
    return e;
  }

  Future<void> deleteEchantillon(String id) async {
    // TODO: replace with: await _api.delete('/echantillons/$id/');
  }

  Future<void> toggleRecuPhysiquement(String id, bool value) async {
    // TODO: replace with: await _api.patch('/echantillons/$id/', {'recu_physiquement': value});
  }

  // TODO: remove when backend is ready
  List<Echantillon> _mockEchantillons() => List.from(mockEchantillonsGestion);
}
