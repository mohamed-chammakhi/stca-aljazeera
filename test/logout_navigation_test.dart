import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/logout_navigation.dart';
import 'package:project3/core/utils/rafraichissement_periodique.dart';
import 'package:project3/main.dart';

void main() {
  testWidgets(
    'la deconnexion remplace la pile par LoginPage et arrete le timer precedent',
    (tester) async {
      var refreshCount = 0;
      var logoutCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: _RefreshPage(
            onRefresh: () async {
              refreshCount += 1;
            },
            onLogout: (context) => logoutAndShowLogin(
              context,
              logout: () async {
                logoutCount += 1;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(_RefreshPage.logoutButtonKey));
      await tester.pumpAndSettle();

      expect(logoutCount, 1);
      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(_RefreshPage), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(LoginPage))).canPop(),
        isFalse,
      );

      await tester.pump(const Duration(seconds: 30));
      await tester.pump();

      expect(refreshCount, 0);
    },
  );
}

class _RefreshPage extends StatefulWidget {
  static const logoutButtonKey = Key('logout-button');

  final Future<void> Function() onRefresh;
  final Future<void> Function(BuildContext context) onLogout;

  const _RefreshPage({required this.onRefresh, required this.onLogout});

  @override
  State<_RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<_RefreshPage>
    with RafraichissementPeriodique {
  @override
  Future<void> rechargerEnSilence() => widget.onRefresh();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ElevatedButton(
        key: _RefreshPage.logoutButtonKey,
        onPressed: () => widget.onLogout(context),
        child: const Text('Deconnexion'),
      ),
    ),
  );
}
