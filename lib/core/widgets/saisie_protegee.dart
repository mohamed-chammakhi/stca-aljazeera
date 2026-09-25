import 'package:flutter/material.dart';

Future<bool> confirmerAbandonSaisie(BuildContext context) async {
  final resultat = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Quitter sans enregistrer ?'),
      content: const Text('Ce que vous avez saisi sera perdu.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Continuer la saisie'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(
            'Quitter',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
      ],
    ),
  );
  return resultat ?? false;
}

class SaisieProtegee extends StatelessWidget {
  const SaisieProtegee({super.key, required this.child, this.actif = true});

  final Widget child;

  /// false = nothing to lose (read-only view): back closes without asking.
  final bool actif;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !actif,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final quitter = await confirmerAbandonSaisie(context);
        if (quitter && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
