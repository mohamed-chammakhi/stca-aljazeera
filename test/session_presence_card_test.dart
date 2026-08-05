import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/3_degustateur/sessions_degustation/widgets/session_card.dart'
    as degustateur;
import 'package:project3/5_chef_degustateur/sessions_degustation/widgets/session_card.dart'
    as chef;
import 'package:project3/core/models/enums.dart';
import 'package:project3/core/models/session_degustation.dart';

SessionDegustation _session() => SessionDegustation(
  id: 'session-test',
  titre: 'Session de test',
  date: '05/08/2026',
  heure: '09:00',
  lieu: 'Salle A',
  statut: StatutSession.planifiee,
  createdBy: 'user-test',
  createdAt: '2026-08-05T08:00:00Z',
);

Future<void> _verifierEchec(
  WidgetTester tester,
  Widget card,
  StateError erreur,
) async {
  final erreursRemontees = <Object>[];
  final execution = runZonedGuarded<Future<void>>(() async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: card)));

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.text('Présence confirmée'), findsNothing);

    await tester.tap(find.byIcon(Icons.check_circle_outline));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.text('Présence confirmée'), findsNothing);
  }, (error, stack) => erreursRemontees.add(error));
  await execution;

  expect(erreursRemontees, contains(same(erreur)));
}

void main() {
  testWidgets('un échec de confirmation ne coche pas la carte dégustateur', (
    tester,
  ) async {
    final erreur = StateError('serveur indisponible');
    await _verifierEchec(
      tester,
      degustateur.SessionCard(
        session: _session(),
        onConfirmerPresence: () async => throw erreur,
      ),
      erreur,
    );
  });

  testWidgets('un échec de confirmation ne coche pas la carte chef', (
    tester,
  ) async {
    final erreur = StateError('serveur indisponible');
    await _verifierEchec(
      tester,
      chef.SessionCard(
        session: _session(),
        onConfirmerPresence: () async => throw erreur,
      ),
      erreur,
    );
  });
}
