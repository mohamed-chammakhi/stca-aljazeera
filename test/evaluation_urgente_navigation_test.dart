import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project3/core/api_client.dart';
import 'package:project3/core/models/echantillon_evaluation.dart';
import 'package:project3/core/services/resultat_service.dart';
import 'package:project3/3_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart'
    as degustateur;
import 'package:project3/core/widgets/evaluation_echantillons/echantillon_card.dart'
    as carte_evaluation;
import 'package:project3/core/services/evaluation_service.dart';
import 'package:project3/3_degustateur/notifications/services/notification_degustateur_service.dart';
import 'package:project3/5_chef_degustateur/evaluation_echantillons/evaluation_echantillons_page.dart'
    as chef;

List<Echantillon> _echantillons() => List.generate(
  12,
  (index) => Echantillon(
    id: 'ech-$index',
    referenceBouteille: 'REF-$index',
    fournisseur: 'Fournisseur',
    dateArriveeEchantillon: '05/08/2026',
    variete: 'Chemlali',
    statut: StatutEchantillon.enAttente,
  ),
);

class _EvaluationServiceFaux extends EvaluationService {
  final List<Echantillon> donnees;
  _EvaluationServiceFaux(this.donnees);

  @override
  Future<Resultat<List<Echantillon>>> fetchEchantillons() async =>
      Resultat(donnees);
}

class _EvaluationChefServiceFaux extends EvaluationService {
  final List<Echantillon> donnees;
  _EvaluationChefServiceFaux(this.donnees);

  @override
  Future<Resultat<List<Echantillon>>> fetchEchantillons() async =>
      Resultat(donnees);
}

class _ApiNotificationFausse extends ApiClient {
  String? chemin;
  Map<String, dynamic>? corps;

  @override
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    chemin = path;
    corps = body;
    return {'created': 1, 'recipients': 1};
  }
}

void main() {
  test('la demande urgente utilise la route réservée à la direction', () async {
    final api = _ApiNotificationFausse();
    final service = NotificationDegustateurService(api: api);

    await service.sendUrgentDegustation('echantillon-uuid');

    expect(api.chemin, '/api/notifications/evaluation-urgente/');
    expect(api.corps, {'echantillon': 'echantillon-uuid'});
  });

  testWidgets(
    'le dégustateur défile vers la carte ciblée et la met en évidence',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: degustateur.EvaluationEchantillonsPage(
            echantillonCible: 'ech-11',
            service: _EvaluationServiceFaux(_echantillons()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is carte_evaluation.EchantillonCard &&
              widget.echantillon.id == 'ech-11' &&
              widget.isHighlighted,
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('le chef défile vers la carte ciblée et la met en évidence', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: chef.EvaluationEchantillonsPage(
          echantillonCible: 'ech-11',
          service: _EvaluationChefServiceFaux(_echantillons()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is carte_evaluation.EchantillonCard &&
            widget.echantillon.id == 'ech-11' &&
            widget.isHighlighted,
      ),
      findsOneWidget,
    );
  });

  testWidgets("une cible absente laisse la page ouverte et l'explique", (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: degustateur.EvaluationEchantillonsPage(
          echantillonCible: 'absent',
          service: _EvaluationServiceFaux(_echantillons()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Évaluation des échantillons'), findsOneWidget);
    expect(
      find.text(
        "L'échantillon demandé n'est plus disponible dans cette liste.",
      ),
      findsOneWidget,
    );
  });

  testWidgets("une cible absente l'explique aussi au chef", (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: chef.EvaluationEchantillonsPage(
          echantillonCible: 'absent',
          service: _EvaluationChefServiceFaux(_echantillons()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Évaluation des échantillons'), findsOneWidget);
    expect(
      find.text(
        "L'échantillon demandé n'est plus disponible dans cette liste.",
      ),
      findsOneWidget,
    );
  });
}
