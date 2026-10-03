import 'package:flutter/material.dart';

import '../services/bordereau_pdf_service.dart';

/// AppBar button: pick a day, then share that day's delivery slip as a PDF.
class BoutonBordereau extends StatelessWidget {
  /// Samples already loaded by the page; filtered on the chosen day here.
  final List<LigneBordereau> Function() lignes;
  final Color couleur;
  final BordereauPdfService? service;

  const BoutonBordereau({
    super.key,
    required this.lignes,
    this.couleur = const Color(0xFF6B8E7A),
    this.service,
  });

  void _message(BuildContext context, String texte) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texte),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _ouvrir(BuildContext context) async {
    final aujourdhui = DateTime.now();
    final jour = await showDatePicker(
      context: context,
      initialDate: aujourdhui,
      firstDate: DateTime(2020),
      lastDate: aujourdhui,
      helpText: 'Date du bordereau',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (jour == null || !context.mounted) return;

    final duJour = lignesDuJour(lignes(), jour);
    if (duJour.isEmpty) {
      _message(context, 'Aucun échantillon ajouté ce jour-là.');
      return;
    }
    try {
      await (service ?? BordereauPdfService()).partager(jour, duJour);
    } catch (_) {
      if (context.mounted) {
        _message(context, "Le bordereau n'a pas pu être créé. Réessayez.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Bordereau',
      icon: Icon(Icons.picture_as_pdf_outlined, size: 21, color: couleur),
      onPressed: () => _ouvrir(context),
    );
  }
}
