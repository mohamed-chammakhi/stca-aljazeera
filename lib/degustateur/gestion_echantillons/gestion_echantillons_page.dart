// ═════════════════════════════════════════════════════════════════════════════
// FILE    : gestion_echantillons/gestion_echantillons_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, and actions
//
// SECTIONS :
//   1. COLORS
//   2. STATE        — search, statut filter, date range
//   3. NAVIGATION   — _goTo, _goToLogin
//   4. MOCK DATA    — replace with API call later
//   5. FILTER LOGIC — _filtres getter, _parseDate
//   6. ACTIONS      — add, edit, delete, snackbar
//   7. BUILD        — appbar, drawer, FAB, SearchFilterBar, list
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../gestion_echantillons/models/echantillon_gestion.dart';
import '../../degustateur/gestion_echantillons/widgets/echantillon_card.dart';
import '../../degustateur/gestion_echantillons/widgets/empty_state.dart';
import '../../degustateur/gestion_echantillons/widgets/search_filter_bar.dart';
import '../gestion_echantillons/widgets/dialogs/formulaire_dialog.dart';
import '../gestion_echantillons/widgets/dialogs/suppression_dialog.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../../../profil.dart';
import '../homepage/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../../../main.dart';
import '../sessions_degustation/sessions_degustation_page.dart';

class GestionEchantillonsPage extends StatefulWidget {
  const GestionEchantillonsPage({super.key});

  @override
  _GestionEchantillonsPageState createState() =>
      _GestionEchantillonsPageState();
}

class _GestionEchantillonsPageState extends State<GestionEchantillonsPage> {
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
  String? _filtreStatut; // null = show all statuts
  DateTime? _dateDebut; // null = no lower date bound
  DateTime? _dateFin; // null = no upper date bound

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

  final List<EchantillonGestion> _echantillons = [
    EchantillonGestion(
      id: '2024/1',
      ref: 'abcd',
      fournisseur: 'Domaine Bel-Air',
      variete: 'Chemlali',
      dateArrivee: '20/02/2026',
      origine: 'Sfax',
      quantite: '5000 KG',
      statut: 'En attente',
    ),
    EchantillonGestion(
      id: '2024/2',
      ref: 'Référence a changer',
      fournisseur: 'Ferme Al Jazira',
      variete: 'Chetoui',
      dateArrivee: '21/02/2026',
      origine: 'Béja',
      quantite: '3200 KG',
      statut: 'En cours',
    ),
    EchantillonGestion(
      id: '2024/3',
      ref: 'Référence a changer',
      fournisseur: 'Coopérative Nord',
      variete: 'Zalmati',
      dateArrivee: '22/02/2026',
      origine: 'Bizerte',
      quantite: '8000 KG',
      statut: 'Soumis',
    ),
    EchantillonGestion(
      id: '2024/4',
      ref: 'Référence a changer',
      fournisseur: 'Green Valley',
      variete: 'Oueslati',
      dateArrivee: '23/02/2026',
      origine: 'Kairouan',
      quantite: '2500 KG',
      statut: 'En attente',
    ),
  ];

  // ───────────────────────────────────────────────────────────────────────────
  // 5. FILTER LOGIC
  // ───────────────────────────────────────────────────────────────────────────

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

  // combines text + statut + date into one filtered list
  List<EchantillonGestion> get _filtres {
    final liste = _echantillons.where((e) {
      final matchRecherche =
          _recherche.isEmpty ||
          e.ref.toLowerCase().contains(_recherche.toLowerCase()) ||
          e.id.toLowerCase().contains(_recherche.toLowerCase()) ||
          e.fournisseur.toLowerCase().contains(_recherche.toLowerCase()) ||
          e.variete.toLowerCase().contains(_recherche.toLowerCase()) ||
          e.origine.toLowerCase().contains(_recherche.toLowerCase());

      final matchStatut = _filtreStatut == null || e.statut == _filtreStatut;

      bool matchDate = true;
      if (_dateFilterActive) {
        final raw = _parseDate(e.dateArrivee);
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

    // TODO: sort by dateArrivee DESC when API connected
    return liste.reversed.toList();
  }

  int get _prochainNumero => _echantillons.length + 1;

  // ───────────────────────────────────────────────────────────────────────────
  // 6. ACTIONS  —  setState always called here, never inside widgets/dialogs
  // ───────────────────────────────────────────────────────────────────────────

  void _onAjouter(EchantillonGestion nouveau) {
    setState(() => _echantillons.add(nouveau));
    _showSuccess('Échantillon ajouté avec succès');
  }

  void _onModifier(EchantillonGestion modifie) {
    setState(() {}); // object already mutated inside formulaire_dialog
    _showSuccess('Échantillon modifié avec succès');
  }

  void _onSupprimer(EchantillonGestion e) {
    setState(() => _echantillons.remove(e));
    _showSuccess('Échantillon ${e.id} supprimé');
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

      // ── DRAWER ───────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => Navigator.pop(context),
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
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_echantillons.length} total',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireDialog(
          context,
          echantillon: null,
          prochainNumero: _prochainNumero,
          onSave: _onAjouter,
        ),
        backgroundColor: green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: Column(
        children: [
          // ── SEARCH + FILTERS — all handled by SearchFilterBar ─────────────
          SearchFilterBar(
            recherche: _recherche,
            controller: _searchController,
            filtreStatut: _filtreStatut,
            dateDebut: _dateDebut,
            dateFin: _dateFin,
            onRechercheChanged: (v) => setState(() => _recherche = v),
            onRechercheClear: () => setState(() {
              _recherche = '';
              _searchController.clear();
            }),
            onStatutChanged: (v) => setState(() => _filtreStatut = v),
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
            child: _filtres.isEmpty
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
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        itemCount: _filtres.length,
                        itemBuilder: (context, index) {
                          final e = _filtres[index];
                          return EchantillonCard(
                            echantillon: e,
                            // opens formulaire_dialog in EDIT mode
                            onModifier: () => showFormulaireDialog(
                              context,
                              echantillon: e,
                              prochainNumero: _prochainNumero,
                              onSave: _onModifier,
                            ),
                            // opens confirmation dialog before deleting
                            onSupprimer: () => showSuppressionDialog(
                              context,
                              echantillon: e,
                              onConfirmer: () => _onSupprimer(e),
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
