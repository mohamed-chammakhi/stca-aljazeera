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
  // ── COLORS ──────────────────────────────────────────────────────────────────
  static const Color _green = Color(0xFF38835A);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _dark  = Color(0xFF1A2E1F);

  // ── STATE ────────────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String    _recherche         = '';
  String?   _filtreStatutLabel; // null = all
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _anyFilter =>
      _dateDebut != null || _dateFin != null ||
      _recherche.isNotEmpty || _filtreStatutLabel != null;

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
      statut: StatutAnalyse.envoyee,
      notes: 'Analyse conforme aux normes COI',
      criteres: [
        CritereAnalyse(label: 'Acidité libre',       valeur: 0.3,   unite: '%',         seuilMin: 0.0,  seuilMax: 0.8),
        CritereAnalyse(label: 'Indice de peroxyde',  valeur: 8.5,   unite: 'mEq O₂/kg', seuilMin: 0.0,  seuilMax: 20.0),
        CritereAnalyse(label: 'Absorbance K232',     valeur: 1.82,  unite: '',          seuilMin: 0.0,  seuilMax: 2.50),
        CritereAnalyse(label: 'Absorbance K270',     valeur: 0.14,  unite: '',          seuilMin: 0.0,  seuilMax: 0.22),
        CritereAnalyse(label: 'ΔK (variation UV)',   valeur: 0.003, unite: '',          seuilMin: -0.01,seuilMax: 0.01),
        CritereAnalyse(label: 'Polyphénols totaux',  valeur: 320.0, unite: 'mg/kg',     seuilMin: 0.0,  seuilMax: null),
        CritereAnalyse(label: 'Humidité',            valeur: 0.09,  unite: '%',         seuilMin: 0.0,  seuilMax: 0.2),
        CritereAnalyse(label: 'Impuretés',           valeur: 0.04,  unite: '%',         seuilMin: 0.0,  seuilMax: 0.1),
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
        CritereAnalyse(label: 'Acidité libre',       valeur: 1.2,  unite: '%',         seuilMin: 0.0,  seuilMax: 0.8),
        CritereAnalyse(label: 'Indice de peroxyde',  valeur: 14.0, unite: 'mEq O₂/kg', seuilMin: 0.0,  seuilMax: 20.0),
        CritereAnalyse(label: 'Absorbance K232',     valeur: 2.10, unite: '',          seuilMin: 0.0,  seuilMax: 2.50),
        CritereAnalyse(label: 'Absorbance K270',     valeur: 0.19, unite: '',          seuilMin: 0.0,  seuilMax: 0.22),
        CritereAnalyse(label: 'ΔK (variation UV)',   valeur: 0.005,unite: '',          seuilMin: -0.01,seuilMax: 0.01),
        CritereAnalyse(label: 'Polyphénols totaux',  valeur: 180.0,unite: 'mg/kg',     seuilMin: 0.0,  seuilMax: null),
        CritereAnalyse(label: 'Humidité',            valeur: 0.15, unite: '%',         seuilMin: 0.0,  seuilMax: 0.2),
        CritereAnalyse(label: 'Impuretés',           valeur: 0.08, unite: '%',         seuilMin: 0.0,  seuilMax: 0.1),
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
        CritereAnalyse(label: 'Acidité libre',       valeur: 0.0, unite: '%',         seuilMin: 0.0,  seuilMax: 0.8),
        CritereAnalyse(label: 'Indice de peroxyde',  valeur: 0.0, unite: 'mEq O₂/kg', seuilMin: 0.0,  seuilMax: 20.0),
        CritereAnalyse(label: 'Absorbance K232',     valeur: 0.0, unite: '',          seuilMin: 0.0,  seuilMax: 2.50),
        CritereAnalyse(label: 'Absorbance K270',     valeur: 0.0, unite: '',          seuilMin: 0.0,  seuilMax: 0.22),
        CritereAnalyse(label: 'ΔK (variation UV)',   valeur: 0.0, unite: '',          seuilMin: -0.01,seuilMax: 0.01),
        CritereAnalyse(label: 'Polyphénols totaux',  valeur: 0.0, unite: 'mg/kg',     seuilMin: 0.0,  seuilMax: null),
        CritereAnalyse(label: 'Humidité',            valeur: 0.0, unite: '%',         seuilMin: 0.0,  seuilMax: 0.2),
        CritereAnalyse(label: 'Impuretés',           valeur: 0.0, unite: '%',         seuilMin: 0.0,  seuilMax: 0.1),
      ],
    ),
  ];

  // ── FILTER LOGIC ─────────────────────────────────────────────────────────────
  StatutAnalyse? _labelToStatut(String? label) {
    switch (label) {
      case 'En attente': return StatutAnalyse.enAttente;
      case 'Envoyée':    return StatutAnalyse.envoyee;
      default:           return null;
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
          final d     = DateTime(raw.year, raw.month, raw.day);
          final debut = _dateDebut != null
              ? DateTime(_dateDebut!.year, _dateDebut!.month, _dateDebut!.day)
              : null;
          final fin   = _dateFin != null
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

  // ── Date filter sheet ─────────────────────────────────────────────────────────
  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        dateDebut: _dateDebut,
        dateFin:   _dateFin,
        onApply: (debut, fin) => setState(() {
          _dateDebut = debut;
          _dateFin   = fin;
        }),
        onClear: () => setState(() {
          _dateDebut = null;
          _dateFin   = null;
        }),
      ),
    );
  }

  // ── ACTIONS ──────────────────────────────────────────────────────────────────
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
        content: Text(msg,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: _green,
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

  // ── BUILD ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final filtres = _filtres;

    return Scaffold(
      backgroundColor: _cream,

      // ── DRAWER ────────────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil:                 () => Navigator.pop(context),
        onEvaluationEchantillons:  () => _goTo(const EvaluationEchantillonsPage()),
        onGestionEchantillons:     () => _goTo(const GestionEchantillonsPage()),
        onAnalyseLaboratoire:      () => _goTo(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => _goTo(const SessionsDegustationPage()),
        onMembredupanel:           () => _goTo(const MembresPanelPage()),
        onProfil:                  () => _goTo(const ProfilePage()),
        onAPropos:                 () => Navigator.pop(context),
        onDeconnexion:             _goToLogin,
      ),

      // ── APPBAR ────────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Analyse de laboratoire',
          style: GoogleFonts.domine(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          DateFilterButton(
            dateDebut: _dateDebut,
            dateFin:   _dateFin,
            onTap:     _showDateFilter,
          ),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireAnalyseDialog(
          context,
          analyse:        null,
          prochainNumero: _prochainNumero,
          onSave:         _onAjouter,
        ),
        backgroundColor: _green,
        icon:  const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvelle analyse',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),

      body: Column(
        children: [

          // ── GREEN SEARCH BAR ──────────────────────────────────────────────────
          Container(
            color:   _green,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color:      _dark.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset:     const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged:  (v) => setState(() => _recherche = v.trim()),
                style: const TextStyle(fontSize: 13, color: _dark),
                decoration: InputDecoration(
                  hintText:  'Rechercher échantillon, technicien, ID…',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Color.fromARGB(255, 150, 149, 149)),
                  prefixIcon: Icon(Icons.search, size: 17, color: Colors.grey.shade400),
                  suffixIcon: _recherche.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _recherche = '';
                            _searchController.clear();
                          }),
                          child: Icon(Icons.close, size: 17, color: Colors.grey.shade400),
                        )
                      : null,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 9),
                ),
              ),
            ),
          ),

          // ── STATUT CHIPS ──────────────────────────────────────────────────────
          Container(
            color:   Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _StatutChip(
                    label:    'Tous',
                    color:    _dark,
                    selected: _filtreStatutLabel == null,
                    onTap:    () => setState(() => _filtreStatutLabel = null),
                  ),
                  const SizedBox(width: 8),
                  _StatutChip(
                    label:    'En attente',
                    color:    const Color(0xFFF9A825),
                    selected: _filtreStatutLabel == 'En attente',
                    onTap:    () => setState(() => _filtreStatutLabel = 'En attente'),
                  ),
                  const SizedBox(width: 8),
                  _StatutChip(
                    label:    'Envoyée',
                    color:    const Color(0xFF1E88E5),
                    selected: _filtreStatutLabel == 'Envoyée',
                    onTap:    () => setState(() => _filtreStatutLabel = 'Envoyée'),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.grey.shade100, height: 1),

          // ── STATS STRIP ───────────────────────────────────────────────────────
          Container(
            color:   Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.biotech_outlined, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  '${filtres.length} analyse${filtres.length > 1 ? "s" : ""}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500),
                ),
                if (_anyFilter) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _recherche         = '';
                      _searchController.clear();
                      _filtreStatutLabel = null;
                      _dateDebut         = null;
                      _dateFin           = null;
                    }),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_alt_off_outlined,
                            size: 13, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'Effacer filtres',
                          style: TextStyle(
                              fontSize:   11,
                              color:      Colors.red.shade500,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
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
                        Icon(Icons.biotech_outlined,
                            size: 52, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Aucune analyse trouvée',
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14)),
                      ],
                    ),
                  )
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: filtres.length,
                      itemBuilder: (context, index) {
                        final a = filtres[index];
                        return AnalyseCard(
                          analyse:     a,
                          onModifier:  () => showFormulaireAnalyseDialog(
                            context,
                            analyse:        a,
                            prochainNumero: _prochainNumero,
                            onSave:         _onModifier,
                          ),
                          onSupprimer: () => showSuppressionAnalyseDialog(
                            context,
                            analyse:     a,
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
// STATUT CHIP  — colored pill (same pattern as evaluation page)
// ─────────────────────────────────────────────────────────────────────────────
class _StatutChip extends StatelessWidget {
  final String       label;
  final Color        color;
  final bool         selected;
  final VoidCallback onTap;

  const _StatutChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:        selected ? color : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.3),
          width: selected ? 1.5 : 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      selected ? Colors.white : color,
        ),
      ),
    ),
  );
}
