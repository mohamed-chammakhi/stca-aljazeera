// ═════════════════════════════════════════════════════════════════════════════
// FILE    : evaluation_echantillons/evaluation_echantillons_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, navigation
//
// SECTIONS (in order) :
//   1. COLORS
//   2. STATE         — search, statut filter, date range filter
//   3. NAVIGATION    — _goTo, _goToLogin
//   4. MOCK DATA     — replace with API call later
//   5. FILTER LOGIC  — _echantillonsFiltres getter, _parseDate
//                      + statut label ↔ enum conversion helpers
//   6. ACTION        — _onActionEchantillon (statut change + navigation)
//   7. BUILD         — appbar, drawer, SearchFilterBar ← NEW, list
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ── Page imports ──────────────────────────────────────────────────────────────
import '../homepage/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../../../main.dart';
import '../../../profil.dart';

import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../formulaire_evaluation.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';

// ── Own model ─────────────────────────────────────────────────────────────────
import 'navigation/models/echantillon.dart';

// ── Own widgets ───────────────────────────────────────────────────────────────
import 'navigation/widgets/echantillon_card.dart';
import 'navigation/widgets/empty_state.dart';

// ── Shared widget — same SearchFilterBar used by gestion page ─────────────────
// imported directly from gestion folder — no copy needed ✅
import '../gestion_echantillons/widgets/search_filter_bar.dart';

class EvaluationEchantillonsPage extends StatefulWidget {
  const EvaluationEchantillonsPage({super.key});

  @override
  _EvaluationEchantillonsPageState createState() =>
      _EvaluationEchantillonsPageState();
}

