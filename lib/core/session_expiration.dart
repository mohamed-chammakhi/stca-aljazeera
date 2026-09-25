import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> sessionNavigatorKey =
    GlobalKey<NavigatorState>();

void Function(String message)? _onSessionExpired;

void registerSessionExpiredHandler(void Function(String message) handler) {
  _onSessionExpired = handler;
}

void showSessionExpiredLogin(String message) {
  _onSessionExpired?.call(message);
}
