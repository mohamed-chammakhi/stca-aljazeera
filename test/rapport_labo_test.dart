import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/analyses/ligne_analyse_labo.dart';
import 'package:project3/core/analyses/ligne_analyse_labo_service.dart';
import 'package:project3/core/analyses/normes_coi.dart';
import 'package:project3/core/analyses/rapport_labo.dart';
import 'package:project3/core/analyses/widgets/tableau_rapport_labo.dart';

const Map<String, double?> _rapport188 = {
  'acidite': 0.30,
  'indice_peroxyde': 9.71,
  'k232': 2.02,
  'k270': 0.12,
  'delta_k': 0.003,
  'humidite': 0.06,
  'impuretes': 0.03,
  'ecn42': 0.052,
  'cholesterol': 0.09,
  'brassicasterol': 0.00,
  'campesterol': 3.30,
  'stigmasterol': 0.64,
  'beta_sitosterol_apparent': 95.00,
  'delta_7_stigmastenol': 0.36,
  'delta_7_avenasterol': 0.61,
  'erythrodiol_uvaol': 2.00,
  'acide_palmitique': 14.65,
  'acide_palmitoleique': 1.61,
  'acide_heptadecanoique': 0.05,
  'acide_heptadecenoique': 0.09,
  'acide_stearique': 2.56,
  'acide_oleique': 64.06,
  'acide_linoleique': 15.68,
  'acide_linolenique': 0.66,
  'acide_arachidique': 0.39,
  'acide_gadoleique': 0.21,
  'trans_c18_1': 0.02,
  'trans_c18_2_c18_3': 0.02,
};

void main() {
  test('LigneAnalyseLabo lit la référence bouteille envoyée par l\'API', () {
    final ligne = LigneAnalyseLabo.fromJson({
      'id': 'analyse-1',
      'echantillon_id': 'sample-1',
      'numero': '2026/0042',
      'echantillon_ref': 'S.T_C3_30T',
      'echantillon_nom': 'Chemlali - Sfax',
      'technicien_nom': 'Technicien Labo',
      'statut': 'soumise',
    });

    expect(ligne.referenceBouteille, 'S.T_C3_30T');
    expect(ligne.toJson()['echantillon_ref'], 'S.T_C3_30T');
  });

  group('RapportLabo.fromJson', () {
    test('conserve les 28 valeurs du certificat 188-2026', () {
      final rapport = RapportLabo.fromJson({
        ..._rapport188,
        'numero_certificat': '188-2026',
        'date_analyse': '2026-03-18T10:30:00Z',
      });

      expect(rapport.valeurs.length, 28);
      expect(rapport.valeurs.values.whereType<double>().length, 28);
      for (final parametre in kTousParametres) {
        expect(
          rapport.valeur(parametre.cle),
          _rapport188[parametre.cle],
          reason: '${parametre.cle} a été perdue ou altérée',
        );
      }
      expect(rapport.classification, 'Extra Vierge');
      expect(rapport.dateAnalyse, '18/03/2026');
    });

    test('lit acidite_libre quand acidite est absente', () {
      final rapport = RapportLabo.fromJson({
        'acidite_libre': '0,30',
        'indice_peroxyde': 9.71,
        'k232': 2.02,
        'k270': 0.12,
      });

      expect(rapport.valeur('acidite'), 0.30);
      expect(rapport.classification, 'Extra Vierge');
    });

    testWidgets('sans stérols, garde le classement et masque leur tableau', (
      tester,
    ) async {
      final rapport = RapportLabo.fromJson({
        'acidite': 0.30,
        'indice_peroxyde': 9.71,
        'k232': 2.02,
        'k270': 0.12,
      });

      expect(rapport.classification, 'Extra Vierge');
      expect(rapport.horsNormes, isEmpty);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: TableauRapportLabo(
                rapport: rapport,
                groupeParTableau: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Résultats principaux'), findsOneWidget);
      expect(find.text('Composition en stérols'), findsNothing);
      expect(find.text('Acides gras'), findsNothing);
    });

    test('un campestérol anormal alerte sans changer le classement', () {
      final rapport = RapportLabo.fromJson({
        ..._rapport188,
        'campesterol': 5.20,
      });

      expect(rapport.classification, 'Extra Vierge');
      expect(rapport.horsNormes.map((p) => p.cle), ['campesterol']);
    });
  });

  test('le service conserve une ligne en attente quand analyse est null', () {
    final ligne = LigneAnalyseLaboService().ligneFromApi({
      'id': 'sample-1',
      'numero': '2026/0042',
      'reference_bouteille': 'BOUT-42',
      'variete': 'Chemlali',
      'gouvernorat': 'Sfax',
      'analyse': null,
    });

    expect(ligne.rapport, isNull);
    expect(ligne.statut, StatutAnalyse.enAttente);
    expect(ligne.numero, '2026/0042');
    expect(ligne.referenceBouteille, 'BOUT-42');
    expect(ligne.echantillonNom, contains('BOUT-42'));
  });

  test('le service privilégie la référence envoyée avec l\'analyse', () {
    final ligne = LigneAnalyseLaboService().ligneFromApi({
      'id': 'sample-avec-analyse',
      'numero': '2026/0044',
      'reference_bouteille': 'ANCIENNE-REF',
      'analyse': {
        'id': 'analyse-1',
        'echantillon_ref': 'S.T_C3_30T',
        'statut': 'soumis',
        'technicien_nom': 'Technicien Labo',
      },
    });

    expect(ligne.echantillonId, 'sample-avec-analyse');
    expect(ligne.numero, '2026/0044');
    expect(ligne.referenceBouteille, 'S.T_C3_30T');
  });

  test('le service masque le rapport tant que l\'analyse est en cours', () {
    final ligne = LigneAnalyseLaboService().ligneFromApi({
      'id': 'sample-2',
      'numero': '2026/0043',
      'reference_bouteille': 'BOUT-43',
      'statut_labo': 'en_cours',
      'analyse': {
        'id': 'analyse-brouillon-1',
        'statut': 'en_cours',
        'technicien_nom': 'Technicien Labo',
        'acidite': '0.30',
        'indice_peroxyde': '9.71',
        'k232': '2.02',
        'k270': '0.12',
      },
    });

    expect(ligne.statut, StatutAnalyse.enAttente);
    expect(ligne.rapport, isNull);
  });
}
