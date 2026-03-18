// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire_collecteur_dialog.dart
//
// Entry point — the ONLY file other pages need to import.
// Sub-files live in the `formulaire-collecteur/` folder next to this file:
//
//   formulaire-collecteur/bouteille_row.dart
//   formulaire-collecteur/formulaire_decorations.dart
//   formulaire-collecteur/formulaire_sections.dart
//   formulaire-collecteur/formulaire_state.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_collecteur.dart';
import 'formulaire-collecteur/formulaire_decorations.dart';
import 'formulaire-collecteur/formulaire_sections.dart';
import 'formulaire-collecteur/formulaire_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the formulaire dialog.
///
/// [onSaveMultiple] receives:
///   • one updated sample  — when modifying an existing échantillon
///   • one sample per row  — when adding (one per bottle row filled in)
void showFormulaireCollecteurDialog(
  BuildContext context, {
  EchantillonCollecteur? echantillon,
  required Function(List<EchantillonCollecteur>) onSaveMultiple,
  required int prochainNumero,
}) {
  showDialog(
    context: context,
    builder: (_) => _FormulaireCollecteurDialog(
      echantillon: echantillon,
      isModification: echantillon != null,
      onSaveMultiple: onSaveMultiple,
      prochainNumero: prochainNumero,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATEFUL DIALOG SHELL
// ─────────────────────────────────────────────────────────────────────────────
class _FormulaireCollecteurDialog extends StatefulWidget {
  final EchantillonCollecteur? echantillon;
  final bool isModification;
  final Function(List<EchantillonCollecteur>) onSaveMultiple;
  final int prochainNumero;

  const _FormulaireCollecteurDialog({
    required this.echantillon,
    required this.isModification,
    required this.onSaveMultiple,
    required this.prochainNumero,
  });

  @override
  State<_FormulaireCollecteurDialog> createState() =>
      _FormulaireCollecteurDialogState();
}

class _FormulaireCollecteurDialogState
    extends State<_FormulaireCollecteurDialog>
    with FormulaireStateMixin {
  @override
  void initState() {
    super.initState();
    initFormulaireState(widget.echantillon);
  }

  @override
  void dispose() {
    disposeFormulaireState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isModification = widget.isModification;
    final bottleCount = bouteilles.length;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),

      title: Row(
        children: [
          Icon(
            isModification ? Icons.edit_outlined : Icons.add_a_photo_outlined,
            color: kGreen,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isModification ? "Modifier l'échantillon" : 'Nouvel échantillon',
              style: GoogleFonts.domine(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: kDarkText,
              ),
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isModification)
                IdBadgeSection(
                  prochainNumero: widget.prochainNumero,
                  bottleCount: bottleCount,
                ),

              PhotoSection(
                photoUrl: photoUrl,
                onTap: () {
                  /* TODO: camera / gallery */
                },
              ),

              const SizedBox(height: 16),
              const FormDivider(),
              const SizedBox(height: 14),

              LocationCascadeSection(
                geoLoaded: geoLoaded,
                gouvernorat: gouvernorat,
                delegation: delegation,
                cite: cite,
                gouvernorats: geo.gouvernorats,
                delegationOptions: delegationOptions,
                citeOptions: citeOptions,
                onGouvernoratChanged: onGouvernoratChanged,
                onDelegationChanged: onDelegationChanged,
                onCiteChanged: onCiteChanged,
              ),

              const SizedBox(height: 12),

              const SectionLabel(label: 'Fournisseur *'),
              IconTextField(
                controller: codeFournisseurCtrl,
                icon: Icons.storefront_outlined,
                hint: 'Ex: NE-81, SF-42...',
              ),

              const SizedBox(height: 16),
              const FormDivider(),
              const SizedBox(height: 14),

              BouteillesSection(
                bouteilles: bouteilles,
                isModification: isModification,
                onAddRow: addBouteilleRow,
                onRemoveRow: removeBouteilleRow,
              ),

              const SizedBox(height: 16),
              const FormDivider(),
              const SizedBox(height: 14),

              DateSection(
                controller: dateCtrl,
                onChanged: handleDateChanged,
                onPickDate: () => pickDate(context),
              ),

              const SizedBox(height: 12),

              const StatutSection(),

              const SizedBox(height: 12),

              RemarquesSection(controller: remarquesCtrl),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => handleSave(
            ctx: context,
            isModification: isModification,
            existing: widget.echantillon,
            prochainNumero: widget.prochainNumero,
            onSaveMultiple: widget.onSaveMultiple,
          ),
          icon: Icon(isModification ? Icons.check : Icons.add, size: 16),
          label: Text(
            isModification
                ? 'Enregistrer'
                : bottleCount > 1
                ? 'Ajouter $bottleCount échantillons'
                : 'Ajouter',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
        ),
      ],
    );
  }
}
