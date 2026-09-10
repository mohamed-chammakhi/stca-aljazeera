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

  /// Formats a server date (ISO 8601, e.g. "2026-09-07T11:25:21.385451+01:00")
  /// for display as "07/09/2026". Returns the original text unchanged if it
  /// isn't a parseable date, and an empty string for null/empty input.
  static String formaterAffichage(dynamic valeur) {
    if (valeur == null) return '';
    final texte = valeur.toString();
    if (texte.isEmpty) return '';
    final parsed = DateTime.tryParse(texte);
    if (parsed == null) return texte;
    final jour = parsed.day.toString().padLeft(2, '0');
    final mois = parsed.month.toString().padLeft(2, '0');
    return '$jour/$mois/${parsed.year}';
  }
}
