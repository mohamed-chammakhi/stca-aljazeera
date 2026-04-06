// ─────────────────────────────────────────────────────────────────────────────
// FILE : membres_panel/membres_panel_page.dart
// PURPOSE : displays all panel members with search
// NOTE : currently uses mock data — ready to be replaced by API call
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/membre_panel.dart';
import 'widgets/membre_card.dart';
import '../../../main.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../profil.dart';
import '../homepage/widgets/app_drawer.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';

const Color gray = Color.fromARGB(255, 81, 82, 81);

const Color _green = Color(0xFF38835A);
//const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

class MembresPanelPage extends StatefulWidget {
  const MembresPanelPage({super.key});

  @override
  State<MembresPanelPage> createState() => _MembresPanelPageState();
}

class _MembresPanelPageState extends State<MembresPanelPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _recherche = '';
  //go to function
  void _goTo(Widget page) {
    Navigator.pop(context); // close drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // Closes drawer then replaces the whole stack — no back button to homepage
  void _goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  // ── MOCK DATA — replace with API call when backend is ready ───────────────
  final List<MembrePanel> _membres = const [
    MembrePanel(
      id: '001',
      nom: 'Chammakhi',
      prenom: 'Ichrak',
      role: 'Dégustateur',
      membreDepuis: 'Jan 2026',
      estEnLigne: true,
    ),
    MembrePanel(
      id: '002',
      nom: 'Ennouri',
      prenom: 'Lobna',
      role: 'Dégustateur',
      membreDepuis: 'Jan 2026',
      estEnLigne: false,
    ),
    MembrePanel(
      id: '003',
      nom: 'Ouni',
      prenom: 'Maha',
      role: 'Dégustateur',
      membreDepuis: 'Fév 2026',
      estEnLigne: true,
    ),
    MembrePanel(
      id: '004',
      nom: 'Fezai',
      prenom: 'Nayrouz',
      role: 'Dégustateur',
      membreDepuis: 'Fév 2026',
      estEnLigne: false,
    ),
    MembrePanel(
      id: '005',
      nom: 'Smaali',
      prenom: 'Yosra',
      role: 'Dégustateur',
      membreDepuis: 'Mar 2026',
      estEnLigne: false,
    ),
  ];

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
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Membres du Panel',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _darkText,
          ),
        ),
        iconTheme: const IconThemeData(color: _darkText),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── STATS BAR ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _green.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _statItem(
                    icon: Icons.group_outlined,
                    label: 'Total',
                    value: '${_membres.length}',
                    color: _green,
                  ),
                  _divider(),
                  _statItem(
                    icon: Icons.circle,
                    label: 'En ligne',
                    value: '${_membres.where((m) => m.estEnLigne).length}',
                    color: Colors.green.shade400,
                  ),
                  _divider(),
                  _statItem(
                    icon: Icons.circle_outlined,
                    label: 'Hors ligne',
                    value: '${_membres.where((m) => !m.estEnLigne).length}',
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── SEARCH BAR ─────────────────────────────────────────────────
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _recherche = v),
              style: const TextStyle(fontSize: 14, color: _darkText),
              decoration: InputDecoration(
                hintText: 'Rechercher un membre...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: _green, size: 20),
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
                  borderSide: const BorderSide(color: _green, width: 1.8),
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
                          thumbColor: MaterialStateProperty.all(gray),
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
        onaccueil: () => Navigator.pop(context),

        // OLD : EvaluationEchantillonsPage from EvaluationEchantillonsPage.dart
        // NEW : will be EvaluationEchantillonsPage from
        //       evaluation_echantillons/evaluation_echantillons_page.dart
        // TODO : replace with _goTo(const EvaluationEchantillonsPage())
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),

        // OLD : GestionEchantillonsPage from GestionEchantillon.dart
        // NEW : GestionEchantillonsPage from
        //       gestion_echantillons/gestion_echantillons_page.dart ✅ done
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),

        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),

        // OLD : ProfilePage from profil.dart (same level)
        // NEW : ProfilePage from ../profil.dart (one level up) ✅ done
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),

        onAPropos: () => Navigator.pop(context),
        onDeconnexion: _goToLogin,
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _statItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.domine(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 30, color: Colors.grey.shade100);
}
