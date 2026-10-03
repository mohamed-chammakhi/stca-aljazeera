class DegDateUtils {
  static DateTime? parseDate(String s) {
    // Server ISO 8601 text (e.g. date_ajout) as well as JJ/MM/AAAA.
    final iso = DateTime.tryParse(s.trim());
    if (iso != null) {
      final local = iso.toLocal();
      return DateTime(local.year, local.month, local.day);
    }
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

  static String formaterDateHeure(dynamic valeur) {
    if (valeur == null) return '';
    final texte = valeur.toString().trim();
    if (texte.isEmpty) return '';

    final parsed = DateTime.tryParse(texte);
    if (parsed != null) {
      final local = parsed.toLocal();
      final jour = local.day.toString().padLeft(2, '0');
      final mois = local.month.toString().padLeft(2, '0');
      final date = '$jour/$mois/${local.year}';
      if (!texte.contains('T') && !texte.contains(':')) return date;
      final heure = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$date $heure:$minute';
    }

    final dejaFormatee = RegExp(
      r'^(\d{2}/\d{2}/\d{4})(?: (\d{2}:\d{2}))?$',
    ).firstMatch(texte);
    if (dejaFormatee != null) {
      return dejaFormatee.group(2) == null
          ? dejaFormatee.group(1)!
          : '${dejaFormatee.group(1)} ${dejaFormatee.group(2)}';
    }
    return '';
  }

  static String formaterDateHeureOuTiret(dynamic valeur) {
    final texte = formaterDateHeure(valeur);
    return texte.isEmpty ? '—' : texte;
  }
}
