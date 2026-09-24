import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/utils/rafraichissement_periodique.dart';

void main() {
  testWidgets('appelle le rechargement apres 30 secondes', (tester) async {
    final compteur = _CompteurRafraichissement();

    await tester.pumpWidget(_WidgetTestRafraichissement(compteur: compteur));
    expect(compteur.appels, 0);

    await tester.pump(const Duration(seconds: 30));
    await tester.pump();

    expect(compteur.appels, 1);
  });

  testWidgets('arrete le rechargement apres retrait du widget', (tester) async {
    final compteur = _CompteurRafraichissement();

    await tester.pumpWidget(_WidgetTestRafraichissement(compteur: compteur));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 30));

    expect(compteur.appels, 0);
  });

  testWidgets('ignore un second tick tant que le premier appel est en cours', (
    tester,
  ) async {
    final compteur = _CompteurRafraichissement();
    final premierAppel = Completer<void>();
    compteur.prochainAppel = premierAppel.future;

    await tester.pumpWidget(_WidgetTestRafraichissement(compteur: compteur));
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(compteur.appels, 1);

    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(compteur.appels, 1);

    premierAppel.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(compteur.appels, 2);
  });
}

class _CompteurRafraichissement {
  int appels = 0;
  Future<void>? prochainAppel;

  Future<void> appeler() {
    appels += 1;
    final futur = prochainAppel;
    prochainAppel = null;
    return futur ?? Future<void>.value();
  }
}

class _WidgetTestRafraichissement extends StatefulWidget {
  final _CompteurRafraichissement compteur;

  const _WidgetTestRafraichissement({required this.compteur});

  @override
  State<_WidgetTestRafraichissement> createState() =>
      _WidgetTestRafraichissementState();
}

class _WidgetTestRafraichissementState
    extends State<_WidgetTestRafraichissement>
    with RafraichissementPeriodique {
  @override
  Future<void> rechargerEnSilence() => widget.compteur.appeler();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
