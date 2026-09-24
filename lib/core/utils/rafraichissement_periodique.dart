import 'dart:async';

import 'package:flutter/widgets.dart';

mixin RafraichissementPeriodique<T extends StatefulWidget> on State<T> {
  Timer? _rafraichissementTimer;
  bool _rafraichissementEnCours = false;

  Future<void> rechargerEnSilence();

  @override
  void initState() {
    super.initState();
    _rafraichissementTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _declencherRafraichissementPeriodique(),
    );
  }

  Future<void> _declencherRafraichissementPeriodique() async {
    if (!mounted || _rafraichissementEnCours) return;
    _rafraichissementEnCours = true;
    try {
      await rechargerEnSilence();
    } finally {
      _rafraichissementEnCours = false;
    }
  }

  @override
  void dispose() {
    _rafraichissementTimer?.cancel();
    super.dispose();
  }
}
