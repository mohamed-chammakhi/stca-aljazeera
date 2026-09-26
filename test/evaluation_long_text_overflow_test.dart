import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/3_degustateur/evaluation_echantillons/formulaire_evaluation.dart';
import 'package:project3/core/models/echantillon_evaluation.dart';
import 'package:project3/core/widgets/evaluation_echantillons/echantillon_card.dart';

const Size _ecranTelephone = Size(360, 780);

String get _long => List.filled(300, 'A').join();

void main() {
  testWidgets('la carte evaluation accepte des valeurs de 300 caracteres', (
    tester,
  ) async {
    tester.view.physicalSize = _ecranTelephone;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final echantillon = Echantillon(
      id: 'sample-long',
      referenceBouteille: _long,
      numero: '2026/0001',
      fournisseur: _long,
      dateArriveeEchantillon: '2026-05-20T09:00:00Z',
      variete: _long,
      gouvernorat: _long,
      delegation: _long,
      quantite: _long,
      collecteur: _long,
      statut: StatutEchantillon.enAttente,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              EchantillonCard(
                echantillon: echantillon,
                onAction: () {},
                onVoir: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('la fiche evaluation accepte des valeurs de 300 caracteres', (
    tester,
  ) async {
    tester.view.physicalSize = _ecranTelephone;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: FormulaireEvaluationPage(
          echantillonId: '2026/0001',
          fournisseur: _long,
          variete: _long,
          origine: _long,
          dateArrivee: '2026-05-20T09:00:00Z',
          readOnly: true,
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
