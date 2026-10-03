import 'package:flutter/material.dart';
import '../../../main.dart';
import '../../core/logout_navigation.dart';

mixin DegustateurNavMixin<T extends StatefulWidget> on State<T> {
  void goToPage(Widget page) {
    if (page is LoginPage) {
      goToLogin();
      return;
    }
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void goToLogin() {
    Navigator.pop(context);
    logoutAndShowLogin(context);
  }
}
