import 'package:flutter_test/flutter_test.dart';
import 'package:project3/1_ceo/utilisateurs/models/echantillon_ceo_view.dart';

EchantillonCeoView defaultEchantillonView({
  required String id,
  String? numero,
}) => EchantillonCeoView(
  id: id,
  numero: numero,
  referenceBouteille: 'REF-001',
  gouvernorat: 'Sfax',
  fournisseurTexte: 'Fournisseur',
  dateAjout: '03/10/2026',
  statut: StatutCeo.selectionne,
  totalTasteurs: 0,
);

void main() {
  test('conserve UUID serveur et numéro d affichage séparément', () {
    final view = defaultEchantillonView(
      id: '550e8400-e29b-41d4-a716-446655440000',
      numero: '2026/0012',
    );

    expect(view.id, '550e8400-e29b-41d4-a716-446655440000');
    expect(view.numero, '2026/0012');
  });
}
