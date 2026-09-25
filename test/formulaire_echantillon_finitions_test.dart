import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart';
import 'package:project3/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart';
import 'package:project3/core/utils/validation_echantillon_formulaire.dart';

void main() {
  group('Validation formulaire echantillon', () {
    test('refuse un formulaire sans bouteille', () {
      expect(
        validerFormulaireEchantillon(
          nombreBouteilles: 0,
          fournisseur: 'hami',
          referencesBouteilles: const [],
        ),
        'Ajoutez au moins une bouteille.',
      );
    });

    test('refuse un formulaire sans fournisseur', () {
      expect(
        validerFormulaireEchantillon(
          nombreBouteilles: 1,
          fournisseur: ' ',
          referencesBouteilles: const ['HAM-C1'],
        ),
        'Le fournisseur est obligatoire.',
      );
    });

    test('refuse une reference bouteille vide', () {
      expect(
        validerFormulaireEchantillon(
          nombreBouteilles: 2,
          fournisseur: 'hami',
          referencesBouteilles: const ['HAM-C1', ''],
        ),
        'La référence bouteille est obligatoire pour la bouteille 2.',
      );
    });

    test('accepte seulement fournisseur et reference', () {
      expect(
        validerFormulaireEchantillon(
          nombreBouteilles: 1,
          fournisseur: 'hami',
          referencesBouteilles: const ['HAM-C1'],
        ),
        isNull,
      );
    });
  });

  testWidgets('la fiche detail affiche le nom fournisseur, pas le code interne', (
    tester,
  ) async {
    final echantillon = EchantillonCollecteur(
      id: 'sample-1',
      numero: '2026/0001',
      gouvernorat: 'Sfax',
      fournisseurId: 'supplier-1',
      codeFournisseur: 'F-0002',
      fournisseurNom: 'hami',
      referenceBouteille: 'HAM-C1',
      achatConfirme: false,
      dateAjout: DateTime(2026, 1, 1),
      collecteurId: 'collector-1',
      collecteurNom: 'Collecteur Test',
      statut: StatutCollecteur.receptionne,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              EchantillonComCard(
                echantillon: echantillon,
                onModifier: () {},
                onSupprimer: () {},
                onConfirmerAchat: null,
                onPlanifierLivraison: null,
                onScheduleArrivee: null,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
    await tester.pumpAndSettle();

    expect(find.text('hami'), findsOneWidget);
    expect(find.text('F-0002'), findsNothing);
  });
}
