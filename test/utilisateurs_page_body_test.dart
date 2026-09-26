import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/models/enums.dart';
import 'package:project3/core/models/user_profile.dart';
import 'package:project3/core/services/resultat_service.dart';
import 'package:project3/core/utilisateurs/utilisateurs_page_body.dart';
import 'package:project3/core/utilisateurs/utilisateurs_service.dart';

class _FakeUtilisateursService extends UtilisateursService {
  final List<UserProfile> users;

  _FakeUtilisateursService(this.users);

  @override
  Future<Resultat<List<UserProfile>>> fetchUsers() async => Resultat(users);
}

UserProfile _user() => UserProfile(
  id: '11111111-1111-1111-1111-111111111111',
  email: 'degustateur@stca.tn',
  role: RoleUtilisateur.degustateur,
  nom: 'Ben Salah',
  prenom: 'Amira',
  telephone: '+216 20 000 000',
  dateCreation: '2026-08-05T10:00:00Z',
);

Future<void> _pumpPage(WidgetTester tester, {required bool peutGerer}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: UtilisateursPageBody(
          peutGerer: peutGerer,
          service: _FakeUtilisateursService([_user()]),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  // Only the chef's card has the arrow; the direction's card opens the profile
  // directly when tapped.
  if (peutGerer) {
    await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('le directeur consulte sans aucune action de gestion', (
    tester,
  ) async {
    await _pumpPage(tester, peutGerer: false);

    expect(find.byKey(const ValueKey('utilisateurs_ajouter')), findsNothing);
    expect(
      find.byKey(
        const ValueKey(
          'utilisateur_toggle_11111111-1111-1111-1111-111111111111',
        ),
      ),
      findsNothing,
    );
    expect(
      find.byKey(
        const ValueKey(
          'utilisateur_supprimer_11111111-1111-1111-1111-111111111111',
        ),
      ),
      findsNothing,
    );
    // The owner removed this sentence and the arrow for the direction.
    expect(find.textContaining('Consultation seule'), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
  });

  testWidgets(
    'le directeur touche une personne : sa fiche s’ouvre avec son statut',
    (tester) async {
      await _pumpPage(tester, peutGerer: false);

      await tester.tap(find.text(_user().nomComplet));
      await tester.pumpAndSettle();

      expect(find.text('Statut'), findsOneWidget);
      expect(find.text('Date de début'), findsOneWidget);
      expect(find.text('05/08/2026'), findsOneWidget);
    },
  );

  testWidgets('le chef dispose des trois actions de gestion', (tester) async {
    await _pumpPage(tester, peutGerer: true);

    expect(find.byKey(const ValueKey('utilisateurs_ajouter')), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey(
          'utilisateur_toggle_11111111-1111-1111-1111-111111111111',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        const ValueKey(
          'utilisateur_supprimer_11111111-1111-1111-1111-111111111111',
        ),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Consultation seule'), findsNothing);
  });
}
