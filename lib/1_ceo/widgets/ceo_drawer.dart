import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/widgets/messagerie/messagerie_badge.dart';

const Color _iconBg = Color(0x1A38835A);

class CeoDrawer extends StatelessWidget {
  final VoidCallback onEchantillons;
  final VoidCallback onAnalyseOrganoleptique;
  final VoidCallback onAnalyseLaboratoire;
  final VoidCallback onValidationAchats;
  final VoidCallback onAchatsConfirmes;
  final VoidCallback onTableauDeBord;
  final VoidCallback onProfil;
  final VoidCallback onutilisiateurs;
  final VoidCallback onMessagerie;
  final VoidCallback onDeconnexion;

  const CeoDrawer({
    super.key,
    required this.onEchantillons,
    required this.onAnalyseOrganoleptique,
    required this.onAnalyseLaboratoire,
    required this.onValidationAchats,
    required this.onAchatsConfirmes,
    required this.onTableauDeBord,
    required this.onProfil,
    required this.onutilisiateurs,
    required this.onMessagerie,
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
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Directeur',
                        style: GoogleFonts.domine(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: kDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'STCA Aljazira',
                        style: const TextStyle(fontSize: 12, color: kDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Nav (same as before) ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  const SizedBox(height: 11),

                  const SizedBox(height: 4),
                  _SectionLabel('Tableau de bord'),

                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Tableau de bord',
                    onTap: onTableauDeBord,
                  ),
                  const SizedBox(height: 4),
                  Divider(color: kOlive.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 4),
                  _SectionLabel('Échantillons'),
                  _DrawerItem(
                    icon: Icons.science_outlined,
                    label: 'Échantillons',
                    onTap: onEchantillons,
                  ),
                  _DrawerItem(
                    customIcon: SizedBox(
                      width: 19,
                      height: 19,
                      child: Image.asset('assets/img/glass.png'),
                    ),
                    label: 'Analyse organoleptique',
                    onTap: onAnalyseOrganoleptique,
                  ),
                  _DrawerItem(
                    icon: Icons.biotech_outlined,
                    label: 'Analyse laboratoire',
                    onTap: onAnalyseLaboratoire,
                  ),
                  _DrawerItem(
                    icon: Icons.fact_check_outlined,
                    label: 'Validation achats',
                    onTap: onValidationAchats,
                  ),
                  _DrawerItem(
                    icon: Icons.handshake_outlined,
                    label: 'Achats confirmés',
                    onTap: onAchatsConfirmes,
                  ),

                  const SizedBox(height: 4),
                  Divider(color: kOlive.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 4),
                  _SectionLabel('Compte'),
                  _DrawerItem(
                    icon: Icons.people_outline,
                    label: 'Utilisateurs',
                    onTap: onutilisiateurs,
                  ),
                  _DrawerItem(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messagerie',
                    trailing: const MessagerieBadge(),
                    onTap: onMessagerie,
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
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

// _SectionLabel and _DrawerItem stay exactly the same as you had them

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

class _DrawerItem extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _DrawerItem({
    this.icon,
    this.customIcon,
    required this.label,
    this.trailing,
    required this.onTap,
  }) : assert(icon != null || customIcon != null);

  @override
  Widget build(BuildContext context) {
    return Material(
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
                  color: _iconBg,
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: kDark,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}
