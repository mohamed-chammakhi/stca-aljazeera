import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/models/enums.dart';

void main() {
  test("les enums acceptent une valeur vide sans planter", () {
    expect(RoleUtilisateurX.fromJson(''), RoleUtilisateur.degustateur);
    expect(StatutCollecteurX.fromJson(''), StatutCollecteur.receptionne);
    expect(StatutDegustateurX.fromJson(''), StatutDegustateur.nonEvaluee);
    expect(StatutLaboX.fromJson(''), StatutLabo.enAttente);
    expect(StatutCeoX.fromJson(''), StatutCeo.selectionne);
    expect(ClassificationHuileX.fromJson(''), ClassificationHuile.extraVierge);
    expect(TypeFruiteX.fromJson(''), TypeFruite.vert);
    expect(ClasseInterneX.fromJson(''), isNull);
    expect(ModePlanificationX.fromJson(''), ModePlanification.dateExacte);
    expect(StatutSessionX.fromJson(''), StatutSession.planifiee);
    expect(PrioriteAnalyseX.fromJson(''), PrioriteAnalyse.normale);
  });
}
