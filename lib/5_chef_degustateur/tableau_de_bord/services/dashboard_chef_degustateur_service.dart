// lib/5_chef_degustateur/tableau_de_bord/services/dashboard_chef_degustateur_service.dart
// TODO: switch all methods back to real API when backend is ready

import '../models/dashboard_chef_degustateur.dart';

class DashboardChefDegustateurService {
  Future<PipelineChefData> fetchPipeline() async {
    return const PipelineChefData(
      receptionne: 12,
      enAttenteEval: 5,
      enCours: 3,
      soumis: 4,
    );
  }

  Future<List<EvaluationUrgenteChef>> fetchUrgentes() async {
    return [
      EvaluationUrgenteChef(
        id: 'aaa00000-0000-0000-0000-000000000001',
        reference: 'Chemlali · 2026/0001',
        collecteurNom: 'Ahmed Dridi',
        fournisseurNom: 'Domaine Bel-Air',
        joursEnAttente: 14,
      ),
      EvaluationUrgenteChef(
        id: 'aaa00000-0000-0000-0000-000000000004',
        reference: 'Oueslati · 2026/0004',
        collecteurNom: 'Nour Messaoud',
        fournisseurNom: 'Green Valley',
        joursEnAttente: 8,
      ),
      EvaluationUrgenteChef(
        id: 'aaa00000-0000-0000-0000-000000000005',
        reference: 'Chemlali · 2026/0005',
        collecteurNom: 'Ahmed Dridi',
        fournisseurNom: 'Domaine Bel-Air',
        joursEnAttente: 6,
      ),
    ];
  }

  Future<List<SessionEnAttente>> fetchSessionsEnAttente() async {
    return [
      SessionEnAttente(
        id: 'SES-005',
        titre: 'Session Oueslati - Lot C',
        date: '28/04/2026',
        heure: '09:00',
        lieu: 'Salle de dégustation A',
        proposePar: 'Lobna E.',
      ),
      SessionEnAttente(
        id: 'SES-006',
        titre: 'Session Rkhami - Sfax',
        date: '02/05/2026',
        heure: '11:00',
        lieu: 'Laboratoire 1',
        proposePar: 'Ichrak C.',
      ),
    ];
  }

  Future<DelaiPanelData> fetchDelai({DateTime? dateDebut, DateTime? dateFin}) async {
    return DelaiPanelData(
      panelMoyen: 3.1,
      membres: [
        DelaiMembre(nom: 'Ichrak C.',  delaiMoyen: 2.1, panelMoyen: 3.1),
        DelaiMembre(nom: 'Lobna E.',   delaiMoyen: 3.5, panelMoyen: 3.1),
        DelaiMembre(nom: 'Maha O.',    delaiMoyen: 2.8, panelMoyen: 3.1),
        DelaiMembre(nom: 'Nayrouz F.', delaiMoyen: 3.9, panelMoyen: 3.1),
        DelaiMembre(nom: 'Yosra S.',   delaiMoyen: 2.5, panelMoyen: 3.1),
      ],
    );
  }

  Future<AlignementPanelData> fetchAlignement({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    return AlignementPanelData(
      membres: [
        AlignementMembre(nom: 'Ichrak C.',  divergencePct: 5.2),
        AlignementMembre(nom: 'Lobna E.',   divergencePct: 12.8),
        AlignementMembre(nom: 'Maha O.',    divergencePct: 8.1),
        AlignementMembre(nom: 'Nayrouz F.', divergencePct: 18.4),
        AlignementMembre(nom: 'Yosra S.',   divergencePct: 6.7),
      ],
    );
  }

  Future<List<ClassificationPoint>> fetchClassifications({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    return [
      const ClassificationPoint(label: 'Jan', extraVierge: 5, vierge: 3, lampante: 2),
      const ClassificationPoint(label: 'Fév', extraVierge: 4, vierge: 4, lampante: 2),
      const ClassificationPoint(label: 'Mar', extraVierge: 7, vierge: 2, lampante: 1),
      const ClassificationPoint(label: 'Avr', extraVierge: 6, vierge: 3, lampante: 1),
    ];
  }

  Future<List<EvaluationUrgenteCeoChef>> fetchUrgentesCeo() async {
    return [
      EvaluationUrgenteCeoChef(
        id: 'aaa00000-0000-0000-0000-000000000002',
        reference: 'Chemlali · 2026/0002',
        collecteurNom: 'Ahmed Dridi',
        fournisseurNom: 'SF-17',
      ),
    ];
  }

  Future<PresenceChefData> fetchPresence({
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    return const PresenceChefData(
      present: 9,
      manquee: 1,
      prochaineTitre: 'Session Oueslati - Lot C',
      prochaineDate: '18/05/2026',
      prochaineLieu: 'Salle de dégustation B',
      prochaineCountdown: 'Dans 11 jours',
    );
  }

  Future<({List<ActiviteItemChef> items, int total})> fetchActivite({
    DateTime? dateDebut,
    DateTime? dateFin,
    int offset = 0,
    int pageSize = 5,
  }) async {
    const all = [
      ActiviteItemChef(id: '0', action: 'Session approuvée — Session Chemlali Lot A',   horodatage: '05 Mai · 10h00', type: 'session_approuvee'),
      ActiviteItemChef(id: '1', action: 'Divergence détectée — OUESLATI-C2 (Nayrouz)', horodatage: '04 Mai · 15h30', type: 'divergence'),
      ActiviteItemChef(id: '2', action: 'Session refusée — Session Rkhami (modifiée)',   horodatage: '03 Mai · 09h10', type: 'session_refusee'),
      ActiviteItemChef(id: '3', action: 'Classification validée — CHETOUI-C3',          horodatage: '01 Mai · 11h45', type: 'evaluation'),
      ActiviteItemChef(id: '4', action: 'Session approuvée — Session Zalmati',          horodatage: '28 Avr · 08h30', type: 'session_approuvee'),
      ActiviteItemChef(id: '5', action: 'Divergence signalée — ZARAZI-C1 (Lobna)',      horodatage: '25 Avr · 14h00', type: 'divergence'),
      ActiviteItemChef(id: '6', action: 'Classification validée — CHEMLALI-C1',         horodatage: '22 Avr · 10h20', type: 'evaluation'),
    ];
    final paged = all.skip(offset).take(pageSize).toList();
    return (items: paged, total: all.length);
  }
}
