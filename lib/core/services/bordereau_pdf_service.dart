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

List<LigneBordereau> lignesDeLaPeriode(
  List<LigneBordereau> lignes,
  DateTime debut,
  DateTime fin,
) {
  final debutLocal = DateTime(debut.year, debut.month, debut.day);
  final finExclusive = DateTime(fin.year, fin.month, fin.day + 1);
  return lignes.where((ligne) {
    final dateLocale = ligne.dateAjout.toLocal();
    return !dateLocale.isBefore(debutLocal) && dateLocale.isBefore(finExclusive);
  }).toList();
}

List<LigneBordereau> lignesDuJour(List<LigneBordereau> lignes, DateTime jour) =>
    lignesDeLaPeriode(lignes, jour, jour);

String messageAucunEchantillon(DateTime debut, DateTime fin) {
  final estUnJour = _memeJour(debut, fin);
  return estUnJour
      ? 'Aucun échantillon enregistré dans l’application ce jour-là.'
      : 'Aucun échantillon enregistré dans l’application pendant cette période.';
}

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

/// Groups the samples of one period by supplier, in order of first appearance.
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
          _texte(l.remarque),
      ],
    );
  }).toList();
}

/// Distinct collector names of the period, in order of first appearance.
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
  Future<Uint8List> genererPdf(
    DateTime debut,
    DateTime fin,
    List<LigneBordereau> lignes,
  ) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Domine/static/Domine-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Domine/static/Domine-Bold.ttf'),
    );
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/img/Aljazia_logo.png')).buffer.asUint8List(),
    );
    final groupes = regrouperBordereau(lignes);
    final agents = agentsBordereau(lignes);
    final dateCreation = _dateLisible(DateTime.now());
    final periode = _memeJour(debut, fin)
        ? 'Jour : ${_dateLisible(debut)}'
        : 'Période : du ${_dateLisible(debut)} au ${_dateLisible(fin)}';

    pw.Widget cellule(String texte, {bool entete = false}) => pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        texte,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: entete ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );

    pw.Widget entetePage(pw.Context context) => pw.Column(
      children: [
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 130,
                padding: const pw.EdgeInsets.all(8),
                child: pw.Image(logo, height: 48),
              ),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: double.infinity,
                      color: PdfColors.grey200,
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        "Bordereau de réception des échantillons d'information",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Row(
                      children: [
                        cellule('Date : $dateCreation'),
                        cellule('Ver : 00'),
                        cellule('Page ${context.pageNumber}/${context.pagesCount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, bottom: 8),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(periode, style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ],
    );

    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 28),
        header: entetePage,
        build: (context) => [
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
                repeat: true,
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  cellule('GOUVERNORAT / ZONE', entete: true),
                  cellule('FOURNISSEUR', entete: true),
                  cellule('RÉFÉRENCE COLLECTEUR', entete: true),
                  cellule('SCELLAGE', entete: true),
                  cellule('REMARQUES', entete: true),
                ],
              ),
              for (var index = 0; index < groupes.length; index++)
                pw.TableRow(
                  decoration: index.isOdd
                      ? const pw.BoxDecoration(color: PdfColors.grey100)
                      : null,
                  children: [
                    cellule(groupes[index].zone),
                    cellule(groupes[index].fournisseur),
                    cellule(groupes[index].references.join('\n')),
                    cellule(groupes[index].scellages.join('\n')),
                    cellule(groupes[index].remarques.join('\n')),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: cellule('DATE : $dateCreation')),
              pw.Expanded(
                flex: 2,
                child: cellule(
                  'AGENT : ${agents.isEmpty ? '—' : agents.join(', ')}',
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  children: [
                    cellule('SIGNATURE'),
                    pw.SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return document.save();
  }

  String nomFichier(DateTime debut, DateTime fin) {
    String date(DateTime valeur) =>
        '${valeur.year}-${valeur.month.toString().padLeft(2, '0')}-${valeur.day.toString().padLeft(2, '0')}';
    return _memeJour(debut, fin)
        ? 'bordereau_${date(debut)}.pdf'
        : 'bordereau_${date(debut)}_${date(fin)}.pdf';
  }
}
