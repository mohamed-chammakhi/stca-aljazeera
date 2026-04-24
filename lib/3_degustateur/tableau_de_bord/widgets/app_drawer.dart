// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/widgets/app_drawer.dart
// PURPOSE : left-side navigation drawer — CEO-style design
// receives : navigation callbacks FROM the page, does NOT navigate itself
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _olive = Color(0xFF6B8143);
const Color _iconBg = Color(0x1A38835A); // green at 10% opacity

class AppDrawer extends StatelessWidget {
  final VoidCallback onaccueil;
  final VoidCallback onEvaluationEchantillons;
  final VoidCallback onGestionEchantillons;
  final VoidCallback onAnalyseLaboratoire;
  final VoidCallback onSessionsDegustationPage;
  final VoidCallback onMembredupanel;
  final VoidCallback onProfil;
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
            // ── Header ───────────────────────────────────────────────────────
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
                        'Dégustateur',
                        style: GoogleFonts.domine(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'STCA Aljazira',
                        style: TextStyle(fontSize: 12, color: _dark),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Navigation items ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  _SectionLabel('Tableau de bord'),
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Accueil',
                    onTap: onaccueil,
                  ),

                  const SizedBox(height: 4),
                  Divider(color: _olive.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 4),

                  _SectionLabel('Échantillons'),
                  _DrawerItem(
                    icon: Icons.folder_outlined,
                    label: 'Gestion des échantillons',
                    onTap: onGestionEchantillons,
                  ),
                  _DrawerItem(
                    customIcon: SizedBox(
                      width: 19,
                      height: 19,
                      child: Image.asset('assets/img/glass.png'),
                    ),
                    label: 'Évaluations des échantillons',
                    onTap: onEvaluationEchantillons,
                  ),
                  _DrawerItem(
                    icon: Icons.science_outlined,
                    label: 'Analyse de laboratoire',
                    onTap: onAnalyseLaboratoire,
                  ),

                  const SizedBox(height: 4),
                  Divider(color: _olive.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 4),

                  _SectionLabel('Panel'),
                  _DrawerItem(
                    icon: Icons.event_note_outlined,
                    label: 'Sessions de dégustation',
                    onTap: onSessionsDegustationPage,
                  ),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'Membres du panel',
                    onTap: onMembredupanel,
                  ),

                  const SizedBox(height: 4),
                  Divider(color: _olive.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 4),

                  _SectionLabel('Compte'),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Votre profil',
                    onTap: onProfil,
                  ),
                ],
              ),
            ),

            // ── Déconnexion ──────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL  — olive uppercase caption above a group of items
// ─────────────────────────────────────────────────────────────────────────────
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
        color: _olive,
        letterSpacing: 1.1,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAWER ITEM  — icon in green bg container + label, no trailing arrow
// ─────────────────────────────────────────────────────────────────────────────
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
            // Icon container
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: customIcon ?? Icon(icon, color: _green, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _dark,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
