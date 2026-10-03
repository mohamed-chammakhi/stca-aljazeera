import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/logout_navigation.dart';
import 'echantillons_labo/echantillons_labo_page.dart';
import 'notifications/notifications_labo_page.dart';
import 'profil_labo_page.dart';

// Drawer header/button uses a muted olive variant distinct from kGreen.
const Color _drawerAccent = Color(0xFF55755E);
const Color _iconBg = Color(0x1A38835A);

enum LaboDestination { echantillons, notifications, profil }

class LaboDrawer extends StatelessWidget {
  final LaboDestination? currentPage;

  const LaboDrawer({super.key, this.currentPage});

  void _navigate(BuildContext context, LaboDestination destination) {
    Navigator.pop(context);
    if (destination == currentPage) return;
    final Widget page = switch (destination) {
      LaboDestination.echantillons => const EchantillonsLaboPage(),
      LaboDestination.notifications => const NotificationsLaboPage(),
      LaboDestination.profil => const ProfilLaboPage(),
    };
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
              decoration: const BoxDecoration(
                color: _drawerAccent,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: kHeaderBg.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Technicien Labo',
                        style: GoogleFonts.domine(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'STCA Aljazira',
                        style: TextStyle(fontSize: 12, color: kDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Nav ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  _SectionLabel('Analyses'),
                  _DrawerItem(
                    icon: Icons.science_outlined,
                    label: 'Échantillons à analyser',
                    active: currentPage == LaboDestination.echantillons,
                    onTap: () =>
                        _navigate(context, LaboDestination.echantillons),
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    active: currentPage == LaboDestination.notifications,
                    onTap: () =>
                        _navigate(context, LaboDestination.notifications),
                  ),
                  const SizedBox(height: 4),
                  Divider(color: kOlive.withOpacity(0.15), height: 1),
                  const SizedBox(height: 4),
                  _SectionLabel('Compte'),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Mon Profil',
                    active: currentPage == LaboDestination.profil,
                    onTap: () => _navigate(context, LaboDestination.profil),
                  ),
                ],
              ),
            ),

            // ── Déconnexion ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    logoutAndShowLogin(context);
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Déconnexion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _drawerAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: kOlive,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _DrawerItem extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _DrawerItem({
    this.icon,
    this.customIcon,
    required this.label,
    required this.onTap,
    this.active = false,
  }) : assert(icon != null || customIcon != null);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: active ? kHeaderBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: customIcon ?? Icon(icon, color: kGreen, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: kDark,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
