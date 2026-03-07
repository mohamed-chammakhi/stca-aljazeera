// ═════════════════════════════════════════════════════════════════════════════
// FILE    : analyse_laboratoire/analyse_laboratoire_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, actions
//
// SECTIONS :
//   1. COLORS
//   2. STATE         — search, statut filter, date range
//   3. NAVIGATION
//   4. MOCK DATA
//   5. FILTER LOGIC  — _filtres getter, _parseDate, _labelToStatut
//   6. ACTIONS       — add, edit, delete, snackbar
//   7. BUILD         — appbar, drawer, FAB, SearchFilterBar, list
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import 'models/analyse_labo.dart';
import 'widgets/analyse_card.dart';
import 'widgets/dialogs/formulaire_analyse_dialog.dart';
import 'widgets/dialogs/suppression_analyse_dialog.dart';

// shared SearchFilterBar (same one used by all list pages)
import '../gestion_echantillons/widgets/search_filter_bar.dart';

// app-wide imports
import '../../../profil.dart';
import '../homepage/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../gestion_echantillons/gestion_echantillons_page.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../../../main.dart';

class AnalyseLaboratoirePage extends StatefulWidget {
  const AnalyseLaboratoirePage({super.key});

  @override
  _AnalyseLaboratoirePageState createState() => _AnalyseLaboratoirePageState();
}

class _AnalyseLaboratoirePageState extends State<AnalyseLaboratoirePage> {
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
  String? _filtreStatutLabel; // null = all
  DateTime? _dateDebut;
  DateTime? _dateFin;

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
  // 4. MOCK DATA  —  replace with API call when backend ready
  // ───────────────────────────────────────────────────────────────────────────

