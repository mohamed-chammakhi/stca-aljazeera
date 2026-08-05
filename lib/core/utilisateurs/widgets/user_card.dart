import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../models/enums.dart';

/// Expandable user card with role accent bar, status indicator, and action buttons.
class UserCard extends StatefulWidget {
  final UserProfile user;
  final Color green;
  final Color darkText;
  final Map<RoleUtilisateur, ({Color bg, Color fg})> roleColors;
  final bool peutGerer;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onViewProfile;

  const UserCard({
    super.key,
    required this.user,
    required this.green,
    required this.darkText,
    required this.roleColors,
    required this.peutGerer,
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: colors.fg),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: colors.bg,
                          child: Text(
                            user.initiales,
                            style: TextStyle(color: colors.fg, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.nomComplet,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.darkText),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _actionsExpanded = !_actionsExpanded),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedRotation(
                              turns: _actionsExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 180),
                              child: Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey.shade400),
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
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 7, height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: user.isActive ? widget.green : Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.isActive ? 'Actif' : 'Inactif',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: user.isActive ? widget.green : Colors.grey.shade500,
                    ),
                  ),
                  const Spacer(),
                  if (widget.peutGerer) ...[
                    GestureDetector(
                      key: ValueKey('utilisateur_toggle_${user.id}'),
                      onTap: widget.onToggleStatus,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: user.isActive ? const Color(0xFFF5F5F5) : const Color(0xFFE6F7EE),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: user.isActive ? const Color(0xFFE0E0E0) : const Color(0xFF9DD4B4),
                          ),
                        ),
                        child: Text(
                          user.isActive ? 'Désactiver' : 'Réactiver',
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: user.isActive ? const Color(0xFF9E9E9E) : const Color(0xFF2E7D52),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _IconBtn(icon: Icons.remove_red_eye_outlined, color: const Color(0xFF9E9E9E), bgColor: const Color(0xFFF5F5F5), onTap: widget.onViewProfile),
                  if (widget.peutGerer) ...[
                    const SizedBox(width: 6),
                    _IconBtn(
                      key: ValueKey('utilisateur_supprimer_${user.id}'),
                      icon: Icons.delete_outline,
                      color: const Color(0xFFBB4444),
                      bgColor: const Color(0xFFFFF5F5),
                      onTap: widget.onDelete,
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _actionsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _IconBtn({super.key, required this.icon, required this.color, required this.bgColor, required this.onTap});

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
