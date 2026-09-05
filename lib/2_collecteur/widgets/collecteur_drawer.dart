import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'col_colors.dart';

class CollecteurDrawer extends StatelessWidget {
  final VoidCallback onMesEchantillons;
  final VoidCallback onMessagerie;
  final VoidCallback onProfil;
  final VoidCallback onDeconnexion;

  const CollecteurDrawer({
    super.key,
    required this.onMesEchantillons,
    required this.onMessagerie,
    required this.onProfil,
    required this.onDeconnexion,
  });

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
                color: Color(0xFF55755E),
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
                      color: const Color.fromARGB(
                        255,
                        146,
                        172,
                        157,
                      ).withValues(alpha: 0.7),
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
                        'Collecteur',
                        style: GoogleFonts.domine(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'STCA Aljazira',
                        style: TextStyle(fontSize: 12, color: colDark),
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
                  _SectionLabel('Activités'),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Mes échantillons',
                    onTap: onMesEchantillons,
                  ),
                  _DrawerItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messagerie CEO',
                    onTap: onMessagerie,
                  ),
                  const SizedBox(height: 4),
                  Divider(color: colOlive.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 4),
                  _SectionLabel('Compte'),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Mon profil',
                    onTap: onProfil,
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
                  onPressed: onDeconnexion,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Déconnexion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF55755E),
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
        color: colOlive,
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

  const _DrawerItem({
    this.icon,
    this.customIcon,
    required this.label,
    required this.onTap,
  }) : assert(icon != null || customIcon != null);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: customIcon ?? Icon(icon, color: colGreen, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colDark,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
