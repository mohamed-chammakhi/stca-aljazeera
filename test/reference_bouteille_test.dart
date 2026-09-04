import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/utils/reference_bouteille.dart';

void main() {
  group('Reference bouteille automatique', () {
    test('assemble fournisseur, citerne et tonnage', () {
      expect(
        construireReferenceBouteille(
          fournisseur: 'S.T',
          numeroCiterne: 'C3',
          quantite: '30',
        ),
        'S.T_C3_30T',
      );
    });

    test('remplace une reference corrigee quand les sources changent', () {
      expect(
        actualiserReferenceBouteille(
          fournisseur: 'S.T',
          numeroCiterne: 'C4',
          quantite: '40',
        ),
        'S.T_C4_40T',
      );
    });

    test('attend que les trois informations soient renseignees', () {
      expect(
        construireReferenceBouteille(
          fournisseur: 'S.T',
          numeroCiterne: '',
          quantite: '30',
        ),
        isEmpty,
      );
    });

    test('supprime les espaces du nom du fournisseur', () {
      expect(
        construireReferenceBouteille(
          fournisseur: 'Domaine Bel Air',
          numeroCiterne: 'C3',
          quantite: '30',
        ),
        'DomaineBelAir_C3_30T',
      );
    });
  });
}