class _EvaluationEchantillonsPageState
    extends State<EvaluationEchantillonsPage> {
  // ───────────────────────────────────────────────────────────────────────────
  // 1. COLORS
  // ───────────────────────────────────────────────────────────────────────────

  static const Color green = Color(0xFF38835A);
  static const Color cream = Color(0xFFF9F6EF);
  static const Color gray = Color.fromARGB(255, 81, 82, 81);

  // ───────────────────────────────────────────────────────────────────────────
  // 2. STATE
  // ───────────────────────────────────────────────────────────────────────────

  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';

  // statut filter stored as String? to match SearchFilterBar's interface
  // converted to/from StatutEchantillon enum via helpers in section 5
  String? _filtreStatutLabel; // null = show all

  // date range filter — null = no date boundary set
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;

  // ───────────────────────────────────────────────────────────────────────────
  // 3. NAVIGATION
  // ───────────────────────────────────────────────────────────────────────────

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 4. MOCK DATA  —  replace with API call when backend is ready
  // ───────────────────────────────────────────────────────────────────────────

  final List<Echantillon> _echantillons = [
    Echantillon(
      id: '2024/1',
      ref: 'reference a changer',
      fournisseur: 'Domaine Bel-Air',
      date: '20/02/2026',
      variete: 'Chemlali',
      statut: StatutEchantillon.enAttente,
    ),
    Echantillon(
      id: '2024/2',
      ref: 'reference a changer',
      fournisseur: 'Ferme Al Jazira',
      date: '21/02/2026',
      variete: 'Chetoui',
      statut: StatutEchantillon.enCours,
    ),
    Echantillon(
      id: '2024/3',
      ref: 'reference a changer',
      fournisseur: 'Coopérative Nord',
      date: '22/02/2026',
      variete: 'Zalmati',
      origine: 'Sfax',
      statut: StatutEchantillon.soumis,
    ),
    Echantillon(
      id: '2024/4',
      ref: 'reference a changer',
      fournisseur: 'Green Valley',
      date: '23/02/2026',
      variete: 'Oueslati',
      statut: StatutEchantillon.enAttente,
    ),
    Echantillon(
      id: '2024/5',
      ref: 'reference a changer',
      fournisseur: 'Domaine Bel-Air',
      date: '24/02/2026',
      variete: 'Chemlali',
      statut: StatutEchantillon.enAttente,
    ),
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // 5. FILTER LOGIC
  // ───────────────────────────────────────────────────────────────────────────

  // -- statut label ↔ enum conversion --
  // SearchFilterBar works with String labels ('En attente', 'En cours', 'Soumis')
  // this page works with StatutEchantillon enum
  // these two helpers bridge the gap so both can coexist

  // label → enum  (used in onStatutChanged callback)
  StatutEchantillon? _labelToStatut(String? label) {
    switch (label) {
      case 'En attente':
        return StatutEchantillon.enAttente;
      case 'En cours':
        return StatutEchantillon.enCours;
      case 'Soumis':
        return StatutEchantillon.soumis;
      default:
        return null; // 'Tous' or null = no filter
    }
  }

  // converts "DD/MM/YYYY" → DateTime for date comparison
  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  // combines text + statut + date range into one filtered list
  List<Echantillon> get _echantillonsFiltres {
    return _echantillons.where((e) {
      // text search
      final matchRecherche =
          _recherche.isEmpty ||
          e.id.toLowerCase().contains(_recherche.toLowerCase()) ||
          e.fournisseur.toLowerCase().contains(_recherche.toLowerCase()) ||
          e.variete.toLowerCase().contains(_recherche.toLowerCase());

      // statut filter — convert label to enum for comparison
      final filtreEnum = _labelToStatut(_filtreStatutLabel);
      final matchStatut = filtreEnum == null || e.statut == filtreEnum;

      // date range filter
      bool matchDate = true;
      if (_dateFilterActive) {
        final raw = _parseDate(e.date);
        if (raw == null) {
          matchDate = false;
        } else {
          final d = DateTime(raw.year, raw.month, raw.day);
          final debut = _dateDebut != null
              ? DateTime(_dateDebut!.year, _dateDebut!.month, _dateDebut!.day)
              : null;
          final fin = _dateFin != null
              ? DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day)
              : null;

          if (debut != null && fin != null) {
            matchDate = !d.isBefore(debut) && !d.isAfter(fin);
          } else if (debut != null) {
            matchDate = !d.isBefore(debut);
          } else if (fin != null) {
            matchDate = !d.isAfter(fin);
          }
        }
      }

      return matchRecherche && matchStatut && matchDate;
    }).toList();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 6. ACTION
  // ───────────────────────────────────────────────────────────────────────────

  void _onActionEchantillon(Echantillon e) {
    if (e.statut == StatutEchantillon.enAttente) {
      setState(() => e.statut = StatutEchantillon.enCours);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormulaireEvaluationPage(
          echantillonId: e.id,
          fournisseur: e.fournisseur,
          variete: e.variete,
          origine: e.origine ?? 'Non spécifiée',
          dateArrivee: e.date,
          photoUrl: e.photoUrl,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Ouverture de l'évaluation pour ${e.id}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 7. BUILD
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,

      // ── DRAWER ───────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),
        onAPropos: () => Navigator.pop(context),
        onDeconnexion: _goToLogin,
      ),

      // ── APPBAR ───────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_echantillonsFiltres.length} échantillon(s)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ── SEARCH + FILTERS ─────────────────────────────────────────────
          // uses the same SearchFilterBar widget as gestion_echantillons_page
          // imported from ../gestion_echantillons/widgets/search_filter_bar.dart
          // filtreStatut is passed as a String label ('En attente' etc.)
          // and converted to StatutEchantillon enum in section 5 via _labelToStatut
          SearchFilterBar(
            recherche: _recherche,
            controller: _searchController,
            filtreStatut: _filtreStatutLabel,
            dateDebut: _dateDebut,
            dateFin: _dateFin,
            onRechercheChanged: (v) => setState(() => _recherche = v),
            onRechercheClear: () => setState(() {
              _recherche = '';
              _searchController.clear();
            }),
            // stores the label as-is — _labelToStatut converts it in the filter
            onStatutChanged: (v) => setState(() => _filtreStatutLabel = v),
            onDateChanged: (debut, fin) => setState(() {
              _dateDebut = debut;
              _dateFin = fin;
            }),
            onDateClear: () => setState(() {
              _dateDebut = null;
              _dateFin = null;
            }),
          ),

          // ── LIST ─────────────────────────────────────────────────────────
          Expanded(
            child: _echantillonsFiltres.isEmpty
                ? const EmptyState()
                : Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(gray),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _echantillonsFiltres.length,
                        itemBuilder: (context, index) {
                          final e = _echantillonsFiltres[index];
                          return EchantillonCard(
                            echantillon: e,
                            onAction: () => _onActionEchantillon(e),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
