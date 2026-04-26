import 'package:flutter/material.dart';
import '../../../main.dart';

mixin DegustateurNavMixin<T extends StatefulWidget> on State<T> {
  void goToPage(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }
}
