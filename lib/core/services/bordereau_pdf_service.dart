import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/echantillon.dart';

/// One sample as it appears on a delivery slip.
class LigneBordereau {
  final DateTime dateAjout;
  final String fournisseur;
  final String gouvernorat;
  final String? delegation;
  final String referenceBouteille;
  final String? numCiterne;
  final String? quantiteEstimee;
  final String? remarque;
  final String? collecteur;

  const LigneBordereau({
    required this.dateAjout,
    required this.fournisseur,
    required this.gouvernorat,
    this.delegation,
    required this.referenceBouteille,
    this.numCiterne,
    this.quantiteEstimee,
    this.remarque,
    this.collecteur,
  });

  /// Returns null when the sample has no readable creation date.
  static LigneBordereau? depuisEchantillon(Echantillon e) {
    final date = dateDepuisTexte(e.dateAjout);
    if (date == null) return null;
    return LigneBordereau(
      dateAjout: date,
      fournisseur: e.fournisseurAffichage,
      gouvernorat: e.gouvernorat,
      delegation: e.delegation,
      referenceBouteille: e.referenceBouteille,
      numCiterne: e.numCiterne,
      quantiteEstimee: e.quantiteEstimee,
      remarque: e.remarqueCollecteur,
      collecteur: e.collecteurNom,
    );
  }
}

/// One table row: every sample of one supplier (same name and same place).
class GroupeBordereau {
  final String zone;
  final String fournisseur;
  final List<String> references;
  final List<String> scellages;
  final List<String> remarques;

  const GroupeBordereau({
    required this.zone,
    required this.fournisseur,
    required this.references,
    required this.scellages,
    required this.remarques,
  });
}

/// Accepts ISO 8601 (server) or dd/MM/yyyy (a sample just created in the form).
DateTime? dateDepuisTexte(String texte) {
  final iso = DateTime.tryParse(texte.trim());
  if (iso != null) return iso.toLocal();
  final parties = texte.trim().split('/');
  if (parties.length != 3) return null;
  final jour = int.tryParse(parties[0]);
  final mois = int.tryParse(parties[1]);
  final annee = int.tryParse(parties[2]);
  if (jour == null || mois == null || annee == null) return null;
  return DateTime(annee, mois, jour);
}

bool _memeJour(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

List<LigneBordereau> lignesDuJour(List<LigneBordereau> lignes, DateTime jour) =>
    lignes.where((l) => _memeJour(l.dateAjout.toLocal(), jour)).toList();

String _texte(String? valeur) => valeur?.trim() ?? '';

String scellageBordereau(LigneBordereau l) {
  final citerne = _texte(l.numCiterne);
  var quantite = _texte(l.quantiteEstimee);
  if (quantite.isNotEmpty && !quantite.toUpperCase().endsWith('T')) {
    quantite = '${quantite}T';
  }
  if (citerne.isEmpty && quantite.isEmpty) return '—';
  if (citerne.isEmpty) return quantite;
  if (quantite.isEmpty) return citerne;
  return '$citerne — $quantite';
}

/// Groups the samples of one day by supplier, in order of first appearance.
List<GroupeBordereau> regrouperBordereau(List<LigneBordereau> lignes) {
  final groupes = <String, List<LigneBordereau>>{};
  for (final ligne in lignes) {
    final cle = [
      _texte(ligne.fournisseur).toLowerCase(),
      _texte(ligne.gouvernorat).toLowerCase(),
      _texte(ligne.delegation).toLowerCase(),
    ].join('|');
    groupes.putIfAbsent(cle, () => []).add(ligne);
  }
  return groupes.values.map((lignesFournisseur) {
    final premiere = lignesFournisseur.first;
    final delegation = _texte(premiere.delegation);
    final gouvernorat = _texte(premiere.gouvernorat);
    final zone = delegation.isEmpty
        ? gouvernorat
        : (gouvernorat.isEmpty ? delegation : '$gouvernorat — $delegation');
    final fournisseur = _texte(premiere.fournisseur);
    return GroupeBordereau(
      zone: zone.isEmpty ? '—' : zone,
      fournisseur: fournisseur.isEmpty ? '—' : fournisseur,
      references: [
        for (final l in lignesFournisseur) _texte(l.referenceBouteille),
      ],
      scellages: [for (final l in lignesFournisseur) scellageBordereau(l)],
      remarques: [
        for (final l in lignesFournisseur)
          if (_texte(l.remarque).isNotEmpty) _texte(l.remarque),
      ],
    );
  }).toList();
}

/// Distinct collector names of the day, in order of first appearance.
List<String> agentsBordereau(List<LigneBordereau> lignes) {
  final noms = <String>[];
  for (final l in lignes) {
    final nom = _texte(l.collecteur);
    if (nom.isNotEmpty && !noms.contains(nom)) noms.add(nom);
  }
  return noms;
}

String _dateLisible(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/'
    '${d.month.toString().padLeft(2, '0')}/${d.year}';

class BordereauPdfService {
  Future<Uint8List> genererPdf(DateTime jour, List<LigneBordereau> lignes) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Alegreya/static/Alegreya-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Alegreya/static/Alegreya-Bold.ttf'),
    );
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/img/Aljazia_logo.png')).buffer.asUint8List(),
    );
    final groupes = regrouperBordereau(lignes);
    final agents = agentsBordereau(lignes);
    final date = _dateLisible(jour);

    pw.Widget cellule(String texte, {bool entete = false}) => pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        texte,
        style: pw.TextStyle(
          fontSize: entete ? 10 : 9,
          fontWeight: entete ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );

    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(logo, height: 48),
              pw.SizedBox(width: 16),
              pw.Expanded(
                child: pw.Text(
                  "Bordereau de réception des échantillons d'information",
                  style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text('Date : $date', style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 14),
          pw.Table(
            border: pw.TableBorder.all(width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(2.2),
              3: pw.FlexColumnWidth(1.8),
              4: pw.FlexColumnWidth(2.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  cellule('Gouvernorat / Zone', entete: true),
                  cellule('Fournisseur', entete: true),
                  cellule('Référence collecteur', entete: true),
                  cellule('Scellage', entete: true),
                  cellule('Remarques', entete: true),
                ],
              ),
              for (final g in groupes)
                pw.TableRow(
                  children: [
                    cellule(g.zone),
                    cellule(g.fournisseur),
                    cellule(g.references.join('\n')),
                    cellule(g.scellages.join('\n')),
                    cellule(g.remarques.join('\n')),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Table(
            border: pw.TableBorder.all(width: 0.6),
            children: [
              pw.TableRow(
                children: [
                  cellule('DATE', entete: true),
                  cellule('AGENT', entete: true),
                  cellule('SIGNATURE', entete: true),
                ],
              ),
              pw.TableRow(
                children: [
                  cellule(date),
                  cellule(agents.isEmpty ? '—' : agents.join('\n')),
                  pw.SizedBox(height: 48),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    return document.save();
  }

  Future<void> partager(DateTime jour, List<LigneBordereau> lignes) async {
    final octets = await genererPdf(jour, lignes);
    final nomJour =
        '${jour.year}-${jour.month.toString().padLeft(2, '0')}-${jour.day.toString().padLeft(2, '0')}';
    await Printing.sharePdf(bytes: octets, filename: 'bordereau_$nomJour.pdf');
  }
}
