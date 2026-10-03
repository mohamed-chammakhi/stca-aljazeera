import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/utils/date_utils.dart';

void main() {
  test('parseDate lit le format JJ/MM/AAAA et le format ISO du serveur', () {
    expect(DegDateUtils.parseDate('03/10/2026'), DateTime(2026, 10, 3));
    expect(
      DegDateUtils.parseDate('2026-10-03T08:41:00'),
      DateTime(2026, 10, 3),
    );
    expect(DegDateUtils.parseDate(''), isNull);
  });

  test('formaterSaisie rend une date d’arrivée lisible et la reconvertit', () {
    const iso = '2026-09-25T18:05:28.815240+01:00';
    expect(DegDateUtils.formaterSaisie(iso), '25/09/2026');
    expect(
      DegDateUtils.dateSaisieVersIso('25/09/2026'),
      '2026-09-25T00:00:00.000',
    );
  });
}
