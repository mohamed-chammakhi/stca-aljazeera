import 'package:flutter/material.dart';

import '../main.dart';
import 'services/auth_service.dart';

Future<void> logoutAndShowLogin(
  BuildContext context, {
  Future<void> Function()? logout,
}) async {
  try {
    await (logout ?? authService.logout)();
  } finally {
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}
