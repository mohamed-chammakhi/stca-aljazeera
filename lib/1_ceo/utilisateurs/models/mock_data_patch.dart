// ═════════════════════════════════════════════════════════════════════════════
// FILE : mock/mock_data.dart
// PURPOSE : Single source of truth for all mock data.
//           Every CEO page imports from here instead of defining its own list.
//           When you connect the real API, you delete this file and replace
//           the imports with service calls — nothing else changes.
// ═════════════════════════════════════════════════════════════════════════════

import 'echantillon_ceo_view.dart';
import '../../utilisateurs/widgets/analyse_labo_sheet.dart';
import '../../utilisateurs/widgets/utilisateurs_ceo_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ALL SAMPLES — used by echantillons_ceo_page.dart
// Every other list below is derived from this one (filtered by statut).
// ─────────────────────────────────────────────────────────────────────────────
final List<EchantillonCeoView> mockEchantillons = [
  EchantillonCeoView(
    id: '2026/0001',
    referenceBouteille: 'CHEMLALI-C1',
    gouvernorat: 'Sfax',
    delegation: 'Sfax Sud',
    codeFournisseur: 'SF-42',
    variete: 'Chemlali',
    quantiteEstimee: '25',
    dateAjout: '01/03/2026',
    dateArriveeEchantillon: '03/03/2026',
    collecteurNom: 'Ahmed Dridi',
    recuPhysiquement: true,
    statut: StatutCeoView.selectionne,
    totalTasteurs: 5,
    evaluations: [
      EvaluationTasteur(
        tasteurId: 'D1',
        tasteurNom: 'Ali Ben Salem',
        classification: ClassificationHuile.extraVierge,
        soumisLe: DateTime(2026, 3, 11, 10, 30),
        fruite: 7.5,
        fruiteVert: true,
        amertume: 5.0,
        piquant: 6.0,
        chome: 0,
        moisi: 0,
        vinaigre: 0,
        gele: 0,
        rance: 0,
        commentaire: 'Bon fruité vert, bien équilibré.',
      ),
      EvaluationTasteur(
        tasteurId: 'D2',
        tasteurNom: 'Sara Mbarki',
        classification: ClassificationHuile.extraVierge,
        soumisLe: DateTime(2026, 3, 11, 11, 15),
        fruite: 8.0,
        fruiteVert: true,
        amertume: 4.5,
        piquant: 5.5,
      ),
      EvaluationTasteur(
        tasteurId: 'D3',
        tasteurNom: 'Hedi Rjaibi',
        classification: ClassificationHuile.vierge,
        soumisLe: DateTime(2026, 3, 11, 14, 0),
        fruite: 4.0,
        fruiteVert: true,
        amertume: 3.0,
        piquant: 3.5,
        chome: 1.0,
      ),
      EvaluationTasteur(
        tasteurId: 'D3',
        tasteurNom: 'rajab saye9',
        classification: ClassificationHuile.vierge,
        soumisLe: DateTime(2026, 3, 11, 14, 0),
        fruite: 4.0,
        fruiteVert: true,
        amertume: 3.0,
        piquant: 3.5,
        chome: 1.0,
      ),
      EvaluationTasteur(
        tasteurId: 'D3',
        tasteurNom: 'ichrak chk',
        classification: ClassificationHuile.vierge,
        soumisLe: DateTime(2026, 3, 11, 14, 0),
        fruite: 4.0,
        fruiteVert: true,
        amertume: 3.0,
        piquant: 3.5,
        chome: 1.0,
      ),
    ],
    analyse: const AnalyseLaboCeoView(
      aciditeLibre: 0.42,
      indicePeroxyde: 8.6,
      k232: 1.92,
      k270: 0.14,
      polyphenolsTotaux: 318,
      dateAnalyse: '05/03/2026',
    ),
  ),

  EchantillonCeoView(
    id: '2026/0002',
    referenceBouteille: 'CHEMLALI-C4',
    gouvernorat: 'Sfax',
    delegation: 'Mahres',
    codeFournisseur: 'SF-17',
    variete: 'Chemlali',
    quantiteEstimee: '12',
    dateAjout: '05/03/2026',
    collecteurNom: 'Ahmed Dridi',
    statut: StatutCeoView.enNegociation,
    totalTasteurs: 5,
    evaluations: [
      EvaluationTasteur(
        tasteurId: 'D1',
        tasteurNom: 'Ali Ben Salem',
        classification: ClassificationHuile.vierge,
        soumisLe: DateTime(2026, 3, 10, 9, 0),
        fruite: 5.0,
        fruiteVert: true,
        amertume: 4.0,
        piquant: 4.5,
      ),
    ],
  ),

  EchantillonCeoView(
    id: '2026/0003',
    referenceBouteille: 'ZALMATI-07-B',
    gouvernorat: 'Gafsa',
    delegation: 'Gafsa Nord',
    codeFournisseur: 'GF-08',
    variete: 'Zalmati',
    quantiteEstimee: '30',
    dateAjout: '20/02/2026',
    dateArriveeEchantillon: '23/02/2026',
    collecteurNom: 'Sami Khaled',
    recuPhysiquement: true,
    statut: StatutCeoView.achatConfirme,
    totalTasteurs: 5,
    budgetNegociation: '8.50 TND/L',
    quantiteCibleT: '30',
    camionReserve: 'TRK-003',
    stockArrive: false,
    dateLivraisonStock: '28/03/2026',
    evaluations: [
      EvaluationTasteur(
        tasteurId: 'D1',
        tasteurNom: 'Ali Ben Salem',
        classification: ClassificationHuile.extraVierge,
        soumisLe: DateTime(2026, 2, 25, 10, 0),
        fruite: 9.0,
        fruiteVert: false,
        amertume: 6.5,
        piquant: 7.5,
      ),
      EvaluationTasteur(
        tasteurId: 'D2',
        tasteurNom: 'Sara Mbarki',
        classification: ClassificationHuile.extraVierge,
        soumisLe: DateTime(2026, 2, 25, 11, 0),
        fruite: 8.5,
        fruiteVert: false,
        amertume: 6.0,
        piquant: 7.0,
      ),
    ],
    analyse: const AnalyseLaboCeoView(
      aciditeLibre: 1.80,
      indicePeroxyde: 18.0,
      k232: 2.40,
      k270: 0.19,
      dateAnalyse: '22/02/2026',
    ),
  ),

  EchantillonCeoView(
    id: '2026/0004',
    referenceBouteille: 'CHETOUI-C3',
    gouvernorat: 'Béja',
    codeFournisseur: 'BJ-15',
    variete: 'Chetoui',
    quantiteEstimee: '8',
    dateAjout: '28/02/2026',
    collecteurNom: 'Sami Khaled',
    statut: StatutCeoView.refuse,
    totalTasteurs: 5,
    raisonRefus: 'Qualité insuffisante',
    evaluations: [],
  ),

  EchantillonCeoView(
    id: '2026/0005',
    referenceBouteille: 'OUESLATI-C2',
    gouvernorat: 'Kairouan',
    codeFournisseur: 'KR-22',
    variete: 'Oueslati',
    quantiteEstimee: '15',
    dateAjout: '18/03/2026',
    collecteurNom: 'Mounir Zouaghi',
    statut: StatutCeoView.selectionne,
    totalTasteurs: 5,
    analyse: const AnalyseLaboCeoView(
      aciditeLibre: 0.55,
      indicePeroxyde: 11.2,
      k232: 2.10,
      k270: 0.18,
      polyphenolsTotaux: 280,
      dateAnalyse: '20/03/2026',
    ),
  ),

  EchantillonCeoView(
    id: '2026/0006',
    referenceBouteille: 'ARBEQUINA-I1',
    gouvernorat: 'Tunis',
    codeFournisseur: 'TN-01',
    variete: 'Arbequina',
    quantiteEstimee: '5',
    dateAjout: '10/03/2026',
    collecteurNom: null, // interne
    statut: StatutCeoView.selectionne,
    totalTasteurs: 5,
  ),

  EchantillonCeoView(
    id: '2026/0007',
    referenceBouteille: 'CHEMLALI-C8',
    gouvernorat: 'Sfax',
    delegation: 'Sfax Sud',
    codeFournisseur: 'SF-42',
    variete: 'Chemlali',
    quantiteEstimee: '25',
    dateAjout: '01/03/2026',
    dateArriveeEchantillon: '05/03/2026',
    collecteurNom: 'Ahmed Dridi',
    recuPhysiquement: true,
    statut: StatutCeoView.achatConfirme,
    totalTasteurs: 5,
    budgetNegociation: '9.20 TND/L',
    quantiteCibleT: '25',
    camionReserve: 'TRK-007',
    noteInterne: 'Qualité extra vierge confirmée.',
    stockArrive: true,
    dateLivraisonStock: '20/03/2026',
  ),

  EchantillonCeoView(
    id: '2026/0008',
    referenceBouteille: 'CHETOUI-C5',
    gouvernorat: 'Béja',
    codeFournisseur: 'BJ-15',
    variete: 'Chetoui',
    quantiteEstimee: '18',
    dateAjout: '28/02/2026',
    dateArriveeEchantillon: '03/03/2026',
    collecteurNom: 'Ahmed Dridi',
    recuPhysiquement: true,
    statut: StatutCeoView.achatConfirme,
    totalTasteurs: 5,
    budgetNegociation: '7.80 TND/L',
    quantiteCibleT: '18',
    stockArrive: true,
    dateLivraisonStock: '15/03/2026',
  ),

  // ── State ④ : dateLivraisonPrevue set, sample not yet received ──────────────
  EchantillonCeoView(
    id: '2026/0009',
    referenceBouteille: 'SAHLI-B2',
    gouvernorat: 'Monastir',
    delegation: 'Ksar Hellal',
    codeFournisseur: 'MN-09',
    variete: 'Sahli',
    quantiteEstimee: '20',
    dateAjout: '25/03/2026',
    dateLivraisonPrevue: '20/04/2026',
    collecteurNom: 'Mounir Zouaghi',
    recuPhysiquement: false,
    statut: StatutCeoView.selectionne,
    totalTasteurs: 5,
    evaluations: [
      EvaluationTasteur(
        tasteurId: 'D2',
        tasteurNom: 'Sara Mbarki',
        classification: ClassificationHuile.extraVierge,
        soumisLe: DateTime(2026, 3, 27, 10, 0),
        fruite: 7.0,
        fruiteVert: false,
        amertume: 5.5,
        piquant: 6.0,
      ),
    ],
  ),

  // ── State ⑤ : achatConfirme but stock delivery not yet scheduled ────────────
  EchantillonCeoView(
    id: '2026/0010',
    referenceBouteille: 'CHEMLALI-C9',
    gouvernorat: 'Sfax',
    delegation: 'Jebeniana',
    codeFournisseur: 'SF-55',
    variete: 'Chemlali',
    quantiteEstimee: '40',
    dateAjout: '15/03/2026',
    dateArriveeEchantillon: '18/03/2026',
    collecteurNom: 'Sami Khaled',
    recuPhysiquement: true,
    statut: StatutCeoView.achatConfirme,
    totalTasteurs: 5,
    budgetNegociation: '9.00 TND/L',
    quantiteCibleT: '40',
    stockArrive: false,
    evaluations: [
      EvaluationTasteur(
        tasteurId: 'D1',
        tasteurNom: 'Ali Ben Salem',
        classification: ClassificationHuile.extraVierge,
        soumisLe: DateTime(2026, 3, 20, 9, 30),
        fruite: 8.0,
        fruiteVert: true,
        amertume: 6.0,
        piquant: 6.5,
      ),
      EvaluationTasteur(
        tasteurId: 'D2',
        tasteurNom: 'Sara Mbarki',
        classification: ClassificationHuile.extraVierge,
        soumisLe: DateTime(2026, 3, 20, 11, 0),
        fruite: 7.5,
        fruiteVert: true,
        amertume: 5.5,
        piquant: 6.0,
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// DERIVED LISTS — each page filters mockEchantillons instead of owning data
// ─────────────────────────────────────────────────────────────────────────────

/// Used by analyse_organoleptique_ceo_page.dart
/// Only samples that have at least started the tasting process.
List<EchantillonCeoView> get mockEchantillonsOrganoleptique => mockEchantillons
    .where(
      (e) => e.evaluations.isNotEmpty || e.statut == StatutCeoView.selectionne,
    )
    .toList();

/// Used by analyse_laboratoire_ceo_page.dart
/// All samples — labo page shows all with or without analysis.
List<EchantillonCeoView> get mockEchantillonsLabo => mockEchantillons;

/// Used by achats_confirmes_ceo_page.dart
/// Only confirmed purchases.
List<EchantillonCeoView> get mockAchatsConfirmes => mockEchantillons
    .where((e) => e.statut == StatutCeoView.achatConfirme)
    .toList();

// ═════════════════════════════════════════════════════════════════════════════
// FILE : mock/mock_data_patch.dart
// PURPOSE : Adds mockUtilisateurs to the mock data layer.
//           Add these lines to mock_data.dart — same file, same pattern.
//           When you connect the real API, replace with GET /api/users.
// ═════════════════════════════════════════════════════════════════════════════

// ── ADD THIS import at the top of mock_data.dart ─────────────────────────────
// import 'utilisateurs/utilisateurs_ceo_page.dart';   ← AppUser + UserRole

// ─────────────────────────────────────────────────────────────────────────────
// ALL USERS — used by utilisateurs_ceo_page.dart
// ─────────────────────────────────────────────────────────────────────────────
final List<AppUser> mockUtilisateurs = [
  AppUser(
    id: 'U001',
    initials: 'TA',
    prenom: 'Takwa',
    nom: 'Amara',
    email: 'takwa.amara@aljazira.tn',
    telephone: '+216 98 123 456',
    dateDebut: '01/01/2024',
    role: UserRole.ceo,
    actif: true,
  ),
  AppUser(
    id: 'U002',
    initials: 'MS',
    prenom: 'Mohamed',
    nom: 'Slim',
    email: 'mslim@aljazira.tn',
    telephone: '+216 55 234 567',
    dateDebut: '15/02/2024',
    role: UserRole.laboratoire,
    actif: true,
  ),
  AppUser(
    id: 'U003',
    initials: 'AB',
    prenom: 'Ali',
    nom: 'Ben Salem',
    email: 'ali.bensalem@aljazira.tn',
    telephone: '+216 20 345 678',
    dateDebut: '10/03/2024',
    role: UserRole.degustateur,
    actif: true,
  ),
  AppUser(
    id: 'U004',
    initials: 'SM',
    prenom: 'Sara',
    nom: 'Mbarki',
    email: 'sara.mbarki@aljazira.tn',
    telephone: '+216 22 456 789',
    dateDebut: '10/03/2024',
    role: UserRole.degustateur,
    actif: true,
  ),
  AppUser(
    id: 'U005',
    initials: 'HR',
    prenom: 'Hedi',
    nom: 'Rjaibi',
    email: 'hedi.rjaibi@aljazira.tn',
    telephone: '+216 25 567 890',
    dateDebut: '10/03/2024',
    role: UserRole.degustateur,
    actif: false,
  ),
  AppUser(
    id: 'U006',
    initials: 'AD',
    prenom: 'Ahmed',
    nom: 'Dridi',
    email: 'ahmed.dridi@aljazira.tn',
    telephone: '+216 50 678 901',
    dateDebut: '01/02/2024',
    role: UserRole.collecteur,
    actif: true,
  ),
  AppUser(
    id: 'U007',
    initials: 'SK',
    prenom: 'Sami',
    nom: 'Khaled',
    email: 'sami.khaled@aljazira.tn',
    telephone: '+216 52 789 012',
    dateDebut: '01/02/2024',
    role: UserRole.collecteur,
    actif: true,
  ),
  AppUser(
    id: 'U008',
    initials: 'MZ',
    prenom: 'Mounir',
    nom: 'Zouaghi',
    email: 'mounir.z@aljazira.tn',
    telephone: '+216 54 890 123',
    dateDebut: '15/02/2024',
    role: UserRole.collecteur,
    actif: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// DERIVED LISTS — mirrors the pattern in mock_data.dart
// ─────────────────────────────────────────────────────────────────────────────

/// Active users only — for panels, session assignment, etc.
List<AppUser> get mockUtilisateursActifs =>
    mockUtilisateurs.where((u) => u.actif).toList();

/// Dégustateurs only — used by session planning
List<AppUser> get mockDegustateurs =>
    mockUtilisateurs.where((u) => u.role == UserRole.degustateur).toList();

/// Collecteurs only — used by sample tracking
List<AppUser> get mockCollecteurs =>
    mockUtilisateurs.where((u) => u.role == UserRole.collecteur).toList();
