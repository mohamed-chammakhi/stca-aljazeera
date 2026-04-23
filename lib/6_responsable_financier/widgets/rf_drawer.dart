import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _olive    = Color(0xFF6B8143);
const Color _iconBg   = Color(0x1A38835A);

class RfDrawer extends StatelessWidget {
  final VoidCallback onAchatsConfirmes;
  final VoidCallback onFactures;
  final VoidCallback onProfil;
  final VoidCallback onDeconnexion;

  const RfDrawer({
    super.key,
    required this.onAchatsConfirmes,
    required this.onFactures,
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
                      color: const Color.fromARGB(255, 146, 172, 157)
                          .withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Resp. Financier',
                        style: GoogleFonts.domine(
                          fontSize: 16,
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

            // ── Nav items ────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _SectionLabel('Achats'),
                  _DrawerItem(
                    icon: Icons.handshake_outlined,
                    label: 'Achats confirmés',
                    onTap: onAchatsConfirmes,
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Factures',
                    onTap: onFactures,
                  ),
                  const SizedBox(height: 4),
                  Divider(color: _olive.withValues(alpha: 0.15), height: 1),
                  const SizedBox(height: 4),
                  _SectionLabel('Compte'),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
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

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
                color: _iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: _green, size: 20)),
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
