import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/widgets/saisie_protegee.dart';

void main() {
  Widget appTest() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => SaisieProtegee(
                    child: AlertDialog(
                      title: const Text('Formulaire protege'),
                      content: const TextField(
                        key: Key('champ-saisie'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                      ],
                    ),
                  ),
                ),
                child: const Text('Ouvrir protege'),
              ),
              ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => SaisieProtegee(
                    child: AlertDialog(
                      title: const Text('Formulaire direct'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Fermer direct'),
                        ),
                      ],
                    ),
                  ),
                ),
                child: const Text('Ouvrir direct'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('protege le formulaire contre les fermetures accidentelles', (
    tester,
  ) async {
    await tester.pumpWidget(appTest());

    await tester.tap(find.text('Ouvrir protege'));
    await tester.pumpAndSettle();
    expect(find.text('Formulaire protege'), findsOneWidget);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Formulaire protege'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Quitter sans enregistrer ?'), findsOneWidget);

    await tester.tap(find.text('Continuer la saisie'));
    await tester.pumpAndSettle();
    expect(find.text('Formulaire protege'), findsOneWidget);
    expect(find.text('Quitter sans enregistrer ?'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quitter'));
    await tester.pumpAndSettle();
    expect(find.text('Formulaire protege'), findsNothing);
  });

  testWidgets('la fermeture explicite par Navigator.pop reste directe', (
    tester,
  ) async {
    await tester.pumpWidget(appTest());

    await tester.tap(find.text('Ouvrir direct'));
    await tester.pumpAndSettle();
    expect(find.text('Formulaire direct'), findsOneWidget);

    await tester.tap(find.text('Fermer direct'));
    await tester.pumpAndSettle();
    expect(find.text('Formulaire direct'), findsNothing);
    expect(find.text('Quitter sans enregistrer ?'), findsNothing);
  });
}
