// lib/3_degustateur/tableau_de_bord/services/dashboard_degustateur_service.dart
// TODO: switch all methods back to real API when backend is ready

import '../models/dashboard_degustateur.dart';

class DashboardDegustateurService {
  Future<List<EvaluationUrgente>> fetchUrgentes() async {
    return [
      EvaluationUrgente(
        id: 'aaa00000-0000-0000-0000-000000000001',
        reference: 'Chemlali · 2026/0001',
        collecteurNom: 'Ahmed Dridi',
        fournisseurNom: 'Domaine Bel-Air',
        joursEnAttente: 14,
      ),
      EvaluationUrgente(
        id: 'aaa00000-0000-0000-0000-000000000004',
        reference: 'Oueslati · 2026/0004',
        collecteurNom: 'Nour Messaoud',
        fournisseurNom: 'Green Valley',
        joursEnAttente: 8,
      ),
    ];
  }

  Future<List<EvaluationUrgenteCeo>> fetchUrgentesCeo() async {
    return [
      EvaluationUrgenteCeo(
        id: 'aaa00000-0000-0000-0000-000000000005',
        reference: 'Chemlali · 2026/0005',
        collecteurNom: 'Ahmed Dridi',
        fournisseurNom: 'Domaine Bel-Air',
      ),
    ];
  }

  Future<PipelineData> fetchPipeline() async {
    return const PipelineData(
      receptionne: 8,
      nonEvaluee: 3,
      enCours: 2,
      soumise: 3,
    );
  }

  Future<List<ClassificationPoint>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    return [
      const ClassificationPoint(label: 'Jan', extraVierge: 4, vierge: 2, lampante: 1),
      const ClassificationPoint(label: 'Fév', extraVierge: 3, vierge: 3, lampante: 2),
      const ClassificationPoint(label: 'Mar', extraVierge: 5, vierge: 1, lampante: 1),
      const ClassificationPoint(label: 'Avr', extraVierge: 6, vierge: 2, lampante: 0),
    ];
  }

  Future<PresenceData> fetchPresence({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    return const PresenceData(
      present: 7,
      manquee: 1,
      prochaineTitre: 'Session Oueslati - Lot C',
      prochaineDate: '18/05/2026',
      prochaineLieu: 'Salle de dégustation B',
      prochaineCountdown: 'Dans 11 jours',
    );
  }

  Future<DelaiSummary> fetchDelai({
    required DateTime dateDebut,
    required DateTime dateFin,
  }) async {
    return DelaiSummary(
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
    );
  }

  Future<({List<ActiviteItem> items, int total})> fetchActivite({
    DateTime? dateDebut,
    DateTime? dateFin,
    int offset = 0,
    int pageSize = 5,
  }) async {
    const all = [
      ActiviteItem(id: '0', action: 'Évaluation soumise — CHEMLALI-C3',           horodatage: '05 Mai · 09h15', type: 'evaluation'),
      ActiviteItem(id: '1', action: 'Évaluation démarrée — OUESLATI-C2',          horodatage: '04 Mai · 14h30', type: 'evaluation'),
      ActiviteItem(id: '2', action: 'Présence confirmée — Session Chemlali Lot A', horodatage: '03 Mai · 08h55', type: 'seance_presente'),
      ActiviteItem(id: '3', action: 'Évaluation soumise — CHETOUI-C3',            horodatage: '01 Mai · 11h00', type: 'evaluation'),
      ActiviteItem(id: '4', action: 'Session manquée — Session Chemlali Lot B',    horodatage: '28 Avr · 09h00', type: 'seance_manquee'),
      ActiviteItem(id: '5', action: 'Évaluation démarrée — ZARAZI-C1',            horodatage: '25 Avr · 15h20', type: 'evaluation'),
      ActiviteItem(id: '6', action: 'Évaluation soumise — CHEMLALI-C1',           horodatage: '22 Avr · 10h10', type: 'evaluation'),
    ];
    final paged = all.skip(offset).take(pageSize).toList();
    return (items: paged, total: all.length);
  }
}
