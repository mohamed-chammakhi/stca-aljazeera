// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/utilisateurs/widgets/user_card.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/theme/app_colors.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/models/enums.dart';

// ── Local aliases — keep widget code unchanged while using core types ──────────
typedef UserRole = RoleUtilisateur;
typedef AppUser  = UserProfile;

// ── Role accent colors ─────────────────────────────────────────────────────────
// CEO → blue, Laboratoire → orange, Dégustateur → kGreen, Collecteur → pink
const _roleColors = {
  RoleUtilisateur.direction: (kBg: Color(0xFFE6F1FB), fg: Color(0xFF185FA5)),
  RoleUtilisateur.laboratoire: (kBg: Color(0xFFFAEEDA), fg: Color(0xFF854F0B)),
  RoleUtilisateur.degustateur: (kBg: Color(0xFFE1F5EE), fg: Color(0xFF0F6E56)),
  RoleUtilisateur.collecteur: (kBg: Color(0xFFFBEAF0), fg: Color(0xFF993556)),
};

// ═════════════════════════════════════════════════════════════════════════════
// WIDGET — _UserCreatedDialog
// Auto-dismisses after 4 seconds; user can also close it manually.
// ═════════════════════════════════════════════════════════════════════════════
class UserCreatedDialog extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;

  const UserCreatedDialog({super.key,
    required this.prenom,
    required this.nom,
    required this.email,
  });

  @override
  State<UserCreatedDialog> createState() => _UserCreatedDialogState();
}

class _UserCreatedDialogState extends State<UserCreatedDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Close button ─────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ── Success icon ─────────────────────────────────────────
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE1F5EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF38835A),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),

            // ── Title ────────────────────────────────────────────────
            Text(
              'Utilisateur créé',
              style: GoogleFonts.domine(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2E1F),
              ),
            ),
            const SizedBox(height: 10),

            // ── Message ──────────────────────────────────────────────
            Text(
              '${widget.prenom} ${widget.nom} a été ajouté avec succès.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4A6358),
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B8E7A)),
                children: [
                  const TextSpan(
                    text: 'Un email contenant son mot de passe a été envoyé à ',
                  ),
                  TextSpan(
                    text: widget.email,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF185FA5),
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Auto-close hint ──────────────────────────────────────
            Text(
              'Cette fenêtre se ferme automatiquement…',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGET — _UserCard
// ═════════════════════════════════════════════════════════════════════════════
class UserCard extends StatefulWidget {
  final AppUser user;
  final Color kGreen;
  final Color kDark;
  final Map<UserRole, ({Color kBg, Color fg})> roleColors;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onViewProfile;

  const UserCard({
    required this.user,
    required this.kGreen,
    required this.kDark,
    required this.roleColors,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onViewProfile,
  });

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  bool _actionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final colors = widget.roleColors[user.role]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Main row with left accent bar ──────────────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar in role color
                Container(width: 4, color: colors.fg),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // ── Avatar ──────────────────────────────────────
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: colors.kBg,
                          child: Text(
                            user.initiales,
                            style: TextStyle(
                              color: colors.fg,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ── Name + email ────────────────────────────────
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.nomComplet,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: widget.kDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // ── Chevron ─────────────────────────────────────
                        GestureDetector(
                          onTap: () => setState(
                            () => _actionsExpanded = !_actionsExpanded,
                          ),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedRotation(
                              turns: _actionsExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 180),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Expandable actions section ─────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                border: Border(
                  top: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  // Status indicator
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: user.isActive
                          ? widget.kGreen
                          : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.isActive ? 'Actif' : 'Inactif',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: user.isActive
                          ? widget.kGreen
                          : Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  // Toggle status
                  GestureDetector(
                    onTap: widget.onToggleStatus,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFFE6F7EE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: user.isActive
                              ? const Color(0xFFE0E0E0)
                              : const Color(0xFF9DD4B4),
                        ),
                      ),
                      child: Text(
                        user.isActive ? 'Désactiver' : 'Réactiver',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: user.isActive
                              ? const Color(0xFF9E9E9E)
                              : const Color(0xFF2E7D52),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // View
                  _IconBtn(
                    icon: Icons.remove_red_eye_outlined,
                    color: const Color(0xFF9E9E9E),
                    bgColor: const Color(0xFFF5F5F5),
                    onTap: widget.onViewProfile,
                  ),
                  const SizedBox(width: 6),
                  // Delete
                  _IconBtn(
                    icon: Icons.delete_outline,
                    color: const Color(0xFFBB4444),
                    bgColor: const Color(0xFFFFF5F5),
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ),
            crossFadeState: _actionsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ── Small icon button ─────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, size: 15, color: color),
    ),
  );
}
