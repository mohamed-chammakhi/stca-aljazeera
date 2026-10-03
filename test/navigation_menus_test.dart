import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/5_chef_degustateur/tableau_de_bord/homepage_page.dart'
    as chef;
import 'package:project3/5_chef_degustateur/tableau_de_bord/widgets/app_drawer.dart';

void main() {
  testWidgets('le menu chef Accueil ouvre le tableau de bord', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          drawer: const AppDrawer(),
          appBar: AppBar(),
          body: const Text('Évaluation des échantillons'),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(chef.HomePage), findsOneWidget);
  });
}
