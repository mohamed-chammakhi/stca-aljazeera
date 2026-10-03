import 'package:flutter/material.dart';

import '../services/bordereau_pdf_service.dart';
import 'apercu_bordereau_page.dart';

/// AppBar button: pick a period, then open its PDF preview.
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
    final periode = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: aujourdhui, end: aujourdhui),
      firstDate: DateTime(2020),
      lastDate: aujourdhui,
      helpText: 'Période du bordereau',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      saveText: 'Valider',
      fieldStartLabelText: 'Du',
      fieldEndLabelText: 'Au',
    );
    if (periode == null || !context.mounted) return;

    final debut = DateTime(
      periode.start.year,
      periode.start.month,
      periode.start.day,
    );
    final fin = DateTime(periode.end.year, periode.end.month, periode.end.day);
    final selection = lignesDeLaPeriode(lignes(), debut, fin);
    if (selection.isEmpty) {
      _message(context, messageAucunEchantillon(debut, fin));
      return;
    }
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ApercuBordereauPage(
            debut: debut,
            fin: fin,
            lignes: selection,
            service: service ?? BordereauPdfService(),
          ),
        ),
      );
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