  final List<AnalyseLabo> _analyses = [
    AnalyseLabo(
      id: 'ANL-001',
      echantillonId: 'OL-2024-001',
      echantillonNom: 'Chemlali - Lot A - Sfax',
      dateAnalyse: '18/02/2026',
      technicienNom: 'Karim B.',
      statut: StatutAnalyse.validee,
      notes: 'Analyse conforme aux normes COI',
      criteres: [
        CritereAnalyse(
          label: 'Acidité libre',
          valeur: 0.3,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.8,
        ),
        CritereAnalyse(
          label: 'Indice de peroxyde',
          valeur: 8.5,
          unite: 'mEq O₂/kg',
          seuilMin: 0.0,
          seuilMax: 20.0,
        ),
        CritereAnalyse(
          label: 'Absorbance K232',
          valeur: 1.82,
          unite: '',
          seuilMin: 0.0,
          seuilMax: 2.50,
        ),
        CritereAnalyse(
          label: 'Absorbance K270',
          valeur: 0.14,
          unite: '',
          seuilMin: 0.0,
          seuilMax: 0.22,
        ),
        CritereAnalyse(
          label: 'ΔK (variation UV)',
          valeur: 0.003,
          unite: '',
          seuilMin: -0.01,
          seuilMax: 0.01,
        ),
        CritereAnalyse(
          label: 'Polyphénols totaux',
          valeur: 320.0,
          unite: 'mg/kg',
          seuilMin: 0.0,
          seuilMax: null,
        ),
        CritereAnalyse(
          label: 'Humidité',
          valeur: 0.09,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.2,
        ),
        CritereAnalyse(
          label: 'Impuretés',
          valeur: 0.04,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.1,
        ),
      ],
    ),
    AnalyseLabo(
      id: 'ANL-002',
      echantillonId: 'OL-2024-002',
      echantillonNom: 'Chetoui - Lot B - Béja',
      dateAnalyse: '19/02/2026',
      technicienNom: 'Karim B.',
      statut: StatutAnalyse.envoyee,
      criteres: [
        CritereAnalyse(
          label: 'Acidité libre',
          valeur: 1.2,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.8,
        ), // non-conforme!
        CritereAnalyse(
          label: 'Indice de peroxyde',
          valeur: 14.0,
          unite: 'mEq O₂/kg',
          seuilMin: 0.0,
          seuilMax: 20.0,
        ),
        CritereAnalyse(
          label: 'Absorbance K232',
          valeur: 2.10,
          unite: '',
          seuilMin: 0.0,
          seuilMax: 2.50,
        ),
        CritereAnalyse(
          label: 'Absorbance K270',
          valeur: 0.19,
          unite: '',
          seuilMin: 0.0,
          seuilMax: 0.22,
        ),
        CritereAnalyse(
          label: 'ΔK (variation UV)',
          valeur: 0.005,
          unite: '',
          seuilMin: -0.01,
          seuilMax: 0.01,
        ),
        CritereAnalyse(
          label: 'Polyphénols totaux',
          valeur: 180.0,
          unite: 'mg/kg',
          seuilMin: 0.0,
          seuilMax: null,
        ),
        CritereAnalyse(
          label: 'Humidité',
          valeur: 0.15,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.2,
        ),
        CritereAnalyse(
          label: 'Impuretés',
          valeur: 0.08,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.1,
        ),
      ],
    ),
    AnalyseLabo(
      id: 'ANL-003',
      echantillonId: 'OL-2024-003',
      echantillonNom: 'Zalmati - Gafsa',
      dateAnalyse: '01/03/2026',
      technicienNom: 'Sonia M.',
      statut: StatutAnalyse.enAttente,
      criteres: [
        CritereAnalyse(
          label: 'Acidité libre',
          valeur: 0.0,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.8,
        ),
        CritereAnalyse(
          label: 'Indice de peroxyde',
          valeur: 0.0,
          unite: 'mEq O₂/kg',
          seuilMin: 0.0,
          seuilMax: 20.0,
        ),
        CritereAnalyse(
          label: 'Absorbance K232',
          valeur: 0.0,
          unite: '',
          seuilMin: 0.0,
          seuilMax: 2.50,
        ),
        CritereAnalyse(
          label: 'Absorbance K270',
          valeur: 0.0,
          unite: '',
          seuilMin: 0.0,
          seuilMax: 0.22,
        ),
        CritereAnalyse(
          label: 'ΔK (variation UV)',
          valeur: 0.0,
          unite: '',
          seuilMin: -0.01,
          seuilMax: 0.01,
        ),
        CritereAnalyse(
          label: 'Polyphénols totaux',
          valeur: 0.0,
          unite: 'mg/kg',
          seuilMin: 0.0,
          seuilMax: null,
        ),
        CritereAnalyse(
          label: 'Humidité',
          valeur: 0.0,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.2,
        ),
        CritereAnalyse(
          label: 'Impuretés',
          valeur: 0.0,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.1,
        ),
      ],
    ),
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // 5. FILTER LOGIC
  // ───────────────────────────────────────────────────────────────────────────

  StatutAnalyse? _labelToStatut(String? label) {
    switch (label) {
      case 'En attente':
        return StatutAnalyse.enAttente;
      case 'Envoyée':
        return StatutAnalyse.envoyee;
      case 'Validée':
        return StatutAnalyse.validee;
      default:
        return null;
    }
  }

  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

  List<AnalyseLabo> get _filtres {
    return _analyses.where((a) {
      final matchRecherche =
          _recherche.isEmpty ||
          a.echantillonNom.toLowerCase().contains(_recherche.toLowerCase()) ||
          a.id.toLowerCase().contains(_recherche.toLowerCase()) ||
          a.technicienNom.toLowerCase().contains(_recherche.toLowerCase());

      final filtreEnum = _labelToStatut(_filtreStatutLabel);
      final matchStatut = filtreEnum == null || a.statut == filtreEnum;

      bool matchDate = true;
      if (_dateDebut != null || _dateFin != null) {
        final raw = _parseDate(a.dateAnalyse);
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

  int get _prochainNumero => _analyses.length + 1;

  // ───────────────────────────────────────────────────────────────────────────
  // 6. ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  void _onAjouter(AnalyseLabo nouvelle) {
    setState(() => _analyses.add(nouvelle));
    _showSuccess('Analyse créée avec succès');
  }

  void _onModifier(AnalyseLabo modifiee) {
    setState(() {});
    _showSuccess('Analyse modifiée avec succès');
  }

  void _onSupprimer(AnalyseLabo a) {
    setState(() => _analyses.remove(a));
    _showSuccess('Analyse "${a.echantillonNom}" supprimée');
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
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

      // ── DRAWER ────────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () =>
            _goTo(const AnalyseLaboratoirePage()), // current
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),
        onAPropos: () => Navigator.pop(context),
        onDeconnexion: _goToLogin,
      ),

      // ── APPBAR ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_analyses.length} analyse(s)',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireAnalyseDialog(
          context,
          analyse: null,
          prochainNumero: _prochainNumero,
          onSave: _onAjouter,
        ),
        backgroundColor: green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle analyse',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          // ── SEARCH + FILTERS ───────────────────────────────────────────
          SearchFilterBar(
            recherche: _recherche,
            controller: _searchController,
            filtreStatut: _filtreStatutLabel,
            dateDebut: _dateDebut,
            dateFin: _dateFin,
            statutLabels: const ['En attente', 'Envoyée', 'Validée'],
            onRechercheChanged: (v) => setState(() => _recherche = v),
            onRechercheClear: () => setState(() {
              _recherche = '';
              _searchController.clear();
            }),
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

          // ── LIST ──────────────────────────────────────────────────────
          Expanded(
            child: _filtres.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.biotech_outlined,
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune analyse trouvée',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Theme(
                    data: Theme.of(context).copyWith(
                      scrollbarTheme: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(gray),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _filtres.length,
                        itemBuilder: (context, index) {
                          final a = _filtres[index];
                          return AnalyseCard(
                            analyse: a,
                            onModifier: () => showFormulaireAnalyseDialog(
                              context,
                              analyse: a,
                              prochainNumero: _prochainNumero,
                              onSave: _onModifier,
                            ),
                            onSupprimer: () => showSuppressionAnalyseDialog(
                              context,
                              analyse: a,
                              onConfirmer: () => _onSupprimer(a),
                            ),
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
