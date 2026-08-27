// ─────────────────────────────────────────────────────────────────────────────
// FILE : membres_panel/membres_panel_page.dart
// PURPOSE : displays all panel members with search
// NOTE : currently uses mock data — ready to be replaced by API call
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/models/membre_panel.dart';
import 'package:project3/core/services/membres_panel_service.dart';
import 'package:project3/core/widgets/membres_panel/membre_card.dart';
import '../../../main.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../profil.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../utilisateurs/utilisateurs_chef_page.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../vue_ensemble_evaluations/vue_ensemble_evaluations_page.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/bandeau_demonstration.dart';
import '../widgets/chef_nav_mixin.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _bg = Color(0xFFFFFFFF);
const Color _gray = Color.fromARGB(255, 81, 82, 81);

class MembresPanelPage extends StatefulWidget {
  const MembresPanelPage({super.key});

  @override
  State<MembresPanelPage> createState() => _MembresPanelPageState();
}

class _MembresPanelPageState extends State<MembresPanelPage> with ChefNavMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  String _recherche = '';

  final _service = MembresPanelService();
  List<MembrePanel> _membres = [];
  bool _estDemonstration = false;
  Object? _erreurChargement;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final resultat = await _service.fetchMembres();
      if (!mounted) return;
      setState(() {
        _membres = resultat.donnees;
        _estDemonstration = resultat.estDemonstration;
        _erreurChargement = null;
      });
    } catch (erreur) {
      if (!mounted) return;
      setState(() => _erreurChargement = erreur);
    }
  }

  // ── FILTERED LIST based on search ─────────────────────────────────────────
  List<MembrePanel> get _membresFiltres {
    if (_recherche.isEmpty) return _membres;
    return _membres
        .where(
          (m) => m.nomComplet.toLowerCase().contains(_recherche.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Membres du Panel',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        iconTheme: const IconThemeData(color: _dark),
      ),

      body: VueResultatService(
        estDemonstration: _estDemonstration,
        erreur: _erreurChargement,
        onReessayer: _loadData,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── SEARCH BAR ─────────────────────────────────────────────────
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _recherche = v),
                style: const TextStyle(fontSize: 14, color: _dark),
                decoration: InputDecoration(
                  hintText: 'Rechercher un membre...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search, color: kGreen, size: 20),
                  suffixIcon: _recherche.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                          onPressed: () => setState(() {
                            _recherche = '';
                            _searchCtrl.clear();
                          }),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kGreen, width: 1.8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── LIST ───────────────────────────────────────────────────────
              Expanded(
                child: _membresFiltres.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucun membre trouvé',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Theme(
                        data: Theme.of(context).copyWith(
                          scrollbarTheme: ScrollbarThemeData(
                          thumbColor: WidgetStateProperty.all(_gray),
                          ),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: _membresFiltres.length,
                            itemBuilder: (context, index) =>
                                MembreCard(membre: _membresFiltres[index]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),

        // OLD : EvaluationEchantillonsPage from EvaluationEchantillonsPage.dart
        // NEW : will be EvaluationEchantillonsPage from
        //       evaluation_echantillons/evaluation_echantillons_page.dart
        // TODO : replace with goToPage(const EvaluationEchantillonsPage())
        onEvaluationEchantillons: () =>
            goToPage(const EvaluationEchantillonsPage()),

        // OLD : GestionEchantillonsPage from GestionEchantillon.dart
        // NEW : GestionEchantillonsPage from
        //       gestion_echantillons/gestion_echantillons_page.dart ✅ done
        onGestionEchantillons: () => goToPage(const GestionEchantillonsPage()),

        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () =>
            goToPage(const SessionsDegustationPage()),

        // OLD : ProfilePage from profil.dart (same level)
        // NEW : ProfilePage from ../profil.dart (one level up) ✅ done
        onMembredupanel: () => goToPage(const MembresPanelPage()),
        onUtilisateurs: () => goToPage(const UtilisateursChefPage()),
        onVueEnsembleEvaluations: () =>
            goToPage(const VueEnsembleEvaluationsPage()),
        onProfil: () => goToPage(const ProfilePage()),

        onDeconnexion: goToLogin,
      ),
    );
  }
}
