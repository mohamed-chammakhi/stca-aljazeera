import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/models/echantillon.dart';
import 'package:project3/core/services/gestion_echantillons_service.dart';
import 'package:project3/core/services/resultat_service.dart';
import 'package:project3/core/widgets/messagerie/conversation_page.dart';

Echantillon _bouteille() => Echantillon.fromJson({
  'id': '6e5f3d24-adac-4136-b6bb-e9e9cbe7ebf4',
  'numero': '2026/0012',
  'fournisseur_id': '',
  'collecteur_id': '',
  'fournisseur_nom': 'hami',
  'gouvernorat': 'Gabes',
  'delegation': 'Gabes Ouest',
  'reference_bouteille': 'hami_4h_120T',
  'num_citerne': '4h',
  'quantite_estimee': '120',
  'variete': 'Chemlali',
  'statut_collecteur': 'receptionne',
  'date_ajout': '2026-09-24T10:00:00Z',
});

class _FauxService extends GestionEchantillonsService {
  final List<(String?, int?)> appels = [];

  _FauxService() : super(uniquementRecusPhysiquement: false);

  @override
  Future<Resultat<List<Echantillon>>> fetchEchantillons({
    String? recherche,
    int? limite,
  }) async {
    appels.add((recherche, limite));
    return Resultat([_bouteille()]);
  }
}

Future<void> _ouvrir(WidgetTester tester, _FauxService service) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: choixBouteillePourTest(service: service)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets(
    'à l’ouverture : les 15 plus récentes ; en tapant : recherche serveur',
    (tester) async {
      final service = _FauxService();
      await _ouvrir(tester, service);

      expect(service.appels.first, ('', 15));

      await tester.enterText(find.byType(TextField), 'hami chemlali');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      expect(service.appels.last, ('hami chemlali', 15));
    },
  );

  testWidgets(
    'chaque ligne montre la référence et les détails de la bouteille',
    (tester) async {
      await _ouvrir(tester, _FauxService());

      expect(find.text('hami_4h_120T'), findsOneWidget);
      expect(find.textContaining('hami — Gabes'), findsWidgets);
      expect(find.textContaining('Chemlali'), findsWidgets);
      expect(find.textContaining('120'), findsWidgets);
    },
  );

  testWidgets(
    'clavier ouvert sur 360 × 640 : pas de débordement, titre visible',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.reset);

      await _ouvrir(tester, _FauxService());

      expect(tester.takeException(), isNull);
      expect(find.text('Citer une bouteille'), findsOneWidget);
      final haut = tester.getTopLeft(find.text('Citer une bouteille')).dy;
      expect(haut, greaterThanOrEqualTo(0));
    },
  );
}
