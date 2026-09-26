import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/models/echantillon.dart';

void main() {
  test("une classification vide ('') se lit comme « pas encore classé »", () {
    final e = Echantillon.fromJson({
      'id': 'a',
      'numero': '2026/0012',
      'fournisseur_id': '',
      'collecteur_id': '',
      'gouvernorat': 'Gabes',
      'reference_bouteille': 'hami_r_5555T',
      'statut_collecteur': 'receptionne',
      'classification': '',
      'date_ajout': '2026-09-25T10:00:00Z',
    });

    expect(e.classification, isNull);
  });
}
