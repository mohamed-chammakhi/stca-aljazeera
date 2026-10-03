import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../services/bordereau_pdf_service.dart';

class ApercuBordereauPage extends StatelessWidget {
  final DateTime debut;
  final DateTime fin;
  final List<LigneBordereau> lignes;
  final BordereauPdfService service;

  const ApercuBordereauPage({
    super.key,
    required this.debut,
    required this.fin,
    required this.lignes,
    required this.service,
  });

  Future<void> _partager(BuildContext context) async {
    try {
      final octets = await service.genererPdf(debut, fin, lignes);
      await Printing.sharePdf(
        bytes: octets,
        filename: service.nomFichier(debut, fin),
      );
    } catch (_) {
      if (context.mounted) _erreur(context);
    }
  }

  Future<void> _imprimer(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (_) => service.genererPdf(debut, fin, lignes),
        name: service.nomFichier(debut, fin),
      );
    } catch (_) {
      if (context.mounted) _erreur(context);
    }
  }

  void _erreur(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Le bordereau n'a pas pu être créé. Réessayez."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bordereau'),
        actions: [
          IconButton(
            tooltip: 'Partager',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _partager(context),
          ),
          IconButton(
            tooltip: 'Imprimer',
            icon: const Icon(Icons.print_outlined),
            onPressed: () => _imprimer(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) => service.genererPdf(debut, fin, lignes),
        initialPageFormat: PdfPageFormat.a4,
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        useActions: false,
        onError: (context, error) => const Center(
          child: Text("Le bordereau n'a pas pu être créé. Réessayez."),
        ),
      ),
    );
  }
}