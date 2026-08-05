import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utilisateurs/utilisateurs_page_body.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../membres_panel/membres_panel_page.dart';
import '../profil.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../tableau_de_bord/homepage_page.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart';
import '../widgets/chef_colors.dart';
import '../widgets/chef_nav_mixin.dart';

class UtilisateursChefPage extends StatefulWidget {
  const UtilisateursChefPage({super.key});

  @override
  State<UtilisateursChefPage> createState() => _UtilisateursChefPageState();
}

class _UtilisateursChefPageState extends State<UtilisateursChefPage>
    with ChefNavMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: chefBg,
      drawer: AppDrawer(
        onaccueil: () => goToPage(const HomePage()),
        onEvaluationEchantillons: () =>
            goToPage(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => goToPage(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () =>
            goToPage(const SessionsDegustationPage()),
        onMembredupanel: () => goToPage(const MembresPanelPage()),
        onUtilisateurs: () => Navigator.pop(context),
        onVueEnsembleEvaluations: () =>
            goToPage(const VueEnsembleEvaluationsPage()),
        onProfil: () => goToPage(const ProfilePage()),
        onDeconnexion: goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: chefHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Utilisateurs',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: chefDark,
          ),
        ),
        iconTheme: const IconThemeData(color: chefDark),
      ),
      body: const UtilisateursPageBody(peutGerer: true),
    );
  }
}
