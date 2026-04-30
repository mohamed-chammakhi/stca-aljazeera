// ─────────────────────────────────────────────────────────────────────────────
// FILE : membres_panel/membres_panel_page.dart
// PURPOSE : displays all panel members with search
// NOTE : currently uses mock data — ready to be replaced by API call
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/membre_panel.dart';
import 'services/membres_panel_service.dart';
import 'widgets/membre_card.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/degustateur_nav_mixin.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../profil/profil_page.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../tableau_de_bord/homepage_page.dart';
import '../widgets/deg_colors.dart';
import '../widgets/nav_mixin.dart';

const Color _green = Color(0xFF38835A);
const Color _darkText = Color(0xFF1A2E1F);
const Color _headerBg = Color.fromARGB(255, 220, 233, 226);

class MembresPanelPage extends StatefulWidget {
  const MembresPanelPage({super.key});

  @override
  State<MembresPanelPage> createState() => _MembresPanelPageState();
}

class _MembresPanelPageState extends State<MembresPanelPage>
    with DegustateurNavMixin {
  final _service = MembresPanelService();
  final TextEditingController _searchCtrl = TextEditingController();
  String _recherche = '';
  List<MembrePanel> _membres = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.fetchMembres();
    setState(() => _membres = data);
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
      backgroundColor: const Color(0xFFFFFFFF),
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
            color: kDark,
          ),
        ),
        iconTheme: const IconThemeData(color: kDark),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── SEARCH BAR ─────────────────────────────────────────────────
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _recherche = v),
              style: const TextStyle(fontSize: 14, color: kDark),
              decoration: InputDecoration(
                hintText: 'Rechercher un membre...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
                          thumbColor: WidgetStateProperty.all(const Color.fromARGB(255, 81, 82, 81)),
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
      drawer: AppDrawer(
        onaccueil: () => goToPage(const HomePage()),

        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),

        onDeconnexion: goToLogin,
      ),
    );
  }
}
