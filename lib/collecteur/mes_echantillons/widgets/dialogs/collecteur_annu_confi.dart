// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/widgets/dialogs/collecteur_dialogs.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../models/echantillon_collecteur.dart';

const Color _green = Color(0xFF38835A);
const Color _orange = Color(0xFFF57C00);

// ── Confirmation achat ────────────────────────────────────────────────────────
Future<void> showConfirmationAchatDialog(
  BuildContext context, {
  required EchantillonCollecteur echantillon,
  required VoidCallback onConfirmer,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: _green, size: 22),
          const SizedBox(width: 8),
          const Text(
            "Confirmer l'achat",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Text(
        'Confirmez-vous l\'achat de l\'échantillon\n'
        '"${echantillon.ref}" ?\n\n'
        'Cette action indique que la négociation\na abouti avec le fournisseur.',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirmer();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Confirmer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

// ── Échec de négociation ──────────────────────────────────────────────────────
Future<void> showEchecNegociationDialog(
  BuildContext context, {
  required EchantillonCollecteur echantillon,
  required Function(String? raison) onConfirmer,
}) {
  final raisonCtrl = TextEditingController();

  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.handshake_outlined,
              color: _orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Négociation non aboutie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _orange.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: _orange, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Le PDG sera notifié que la négociation pour '
                    '"${echantillon.ref}" n\'a pas abouti.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Raison (optionnel)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: raisonCtrl,
            maxLines: 3,
            minLines: 2,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A2E1F)),
            decoration: InputDecoration(
              hintText: 'Ex: Prix trop élevé, fournisseur indisponible...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              filled: true,
              fillColor: const Color(0xFFF7FAF8),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _orange, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final raison = raisonCtrl.text.trim().isEmpty
                ? null
                : raisonCtrl.text.trim();
            Navigator.pop(ctx);
            onConfirmer(raison);
          },
          icon: const Icon(Icons.send_outlined, size: 15),
          label: const Text(
            'Signaler au PDG',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    ),
  );
}

// ── Planification livraison ───────────────────────────────────────────────────
Future<void> showPlanificationLivraisonDialog(
  BuildContext context, {
  required EchantillonCollecteur echantillon,
  required ValueChanged<LivraisonInfo> onSave,
}) {
  final livraisonExistante = echantillon.livraison;

  // ── FIX: selectedDate is non-nullable after validation. ───────────────────
  // We keep it nullable during editing so the "no date chosen" state is
  // representable, but we guard before calling onSave so the compiler is
  // satisfied that the DateTime passed to LivraisonInfo is never null.
  DateTime? selectedDate = livraisonExistante?.date;

  final heureCtrl = TextEditingController(
    text: livraisonExistante?.heure ?? '',
  );
  final lieuCtrl = TextEditingController(text: livraisonExistante?.lieu ?? '');

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Planifier la livraison',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2E1F),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Date ────────────────────────────────────────────────
                _Label('Date de livraison *'),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(primary: _green),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: _green,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Sélectionner une date',
                          style: TextStyle(
                            fontSize: 14,
                            color: selectedDate != null
                                ? const Color(0xFF1A2E1F)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Heure + Lieu ─────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Heure *'),
                          _Field(
                            controller: heureCtrl,
                            hint: 'ex: 09:00',
                            keyboardType: TextInputType.datetime,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Lieu *'),
                          _Field(
                            controller: lieuCtrl,
                            hint: 'Adresse ou ville',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Buttons ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _green,
                          side: const BorderSide(color: _green),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate all three fields
                          if (selectedDate == null ||
                              heureCtrl.text.trim().isEmpty ||
                              lieuCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Tous les champs sont obligatoires',
                                ),
                                backgroundColor: Colors.red.shade400,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(20),
                              ),
                            );
                            return;
                          }

                          // ── FIX: selectedDate is guaranteed non-null
                          // here because we returned early above if null.
                          // Cast with ! so LivraisonInfo receives DateTime.
                          Navigator.pop(ctx);
                          onSave(
                            LivraisonInfo(
                              date: selectedDate!, // non-null after guard
                              heure: heureCtrl.text.trim(),
                              lieu: lieuCtrl.text.trim(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Enregistrer',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ── Suppression échantillon ───────────────────────────────────────────────────
Future<void> showSuppressionCollecteurDialog(
  BuildContext context, {
  required EchantillonCollecteur echantillon,
  required VoidCallback onConfirmer,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade400,
            size: 22,
          ),
          const SizedBox(width: 8),
          const Text(
            "Supprimer l'échantillon",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Text(
        'Voulez-vous supprimer\n"${echantillon.ref}" ?\n\n'
        'Cette action est irréversible.',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirmer();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Supprimer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B8143),
      ),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;

  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 14, color: Color(0xFF1A2E1F)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _green, width: 1.8),
      ),
    ),
  );
}
