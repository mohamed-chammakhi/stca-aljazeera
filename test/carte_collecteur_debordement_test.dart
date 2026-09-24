import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/2_collecteur/mes_echantillons/models/echantillon_collecteur.dart';
import 'package:project3/2_collecteur/mes_echantillons/services/echantillon_mock_data.dart';
import 'package:project3/2_collecteur/mes_echantillons/widgets/card/echantillon_collecteur_card.dart';

const Size _ecranTelephone = Size(360, 780);

bool _avecSectionNegociation(EchantillonCollecteur echantillon) =>
    echantillon.statut == StatutCollecteur.enNegociation ||
    echantillon.statut == StatutCollecteur.achatConfirme;

Future<void> _rendre(
  WidgetTester tester,
  EchantillonCollecteur echantillon,
) async {
  tester.view.physicalSize = _ecranTelephone;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          children: [
            EchantillonComCard(
              echantillon: echantillon,
              onModifier: echantillon.canModify ? () {} : null,
              onSupprimer: echantillon.canDelete ? () {} : null,
              onConfirmerAchat: echantillon.canConfirm ? () {} : null,
              onPlanifierLivraison: echantillon.canPlanifier ? () {} : null,
              onScheduleArrivee: echantillon.canScheduleArrivee ? () {} : null,
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _deplierToutesLesSections(
  WidgetTester tester,
  EchantillonCollecteur echantillon,
) async {
  await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
  await tester.pumpAndSettle();

  if (_avecSectionNegociation(echantillon)) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down).last);
    await tester.pumpAndSettle();
  }
}

void main() {
  group('Carte collecteur sur ecran etroit', () {
    for (final echantillon in mockEchantillons()) {
      testWidgets('${echantillon.id} tient avec toutes les sections depliees', (
        tester,
      ) async {
        await _rendre(tester, echantillon);
        await _deplierToutesLesSections(tester, echantillon);

        // La référence apparaît dans l'en-tête et dans le détail déplié.
        // Un débordement ferait déjà échouer le test à lui seul.
        expect(find.text(echantillon.referenceBouteille), findsWidgets);
      });
    }
  });
}
