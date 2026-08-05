import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/services/resultat_service.dart';
import 'package:project3/core/widgets/bandeau_demonstration.dart';

void main() {
  group('avecSecours', () {
    test(
      'retourne les données réelles sans marqueur de démonstration',
      () async {
        final resultat = await avecSecours(() async => 42, () => -1);

        expect(resultat.donnees, 42);
        expect(resultat.estDemonstration, isFalse);
        expect(resultat.messageErreur, isNull);
      },
    );

    test('signale les données de secours en développement', () async {
      final resultat = await avecSecours<int>(
        () async => throw StateError('serveur indisponible'),
        () => 7,
      );

      expect(resultat.donnees, 7);
      expect(resultat.estDemonstration, isTrue);
      expect(resultat.messageErreur, contains('serveur indisponible'));
    });
  });

  testWidgets('le bandeau annonce la démonstration et permet de réessayer', (
    tester,
  ) async {
    var essais = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BandeauDemonstration(onReessayer: () => essais++)),
      ),
    );

    expect(
      find.text('Données de démonstration — serveur injoignable'),
      findsOneWidget,
    );
    await tester.tap(find.text('Réessayer'));
    expect(essais, 1);
  });
}
