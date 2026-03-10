// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/homepage_page.dart
// PURPOSE : THE BRAIN of the homepage
// owns : _notificationCount, _notifications, all setState calls
// owns : all navigation logic
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

// ── Homepage own widgets ──────────────────────────────────────────────────────
import 'widgets/notification_bell.dart';
import 'widgets/notification_panel.dart';
import 'widgets/app_drawer.dart';
import 'widgets/home_body.dart';
import 'models/notification_item.dart';

import '../../../profil.dart';

import '../../../main.dart';
import '../sessions_degustation/sessions_degustation_page.dart';

import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../membres_panel/membres_panel_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MyApp
// ─────────────────────────────────────────────────────────────────────────────
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tasting Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF38835A),
        scaffoldBackgroundColor: const Color(0xFFF9F6EF),
      ),
      home: const HomePage(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HomePage
// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color green = Color(0xFF38835A);

  // ── STATE — lives here, cannot be moved ──────────────────────────────────
  int _notificationCount = 3;

  final List<NotificationItem> _notifications = [
    NotificationItem(
      message: 'Nouvelle dégustation programmée pour demain',
      time: 'Il y a 1h',
    ),
    NotificationItem(
      message: "Résultats d'analyse de laboratoire disponibles",
      time: 'Il y a 2h',
    ),
    NotificationItem(message: 'Réunion planifiée à 14h00', time: 'Il y a 3h'),
  ];

  // ── ACTIONS — all setState calls live here ───────────────────────────────

  void _addNotification(String message) {
    setState(() {
      _notifications.insert(
        0,
        NotificationItem(message: message, time: "À l'instant"),
      );
      _notificationCount++;
    });
  }

  void _markAllAsRead() {
    setState(() => _notificationCount = 0);
  }

  // ── NAVIGATION ────────────────────────────────────────────────────────────

  // Closes drawer then pushes a new page on top
  void _goTo(Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // Closes drawer then replaces the whole stack — no back button to homepage
  void _goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF),

      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white, size: 28),
        actions: [
          // NotificationBell — from widgets/notification_bell.dart
          // count and onTap passed FROM HERE
          NotificationBell(
            count: _notificationCount,
            onTap: () {
              _markAllAsRead();
              showNotificationPanel(context, notifications: _notifications);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // HomeBody — from widgets/home_body.dart
      body: HomeBody(
        onSimulerNotification: () =>
            _addNotification('Nouveau rapport disponible'),
      ),
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),
        onAPropos: () => Navigator.pop(context),
        onDeconnexion: _goToLogin,
      ),
    );
  }
}
