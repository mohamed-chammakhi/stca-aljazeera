// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/homepage_page.dart
// PURPOSE : THE BRAIN of the homepage
// owns : _unreadCount, all setState calls
// owns : all navigation logic
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/logout_navigation.dart';
import 'package:project3/core/widgets/messagerie/conversations_page.dart';
import 'package:project3/core/utils/rafraichissement_periodique.dart';

import 'widgets/app_drawer.dart';
import '../utilisateurs/utilisateurs_chef_page.dart';
import '../widgets/chef_colors.dart';
import 'widgets/home_body.dart';

import '../profil.dart';
import 'package:project3/core/models/notification_degustateur.dart';
import '../notifications/services/notification_degustateur_service.dart';
import '../../../core/widgets/bandeau_demonstration.dart';
import '../notifications/notifications_degustateur_page.dart';

import '../../../main.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomePage
// ─────────────────────────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RafraichissementPeriodique {
  static const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
  static const Color _dark = Color(0xFF1A2E1F);

  // ── Notifications ─────────────────────────────────────────────────────────
  final _notifService = NotificationDegustateurService();
  int _unreadCount = 0;
  bool _estDemonstration = false;
  Object? _erreurChargement;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final resultat = await _notifService.fetchUnreadCount();
      if (!mounted) return;
      setState(() {
        _unreadCount = resultat.donnees;
        _estDemonstration = resultat.estDemonstration;
        _erreurChargement = null;
      });
    } catch (erreur) {
      if (mounted) setState(() => _erreurChargement = erreur);
    }
  }

  @override
  Future<void> rechargerEnSilence() async {
    try {
      final resultat = await _notifService.fetchUnreadCount();
      if (!mounted || (resultat.estDemonstration && !_estDemonstration)) {
        return;
      }
      setState(() {
        _unreadCount = resultat.donnees;
        _estDemonstration = resultat.estDemonstration;
        _erreurChargement = null;
      });
    } catch (_) {}
  }

  // ── ACTIONS ───────────────────────────────────────────────────────────────

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsDegustateurPage(
          service: _notifService,
          onNavigate: _handleNotifNavigation,
        ),
      ),
    ).then((_) => _loadUnreadCount());
  }

  void _handleNotifNavigation(NotificationDegustateur n) {
    switch (n.section) {
      case 'EVALUATIONS':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => n.echantillonId == null
                ? const EvaluationEchantillonsPage()
                : EvaluationEchantillonsPage(echantillonCible: n.echantillonId),
          ),
        );
        break;
      case 'ANALYSES':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalyseLaboratoirePage()),
        );
        break;
      case 'SESSIONS':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SessionsDegustationPage()),
        );
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GestionEchantillonsPage()),
        );
        break;
    }
  }

  // ── NAVIGATION ────────────────────────────────────────────────────────────

  void _goTo(Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goToLogin() {
    Navigator.pop(context);
    logoutAndShowLogin(context);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Tableau de Bord',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        iconTheme: const IconThemeData(color: _dark, size: 28),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: _dark),
                onPressed: _openNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: _unreadCount > 9 ? 18 : 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: VueResultatService(
        estDemonstration: _estDemonstration,
        erreur: _erreurChargement,
        onReessayer: _loadUnreadCount,
        onRefresh: _loadUnreadCount,
        couleurRafraichissement: chefGreen,
        child: HomeBody(
          onSimulerNotification: () {},
          onRefreshParent: _loadUnreadCount,
        ),
      ),
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onUtilisateurs: () => _goTo(const UtilisateursChefPage()),
        onVueEnsembleEvaluations: () =>
            _goTo(const VueEnsembleEvaluationsPage()),
        onMessagerie: () => _goTo(const ConversationsPage()),
        onProfil: () => _goTo(const ProfilePage()),
        onDeconnexion: _goToLogin,
      ),
    );
  }
}
