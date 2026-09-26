import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/models/fournisseur.dart';
import 'package:project3/core/services/resultat_service.dart';
import 'package:project3/core/widgets/champ_autocomplete.dart';

void main() {
  Fournisseur fournisseur({
    String nom = 'hami',
    String? region,
    String? delegation,
  }) => Fournisseur(
    id: 'supplier-$nom-${region ?? ''}-${delegation ?? ''}',
    nom: nom,
    region: region,
    delegation: delegation,
  );

  group('libelleFournisseur', () {
    test('affiche seulement le nom sans lieu', () {
      expect(libelleFournisseur(fournisseur()), 'hami');
    });

    test('affiche le nom et le gouvernorat sans delegation', () {
      expect(libelleFournisseur(fournisseur(region: 'Gabes')), 'hami — Gabes');
    });

    test('affiche le nom, le gouvernorat et la delegation', () {
      expect(
        libelleFournisseur(
          fournisseur(region: 'Gabes', delegation: 'El Hamma'),
        ),
        'hami — Gabes (El Hamma)',
      );
    });

    test('ignore les blancs autour du lieu', () {
      expect(
        libelleFournisseur(
          fournisseur(region: '  Sfax ', delegation: ' Sakiet Ezzit '),
        ),
        'hami — Sfax (Sakiet Ezzit)',
      );
    });
  });

  testWidgets('la selection affiche le lieu mais garde le nom dans le champ', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    Fournisseur? choisi;

    final suggestion = fournisseur(region: 'Gabes', delegation: 'El Hamma');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChampAutocomplete<Fournisseur>(
            controller: controller,
            label: 'Fournisseur',
            chercher: (_) async => Resultat([suggestion]),
            libelle: libelleFournisseur,
            texteSelection: (f) => f.nom,
            onSelection: (f) => choisi = f,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.text('hami — Gabes (El Hamma)'), findsOneWidget);

    await tester.tap(find.text('hami — Gabes (El Hamma)'));
    await tester.pumpAndSettle();

    expect(controller.text, 'hami');
    expect(choisi?.region, 'Gabes');
    expect(choisi?.delegation, 'El Hamma');
  });
}
