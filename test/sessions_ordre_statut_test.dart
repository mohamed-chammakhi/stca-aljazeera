import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/3_degustateur/sessions_degustation/sessions_degustation_page.dart'
    as degustateur_page;
import 'package:project3/5_chef_degustateur/sessions_degustation/sessions_degustation_page.dart'
    as chef_page;
import 'package:project3/core/models/session_degustation.dart';
import 'package:project3/core/services/resultat_service.dart';
import 'package:project3/core/services/sessions_service.dart';
import 'package:project3/core/widgets/sessions_degustation/session_card.dart';

class _SessionsService extends SessionsService {
  final List<SessionDegustation> data;

  const _SessionsService(this.data, {super.peutValider});

  @override
  Future<Resultat<List<SessionDegustation>>> fetchSessions() async =>
      Resultat(data);
}

SessionDegustation _session({
  required String id,
  required String titre,
  required String date,
  required String heure,
  required StatutSession statut,
  String createdAt = '2099-01-01T08:00:00Z',
}) {
  return SessionDegustation(
    id: id,
    titre: titre,
    date: date,
    heure: heure,
    lieu: 'Salle A',
    statut: statut,
    createdBy: 'user-test',
    createdAt: createdAt,
  );
}

Future<void> _pumpPage(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(700, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(home: page));
  await tester.pump();
}

void _expectVerticalOrder(List<String> titres, WidgetTester tester) {
  var previousTop = -1.0;
  for (final titre in titres) {
    final top = tester.getTopLeft(find.text(titre)).dy;
    expect(top, greaterThan(previousTop));
    previousTop = top;
  }
}

