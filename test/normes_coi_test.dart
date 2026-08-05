// Table des normes COI — tests.
//
// Le cas central est le certificat 188-2026, un vrai rapport du laboratoire
// STCA Al Jazira. Il conclut « extra virgin olive oil » ; la table doit
// arriver à la même conclusion sur les mêmes 28 valeurs, sans en juger une
// seule hors norme. C'est la seule preuve dont on dispose que les seuils
// écrits dans le code correspondent à ceux qu'applique le laboratoire.

import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/analyses/normes_coi.dart';

/// Les 28 valeurs du certificat 188-2026, recopiées telles qu'imprimées.
const Map<String, double?> _rapport188 = {
  // Résultats principaux
  'acidite': 0.30,
  'indice_peroxyde': 9.71,
  'k232': 2.02,
  'k270': 0.12,
  'delta_k': 0.003,
  'humidite': 0.06,
  'impuretes': 0.03,
  'ecn42': 0.052,
  // Stérols
  'cholesterol': 0.09,
  'brassicasterol': 0.00,
  'campesterol': 3.30,
  'stigmasterol': 0.64,
  'beta_sitosterol_apparent': 95.00,
  'delta_7_stigmastenol': 0.36,
  'delta_7_avenasterol': 0.61,
  'erythrodiol_uvaol': 2.00,
  // Acides gras
  'acide_palmitique': 14.65,
  'acide_palmitoleique': 1.61,
  'acide_heptadecanoique': 0.05,
  'acide_heptadecenoique': 0.09,
  'acide_stearique': 2.56,
  'acide_oleique': 64.06,
  'acide_linoleique': 15.68,
  'acide_linolenique': 0.66,
  'acide_arachidique': 0.39,
  'acide_gadoleique': 0.21,
  'trans_c18_1': 0.02,
  'trans_c18_2_c18_3': 0.02,
};

