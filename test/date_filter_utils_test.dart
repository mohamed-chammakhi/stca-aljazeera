import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/analyses/ligne_analyse_labo.dart' as analyse;
import 'package:project3/core/models/echantillon.dart' as gestion;
import 'package:project3/core/models/echantillon_evaluation.dart' as evaluation;
import 'package:project3/core/models/enums.dart';
import 'package:project3/core/utils/date_filter_utils.dart';
import 'package:project3/core/widgets/search_date_filter_bar.dart';

void main() {
  group('Filtre dates unifie', () {
    test('compare une date ISO sur une periode inclusive', () {
      expect(
        dateCorrespondAuFiltre(
          '2026-03-15T10:30:00Z',
          debut: DateTime(2026, 3, 15),
          fin: DateTime(2026, 3, 20),
        ),
        isTrue,
      );
      expect(
        dateCorrespondAuFiltre(
          '2026-03-21',
          debut: DateTime(2026, 3, 15),
          fin: DateTime(2026, 3, 20),
        ),
        isFalse,
      );
    });

    test('compare une date francaise et refuse une valeur vide', () {
      expect(
        dateCorrespondAuFiltre('15/03/2026', debut: DateTime(2026, 3, 15)),
        isTrue,
      );
      expect(
        dateCorrespondAuFiltre(null, debut: DateTime(2026, 3, 15)),
        isFalse,
      );
    });

    test('resout les trois dates de gestion echantillon', () {
      final echantillon = gestion.Echantillon(
        id: 'sample-1',
        numero: '2026/0001',
        fournisseurId: 'supplier-1',
        collecteurId: 'collector-1',
        gouvernorat: 'Sfax',
        referenceBouteille: 'CHEMLALI-C1',
        statutCollecteur: StatutCollecteur.receptionne,
        dateAjout: '2026-03-01',
        dateArriveeEchantillon: '2026-03-10',
        dateReceptionEchantillon: '2026-03-12',
      );

      expect(
        dateGestionEchantillon(echantillon, DateFilterType.enregistrement),
        '2026-03-01',
      );
      expect(
        dateGestionEchantillon(
          echantillon,
          DateFilterType.livraisonEchantillon,
        ),
        '2026-03-10',
      );
      expect(
        dateGestionEchantillon(echantillon, DateFilterType.receptionPhysique),
        '2026-03-12',
      );
    });

    test(
      'livraison echantillon reste la date annoncee apres achat confirme',
      () {
        final echantillon = gestion.Echantillon(
          id: 'sample-achat',
          numero: '2026/10000',
          fournisseurId: 'supplier-1',
          collecteurId: 'collector-1',
          gouvernorat: 'Sfax',
          referenceBouteille: 'CHEMLALI-C10000',
          statutCollecteur: StatutCollecteur.achatConfirme,
          dateAjout: '2026-10-01',
          dateArriveeEchantillon: '2026-10-10T08:00:00Z',
          dateReceptionEchantillon: '2026-10-12T09:30:00Z',
        );
        final livraison = dateGestionEchantillon(
          echantillon,
          DateFilterType.livraisonEchantillon,
        );

        expect(
          dateCorrespondAuFiltre(livraison, debut: DateTime(2026, 10, 10)),
          isTrue,
        );
        expect(
          dateCorrespondAuFiltre(livraison, debut: DateTime(2026, 10, 12)),
          isFalse,
        );
      },
    );

    test('resout les trois dates devaluation echantillon', () {
      final echantillon = evaluation.Echantillon(
        id: 'sample-1',
        referenceBouteille: 'REF-1',
        numero: '2026/0001',
        fournisseur: 'Domaine Test',
        dateArriveeEchantillon: '2026-03-10',
        dateAjout: '2026-03-01',
        dateReceptionEchantillon: '2026-03-12',
        variete: 'Chemlali',
        statut: evaluation.StatutEchantillon.enAttente,
      );

      expect(
        dateEvaluationEchantillon(echantillon, DateFilterType.enregistrement),
        '2026-03-01',
      );
      expect(
        dateEvaluationEchantillon(
          echantillon,
          DateFilterType.livraisonEchantillon,
        ),
        '2026-03-10',
      );
      expect(
        dateEvaluationEchantillon(
          echantillon,
          DateFilterType.receptionPhysique,
        ),
        '2026-03-12',
      );
    });

    test('resout les trois dates danalyse laboratoire', () {
      const ligne = analyse.LigneAnalyseLabo(
        id: 'analysis-1',
        echantillonId: 'sample-1',
        numero: '2026/0001',
        referenceBouteille: 'CHEMLALI-C1',
        echantillonNom: 'Chemlali - Sfax',
        technicienNom: 'Technicien Test',
        statut: analyse.StatutAnalyse.enAttente,
        dateAjout: '01/03/2026',
        dateArriveeEchantillon: '10/03/2026',
        dateReceptionEchantillon: '12/03/2026',
      );

      expect(
        dateAnalyseLabo(ligne, DateFilterType.enregistrement),
        '01/03/2026',
      );
      expect(
        dateAnalyseLabo(ligne, DateFilterType.livraisonEchantillon),
        '10/03/2026',
      );
      expect(
        dateAnalyseLabo(ligne, DateFilterType.receptionPhysique),
        '12/03/2026',
      );
    });
  });
}