void main() {
  final unsortedSessions = [
    _session(
      id: 'ancienne',
      titre: 'Session ancienne',
      date: '10/01/2099',
      heure: '09:00',
      statut: StatutSession.planifiee,
    ),
    _session(
      id: 'future',
      titre: 'Session future',
      date: '20/01/2099',
      heure: '09:00',
      statut: StatutSession.planifiee,
    ),
    _session(
      id: 'tie-old',
      titre: 'Session meme date ancienne creation',
      date: '15/01/2099',
      heure: '09:00',
      statut: StatutSession.planifiee,
      createdAt: '2099-01-01T08:00:00Z',
    ),
    _session(
      id: 'tie-new',
      titre: 'Session meme date recente creation',
      date: '15/01/2099',
      heure: '09:00',
      statut: StatutSession.planifiee,
      createdAt: '2099-01-02T08:00:00Z',
    ),
  ];

  test('le tri place la session creee a sa position chronologique', () {
    final creee = _session(
      id: 'created',
      titre: 'Session creee',
      date: '18/01/2099',
      heure: '09:00',
      statut: StatutSession.planifiee,
      createdAt: '2099-01-03T08:00:00Z',
    );

    final tries = trierSessionsDegustation([...unsortedSessions, creee]);

    expect(tries.map((session) => session.titre), [
      'Session future',
      'Session creee',
      'Session meme date recente creation',
      'Session meme date ancienne creation',
      'Session ancienne',
    ]);
  });

  test('une session sans heure est triee a la fin de sa journee', () {
    final sansHeure = _session(
      id: 'sans-heure',
      titre: 'Session sans heure',
      date: '15/01/2099',
      heure: '',
      statut: StatutSession.planifiee,
    );
    final tardive = _session(
      id: 'tardive',
      titre: 'Session tardive',
      date: '15/01/2099',
      heure: '22:00',
      statut: StatutSession.planifiee,
    );

    expect(
      trierSessionsDegustation([
        sansHeure,
        tardive,
      ]).map((session) => session.titre),
      ['Session sans heure', 'Session tardive'],
    );
    expect(sansHeure.dateHeure, DateTime(2099, 1, 15, 23, 59));
  });

  test('fromJson accepte heure et lieu absents sans afficher null', () {
    final session = SessionDegustation.fromJson({
      'id': 'sans-options',
      'titre': 'Session minimale',
      'date': '2099-01-15',
      'heure': null,
      'lieu': null,
      'statut': 'planifiee',
      'created_by': 'user-test',
      'created_at': '2099-01-01T08:00:00Z',
    });

    expect(session.heure, isEmpty);
    expect(session.lieu, isEmpty);
    expect(session.toJson()['heure'], isNull);
    expect(session.dateHeureAffichage, '15/01/2099');
  });

  testWidgets('degustateur - les sessions sont affichees dans le bon ordre', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      degustateur_page.SessionsDegustationPage(
        service: _SessionsService(unsortedSessions),
      ),
    );

    _expectVerticalOrder([
      'Session future',
      'Session meme date recente creation',
      'Session meme date ancienne creation',
      'Session ancienne',
    ], tester);
  });

  testWidgets('chef - les sessions sont affichees dans le bon ordre', (
    tester,
  ) async {
    await _pumpPage(
      tester,
      chef_page.SessionsDegustationPage(
        service: _SessionsService(unsortedSessions, peutValider: true),
      ),
    );

    _expectVerticalOrder([
      'Session future',
      'Session meme date recente creation',
      'Session meme date ancienne creation',
      'Session ancienne',
    ], tester);
  });

  testWidgets('les badges de statut sont visibles sur les cartes', (
    tester,
  ) async {
    final sessions = [
      _session(
        id: 'pending',
        titre: 'Pending',
        date: '05/08/2099',
        heure: '09:00',
        statut: StatutSession.enAttenteValidation,
      ),
      _session(
        id: 'approved',
        titre: 'Approved',
        date: '05/08/2099',
        heure: '10:00',
        statut: StatutSession.planifiee,
      ),
      _session(
        id: 'refused',
        titre: 'Refused',
        date: '05/08/2099',
        heure: '11:00',
        statut: StatutSession.refusee,
      ),
      _session(
        id: 'past',
        titre: 'Past',
        date: '05/08/2020',
        heure: '09:00',
        statut: StatutSession.planifiee,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: sessions
                .map((session) => SessionCard(session: session))
                .toList(),
          ),
        ),
      ),
    );

    expect(find.text('En attente de validation'), findsOneWidget);
    expect(find.text('Approuvée'), findsOneWidget);
    expect(find.text('Refusée'), findsOneWidget);
    expect(find.text('Terminée'), findsOneWidget);
  });

  testWidgets('les filtres gardent uniquement les sessions du statut choisi', (
    tester,
  ) async {
    final sessions = [
      _session(
        id: 'pending',
        titre: 'Session en attente',
        date: '05/08/2099',
        heure: '09:00',
        statut: StatutSession.enAttenteValidation,
      ),
      _session(
        id: 'approved',
        titre: 'Session approuvee',
        date: '05/08/2099',
        heure: '10:00',
        statut: StatutSession.enCours,
      ),
      _session(
        id: 'refused',
        titre: 'Session refusee',
        date: '05/08/2099',
        heure: '11:00',
        statut: StatutSession.refusee,
      ),
      _session(
        id: 'past',
        titre: 'Session terminee',
        date: '05/08/2020',
        heure: '09:00',
        statut: StatutSession.planifiee,
      ),
    ];

    await _pumpPage(
      tester,
      chef_page.SessionsDegustationPage(
        service: _SessionsService(sessions, peutValider: true),
      ),
    );

    await tester.tap(find.text('Refusée').first);
    await tester.pump();

    expect(find.text('Session refusee'), findsOneWidget);
    expect(find.text('Session en attente'), findsNothing);
    expect(find.text('Session approuvee'), findsNothing);
    expect(find.text('Session terminee'), findsNothing);

    await tester.tap(find.text('Terminée').first);
    await tester.pump();

    expect(find.text('Session terminee'), findsOneWidget);
    expect(find.text('Session refusee'), findsNothing);
  });
}
