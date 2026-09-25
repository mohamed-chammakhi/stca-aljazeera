import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/api_client.dart';
import 'package:project3/core/auth/mot_de_passe_oublie_page.dart';
import 'package:project3/core/services/mot_de_passe_oublie_service.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(baseUrl: 'http://test.invalid');

  final calls = <String>[];
  final bodies = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> postPublic(
    String path,
    Map<String, dynamic> body,
  ) async {
    calls.add(path);
    bodies.add(Map<String, dynamic>.from(body));
    if (path.endsWith('/verifier/')) {
      return {'jeton': 'jeton-test'};
    }
    return {'detail': 'ok'};
  }
}

void main() {
  testWidgets(
    'enchaîne les trois étapes avec un faux client HTTP',
    (tester) async {
      final api = _FakeApiClient();
      final service = MotDePasseOublieService(api: api);

      await tester.pumpWidget(_Host(service: service));

      await tester.tap(find.text('Ouvrir'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('forgot-password-email')),
        'reset@stca.tn',
      );
      await tester.tap(find.byKey(const Key('forgot-password-send')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('forgot-password-code')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('forgot-password-code')),
        '123456',
      );
      await tester.tap(find.byKey(const Key('forgot-password-verify')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('forgot-password-new-password')),
        findsOneWidget,
      );

      await tester.enterText(
        find.byKey(const Key('forgot-password-new-password')),
        'Nouveau@456',
      );
      await tester.enterText(
        find.byKey(const Key('forgot-password-confirmation')),
        'Nouveau@456',
      );
      await tester.tap(find.byKey(const Key('forgot-password-save')));
      await tester.pumpAndSettle();

      expect(find.text('Mot de passe modifié. Connectez-vous.'), findsOneWidget);
      expect(api.calls, [
        '/api/auth/mot-de-passe-oublie/',
        '/api/auth/mot-de-passe-oublie/verifier/',
        '/api/auth/mot-de-passe-oublie/nouveau/',
      ]);
      expect(api.bodies.last, {
        'jeton': 'jeton-test',
        'nouveau_mot_de_passe': 'Nouveau@456',
      });
    },
  );
}

class _Host extends StatefulWidget {
  final MotDePasseOublieService service;

  const _Host({required this.service});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  String? _message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MotDePasseOubliePage(
                        service: widget.service,
                      ),
                    ),
                  );
                  if (changed == true) {
                    setState(() {
                      _message = 'Mot de passe modifié. Connectez-vous.';
                    });
                  }
                },
                child: const Text('Ouvrir'),
              ),
              if (_message != null) Text(_message!),
            ],
          ),
        ),
      ),
    );
  }
}
