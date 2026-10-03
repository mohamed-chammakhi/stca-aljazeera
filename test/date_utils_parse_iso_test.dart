import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/utils/date_utils.dart';

void main() {
  test('parseDate lit le format JJ/MM/AAAA et le format ISO du serveur', () {
    expect(DegDateUtils.parseDate('03/10/2026'), DateTime(2026, 10, 3));
    expect(DegDateUtils.parseDate('2026-10-03T08:41:00'), DateTime(2026, 10, 3));
    expect(DegDateUtils.parseDate(''), isNull);
  });
}
