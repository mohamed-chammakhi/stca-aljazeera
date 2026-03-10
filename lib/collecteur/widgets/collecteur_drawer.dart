// ═════════════════════════════════════════════════════════════════════════════
// FILE    : collecteur/pages/widgets/collecteur_drawer.dart
// PURPOSE : side menu shared across all collecteur pages
//           pages : Mes échantillons | Carte | Messagerie
//                   Préférences CEO  | Tableau de bord | Profil
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _cream      = Color(0xFFF9F6EF);
const Color _darkText   = Color(0xFF1A2E1F);

class CollecteurDrawer extends StatelessWidget {
  final String          currentPage;
  final ValueChanged<String> onNavigate;

  const CollecteurDrawer({
    super.key,
    required this.currentPage,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [

          // ── HEADER ──────────────────────────────────
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.fromLTRB(
                20, 56, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1B4332),
                  Color(0xFF38835A),
                ],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius:          28,
                  backgroundColor: Colors.white
                      .withOpacity(0.2),
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                const Text('Ahmed Dhahbi',
                    style: TextStyle(
                        color:      Colors.white,
                        fontSize:   16,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color:        Colors.white
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Collecteur',
                      style: TextStyle(
                          color:    Colors.white,
                          fontSize: 11)),
                ),
              ],
            ),
          ),

          // ── MENU ITEMS ──────────────────────────────
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _Item(
                  icon:      Icons.inventory_2_outlined,
                  label:     'Mes échantillons',
                  page:      'echantillons',
                  current:   currentPage,
                  onTap:     () => onNavigate('echantillons'),
                ),
                _Item(
                  icon:      Icons.map_outlined,
                  label:     'Carte géographique',
                  page:      'carte',
                  current:   currentPage,
                  onTap:     () => onNavigate('carte'),
                ),
                _Item(
                  icon:      Icons.chat_bubble_outline,
                  label:     'Messagerie CEO',
                  page:      'messagerie',
                  current:   currentPage,
                  onTap:     () => onNavigate('messagerie'),
                ),
                _Item(
                  icon:      Icons.thumb_up_alt_outlined,
                  label:     'Préférences du CEO',
                  page:      'preferences',
                  current:   currentPage,
                  onTap:     () => onNavigate('preferences'),
                ),
                _Item(
                  icon:      Icons.bar_chart_outlined,
                  label:     'Tableau de bord',
                  page:      'dashboard',
                  current:   currentPage,
                  onTap:     () => onNavigate('dashboard'),
                ),

                Divider(
                    color:  Colors.grey.shade100,
                    indent: 16,
                    endIndent: 16),

                _Item(
                  icon:    Icons.person_outline,
                  label:   'Mon profil',
                  page:    'profil',
                  current: currentPage,
                  onTap:   () => onNavigate('profil'),
                ),
              ],
            ),
          ),

          // ── LOGOUT ──────────────────────────────────
          Divider(color: Colors.grey.shade100),
          ListTile(
            leading: const Icon(Icons.logout,
                color: Colors.red, size: 20),
            title: const Text('Déconnexion',
                style: TextStyle(
                    color:    Colors.red,
                    fontSize: 14)),
            onTap: () => onNavigate('logout'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   page;
  final String   current;
  final VoidCallback onTap;

  const _Item({
    required this.icon,
    required this.label,
    required this.page,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == page;
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color:        isActive
            ? _green.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon,
            color:  isActive ? _green : Colors.grey.shade400,
            size:   20),
        title: Text(label,
            style: TextStyle(
                fontSize:   14,
                fontWeight: isActive
                    ? FontWeight.w700
                    : FontWeight.w400,
                color:      isActive
                    ? _green
                    : _darkText)),
        onTap: onTap,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
