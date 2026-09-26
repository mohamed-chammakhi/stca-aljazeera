/// Reads a number sent by the server.
///
/// Django sends DecimalField values as text ("1234.00") and other numbers as
/// numbers; a plain `as num?` cast crashes on the first form and empties the
/// whole screen. Returns null for null, empty or unreadable values.
double? nombreDepuisJson(dynamic valeur) {
  if (valeur == null) return null;
  if (valeur is num) return valeur.toDouble();
  return double.tryParse(valeur.toString().trim().replaceAll(',', '.'));
}
