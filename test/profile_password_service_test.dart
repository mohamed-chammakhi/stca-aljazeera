import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/api_client.dart';
import 'package:project3/core/password_validation.dart';
import 'package:project3/core/services/profile_service.dart';
import 'package:project3/core/widgets/change_password_dialog.dart';

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient() : super(baseUrl: 'http://test.invalid');

  String? path;
  Map<String, dynamic>? body;
  final completer = Completer<void>();

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    this.path = path;
    this.body = Map<String, dynamic>.from(body);
    await completer.future;
    return {'detail': 'Mot de passe changé avec succès.'};
  }
}

class _FailingProfileService extends ProfileService {
  _FailingProfileService()
    : super(api: ApiClient(baseUrl: 'http://test.invalid'));

  @override
  Future<void> changerMotDePasse({
    required String ancien,
    required String nouveau,
  }) async {
    throw ApiException(
      400,
      'Mot de passe actuel incorrect.',
      code: 'password_incorrect',
    );
  }
}

void main() {
  test(
    'le service attend la réponse et envoie les deux mots de passe',
    () async {
      final api = _RecordingApiClient();
      final service = ProfileService(api: api);
      var completed = false;

      final request = service
          .changerMotDePasse(ancien: 'Ancien@123', nouveau: 'Nouveau@456')
          .then((_) => completed = true);
      await Future<void>.delayed(Duration.zero);

      expect(api.path, '/api/users/me/changer-mot-de-passe/');
      expect(api.body, {
        'ancien_mot_de_passe': 'Ancien@123',
        'nouveau_mot_de_passe': 'Nouveau@456',
      });
      expect(completed, isFalse);

      api.completer.complete();
      await request;
      expect(completed, isTrue);
    },
  );

  test('le mauvais ancien mot de passe reçoit un message clair', () {
    final service = ProfileService(api: _RecordingApiClient());

    expect(
      service.messageFor(
        ApiException(
          400,
          'Mot de passe actuel incorrect.',
          code: 'password_incorrect',
        ),
      ),
      'Mot de passe actuel incorrect.',
    );
  });

  test('le validateur applique les trois règles du mot de passe', () {
    expect(validatePassword('Ab@1'), isNotNull);
    expect(validatePassword('Nouveau@'), isNotNull);
    expect(validatePassword('Nouveau1'), isNotNull);
    expect(validatePassword('Nouveau@1'), isNull);
  });

  testWidgets(
    "une erreur serveur garde le dialogue ouvert et n'affiche aucun succès",
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (_) => ChangePasswordDialog(
                    accentColor: Colors.green,
                    labelColor: Colors.green,
                    titleColor: Colors.black,
                    service: _FailingProfileService(),
                  ),
                ),
                child: const Text('Ouvrir'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mot de passe actuel'),
        'Ancien@123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nouveau mot de passe'),
        'Nouveau@456',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirmer le mot de passe'),
        'Nouveau@456',
      );
      await tester.tap(find.byKey(const Key('change-password-submit')));
      await tester.pumpAndSettle();

      expect(find.byType(ChangePasswordDialog), findsOneWidget);
      expect(find.text('Mot de passe actuel incorrect.'), findsOneWidget);
      expect(find.text('Mot de passe changé avec succès'), findsNothing);
    },
  );
}
