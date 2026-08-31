import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/utils/reference_bouteille.dart';

void main() {
  group('Référence bouteille automatique', () {
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

    test('ne remplace plus une référence corrigée manuellement', () {
      expect(
        actualiserReferenceBouteille(
          referenceActuelle: 'REFERENCE-CORRIGEE',
          referenceModifieeManuellement: true,
          fournisseur: 'S.T',
          numeroCiterne: 'C4',
          quantite: '40',
        ),
        'REFERENCE-CORRIGEE',
      );
    });

    test('attend que les trois informations soient renseignées', () {
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
