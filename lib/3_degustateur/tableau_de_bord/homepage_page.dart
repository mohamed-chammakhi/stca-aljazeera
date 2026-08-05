// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/homepage_page.dart
// PURPOSE : THE BRAIN of the homepage
// owns : _unreadCount, all setState calls
// owns : all navigation logic
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Homepage own widgets ──────────────────────────────────────────────────────
import 'widgets/app_drawer.dart';
import 'widgets/home_body.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/degustateur_nav_mixin.dart';
import '../profil/profil_page.dart';
import '../notifications/models/notification_degustateur.dart';
import '../notifications/services/notification_degustateur_service.dart';
import '../../../core/widgets/bandeau_demonstration.dart';
import '../notifications/notifications_degustateur_page.dart';

import '../../../main.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../membres_panel/membres_panel_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _dark = Color(0xFF1A2E1F);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with DegustateurNavMixin {
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
          MaterialPageRoute(builder: (_) => const EvaluationEchantillonsPage()),
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

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6EF),

      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        toolbarHeight: 65,
        title: Text(
          'Tableau de Bord',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),
        iconTheme: const IconThemeData(color: kDark, size: 28),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: kDark),
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
        child: const HomeBody(),
      ),
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            goToPage(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => goToPage(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () =>
            goToPage(const SessionsDegustationPage()),
        onMembredupanel: () => goToPage(const MembresPanelPage()),
        onProfil: () => goToPage(const ProfilePage()),
        onDeconnexion: goToLogin,
      ),
    );
  }
}
