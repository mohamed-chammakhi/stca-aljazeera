import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/utils/reference_bouteille.dart';
import 'package:project3/core/widgets/dialog_reference_bouteille.dart';

void main() {
  group('Reference bouteille automatique', () {
    test('assemble fournisseur, citerne et tonnage', () {
      expect(
        construireReferenceBouteille(
          fournisseur: 'S.T',
          numeroCiterne: 'C3',
          quantite: '30',
        ),
        'S.T_C3_30T',
      );
    });

    test('remplace une reference corrigee quand les sources changent', () {
      expect(
        actualiserReferenceBouteille(
          fournisseur: 'S.T',
          numeroCiterne: 'C4',
          quantite: '40',
        ),
        'S.T_C4_40T',
      );
    });

    test('attend que les trois informations soient renseignees', () {
      expect(
        construireReferenceBouteille(
          fournisseur: 'S.T',
          numeroCiterne: '',
          quantite: '30',
        ),
        isEmpty,
      );
    });

    test('supprime les espaces du nom du fournisseur', () {
      expect(
        construireReferenceBouteille(
          fournisseur: 'Domaine Bel Air',
          numeroCiterne: 'C3',
          quantite: '30',
        ),
        'DomaineBelAir_C3_30T',
      );
    });

    test('utilise le nom du fournisseur choisi, pas son code interne', () {
      final fournisseur = fournisseurPourReferenceBouteille(
        texteChampFournisseur: 'omarr',
      );

      expect(
        construireReferenceBouteille(
          fournisseur: fournisseur,
          numeroCiterne: '4h',
          quantite: '14239',
        ),
        'omarr_4h_14239T',
      );
    });
  });

  group('Confirmation de reference recalculee', () {
    test('demande confirmation en modification si la reference est automatique', () {
      final decision = referenceRecalculeeAConfirmer(
        estModification: true,
        ancienneReference: 'omarr_4h_100T',
        referenceActuelle: 'omarr_4h_14239T',
        fournisseur: 'omarr',
        numeroCiterne: '4h',
        quantite: '14239',
      );

      expect(decision, isNotNull);
      expect(decision!.ancienneReference, 'omarr_4h_100T');
      expect(decision.nouvelleReference, 'omarr_4h_14239T');
    });

    test('ne demande rien si la reference a ete saisie a la main', () {
      final decision = referenceRecalculeeAConfirmer(
        estModification: true,
        ancienneReference: 'omarr_4h_100T',
        referenceActuelle: 'REF-MANUELLE',
        fournisseur: 'omarr',
        numeroCiterne: '4h',
        quantite: '14239',
      );

      expect(decision, isNull);
    });

    test('ne demande rien en ajout', () {
      final decision = referenceRecalculeeAConfirmer(
        estModification: false,
        ancienneReference: '',
        referenceActuelle: 'omarr_4h_14239T',
        fournisseur: 'omarr',
        numeroCiterne: '4h',
        quantite: '14239',
      );

      expect(decision, isNull);
    });
  });

  group('Dialog reference recalculee', () {
    Future<ChoixReferenceBouteille?> ouvrirDialog(
      WidgetTester tester,
      String bouton,
    ) async {
      ChoixReferenceBouteille? choix;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                choix = await demanderChoixReferenceBouteilleRecalculee(
                  context,
                  ancienneReference: 'omarr_4h_100T',
                  nouvelleReference: 'omarr_4h_14239T',
                  couleurPrincipale: const Color(0xFF38835A),
                );
              },
              child: const Text('Ouvrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      expect(find.text('La référence a changé'), findsOneWidget);
      expect(find.text('Ancienne : omarr_4h_100T'), findsOneWidget);
      expect(find.text('Nouvelle : omarr_4h_14239T'), findsOneWidget);

      await tester.tap(find.text(bouton));
      await tester.pumpAndSettle();
      return choix;
    }

    testWidgets("Garder l'ancienne renvoie le choix ancienne", (tester) async {
      final choix = await ouvrirDialog(tester, "Garder l'ancienne");

      expect(choix, ChoixReferenceBouteille.garderAncienne);
    });

    testWidgets('Utiliser la nouvelle renvoie le choix nouvelle', (tester) async {
      final choix = await ouvrirDialog(tester, 'Utiliser la nouvelle');

      expect(choix, ChoixReferenceBouteille.utiliserNouvelle);
    });
  });
}
