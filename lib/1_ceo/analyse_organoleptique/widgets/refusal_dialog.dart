import 'package:flutter/material.dart';
import 'package:project3/core/widgets/saisie_protegee.dart';

/// Refusal dialog for rejecting a sample.
/// Manages its own text controller for the optional reason field.
/// Calls [onRefuse] with the trimmed reason (null if blank); the page owns the state mutation.
class RefusalDialog extends StatefulWidget {
  final String reference;
  final String? initialRaison;
  final void Function(String? raison) onRefuse;

  const RefusalDialog({
    super.key,
    required this.reference,
    this.initialRaison,
    required this.onRefuse,
  });

  @override
  State<RefusalDialog> createState() => _RefusalDialogState();
}

class _RefusalDialogState extends State<RefusalDialog> {
  late final TextEditingController _raisonCtrl;

  @override
  void initState() {
    super.initState();
    _raisonCtrl = TextEditingController(text: widget.initialRaison ?? '');
  }

  @override
  void dispose() {
    _raisonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SaisieProtegee(
      child: AlertDialog(
      title: const Text(
        "Refuser l'échantillon",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.reference,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _raisonCtrl,
            decoration: InputDecoration(
              labelText: 'Raison du refus (optionnelle)',
              border: const OutlineInputBorder(),
              isDense: true,
              hintText: 'Ex: Acidité trop élevée',
              hintStyle: TextStyle(color: Colors.grey.shade400),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade500),
          onPressed: () {
            final raison = _raisonCtrl.text.trim().isEmpty
                ? null
                : _raisonCtrl.text.trim();
            Navigator.pop(context);
            widget.onRefuse(raison);
          },
          child: const Text(
            'Confirmer le refus',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      ),
    );
  }
}
