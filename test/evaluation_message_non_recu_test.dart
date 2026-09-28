import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/api_client.dart';
import 'package:project3/core/services/evaluation_service.dart';

void main() {
  const texte =
      "Cet échantillon n'est pas encore arrivé à la société. Cochez d'abord "
      "« Réception physique » sur sa fiche, puis soumettez l'évaluation.";

  test('le message « échantillon non reçu » est affiché tel quel', () {
    final erreur = ApiException(
      400,
      '{echantillon: [$texte]}',
      champs: {
        'echantillon': [texte],
      },
    );

    expect(EvaluationService().messageFor(erreur), texte);
  });

  test('sans erreur de champ, le message du serveur reste affiché', () {
    final erreur = ApiException(400, 'Évaluation déjà soumise.');

    expect(EvaluationService().messageFor(erreur), 'Évaluation déjà soumise.');
  });
}
