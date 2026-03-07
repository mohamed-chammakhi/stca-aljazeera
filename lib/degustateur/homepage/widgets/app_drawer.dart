// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/widgets/app_drawer.dart
// PURPOSE : the full left-side navigation drawer
// receives : context and all navigation callbacks FROM the page
// does NOT navigate itself — all navigation logic stays in homepage
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _darkText = Color(0xFF1A2E1F);

class AppDrawer extends StatelessWidget {
  // Each callback is a navigation action defined in homepage_page.dart
  final VoidCallback onaccueil;
  final VoidCallback onEvaluationEchantillons;
  final VoidCallback onGestionEchantillons;
  final VoidCallback onAnalyseLaboratoire;
  final VoidCallback onSessionsDegustationPage;
  final VoidCallback onMembredupanel;
  final VoidCallback onProfil;
  final VoidCallback onAPropos;
  final VoidCallback onDeconnexion;

  const AppDrawer({
    super.key,
    required this.onaccueil,
    required this.onEvaluationEchantillons,
    required this.onGestionEchantillons,
    required this.onAnalyseLaboratoire,
    required this.onSessionsDegustationPage,
    required this.onMembredupanel,
    required this.onProfil,
    required this.onAPropos,
    required this.onDeconnexion,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ── HEADER ──
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: _green,
              boxShadow: [
                BoxShadow(
                  color: _green.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.3,
                    child: Image.asset(
                      'assets/img/blue_glass.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [SizedBox(height: 12)],
                  ),
                ),
              ],
            ),
          ),

          // ── MENU ITEMS ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              children: [
                _buildItem(
                  icon: const Icon(
                    Icons.dashboard_outlined,
                    color: _green,
                    size: 22,
                  ),

                  label: 'Accueil',
                  onTap: onaccueil,
                ),
                _buildItem(
                  icon: const Icon(
                    Icons.folder_outlined,
                    color: _green,
                    size: 22,
                  ),

                  label: 'Gestion des Échantillons',
                  onTap: onGestionEchantillons,
                ),
                _buildItem(
                  icon: SizedBox(
                    width: 19, // ← control size here
                    height: 19, // ← not in Image.asset
                    child: Image.asset(
                      'assets/img/glass.png',
                      //color: const Color.fromARGB(255, 55, 136, 93),
                      //colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                  label: 'Évaluations des Échantillons',
                  onTap: onEvaluationEchantillons,
                ),

                _buildItem(
                  icon: const Icon(
                    Icons.science_outlined,
                    color: _green,
                    size: 22,
                  ),

                  label: 'Analyse de Laboratoire',
                  onTap: onAnalyseLaboratoire,
                ),
                _buildItem(
                  icon: const Icon(
                    Icons.event_note_outlined,
                    color: _green,
                    size: 22,
                  ),

                  label: 'Sessions de dégustation',
                  onTap: onSessionsDegustationPage,
                ),
                _buildItem(
                  icon: const Icon(
                    Icons.people_outline,
                    color: _green,
                    size: 22,
                  ),

                  label: 'Membres du Panel',
                  onTap: onMembredupanel,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Divider(color: Colors.grey.shade200, thickness: 1),
                ),

                _buildItem(
                  icon: const Icon(
                    Icons.person_outline,
                    color: _green,
                    size: 22,
                  ),

                  label: 'Votre Profil',
                  onTap: onProfil,
                ),
                _buildItem(
                  icon: const Icon(Icons.info_outline, color: _green, size: 22),

                  label: 'À propos',
                  onTap: onAPropos,
                ),
              ],
            ),
          ),

          // ── FOOTER — Logout button ──
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: 180,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onDeconnexion,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Déconnexion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 85, 117, 94),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Private helper — one drawer item ──
  Widget _buildItem({
    required Widget icon, // ← changed from IconData to Widget
    required String label,
    required VoidCallback onTap,
    double fontSize = 14,
  }) {
    return ListTile(
      leading: icon, // ← directly use the widget
      title: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: _darkText,
          letterSpacing: 0.3,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_outlined,
        size: 14,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
      hoverColor: _cream,
    );
  }
}
