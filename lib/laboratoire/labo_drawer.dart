// ─────────────────────────────────────────────────────────────────────────────
// FILE : laboratoire/widgets/labo_drawer.dart
// PURPOSE : Left-side navigation drawer for the lab technician role
//           Mirrors the structure of AppDrawer
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _darkText = Color(0xFF1A2E1F);

class LaboDrawer extends StatelessWidget {
  final VoidCallback onEchantillons;
  final VoidCallback onProfil;
  final VoidCallback onDeconnexion;

  const LaboDrawer({
    super.key,
    required this.onEchantillons,
    required this.onProfil,
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
                      'assets/img/labo.png',
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
                    Icons.science_outlined,
                    color: _green,
                    size: 22,
                  ),
                  label: 'Échantillons à analyser',
                  onTap: onEchantillons,
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
                  label: 'Mon Profil',
                  onTap: onProfil,
                ),
              ],
            ),
          ),

          // ── FOOTER — Logout ──
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
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    double fontSize = 14,
  }) {
    return ListTile(
      leading: icon,
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
