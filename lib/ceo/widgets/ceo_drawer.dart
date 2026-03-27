// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/widgets/ceo_drawer.dart
// PURPOSE : Side navigation drawer for the CEO role
// USED BY : All CEO pages
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CeoDrawer extends StatelessWidget {
  final VoidCallback onAccueil;
  final VoidCallback onEchantillons;
  final VoidCallback onPanelDegustation;
  final VoidCallback onCollecteurs;
  final VoidCallback onLaboratoire;
  final VoidCallback onUtilisateurs;
  final VoidCallback onTableauDeBord;
  final VoidCallback onNotifications;
  final VoidCallback onProfil;
  final VoidCallback onDeconnexion;

  const CeoDrawer({
    super.key,
    required this.onAccueil,
    required this.onEchantillons,
    required this.onPanelDegustation,
    required this.onCollecteurs,
    required this.onLaboratoire,
    required this.onUtilisateurs,
    required this.onTableauDeBord,
    required this.onNotifications,
    required this.onProfil,
    required this.onDeconnexion,
  });

  static const Color _green = Color(0xFF38835A);
  static const Color _oliveGreen = Color(0xFF6B8143);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _darkText = Color(0xFF1A2E1F);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _cream,
      child: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: _green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Directeur Général',
                    style: GoogleFonts.domine(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'STCA Aljazira',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // ── Menu Items ────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    label: 'Accueil',
                    onTap: onAccueil,
                  ),
                  _DrawerItem(
                    icon: Icons.science_outlined,
                    label: 'Échantillons',
                    onTap: onEchantillons,
                  ),
                  _DrawerItem(
                    icon: Icons.wine_bar_outlined,
                    label: 'Panel de Dégustation',
                    onTap: onPanelDegustation,
                  ),
                  _DrawerItem(
                    icon: Icons.directions_car_outlined,
                    label: 'Collecteurs',
                    onTap: onCollecteurs,
                  ),
                  _DrawerItem(
                    icon: Icons.biotech_outlined,
                    label: 'Laboratoire',
                    onTap: onLaboratoire,
                  ),
                  _DrawerItem(
                    icon: Icons.group_outlined,
                    label: 'Utilisateurs',
                    onTap: onUtilisateurs,
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Tableau de Bord',
                    onTap: onTableauDeBord,
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    onTap: onNotifications,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Divider(color: Color(0xFFE0DDD5)),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Mon Profil',
                    onTap: onProfil,
                  ),
                  _DrawerItem(
                    icon: Icons.logout,
                    label: 'Déconnexion',
                    onTap: onDeconnexion,
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            // ── Footer version ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Panel Dégustation v1.0',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE WIDGET — _DrawerItem
// ─────────────────────────────────────────────────────────────────────────────
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  static const Color _green = Color(0xFF38835A);

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade400 : _green;
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red.shade400 : const Color(0xFF1A2E1F),
        ),
      ),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
