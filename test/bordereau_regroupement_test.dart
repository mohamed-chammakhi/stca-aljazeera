import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/services/bordereau_pdf_service.dart';

LigneBordereau _ligne({
  required String fournisseur,
  required String reference,
  DateTime? date,
  String gouvernorat = 'Sfax',
  String? delegation,
  String? citerne,
  String? quantite,
  String? remarque,
  String? collecteur,
}) => LigneBordereau(
  dateAjout: date ?? DateTime(2026, 9, 28, 10),
  fournisseur: fournisseur,
  gouvernorat: gouvernorat,
  delegation: delegation,
  referenceBouteille: reference,
  numCiterne: citerne,
  quantiteEstimee: quantite,
  remarque: remarque,
  collecteur: collecteur,
);

void main() {
  test('les échantillons du même fournisseur sont sur une seule ligne', () {
    final groupes = regrouperBordereau([
      _ligne(
        fournisseur: 'Hami',
        reference: 'HAMI-C1-10T',
        delegation: 'Sfax Sud',
        citerne: 'C1',
        quantite: '10',
      ),
      _ligne(fournisseur: 'Ben Ali', reference: 'BA-C3', citerne: 'C3'),
      _ligne(
        fournisseur: 'Hami',
        reference: 'HAMI-C2-8T',
        delegation: 'Sfax Sud',
        citerne: 'C2',
        quantite: '8T',
        remarque: 'Huile trouble',
      ),
    ]);

    expect(groupes, hasLength(2));
    expect(groupes.first.fournisseur, 'Hami');
    expect(groupes.first.zone, 'Sfax — Sfax Sud');
    expect(groupes.first.references, ['HAMI-C1-10T', 'HAMI-C2-8T']);
    expect(groupes.first.scellages, ['C1 — 10T', 'C2 — 8T']);
    expect(groupes.first.remarques, ['Huile trouble']);
    expect(groupes.last.zone, 'Sfax');
    expect(groupes.last.scellages, ['C3']);
  });

  test('deux homonymes de lieux différents restent séparés', () {
    final groupes = regrouperBordereau([
      _ligne(fournisseur: 'Omar', reference: 'O-1', gouvernorat: 'Sfax'),
      _ligne(fournisseur: 'Omar', reference: 'O-2', gouvernorat: 'Gabès'),
    ]);

    expect(groupes, hasLength(2));
  });

  test('seuls les échantillons du jour choisi sont gardés', () {
    final lignes = [
      _ligne(fournisseur: 'Hami', reference: 'A', date: DateTime(2026, 9, 28, 8)),
      _ligne(fournisseur: 'Hami', reference: 'B', date: DateTime(2026, 9, 27, 23)),
    ];

    final duJour = lignesDuJour(lignes, DateTime(2026, 9, 28));

    expect(duJour.map((l) => l.referenceBouteille), ['A']);
    expect(lignesDuJour(lignes, DateTime(2026, 9, 26)), isEmpty);
  });

  test('les agents sont listés une seule fois', () {
    final agents = agentsBordereau([
      _ligne(fournisseur: 'Hami', reference: 'A', collecteur: 'Ahmed Dridi'),
      _ligne(fournisseur: 'Omar', reference: 'B', collecteur: 'Sami Khaled'),
      _ligne(fournisseur: 'Hami', reference: 'C', collecteur: 'Ahmed Dridi'),
    ]);

    expect(agents, ['Ahmed Dridi', 'Sami Khaled']);
  });

  test('la date d\u2019ajout est lue en ISO ou en jj/mm/aaaa', () {
    expect(dateDepuisTexte('28/09/2026'), DateTime(2026, 9, 28));
    expect(dateDepuisTexte('2026-09-28T09:00:00')?.day, 28);
    expect(dateDepuisTexte(''), isNull);
  });
}
