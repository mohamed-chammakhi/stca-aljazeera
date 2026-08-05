import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/api_client.dart';
import 'package:project3/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart';

class _ApiDegustateurFausse extends ApiClient {
  final List<String> appels = [];

  @override
  Future<Map<String, dynamic>> get(String path) async {
    appels.add(path);
    switch (Uri.parse(path).path) {
      case '/api/degustateur/dashboard/pipeline/':
        return {
          'receptionne': 1,
          'non_evaluee': 2,
          'en_cours': 3,
          'soumise': 4,
        };
      case '/api/degustateur/dashboard/presence/':
        return {
          'present': 2,
          'manquee': 1,
          'prochaine_titre': 'Session A',
          'prochaine_date': '2026-08-06',
          'prochaine_lieu': 'Salle A',
          'prochaine_countdown': '1j',
        };
      case '/api/degustateur/dashboard/delai/':
        return {
          'mon_delai_moyen': 1.5,
          'panel_moyen': 2.25,
          'nb_evals': 1,
          'points': [
            {'date': '2026-08-03', 'delai': 1},
          ],
        };
      case '/api/degustateur/activite/':
        return {
          'count': 1,
          'results': [
            {
              'type': 'evaluation',
              'date': '2026-08-03T10:30:00Z',
              'description': 'Évaluation — ECH-1 (soumis)',
            },
          ],
        };
    }
    throw StateError('GET inattendu: $path');
  }

  @override
  Future<List<dynamic>> getList(String path) async {
    appels.add(path);
    switch (Uri.parse(path).path) {
      case '/api/degustateur/dashboard/urgentes/':
        return [
          {
            'id': 'ech-1',
            'reference': 'ECH-1',
            'collecteur_nom': 'Collecteur',
            'fournisseur_nom': 'Fournisseur',
            'jours_en_attente': 2,
          },
        ];
      case '/api/degustateur/dashboard/classifications/':
        return [
          {
            'label': 'Aug 2026',
            'extra_vierge': 1,
            'vierge': 2,
            'lampante': 3,
          },
        ];
    }
    throw StateError('GET list inattendu: $path');
  }
}

void main() {
  test('branche les six routes dégustateur construites sur leur contrat Django', () async {
    final api = _ApiDegustateurFausse();
    final service = DashboardDegustateurService(api: api);
    final debut = DateTime(2026, 8, 1);
    final fin = DateTime(2026, 8, 5);

    final urgentes = await service.fetchUrgentes();
    final pipeline = await service.fetchPipeline();
    final classifications = await service.fetchClassifications(
      dateDebut: debut,
      dateFin: fin,
    );
    final presence = await service.fetchPresence(
      dateDebut: debut,
      dateFin: fin,
    );
    final delai = await service.fetchDelai(dateDebut: debut, dateFin: fin);
    final activite = await service.fetchActivite(
      dateDebut: debut,
      dateFin: fin,
      offset: 5,
      pageSize: 10,
    );

    expect([
      urgentes,
      pipeline,
      classifications,
      presence,
      delai,
      activite,
    ].every((resultat) => !resultat.estDemonstration), isTrue);
    expect(urgentes.donnees.single.id, 'ech-1');
    expect(pipeline.donnees.soumise, 4);
    expect(classifications.donnees.single.lampante, 3);
    expect(presence.donnees.present, 2);
    expect(delai.donnees.monDelaiMoyen, 1.5);
    expect(delai.donnees.points.single.monDelai, 1);
    expect(delai.donnees.points.single.panelMoyen, 2.25);
    expect(activite.donnees.total, 1);
    expect(activite.donnees.items.single.action, 'Évaluation — ECH-1 (soumis)');
    expect(activite.donnees.items.single.horodatage, '2026-08-03T10:30:00Z');

    expect(api.appels, hasLength(6));
    for (final appel in api.appels.where((appel) {
      final chemin = Uri.parse(appel).path;
      return chemin.endsWith('/classifications/') ||
          chemin.endsWith('/presence/') ||
          chemin.endsWith('/delai/') ||
          chemin.endsWith('/activite/');
    })) {
      final parametres = Uri.parse(appel).queryParameters;
      expect(parametres['date_debut'], '2026-08-01');
      expect(parametres['date_fin'], '2026-08-05');
    }
    final appelActivite = Uri.parse(
      api.appels.singleWhere((appel) => Uri.parse(appel).path.endsWith('/activite/')),
    );
    expect(appelActivite.queryParameters['offset'], '5');
    expect(appelActivite.queryParameters['limit'], '10');
  });
}
