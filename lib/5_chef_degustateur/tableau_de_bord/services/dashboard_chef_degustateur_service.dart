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

  Future<List<EvaluationUrgenteCeoChef>> fetchUrgentesCeo() async {
    // TODO: replace with: return _api.get('/chef/dashboard/urgentes-ceo/');
    return _mockUrgentesCeo();
  }

  Future<PresenceChefData> fetchPresence({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    // TODO: replace with API call passing date params
    return _mockPresence();
  }

  Future<({List<ActiviteItemChef> items, int total})> fetchActivite({
    DateTime? dateDebut,
    DateTime? dateFin,
    int offset = 0,
    int pageSize = 5,
  }) async {
    // TODO: replace with paginated API call
    final all = _mockActivite();
    final slice = all.skip(offset).take(pageSize).toList();
    return (items: slice, total: all.length);
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

  // TODO: remove when backend is ready
  List<EvaluationUrgenteCeoChef> _mockUrgentesCeo() => const [
    EvaluationUrgenteCeoChef(
      id: 'ceo-chef-1',
      reference: 'OUESLATI-C2 · 2026/0007',
      collecteurNom: 'Sami Ben Amor',
      fournisseurNom: 'Ferme El Baraka',
    ),
    EvaluationUrgenteCeoChef(
      id: 'ceo-chef-2',
      reference: 'ZALMATI-C1 · 2026/0011',
      collecteurNom: 'Rim Bouzid',
      fournisseurNom: 'Ferme El Hamra',
    ),
  ];

  // TODO: remove when backend is ready
  PresenceChefData _mockPresence() => const PresenceChefData(
    present: 18,
    manquee: 1,
    prochaineTitre: 'Prochaine séance : 28 Avr 2026',
    prochaineDate: '28 Avr 2026',
    prochaineLieu: 'Salle de dégustation A · 09h00',
    prochaineCountdown: '4j',
  );

  // TODO: remove when backend is ready
  List<ActiviteItemChef> _mockActivite() => const [
    ActiviteItemChef(id: 'ca1', action: 'Session #15 approuvée', horodatage: '24 Avr · 11h00', type: 'approbation'),
    ActiviteItemChef(id: 'ca2', action: 'Évaluation soumise — CHEMLALI-C4', horodatage: '24 Avr · 10h32', type: 'evaluation'),
    ActiviteItemChef(id: 'ca3', action: 'Séance de dégustation rejointe — Séance #14', horodatage: '23 Avr · 09h00', type: 'seance_presente'),
    ActiviteItemChef(id: 'ca4', action: 'Session #14 approuvée', horodatage: '22 Avr · 15h30', type: 'approbation'),
    ActiviteItemChef(id: 'ca5', action: 'Évaluation soumise — OUESLATI-C2', horodatage: '21 Avr · 14h15', type: 'evaluation'),
    ActiviteItemChef(id: 'ca6', action: 'Séance manquée — Séance #13', horodatage: '19 Avr · 09h00', type: 'seance_manquee'),
    ActiviteItemChef(id: 'ca7', action: 'Évaluation soumise — CHETOUI-C2', horodatage: '19 Avr · 11h47', type: 'evaluation'),
    ActiviteItemChef(id: 'ca8', action: 'Session refusée — Séance Chemlali', horodatage: '17 Avr · 10h00', type: 'refus'),
    ActiviteItemChef(id: 'ca9', action: 'Séance rejointe — Séance #12', horodatage: '15 Avr · 09h00', type: 'seance_presente'),
    ActiviteItemChef(id: 'ca10', action: 'Évaluation soumise — ZALMATI-C1', horodatage: '14 Avr · 16h40', type: 'evaluation'),
  ];

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
