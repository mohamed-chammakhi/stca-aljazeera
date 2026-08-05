import '../../../core/api_client.dart';
import '../../../core/services/resultat_service.dart';
import '../models/dashboard_degustateur.dart';

typedef PageActiviteDegustateur = ({List<ActiviteItem> items, int total});

class DashboardDegustateurService {
  final ApiClient _api;

  DashboardDegustateurService({ApiClient? api}) : _api = api ?? apiClient;

  Future<Resultat<List<EvaluationUrgente>>> fetchUrgentes() => avecSecours(
    () async => (await _api.getList('/api/degustateur/dashboard/urgentes/'))
        .map((json) => EvaluationUrgente.fromJson(json as Map<String, dynamic>))
        .toList(),
    () => [
      const EvaluationUrgente(
        id: 'aaa00000-0000-0000-0000-000000000001',
        reference: 'Chemlali · 2026/0001',
        collecteurNom: 'Ahmed Dridi',
        fournisseurNom: 'Domaine Bel-Air',
        joursEnAttente: 14,
      ),
      const EvaluationUrgente(
        id: 'aaa00000-0000-0000-0000-000000000004',
        reference: 'Oueslati · 2026/0004',
        collecteurNom: 'Nour Messaoud',
        fournisseurNom: 'Green Valley',
        joursEnAttente: 8,
      ),
    ],
  );

  Future<List<EvaluationUrgenteCeo>> fetchUrgentesCeo() async {
    return [
      const EvaluationUrgenteCeo(
        id: 'aaa00000-0000-0000-0000-000000000005',
        reference: 'Chemlali · 2026/0005',
        collecteurNom: 'Ahmed Dridi',
        fournisseurNom: 'Domaine Bel-Air',
      ),
    ];
  }

  Future<Resultat<PipelineData>> fetchPipeline() => avecSecours(
    () async => PipelineData.fromJson(
      await _api.get('/api/degustateur/dashboard/pipeline/'),
    ),
    () => const PipelineData(
      receptionne: 8,
      nonEvaluee: 3,
      enCours: 2,
      soumise: 3,
    ),
  );

  Future<Resultat<List<ClassificationPoint>>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) => avecSecours(
    () async => (await _api.getList(_cheminAvecDates(
      '/api/degustateur/dashboard/classifications/',
      dateDebut: dateDebut,
      dateFin: dateFin,
    )))
        .map((json) => ClassificationPoint.fromJson(json as Map<String, dynamic>))
        .toList(),
    () => const [
      ClassificationPoint(label: 'Jan', extraVierge: 4, vierge: 2, lampante: 1),
      ClassificationPoint(label: 'Fév', extraVierge: 3, vierge: 3, lampante: 2),
      ClassificationPoint(label: 'Mar', extraVierge: 5, vierge: 1, lampante: 1),
      ClassificationPoint(label: 'Avr', extraVierge: 6, vierge: 2, lampante: 0),
    ],
  );

  Future<Resultat<PresenceData>> fetchPresence({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) => avecSecours(
    () async => PresenceData.fromJson(
      await _api.get(_cheminAvecDates(
        '/api/degustateur/dashboard/presence/',
        dateDebut: dateDebut,
        dateFin: dateFin,
      )),
    ),
    () => const PresenceData(
      present: 7,
      manquee: 1,
      prochaineTitre: 'Session Oueslati - Lot C',
      prochaineDate: '18/05/2026',
      prochaineLieu: 'Salle de dégustation B',
      prochaineCountdown: 'Dans 11 jours',
    ),
  );

  Future<Resultat<DelaiSummary>> fetchDelai({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) => avecSecours(
    () async => DelaiSummary.fromJson(
      await _api.get(_cheminAvecDates(
        '/api/degustateur/dashboard/delai/',
        dateDebut: dateDebut,
        dateFin: dateFin,
      )),
    ),
    () => DelaiSummary(
      monDelaiMoyen: 2.3,
      panelMoyen: 3.1,
      nbEvals: 6,
      points: [
        DelaiPoint(date: DateTime(2026, 3, 1),  monDelai: 1.5, panelMoyen: 3.0),
        DelaiPoint(date: DateTime(2026, 3, 15), monDelai: 2.0, panelMoyen: 3.2),
        DelaiPoint(date: DateTime(2026, 4, 1),  monDelai: 3.0, panelMoyen: 3.1),
        DelaiPoint(date: DateTime(2026, 4, 15), monDelai: 2.5, panelMoyen: 3.0),
        DelaiPoint(date: DateTime(2026, 5, 1),  monDelai: 2.1, panelMoyen: 3.1),
      ],
    ),
  );

  Future<Resultat<PageActiviteDegustateur>> fetchActivite({
    DateTime? dateDebut,
    DateTime? dateFin,
    int offset = 0,
    int pageSize = 5,
  }) => avecSecours(
    () async {
      final json = await _api.get(_cheminAvecDates(
        '/api/degustateur/activite/',
        dateDebut: dateDebut,
        dateFin: dateFin,
        autresParametres: {'offset': '$offset', 'limit': '$pageSize'},
      ));
      return (
        items: (json['results'] as List<dynamic>)
            .map((item) => ActiviteItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        total: json['count'] as int,
      );
    },
    () {
      const all = [
        ActiviteItem(id: '0', action: 'Évaluation soumise — CHEMLALI-C3',           horodatage: '05 Mai · 09h15', type: 'evaluation'),
        ActiviteItem(id: '1', action: 'Évaluation démarrée — OUESLATI-C2',          horodatage: '04 Mai · 14h30', type: 'evaluation'),
        ActiviteItem(id: '2', action: 'Présence confirmée — Session Chemlali Lot A', horodatage: '03 Mai · 08h55', type: 'seance_presente'),
        ActiviteItem(id: '3', action: 'Évaluation soumise — CHETOUI-C3',            horodatage: '01 Mai · 11h00', type: 'evaluation'),
        ActiviteItem(id: '4', action: 'Session manquée — Session Chemlali Lot B',    horodatage: '28 Avr · 09h00', type: 'seance_manquee'),
        ActiviteItem(id: '5', action: 'Évaluation démarrée — ZARAZI-C1',            horodatage: '25 Avr · 15h20', type: 'evaluation'),
        ActiviteItem(id: '6', action: 'Évaluation soumise — CHEMLALI-C1',           horodatage: '22 Avr · 10h10', type: 'evaluation'),
      ];
      return (items: all.skip(offset).take(pageSize).toList(), total: all.length);
    },
  );

  String _cheminAvecDates(
    String chemin, {
    DateTime? dateDebut,
    DateTime? dateFin,
    Map<String, String> autresParametres = const {},
  }) {
    final parametres = <String, String>{
      ...autresParametres,
      if (dateDebut != null) 'date_debut': _dateApi(dateDebut),
      if (dateFin != null) 'date_fin': _dateApi(dateFin),
    };
    return Uri(path: chemin, queryParameters: parametres).toString();
  }

  String _dateApi(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
