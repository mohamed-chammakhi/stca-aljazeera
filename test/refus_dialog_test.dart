// Refus scindé — tests d'interface.
//
// La logique serveur est déjà couverte côté Django. Ce qui manque ici, c'est la
// preuve que les fenêtres s'affichent, réagissent aux choix et rendent bien ce
// que la page va envoyer à l'API.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/1_ceo/validation_achats/widgets/refus_dialog.dart';
import 'package:project3/core/widgets/marqueur_renegocie.dart';

/// Ouvre la fenêtre et rend la décision au moment où elle se ferme.
Future<DecisionRefus?> _ouvrirRefus(
  WidgetTester tester, {
  int nbRenegociations = 0,
  String? quantiteActuelle,
}) async {
  DecisionRefus? resultat;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              resultat = await showDialog<DecisionRefus>(
                context: context,
                builder: (_) => RefusDecisionDialog(
                  referenceBouteille: 'CHEMLALI-K7',
                  nbRenegociations: nbRenegociations,
                  quantiteActuelle: quantiteActuelle,
                ),
              );
            },
            child: const Text('ouvrir'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('ouvrir'));
  await tester.pumpAndSettle();
  return resultat;
}

void main() {
  group('Fenêtre de refus', () {
    testWidgets('s\'affiche avec les deux options', (tester) async {
      await _ouvrirRefus(tester);

      expect(find.text('Renvoyer en négociation'), findsOneWidget);
      expect(find.text('Refus définitif'), findsOneWidget);
      expect(find.text('CHEMLALI-K7'), findsOneWidget);
    });

    testWidgets('ouvre les champs de contre-proposition par défaut',
        (tester) async {
      await _ouvrirRefus(tester);

      expect(find.text('Intervalle de prix'), findsOneWidget);
      expect(find.text('Quantité souhaitée'), findsOneWidget);
      expect(find.text('Date de livraison souhaitée'), findsOneWidget);
    });

    testWidgets('le refus définitif remplace les champs par l\'avertissement',
        (tester) async {
      await _ouvrirRefus(tester);
      await tester.tap(find.text('Refus définitif'));
      await tester.pumpAndSettle();

      expect(find.text('Intervalle de prix'), findsNothing);
      expect(find.text('Quantité souhaitée'), findsNothing);
      expect(
        find.textContaining('rien ne permet de revenir en arrière'),
        findsOneWidget,
      );
    });

    testWidgets('reprend la quantité déjà négociée', (tester) async {
      await _ouvrirRefus(tester, quantiteActuelle: '28');
      expect(find.widgetWithText(TextField, '28'), findsOneWidget);
    });

    testWidgets('refuse de valider sans raison', (tester) async {
      await _ouvrirRefus(tester);
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();

      // La fenêtre reste ouverte et explique ce qui manque.
      expect(find.textContaining('La raison est obligatoire'), findsOneWidget);
      expect(find.text('Renvoyer en négociation'), findsOneWidget);
    });

    testWidgets('refuse un prix haut inférieur au prix bas', (tester) async {
      await _ouvrirRefus(tester);
      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), '7.50');
      await tester.enterText(champs.at(1), '7.00');
      await tester.enterText(champs.at(3), 'Trop cher');
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('doit être supérieur au prix bas'),
        findsOneWidget,
      );
    });

    testWidgets('rend une contre-proposition complète', (tester) async {
      DecisionRefus? decision;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  decision = await showDialog<DecisionRefus>(
                    context: context,
                    builder: (_) => const RefusDecisionDialog(
                      referenceBouteille: 'CHEMLALI-K7',
                    ),
                  );
                },
                child: const Text('ouvrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('ouvrir'));
      await tester.pumpAndSettle();

      final champs = find.byType(TextField);
      await tester.enterText(champs.at(0), '7.00');
      await tester.enterText(champs.at(1), '7.40');
      await tester.enterText(champs.at(2), '28');
      await tester.enterText(champs.at(3), 'Prix trop élevé');
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();

      expect(decision, isNotNull);
      expect(decision!.definitif, isFalse);
      expect(decision!.contrePrix, '7.00');
      expect(decision!.contrePrixMax, '7.40');
      expect(decision!.quantiteCibleT, '28');
      expect(decision!.raison, 'Prix trop élevé');
      expect(decision!.prixLisible, '7.00 – 7.40 TND/L');
    });

    testWidgets('un prix ferme se lit sans intervalle', (tester) async {
      const decision = DecisionRefus(
        definitif: false,
        raison: 'x',
        contrePrix: '7.00',
        contrePrixMax: '',
      );
      expect(decision.prixLisible, '7.00 TND/L');
    });
  });

  group('Confirmation', () {
    Future<void> montrer(WidgetTester tester, DecisionRefus d,
        {int tours = 0}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmerRefusDialog(
              referenceBouteille: 'CHEMLALI-K7',
              decision: d,
              nbRenegociations: tours,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('la renégociation récapitule et annonce le tour suivant',
        (tester) async {
      await montrer(
        tester,
        const DecisionRefus(
          definitif: false,
          raison: 'Trop cher',
          contrePrix: '7.00',
          contrePrixMax: '7.40',
          quantiteCibleT: '28',
        ),
        tours: 2,
      );

      expect(find.text('Renvoyer en négociation ?'), findsOneWidget);
      expect(find.text('7.00 – 7.40 TND/L'), findsOneWidget);
      expect(find.text('28 T'), findsOneWidget);
      expect(find.text('3ᵉ'), findsOneWidget);
      expect(find.text('Envoyer'), findsOneWidget);
    });

    testWidgets('le refus définitif avertit et nomme son bouton',
        (tester) async {
      await montrer(
        tester,
        const DecisionRefus(definitif: true, raison: 'Qualité insuffisante'),
      );

      expect(find.text('Refus définitif ?'), findsOneWidget);
      expect(find.textContaining('irréversible'), findsOneWidget);
      expect(find.text('Qualité insuffisante'), findsOneWidget);
      // Le bouton dit ce qu'il fait, pas « Confirmer ».
      expect(find.text('Refuser définitivement'), findsOneWidget);
      expect(find.text('Confirmer'), findsNothing);
    });
  });

  group('Marqueur Renégocié', () {
    Future<void> montrer(WidgetTester tester, int n) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: MarqueurRenegocie(nombre: n))),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('invisible tant qu\'aucun tour n\'a eu lieu', (tester) async {
      await montrer(tester, 0);
      expect(find.byIcon(Icons.replay), findsNothing);
    });

    testWidgets('affiche le compteur', (tester) async {
      await montrer(tester, 2);
      expect(find.text('Renégocié ×2'), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('reste contourné à 2 tours, devient plein à 3', (tester) async {
      const orange = Color(0xFFD07B2F);
      const creme = Color(0xFFFEF3E8);

      await montrer(tester, 2);
      var deco = tester
          .widget<Container>(find.byType(Container).first)
          .decoration as BoxDecoration;
      expect(deco.color, creme);

      await montrer(tester, 3);
      deco = tester
          .widget<Container>(find.byType(Container).first)
          .decoration as BoxDecoration;
      expect(deco.color, orange);
    });
  });
}
