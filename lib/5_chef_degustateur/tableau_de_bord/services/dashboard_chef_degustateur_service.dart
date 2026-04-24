import '../models/dashboard_chef_degustateur.dart';

class DashboardChefDegustateurService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  Future<PipelineChefData> fetchPipeline() async {
    // TODO: replace with: return _api.get('/chef/dashboard/pipeline/');
    return _mockPipeline();
  }

  Future<List<EvaluationUrgenteChef>> fetchUrgentes() async {
    // TODO: replace with: return _api.get('/chef/dashboard/urgentes/');
    return _mockUrgentes();
  }

  Future<List<SessionEnAttente>> fetchSessionsEnAttente() async {
    // TODO: replace with: return _api.get('/chef/dashboard/sessions-en-attente/');
    return _mockSessions();
  }

  Future<DelaiPanelData> fetchDelai({DateTime? dateDebut, DateTime? dateFin}) async {
    // TODO: replace with API call passing date_debut / date_fin params
    return _mockDelai();
  }

  Future<AlignementPanelData> fetchAlignement({DateTime? dateDebut, DateTime? dateFin}) async {
    // TODO: replace with API call passing date_debut / date_fin params
    return _mockAlignement();
  }

  Future<List<ClassificationPoint>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    // TODO: replace with API call passing date_debut / date_fin params
    return _mockClassifications();
  }

  // ── Mock data ──────────────────────────────────────────────────────────────
  // TODO: remove when backend is ready

  PipelineChefData _mockPipeline() => const PipelineChefData(
    receptionne: 2412,
    enAttenteEval: 187,
    enCours: 43,
    soumis: 1089,
  );

  List<EvaluationUrgenteChef> _mockUrgentes() => const [
    EvaluationUrgenteChef(
      id: 'u1',
      reference: 'CHEMLALI-C1 · 2026/0001',
      collecteurNom: 'Ahmed Dridi',
      fournisseurNom: 'Domaine Bel-Air',
      joursEnAttente: 2,
    ),
    EvaluationUrgenteChef(
      id: 'u2',
      reference: 'CHETOUI-C3 · 2026/0003',
      collecteurNom: 'Rania Hammami',
      fournisseurNom: 'Ferme Al Jazira',
      joursEnAttente: 1,
    ),
  ];

  List<SessionEnAttente> _mockSessions() => const [
    SessionEnAttente(
      id: 's1',
      titre: 'Session Oueslati — Lot C',
      date: '28/04/2026',
      heure: '09:00',
      lieu: 'Salle A',
      proposePar: 'Lobna E.',
    ),
    SessionEnAttente(
      id: 's2',
      titre: 'Session Rkhami — Sfax',
      date: '02/05/2026',
      heure: '11:00',
      lieu: 'Labo 1',
      proposePar: 'Ichrak C.',
    ),
  ];

  DelaiPanelData _mockDelai() => DelaiPanelData(
    panelMoyen: 1.86,
    membres: const [
      DelaiMembre(nom: 'Maha O.',    delaiMoyen: 3.8, panelMoyen: 1.86),
      DelaiMembre(nom: 'Yosra S.',   delaiMoyen: 2.3, panelMoyen: 1.86),
      DelaiMembre(nom: 'Lobna E.',   delaiMoyen: 1.6, panelMoyen: 1.86),
      DelaiMembre(nom: 'Nayrouz F.', delaiMoyen: 1.4, panelMoyen: 1.86),
      DelaiMembre(nom: 'Ichrak C.',  delaiMoyen: 1.2, panelMoyen: 1.86),
    ],
  );

  AlignementPanelData _mockAlignement() => const AlignementPanelData(
    membres: [
      AlignementMembre(nom: 'Maha O.',    divergencePct: 62.0),
      AlignementMembre(nom: 'Yosra S.',   divergencePct: 28.0),
      AlignementMembre(nom: 'Nayrouz F.', divergencePct: 12.0),
      AlignementMembre(nom: 'Lobna E.',   divergencePct: 8.0),
      AlignementMembre(nom: 'Ichrak C.',  divergencePct: 5.0),
    ],
  );

  List<ClassificationPoint> _mockClassifications() => const [
    ClassificationPoint(label: 'Oct', extraVierge: 1, vierge: 0, lampante: 1),
    ClassificationPoint(label: 'Nov', extraVierge: 2, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Déc', extraVierge: 3, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Jan', extraVierge: 5, vierge: 2, lampante: 0),
    ClassificationPoint(label: 'Fév', extraVierge: 2, vierge: 1, lampante: 1),
    ClassificationPoint(label: 'Mar', extraVierge: 1, vierge: 1, lampante: 0),
    ClassificationPoint(label: 'Avr', extraVierge: 1, vierge: 0, lampante: 0),
  ];
}
