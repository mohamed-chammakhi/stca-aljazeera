import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Success dialog shown after a new user is created.
/// Auto-dismisses after 4 seconds; user can also close manually.
class UserCreatedDialog extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;

  const UserCreatedDialog({
    super.key,
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
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context, rootNavigator: true).pop(),
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
            Text(
              'Utilisateur crÃ©Ã©',
              style: GoogleFonts.domine(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2E1F),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.prenom} ${widget.nom} a Ã©tÃ© ajoutÃ© avec succÃ¨s.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF4A6358)),
            ),
            const SizedBox(height: 6),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B8E7A)),
                children: [
                  const TextSpan(
                    text: 'Mot de passe temporaire : Test@12345 pour ',
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
            Text(
              'Cette fenÃªtre se ferme automatiquementâ€¦',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
