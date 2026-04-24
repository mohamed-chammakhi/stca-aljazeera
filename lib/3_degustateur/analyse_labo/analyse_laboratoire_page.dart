// ═════════════════════════════════════════════════════════════════════════════
// FILE    : analyse_laboratoire/analyse_laboratoire_page.dart
// PURPOSE : THE BRAIN — owns all state, filter logic, actions
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/analyse_labo.dart';
import 'widgets/analyse_card.dart';
import 'widgets/dialogs/formulaire_analyse_dialog.dart';
import 'widgets/dialogs/suppression_analyse_dialog.dart';
// date filter sheet + button
import '../gestion_echantillons/widgets/search_filter_bar.dart';

// app-wide imports
import '../profil.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
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
  // ── COLORS ──────────────────────────────────────────────────────────────────
  static const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
  static const Color _green = Color(0xFF38835A);
  static const Color _dark = Color(0xFF1A2E1F);
  static const Color _bg = Color(0xFFFFFFFF);

  // ── STATE ────────────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';
  String? _filtreStatutLabel; // null = all
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _anyFilter =>
      _dateDebut != null ||
      _dateFin != null ||
      _recherche.isNotEmpty ||
      _filtreStatutLabel != null;

  // ── NAVIGATION ───────────────────────────────────────────────────────────────
  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  // ── MOCK DATA  ───────────────────────────────────────────────────────────────
  final List<AnalyseLabo> _analyses = [
    AnalyseLabo(
      id: 'ANL-001',
      echantillonId: 'OL-2024-001',
      echantillonNom: 'Chemlali - Lot A - Sfax',
      dateAnalyse: '18/02/2026',
      technicienNom: 'Karim B.',
      statut: StatutAnalyse.soumise,
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
      statut: StatutAnalyse.soumise,
      criteres: [
        CritereAnalyse(
          label: 'Acidité libre',
          valeur: 1.2,
          unite: '%',
          seuilMin: 0.0,
          seuilMax: 0.8,
        ),
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

  // ── FILTER LOGIC ─────────────────────────────────────────────────────────────
  StatutAnalyse? _labelToStatut(String? label) {
    switch (label) {
      case 'Analyse en attente':
        return StatutAnalyse.enAttente;
      case 'Analyse soumise':
        return StatutAnalyse.soumise;
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

  // ── CRUD helpers ─────────────────────────────────────────────────────────────
  int get _prochainNumero => _analyses.length + 1;

  void _onAjouter(AnalyseLabo analyse) {
    setState(() => _analyses.add(analyse));
    _showSuccess('Analyse ajoutée pour ${analyse.echantillonNom}');
  }

  void _onModifier(AnalyseLabo analyse) {
    setState(() {});
    _showSuccess('Analyse modifiée');
  }

  void _onSupprimer(AnalyseLabo analyse) {
    setState(() => _analyses.remove(analyse));
    _showSuccess('Analyse supprimée');
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
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // ── Date filter sheet ─────────────────────────────────────────────────────────
  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        onApply: (debut, fin) => setState(() {
          _dateDebut = debut;
          _dateFin = fin;
        }),
        onClear: () => setState(() {
          _dateDebut = null;
          _dateFin = null;
        }),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtres = _filtres;

    return Scaffold(
      backgroundColor: _bg,

      // ── FAB ───────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireAnalyseDialog(
          context,
          analyse: null,
          prochainNumero: _prochainNumero,
          onSave: _onAjouter,
        ),
        backgroundColor: const Color.fromARGB(255, 197, 206, 201),
        elevation: 2,
        icon: const Icon(Icons.add, color: _dark),
        label: const Text(
          'Nouvelle analyse',
          style: TextStyle(color: _dark, fontWeight: FontWeight.w700),
        ),
      ),

      // ── DRAWER ────────────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil: () => Navigator.pop(context),
        onEvaluationEchantillons: () =>
            _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel: () => _goTo(const MembresPanelPage()),
        onProfil: () => _goTo(const ProfilePage()),
        onDeconnexion: _goToLogin,
      ),

      // ── APPBAR ────────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Analyse de laboratoire',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        iconTheme: const IconThemeData(color: _dark),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _dateFilterActive ? _green : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: 'Filtrer par date',
              ),
              if (_dateFilterActive)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: Column(
        children: [
          // ── UNIFIED HEADER ZONE ───────────────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _recherche = v.trim()),
                  style: const TextStyle(fontSize: 14, color: _dark),
                  decoration: InputDecoration(
                    hintText: 'Rechercher échantillon, technicien, ID…',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B8E7A),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B8E7A),
                      size: 20,
                    ),
                    suffixIcon: _recherche.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 17,
                              color: Color(0xFF6B8E7A),
                            ),
                            onPressed: () => setState(() {
                              _recherche = '';
                              _searchController.clear();
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 11,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _green, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // ── Filter chips ──────────────────────────────────────────
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StatutChip(
                        label: 'Tous',
                        activeColor: const Color(0xFF616161),
                        inactiveColor: const Color(0xFFF0F0F0),
                        inactiveTextColor: const Color(0xFF757575),
                        selected: _filtreStatutLabel == null,
                        onTap: () => setState(() => _filtreStatutLabel = null),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'Analyse en attente',
                        activeColor: const Color(0xFFD07B2F),
                        inactiveColor: const Color(0xFFFEF3E8),
                        inactiveTextColor: const Color(0xFFD07B2F),
                        selected: _filtreStatutLabel == 'Analyse en attente',
                        onTap: () => setState(
                          () => _filtreStatutLabel = 'Analyse en attente',
                        ),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'Analyse soumise',
                        activeColor: const Color(0xFF38835A),
                        inactiveColor: const Color(0xFFE6F4ED),
                        inactiveTextColor: const Color(0xFF38835A),
                        selected: _filtreStatutLabel == 'Analyse soumise',
                        onTap: () => setState(
                          () => _filtreStatutLabel = 'Analyse soumise',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Thin separator
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── STATS STRIP ───────────────────────────────────────────────────────
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                Icon(
                  Icons.biotech_outlined,
                  size: 13,
                  color: const Color.fromARGB(255, 156, 156, 156),
                ),
                const SizedBox(width: 6),
                Text(
                  '${filtres.length} analyse${filtres.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 156, 156, 156),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── LIST ──────────────────────────────────────────────────────────────
          Expanded(
            child: filtres.isEmpty
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
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                      itemCount: filtres.length,
                      itemBuilder: (context, index) {
                        final a = filtres[index];
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUT CHIP  — matches design system (gestion_echantillons pattern)
// ─────────────────────────────────────────────────────────────────────────────
class _StatutChip extends StatelessWidget {
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveTextColor;
  final bool selected;
  final VoidCallback onTap;

  const _StatutChip({
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveTextColor,
    required this.selected,
    required this.onTap,
  });

  static const Color _inactiveBg = Color(0xFFF0F0F0);
  static const Color _inactiveFg = Color(0xFF9E9E9E);
  static const Color _inactiveBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final bool isTous = label == 'Tous';

    final Color bg;
    final Color fg;
    final Color border;

    if (!selected) {
      bg = _inactiveBg;
      fg = _inactiveFg;
      border = _inactiveBorder;
    } else if (isTous) {
      bg = const Color(0xFF757575);
      fg = Colors.white;
      border = const Color(0xFF757575);
    } else {
      bg = inactiveColor;
      fg = inactiveTextColor;
      border = inactiveTextColor.withValues(alpha: 0.45);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        (isTous ? const Color(0xFF757575) : inactiveTextColor)
                            .withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
