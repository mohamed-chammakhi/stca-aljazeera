import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/analyses/ligne_analyse_labo.dart';
import 'package:project3/core/widgets/analyse_labo/analyse_card.dart';

LigneAnalyseLabo _ligne({required bool recuPhysiquement}) => LigneAnalyseLabo(
  id: 'sample-1',
  echantillonId: 'sample-1',
  numero: '2026/0001',
  referenceBouteille: 'B-001',
  echantillonNom: 'Chemlali - Sfax',
  technicienNom: 'En attente laboratoire',
  statut: StatutAnalyse.enAttente,
  recuPhysiquement: recuPhysiquement,
);

void main() {
  testWidgets(
    'un échantillon non reçu désactive urgent et affiche son statut',
    (tester) async {
      var urgentAppele = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyseCard(
              analyse: _ligne(recuPhysiquement: false),
              onUrgentLabo: () => urgentAppele = true,
            ),
          ),
        ),
      );

      expect(find.text('Pas encore reçu dans la société'), findsOneWidget);
      expect(
        find.text('Disponible après la réception physique'),
        findsOneWidget,
      );
      await tester.tap(find.text('Urgent'));
      expect(urgentAppele, isFalse);
    },
  );

  testWidgets('un échantillon reçu sans analyse est en attente', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalyseCard(
            analyse: _ligne(recuPhysiquement: true),
            onUrgentLabo: () {},
          ),
        ),
      ),
    );

    expect(find.text("En attente d'analyse"), findsOneWidget);
  });
}
