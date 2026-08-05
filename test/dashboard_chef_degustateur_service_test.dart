import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/api_client.dart';
import 'package:project3/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart';

class _ApiChefFausse extends ApiClient {
  final List<String> appels = [];

  @override
  Future<Map<String, dynamic>> get(String path) async {
    appels.add(path);
    switch (Uri.parse(path).path) {
      case '/api/chef/dashboard/pipeline/':
        return {'receptionne': 1, 'en_attente_eval': 2, 'en_cours': 3, 'soumis': 4};
      case '/api/chef/dashboard/delai/':
        return {
          'membres': [
            {'nom': 'Membre A', 'delai_moyen': 1.5, 'panel_moyen': 2.0},
          ],
          'panel_moyen': 2,
        };
      case '/api/chef/dashboard/alignement/':
        return {
          'membres': [
            {'nom': 'Membre A', 'divergence_pct': 4.5},
          ],
        };
      case '/api/chef/dashboard/presence/':
        return {
          'present': 3,
          'manquee': 1,
          'prochaine_titre': null,
          'prochaine_date': null,
          'prochaine_lieu': null,
          'prochaine_countdown': null,
        };
      case '/api/chef/dashboard/activite/':
        return {
          'count': 1,
          'results': [
            {
              'id': 'act-1',
              'action': 'Évaluation soumise',
              'horodatage': '2026-08-05T10:00:00Z',
              'type': 'evaluation',
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
      case '/api/chef/dashboard/urgentes/':
        return [
          {
            'id': 'ech-1',
            'reference': 'ECH-1',
            'collecteur_nom': 'Collecteur',
            'fournisseur_nom': 'Fournisseur',
            'jours_en_attente': 2,
          },
        ];
      case '/api/chef/dashboard/sessions-en-attente/':
        return [
          {
            'id': 'session-1',
            'titre': 'Session',
            'date': '2026-08-06',
            'heure': null,
            'lieu': 'Salle A',
            'propose_par': 'Chef',
          },
        ];
      case '/api/chef/dashboard/classifications/':
        return [
          {'label': 'Aug 2026', 'extra_vierge': 1, 'vierge': 2, 'lampante': 3},
        ];
      case '/api/chef/dashboard/urgentes-ceo/':
        return [
          {
            'id': 'ech-2',
            'reference': 'ECH-2',
            'collecteur_nom': 'Collecteur',
            'fournisseur_nom': 'Fournisseur',
          },
        ];
    }
    throw StateError('GET list inattendu: $path');
  }
}

void main() {
  test('branche les neuf routes du tableau de bord chef et leurs paramètres', () async {
    final api = _ApiChefFausse();
    final service = DashboardChefDegustateurService(api: api);
    final debut = DateTime(2026, 8, 1);
    final fin = DateTime(2026, 8, 5);

    final pipeline = await service.fetchPipeline();
    final urgentes = await service.fetchUrgentes();
    final sessions = await service.fetchSessionsEnAttente();
    final delai = await service.fetchDelai(dateDebut: debut, dateFin: fin);
    final alignement = await service.fetchAlignement(dateDebut: debut, dateFin: fin);
    final classifications = await service.fetchClassifications(dateDebut: debut, dateFin: fin);
    final urgentesCeo = await service.fetchUrgentesCeo();
    final presence = await service.fetchPresence(dateDebut: debut, dateFin: fin);
    final activite = await service.fetchActivite(
      dateDebut: debut,
      dateFin: fin,
      offset: 5,
      pageSize: 10,
    );

    expect([
      pipeline,
      urgentes,
      sessions,
      delai,
      alignement,
      classifications,
      urgentesCeo,
      presence,
      activite,
    ].every((resultat) => !resultat.estDemonstration), isTrue);
    expect(pipeline.donnees.soumis, 4);
    expect(urgentes.donnees.single.joursEnAttente, 2);
    expect(sessions.donnees.single.heure, '');
    expect(delai.donnees.panelMoyen, 2);
    expect(alignement.donnees.membres.single.divergencePct, 4.5);
    expect(classifications.donnees.single.lampante, 3);
    expect(urgentesCeo.donnees.single.id, 'ech-2');
    expect(presence.donnees.present, 3);
    expect(activite.donnees.items.single.id, 'act-1');
    expect(activite.donnees.total, 1);

    expect(api.appels, hasLength(9));
    for (final appel in api.appels.where((appel) {
      final chemin = Uri.parse(appel).path;
      return chemin.endsWith('/delai/') ||
          chemin.endsWith('/alignement/') ||
          chemin.endsWith('/classifications/') ||
          chemin.endsWith('/presence/') ||
          chemin.endsWith('/activite/');
    })) {
      expect(Uri.parse(appel).queryParameters['date_debut'], '2026-08-01');
      expect(Uri.parse(appel).queryParameters['date_fin'], '2026-08-05');
    }
    final appelActivite = Uri.parse(
      api.appels.singleWhere((appel) => Uri.parse(appel).path.endsWith('/activite/')),
    );
    expect(appelActivite.queryParameters['offset'], '5');
    expect(appelActivite.queryParameters['limit'], '10');
  });
}
