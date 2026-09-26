import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserCreatedDialog extends StatefulWidget {
  final String prenom;
  final String nom;
  final String email;
  final String role;
  final String? motDePasseTemporaire;
  final bool emailUtilisateurEnvoye;

  const UserCreatedDialog({
    super.key,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.role,
    this.motDePasseTemporaire,
    this.emailUtilisateurEnvoye = false,
  });

  @override
  State<UserCreatedDialog> createState() => _UserCreatedDialogState();
}

class _UserCreatedDialogState extends State<UserCreatedDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 8), () {
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
              'Compte créé',
              style: GoogleFonts.domine(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2E1F),
              ),
            ),
            const SizedBox(height: 12),
            _line('Nom', '${widget.prenom} ${widget.nom}'),
            _line('Email', widget.email),
            _line('Rôle', widget.role),
            const SizedBox(height: 12),
            Text(
              widget.emailUtilisateurEnvoye
                  ? 'Nous avons envoyé ses identifiants à ${widget.email}.'
                  : "Le compte est créé, mais l'email des identifiants n'a pas pu être envoyé.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4A6358)),
            ),
            if (widget.motDePasseTemporaire != null) ...[
              const SizedBox(height: 8),
              Text(
                'Son mot de passe est : ${widget.motDePasseTemporaire}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF185FA5),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Cette fenêtre se ferme automatiquement.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$label : $value',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: Color(0xFF4A6358)),
      ),
    );
  }
}