void main() {
  group('Certificat 188-2026 — un vrai rapport', () {
    test('porte exactement les 28 paramètres de la table', () {
      expect(kTousParametres.length, 28);
      expect(_rapport188.length, 28);
      for (final p in kTousParametres) {
        expect(
          _rapport188.containsKey(p.cle),
          isTrue,
          reason: '${p.cle} manque au rapport de référence',
        );
      }
    });

    test('ne fait sortir aucune valeur de la norme', () {
      final hors = parametresHorsNormes(_rapport188);
      expect(
        hors,
        isEmpty,
        reason: 'jugés hors norme : ${hors.map((p) => p.label).join(', ')}',
      );
    });

    test('est classé extra vierge, comme le conclut le laboratoire', () {
      expect(classificationCoi(_rapport188), 'Extra Vierge');
    });
  });

  group('Les trois tableaux', () {
    test('comptent 8, 8 et 12 lignes, comme sur le papier', () {
      expect(kParametresPrincipaux.length, 8);
      expect(kSterols.length, 8);
      expect(kAcidesGras.length, 12);
    });

    test('n\'ont aucune clé en double', () {
      final cles = kTousParametres.map((p) => p.cle).toList();
      expect(cles.toSet().length, cles.length);
    });
  });

  group('Lecture des décimales', () {
    test('la virgule du rapport et le point du clavier donnent le même nombre', () {
      expect(lireDecimal('0,30'), 0.30);
      expect(lireDecimal('0.30'), 0.30);
      expect(lireDecimal('0,003'), 0.003);
    });

    test('un champ vide ou illisible ne vaut pas zéro', () {
      // Confondre « non mesuré » et « mesuré à zéro » ferait passer un rapport
      // incomplet pour un rapport parfait.
      expect(lireDecimal(''), isNull);
      expect(lireDecimal('   '), isNull);
      expect(lireDecimal('abc'), isNull);
      expect(lireDecimal(null), isNull);
    });

    test('les espaces de saisie sont ignorés', () {
      expect(lireDecimal(' 14,65 '), 14.65);
    });
  });

  group('Conformité', () {
    test('une valeur non saisie ne se juge pas', () {
      final acidite = kParametresPrincipaux.first;
      expect(conformite(acidite, null), isNull);
    });

    test('un paramètre sans seuil ne se juge pas non plus', () {
      // Le COI ne fixe pas de limite au Δ7-avénastérol.
      final avenasterol = kSterols.firstWhere(
        (p) => p.cle == 'delta_7_avenasterol',
      );
      expect(avenasterol.aUneNorme, isFalse);
      expect(conformite(avenasterol, 99.0), isNull);
    });

    test('la borne est inclusive : l\'acidité à 0,80 reste conforme', () {
      final acidite = kParametresPrincipaux.first;
      expect(conformite(acidite, 0.80), isTrue);
      expect(conformite(acidite, 0.81), isFalse);
    });

    test('un intervalle se juge des deux côtés', () {
      final oleique = kAcidesGras.firstWhere((p) => p.cle == 'acide_oleique');
      expect(conformite(oleique, 54.9), isFalse);
      expect(conformite(oleique, 55.0), isTrue);
      expect(conformite(oleique, 83.0), isTrue);
      expect(conformite(oleique, 83.1), isFalse);
    });

    test('le stigmastérol se juge contre le campestérol, pas contre un seuil', () {
      final stigmasterol = kSterols.firstWhere((p) => p.cle == 'stigmasterol');

      expect(
        conformite(stigmasterol, 0.64, valeurs: {'campesterol': 3.30}),
        isTrue,
      );
      expect(
        conformite(stigmasterol, 4.00, valeurs: {'campesterol': 3.30}),
        isFalse,
      );
      // Sans campestérol, la question n'a pas de réponse.
      expect(conformite(stigmasterol, 0.64), isNull);
    });
  });

  group('Classement COI', () {
    // Les quatre grandeurs de dégradation suffisent au classement.
    Map<String, double?> base({
      double? acidite = 0.30,
      double? peroxyde = 9.71,
      double? k232 = 2.02,
      double? k270 = 0.12,
    }) => {
      'acidite': acidite,
      'indice_peroxyde': peroxyde,
      'k232': k232,
      'k270': k270,
    };

    test('reste indécidable tant qu\'une des quatre valeurs manque', () {
      expect(classificationCoi(base(k270: null)), isNull);
      expect(classificationCoi(const {}), isNull);
    });

    test('extra vierge quand les quatre sont dans les clous', () {
      expect(classificationCoi(base()), 'Extra Vierge');
    });

    test('une seule valeur suffit à faire descendre en vierge', () {
      expect(classificationCoi(base(acidite: 1.50)), 'Vierge');
      expect(classificationCoi(base(k270: 0.24)), 'Vierge');
    });

    test('lampante au-delà de vierge', () {
      expect(classificationCoi(base(acidite: 3.00)), 'Lampante');
      expect(classificationCoi(base(peroxyde: 25.0)), 'Lampante');
    });

    test('un stérol hors norme ne change pas le classement', () {
      // Un stérol anormal trahit un mélange, pas une dégradation : il doit
      // déclencher l'alerte sans toucher au classement, sinon le directeur
      // verrait « Lampante » là où le laboratoire écrit « extra vierge ».
      final melange = {..._rapport188, 'campesterol': 5.20};
      expect(classificationCoi(melange), 'Extra Vierge');
      expect(parametresHorsNormes(melange).map((p) => p.cle), ['campesterol']);
    });
  });

  group('Affichage des valeurs', () {
    test('deux décimales par défaut', () {
      expect(formatValeur(0.30), '0.30');
      expect(formatValeur(64.06), '64.06');
      expect(formatValeur(0.0), '0.00');
    });

    test('trois décimales sous 0,01, sinon le ΔK disparaîtrait', () {
      expect(formatValeur(0.003), '0.003');
    });

    test('l\'unité suit la valeur, et un tiret marque l\'absence', () {
      expect(formatValeurUnite(14.65, '%'), '14.65 %');
      expect(formatValeurUnite(2.02, ''), '2.02');
      expect(formatValeurUnite(null, '%'), '—');
    });
  });

  group('Libellés de norme', () {
    test('disent la contrainte telle qu\'elle est', () {
      expect(kParametresPrincipaux.first.norme, '≤ 0.80');
      expect(
        kSterols.firstWhere((p) => p.cle == 'beta_sitosterol_apparent').norme,
        '≥ 93',
      );
      expect(
        kAcidesGras.firstWhere((p) => p.cle == 'acide_oleique').norme,
        '55 – 83',
      );
      expect(
        kSterols.firstWhere((p) => p.cle == 'stigmasterol').norme,
        '< campestérol',
      );
      expect(
        kSterols.firstWhere((p) => p.cle == 'delta_7_avenasterol').norme,
        '—',
      );
    });
  });
}
