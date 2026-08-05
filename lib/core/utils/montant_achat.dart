// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/utils/montant_achat.dart
// PURPOSE : What a purchase actually costs — unit price × quantity.
//
//           The unit price is stored as free text ("7.95 TND/L") while the
//           quantity is in tonnes, so the two have to be reconciled before they
//           can be multiplied. That reconciliation lives here and nowhere else:
//           the confirmation dialog and the proposal details must never be able
//           to show two different totals for the same purchase.
// ═════════════════════════════════════════════════════════════════════════════

/// Olive oil is lighter than water: about 0.916 kg per litre at 20 °C.
///
/// Only used when the price is quoted per litre and the quantity in tonnes.
/// If the company prices per kilo instead, the price string says so and this
/// constant is never touched.
const double kDensiteHuileOlive = 0.916;

class MontantAchat {
  /// Total cost, or null when either figure is missing or unreadable.
  ///
  /// [prixUnitaire] is the stored text, e.g. "7.95 TND/L".
  /// [quantiteTonnes] is the stored quantity in tonnes, e.g. "28".
  static double? calculer(String? prixUnitaire, String? quantiteTonnes) {
    final prix = _nombre(prixUnitaire);
    final tonnes = _nombre(quantiteTonnes);
    if (prix == null || tonnes == null) return null;

    final kilos = tonnes * 1000;
    switch (_unite(prixUnitaire!)) {
      case _Unite.parLitre:
        return prix * (kilos / kDensiteHuileOlive);
      case _Unite.parKilo:
        return prix * kilos;
      case _Unite.parTonne:
        return prix * tonnes;
    }
  }

  /// "243 015 TND" — grouped by thousands, no decimals.
  ///
  /// A purchase total runs into the hundreds of thousands; centimes would only
  /// add noise to a figure read at a glance before committing.
  static String? formater(String? prixUnitaire, String? quantiteTonnes) {
    final total = calculer(prixUnitaire, quantiteTonnes);
    if (total == null) return null;
    return '${_espacerMilliers(total.round())} TND';
  }

  // ── Parsing ─────────────────────────────────────────────────────────────────

  /// First number in the text, comma or dot as decimal separator.
  static double? _nombre(String? texte) {
    if (texte == null) return null;
    final m = RegExp(r'\d+(?:[.,]\d+)?').firstMatch(texte.replaceAll(' ', ''));
    if (m == null) return null;
    return double.tryParse(m.group(0)!.replaceAll(',', '.'));
  }

  static _Unite _unite(String prixUnitaire) {
    final t = prixUnitaire.toLowerCase();
    if (t.contains('/kg') || t.contains('/ kg')) return _Unite.parKilo;
    if (t.contains('/t')) return _Unite.parTonne;
    // Per litre is how the price is quoted today; it stays the default so a
    // price written without a unit is not silently read a thousand times too low.
    return _Unite.parLitre;
  }

  static String _espacerMilliers(int n) {
    final chiffres = n.abs().toString();
    final buffer = StringBuffer(n < 0 ? '-' : '');
    for (var i = 0; i < chiffres.length; i++) {
      if (i > 0 && (chiffres.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(chiffres[i]);
    }
    return buffer.toString();
  }
}

enum _Unite { parLitre, parKilo, parTonne }
