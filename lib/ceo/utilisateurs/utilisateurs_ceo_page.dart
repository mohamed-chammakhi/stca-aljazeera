// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/utilisateurs/utilisateurs_ceo_page.dart
// PURPOSE : CEO user management — all roles, create accounts, activate/deactivate
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';

import '../homepage/homepage_ceo_page.dart';
import '../laboratoire/laboratoire_ceo_page.dart';
import '../panel_degustation/panel_degustation_ceo_page.dart';
import '../utilisateurs/utilisateurs_ceo_page.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../../../main.dart';
import '../collecteurs/collecteurs_ceo_page.dart';

enum RoleUtilisateur { degustateur, collecteur, laboratoire, ceo }

class UtilisateursCeoPage extends StatefulWidget {
  const UtilisateursCeoPage({super.key});

  @override
  State<UtilisateursCeoPage> createState() => _UtilisateursCeoPageState();
}

class _UtilisateursCeoPageState extends State<UtilisateursCeoPage> {
  static const Color _green = Color(0xFF38835A);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _gray = Color.fromARGB(255, 81, 82, 81);

  RoleUtilisateur? _filtreRole;
  final TextEditingController _searchCtrl = TextEditingController();
  String _recherche = '';

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Mock users — replace with API ─────────────────────────────────────────
  final List<_UtilisateurMock> _utilisateurs = [
    _UtilisateurMock(
      id: 'U01',
      nom: 'Ali Ben Salem',
      email: 'ali@aljazira.tn',
      role: RoleUtilisateur.degustateur,
      actif: true,
      dateDebut: '01/01/2024',
    ),
    _UtilisateurMock(
      id: 'U02',
      nom: 'Sara Mbarki',
      email: 'sara@aljazira.tn',
      role: RoleUtilisateur.degustateur,
      actif: true,
      dateDebut: '01/01/2024',
    ),
    _UtilisateurMock(
      id: 'U03',
      nom: 'Ahmed Dridi',
      email: 'ahmed@aljazira.tn',
      role: RoleUtilisateur.collecteur,
      actif: true,
      dateDebut: '15/03/2023',
    ),
    _UtilisateurMock(
      id: 'U04',
      nom: 'Sami Khaled',
      email: 'sami@aljazira.tn',
      role: RoleUtilisateur.collecteur,
      actif: true,
      dateDebut: '01/06/2023',
    ),
    _UtilisateurMock(
      id: 'U05',
      nom: 'Tarek Lamine',
      email: 'tarek@aljazira.tn',
      role: RoleUtilisateur.laboratoire,
      actif: true,
      dateDebut: '01/09/2022',
    ),
    _UtilisateurMock(
      id: 'U06',
      nom: 'Nour Mansouri',
      email: 'nour@aljazira.tn',
      role: RoleUtilisateur.degustateur,
      actif: false,
      dateDebut: '01/01/2024',
    ),
  ];

  List<_UtilisateurMock> get _filtres {
    return _utilisateurs.where((u) {
      final q = _recherche.toLowerCase();
      final matchSearch =
          _recherche.isEmpty ||
          u.nom.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
      final matchRole = _filtreRole == null || u.role == _filtreRole;
      return matchSearch && matchRole;
    }).toList();
  }

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(20),
    ),
  );

  static const _chips = [
    _ChipData(null, 'Tous'),
    _ChipData(RoleUtilisateur.degustateur, 'Dégustateurs'),
    _ChipData(RoleUtilisateur.collecteur, 'Collecteurs'),
    _ChipData(RoleUtilisateur.laboratoire, 'Laboratoire'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      drawer: CeoDrawer(
        onAccueil: () => _goTo(const HomePageCeo()),
        onEchantillons: () => _goTo(const EchantillonsCeoPage()),
        onPanelDegustation: () => _goTo(const PanelDegustationCeoPage()),
        onCollecteurs: () => _goTo(const CollecteursCeoPage()),
        onLaboratoire: () => _goTo(const LaboratoireCeoPage()),
        onUtilisateurs: () => _goTo(const UtilisateursCeoPage()),
        onTableauDeBord: () => _goTo(const Placeholder()),
        onNotifications: () => _goTo(const Placeholder()),
        onProfil: () => _goTo(const Placeholder()),
        onDeconnexion: () => _goTo(const LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Utilisateurs',
          style: GoogleFonts.domine(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_utilisateurs.length} utilisateurs',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSuccess('TODO: Formulaire ajout utilisateur'),
        backgroundColor: _green,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _recherche = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Nom, email...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: _green, size: 20),
                suffixIcon: _recherche.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
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
                  borderSide: const BorderSide(color: _green, width: 1.5),
                ),
              ),
            ),
          ),

          // Role filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _chips.length,
                itemBuilder: (_, i) {
                  final chip = _chips[i];
                  final isSel = _filtreRole == chip.role;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filtreRole = chip.role),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSel ? _green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? _green : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          chip.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSel ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(_gray),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: _filtres.length,
                  itemBuilder: (_, i) {
                    final u = _filtres[i];
                    return _UserCard(
                      utilisateur: u,
                      onToggleActif: () {
                        setState(() => u.actif = !u.actif);
                        _showSuccess(
                          u.actif ? '${u.nom} réactivé' : '${u.nom} désactivé',
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final _UtilisateurMock utilisateur;
  final VoidCallback onToggleActif;
  const _UserCard({required this.utilisateur, required this.onToggleActif});

  static const Color _green = Color(0xFF38835A);
  static const Color _darkText = Color(0xFF1A2E1F);

  Color get _roleColor {
    switch (utilisateur.role) {
      case RoleUtilisateur.degustateur:
        return _green;
      case RoleUtilisateur.collecteur:
        return Colors.blue.shade600;
      case RoleUtilisateur.laboratoire:
        return Colors.teal.shade600;
      case RoleUtilisateur.ceo:
        return Colors.purple.shade600;
    }
  }

  String get _roleLabel {
    switch (utilisateur.role) {
      case RoleUtilisateur.degustateur:
        return 'Dégustateur';
      case RoleUtilisateur.collecteur:
        return 'Collecteur';
      case RoleUtilisateur.laboratoire:
        return 'Laboratoire';
      case RoleUtilisateur.ceo:
        return 'Directeur';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: utilisateur.actif ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: utilisateur.actif ? Colors.transparent : Colors.grey.shade200,
        ),
        boxShadow: utilisateur.actif
            ? [
                BoxShadow(
                  color: _green.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: utilisateur.actif
                  ? _roleColor.withOpacity(0.1)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              color: utilisateur.actif ? _roleColor : Colors.grey.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  utilisateur.nom,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: utilisateur.actif ? _darkText : Colors.grey.shade400,
                  ),
                ),
                Text(
                  utilisateur.email,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: utilisateur.actif
                      ? _roleColor.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _roleLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: utilisateur.actif
                        ? _roleColor
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onToggleActif,
                child: Text(
                  utilisateur.actif ? 'Désactiver' : 'Réactiver',
                  style: TextStyle(
                    fontSize: 11,
                    color: utilisateur.actif ? Colors.red.shade400 : _green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UtilisateurMock {
  final String id;
  final String nom;
  final String email;
  final RoleUtilisateur role;
  bool actif;
  final String dateDebut;
  _UtilisateurMock({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    required this.actif,
    required this.dateDebut,
  });
}

class _ChipData {
  final RoleUtilisateur? role;
  final String label;
  const _ChipData(this.role, this.label);
}
