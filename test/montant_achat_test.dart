import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/utils/montant_achat.dart';

void main() {
  group('MontantAchat', () {
    test('lit un prix sans unité comme un prix par tonne', () {
      expect(MontantAchat.calculer('8000', '30'), 240000);
      expect(MontantAchat.formater('8000', '30'), '240 000 TND');
    });

    test('conserve le total d’un ancien prix explicite par litre', () {
      expect(
        MontantAchat.calculer('9.50 TND/L', '30'),
        closeTo(311135.3711790393, 0.0001),
      );
    });
  });
}
