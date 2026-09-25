import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/services/resultat_service.dart';
import 'package:project3/core/widgets/champ_autocomplete.dart';

void main() {
  Future<void> afficherAutocomplete(
    WidgetTester tester,
    TextEditingController controller,
  ) async {
    final valeurs = ['Chemlali', 'Chetoui', 'Oueslati'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ChampAutocomplete<String>(
                controller: controller,
                label: "Variété d'olive",
                hint: 'Chemlali, Chetoui...',
                chercher: (saisie) async {
                  final q = saisie.trim().toLowerCase();
                  if (q.isEmpty) return Resultat(valeurs);
                  return Resultat(
                    valeurs
                        .where((v) => v.toLowerCase().contains(q))
                        .toList(),
                  );
                },
                libelle: (valeur) => valeur,
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('toucher le champ vide affiche des suggestions', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await afficherAutocomplete(tester, controller);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.text('Chemlali'), findsOneWidget);
    expect(find.text('Chetoui'), findsOneWidget);
    expect(find.text('Oueslati'), findsOneWidget);
  });

  testWidgets('taper filtre la liste', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await afficherAutocomplete(tester, controller);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'chet');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(find.text('Chetoui'), findsOneWidget);
    expect(find.text('Chemlali'), findsNothing);
    expect(find.text('Oueslati'), findsNothing);
  });

  testWidgets('choisir une suggestion remplit le champ et ferme la liste', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await afficherAutocomplete(tester, controller);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chemlali'));
    await tester.pumpAndSettle();

    expect(controller.text, 'Chemlali');
    expect(find.text('Chetoui'), findsNothing);
    expect(find.text('Oueslati'), findsNothing);
  });

  testWidgets("on peut garder un texte qui n'est dans aucune suggestion", (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await afficherAutocomplete(tester, controller);

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Nouvelle variété');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();

    expect(controller.text, 'Nouvelle variété');
    expect(find.text('Chemlali'), findsNothing);
    expect(find.text('Chetoui'), findsNothing);
    expect(find.text('Oueslati'), findsNothing);
  });
}
