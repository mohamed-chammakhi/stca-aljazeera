import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/models/echantillon.dart';
import 'package:project3/core/models/enums.dart';
import 'package:project3/core/widgets/gestion_echantillons/echantillon_card.dart';

void main() {
  testWidgets('la carte affiche la date d enregistrement avec l heure', (
    tester,
  ) async {
    final echantillon = Echantillon(
      id: 'sample-1',
      numero: '2026/0001',
      fournisseurId: 'supplier-1',
      collecteurId: 'collector-1',
      fournisseurNom: 'Domaine Test',
      collecteurNom: 'Collecteur Test',
      gouvernorat: 'Sfax',
      referenceBouteille: 'REF-001',
      statutCollecteur: StatutCollecteur.receptionne,
      dateAjout: '2026-10-03T08:41:00Z',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EchantillonCard(
            echantillon: echantillon,
            onToggleRecu: () async => false,
          ),
        ),
      ),
    );

    await tester.tap(find.text('REF-001').first);
    await tester.pumpAndSettle();

    expect(find.text('Enregistré le'), findsOneWidget);
    expect(
      find.textContaining(RegExp(r'03/10/2026 \d{2}:\d{2}')),
      findsOneWidget,
    );
  });
}
