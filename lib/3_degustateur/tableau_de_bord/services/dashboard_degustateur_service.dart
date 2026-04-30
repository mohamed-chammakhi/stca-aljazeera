// lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart

import '../models/dashboard_degustateur.dart';

class DashboardDegustateurService {
  // TODO: inject ApiClient here when backend is ready
  // final ApiClient _api;

  // ── Urgent evaluations (time-based) ─────────────────────────────────────────
  Future<List<EvaluationUrgente>> fetchUrgentes() async {
    // TODO: replace with: return _api.get('/degustateur/dashboard/urgentes/');
    return _mockUrgentes();
  }

  // ── Urgent evaluations flagged by CEO ────────────────────────────────────────
  Future<List<EvaluationUrgenteCeo>> fetchUrgentesCeo() async {
    // TODO: replace with: return _api.get('/degustateur/dashboard/urgentes-ceo/');
    return _mockUrgentesCeo();
  }

  // ── Pipeline ────────────────────────────────────────────────────────────────
  Future<PipelineData> fetchPipeline() async {
    // TODO: replace with: return _api.get('/degustateur/dashboard/pipeline/');
    return _mockPipeline();
  }

  // ── Classifications ─────────────────────────────────────────────────────────
  Future<List<ClassificationPoint>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    // TODO: replace with API call passing date params
    return _mockClassifications();
  }

  // ── Presence ────────────────────────────────────────────────────────────────
  Future<PresenceData> fetchPresence({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    // TODO: replace with API call passing date params
    return _mockPresence();
  }

  // ── Délai de soumission ─────────────────────────────────────────────────────
  Future<DelaiSummary> fetchDelai({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    // TODO: replace with: return _api.get('/degustateur/dashboard/delai/?date_debut=...&date_fin=...');
    return _mockDelai();
  }

  // ── Activité récente ────────────────────────────────────────────────────────
  // Returns up to [pageSize] items starting at [offset].
  // Backend: GET /api/activite/?date_debut=...&date_fin=...&offset=0&limit=5
  Future<({List<ActiviteItem> items, int total})> fetchActivite({
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

  // ── Mock data ───────────────────────────────────────────────────────────────
  // TODO: remove when backend is ready

  List<EvaluationUrgente> _mockUrgentes() => [
    const EvaluationUrgente(
      id: 'urg-1',
      reference: 'CHEMLALI-C1 · 2026/0001',
      collecteurNom: 'Ahmed Dridi',
      fournisseurNom: 'Domaine Bel-Air',
      joursEnAttente: 3,
    ),
    const EvaluationUrgente(
      id: 'urg-2',
      reference: 'CHETOUI-C3 · 2026/0003',
      collecteurNom: 'Rania Hammami',
      fournisseurNom: 'Ferme Al Jazira',
      joursEnAttente: 1,
    ),
  ];

  // TODO: remove when backend is ready
  List<EvaluationUrgenteCeo> _mockUrgentesCeo() => const [
    EvaluationUrgenteCeo(
      id: 'ceo-1',
      reference: 'OUESLATI-C2 · 2026/0007',
      collecteurNom: 'Sami Ben Amor',
      fournisseurNom: 'Ferme El Baraka',
    ),
  ];

  PipelineData _mockPipeline() => const PipelineData(
    receptionne: 3,
    nonEvaluee: 5,
    enCours: 2,
    soumise: 14,
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

  PresenceData _mockPresence() => const PresenceData(
    present: 13,
    manquee: 2,
    prochaineTitre: 'Prochaine séance : 28 Avr 2026',
    prochaineDate: '28 Avr 2026',
    prochaineLieu: 'Salle de dégustation A · 09h00',
    prochaineCountdown: '4j',
  );

  DelaiSummary _mockDelai() => DelaiSummary(
    monDelaiMoyen: 1.8,
    panelMoyen: 1.4,
    nbEvals: 23,
    points: [
      DelaiPoint(date: DateTime(2026, 1, 2), monDelai: 1.0, panelMoyen: 1.2),
      DelaiPoint(date: DateTime(2026, 1, 9), monDelai: 2.5, panelMoyen: 1.3),
      DelaiPoint(date: DateTime(2026, 1, 15), monDelai: 1.2, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 1, 22), monDelai: 3.0, panelMoyen: 1.5),
      DelaiPoint(date: DateTime(2026, 2, 5), monDelai: 1.5, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 2, 12), monDelai: 0.8, panelMoyen: 1.3),
      DelaiPoint(date: DateTime(2026, 3, 1), monDelai: 2.0, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 3, 14), monDelai: 1.8, panelMoyen: 1.5),
      DelaiPoint(date: DateTime(2026, 4, 2), monDelai: 2.2, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 4, 10), monDelai: 1.0, panelMoyen: 1.3),
      DelaiPoint(date: DateTime(2026, 4, 19), monDelai: 1.5, panelMoyen: 1.4),
      DelaiPoint(date: DateTime(2026, 4, 21), monDelai: 1.9, panelMoyen: 1.4),
    ],
  );

  List<ActiviteItem> _mockActivite() => const [
    ActiviteItem(
      id: 'a1',
      action: 'Évaluation soumise — CHEMLALI-C4',
      horodatage: '24 Avr · 10h32',
      type: 'evaluation',
    ),
    ActiviteItem(
      id: 'a2',
      action: 'Séance de dégustation rejointe — Séance #14',
      horodatage: '23 Avr · 09h00',
      type: 'seance_presente',
    ),
    ActiviteItem(
      id: 'a3',
      action: 'Évaluation soumise — OUESLATI-C2',
      horodatage: '21 Avr · 14h15',
      type: 'evaluation',
    ),
    ActiviteItem(
      id: 'a4',
      action: 'Séance manquée — Séance #13',
      horodatage: '19 Avr · 09h00',
      type: 'seance_manquee',
    ),
    ActiviteItem(
      id: 'a5',
      action: 'Évaluation soumise — CHETOUI-C2',
      horodatage: '19 Avr · 11h47',
      type: 'evaluation',
    ),
    ActiviteItem(
      id: 'a6',
      action: 'Séance rejointe — Séance #12',
      horodatage: '15 Avr · 09h00',
      type: 'seance_presente',
    ),
    ActiviteItem(
      id: 'a7',
      action: 'Évaluation soumise — ZALMATI-C1',
      horodatage: '14 Avr · 16h40',
      type: 'evaluation',
    ),
    ActiviteItem(
      id: 'a8',
      action: 'Évaluation soumise — CHEMLALI-C2',
      horodatage: '12 Avr · 10h05',
      type: 'evaluation',
    ),
    ActiviteItem(
      id: 'a9',
      action: 'Profil mis à jour',
      horodatage: '08 Avr · 08h30',
      type: 'profil',
    ),
    ActiviteItem(
      id: 'a10',
      action: 'Évaluation soumise — OUESLATI-C1',
      horodatage: '05 Avr · 14h00',
      type: 'evaluation',
    ),
  ];
}
