class DegDateUtils {
  static DateTime? parseDate(String s) {
    try {
      final datePart = s.split(' ').first;
      final p = datePart.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }
}
