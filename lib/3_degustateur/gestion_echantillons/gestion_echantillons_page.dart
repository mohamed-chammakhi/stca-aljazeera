import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tableau_de_bord/homepage_page.dart';

import '../../../core/models/echantillon.dart';
import '../../../core/models/enums.dart';
import 'services/gestion_echantillons_service.dart';
import 'widgets/echantillon_card.dart';
import '../../../core/widgets/empty_state.dart';
import 'widgets/dialogs/formulaire_dialog.dart';
import 'widgets/dialogs/suppression_dialog.dart';
import 'widgets/search_filter_bar.dart';
import '../evaluation_echantillons/evaluation_echantillons_page.dart';
import '../profil/profil_page.dart';
import '../tableau_de_bord/widgets/app_drawer.dart';
import '../membres_panel/membres_panel_page.dart';
import '../../../main.dart';
import '../sessions_degustation/sessions_degustation_page.dart';
import '../analyse_labo/analyse_laboratoire_page.dart';
import '../../../core/widgets/statut_chip.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../widgets/degustateur_nav_mixin.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────
class GestionEchantillonsPage extends StatefulWidget {
  const GestionEchantillonsPage({super.key});

  @override
  _GestionEchantillonsPageState createState() =>
      _GestionEchantillonsPageState();
}

class _GestionEchantillonsPageState extends State<GestionEchantillonsPage>
    with DegustateurNavMixin {
  final _service = GestionEchantillonsService();

  // ───────────────────────────────────────────────────────────────────────────
  // 1. STATE
  // ───────────────────────────────────────────────────────────────────────────

  final TextEditingController _searchController = TextEditingController();
  String _recherche = '';
  String? _filtreStatut;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;

  // ───────────────────────────────────────────────────────────────────────────
  // 2. DATA
  // ───────────────────────────────────────────────────────────────────────────

  List<Echantillon> _echantillons = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.fetchEchantillons();
    setState(() => _echantillons = data);
  }

  // ───────────────────────────────────────────────────────────────────────────
  // 3. FILTER LOGIC
  // ───────────────────────────────────────────────────────────────────────────

  List<Echantillon> get _filtres {
    final liste = _echantillons.where((e) {
      final q = _recherche.toLowerCase();
      final matchRecherche =
          _recherche.isEmpty ||
          e.referenceBouteille.toLowerCase().contains(q) ||
          e.ref.toLowerCase().contains(q) ||
          (e.codeFournisseur?.toLowerCase().contains(q) ?? false) ||
          (e.variete?.toLowerCase().contains(q) ?? false) ||
          e.gouvernorat.toLowerCase().contains(q) ||
          (e.delegation?.toLowerCase().contains(q) ?? false) ||
          (e.collecteurNom?.toLowerCase().contains(q) ?? false);

      final matchStatut =
          _filtreStatut == null || e.statutDegustateur?.label == _filtreStatut;

      bool matchDate = true;
      if (_dateFilterActive) {
        final raw = DegDateUtils.parseDate(e.dateAjout);
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

    return liste.reversed.toList();
  }

  int get _prochainNumero => _echantillons.length + 1;

  // ───────────────────────────────────────────────────────────────────────────
  // 6. ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  void _onAjouter(List<Echantillon> nouveaux) {
    setState(() => _echantillons.addAll(nouveaux));
    final label = nouveaux.length == 1
        ? 'Échantillon ajouté avec succès'
        : '${nouveaux.length} échantillons ajoutés';
    _showSuccess(label);
  }

  void _onModifier(List<Echantillon> modifies) {
    setState(() {});
    _showSuccess('Échantillon modifié avec succès');
  }

  void _onSupprimer(Echantillon e) {
    setState(() => _echantillons.remove(e));
    _showSuccess('Échantillon ${e.id} supprimé');
  }

  void _onToggleRecu(Echantillon e) {
    setState(() => e.recuPhysiquement = !e.recuPhysiquement);
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
        backgroundColor: kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        titre: "Filtrer par date d'enregistrement",
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

  // ───────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ───────────────────────────────────────────────────────────────────────────

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
    final items = _filtres;

    return Scaffold(
      backgroundColor: kBg,

      // ── DRAWER ─────────────────────────────────────────────────────────────
      drawer: AppDrawer(
        onaccueil: () => goToPage(const HomePage()),
        onEvaluationEchantillons: () =>
            goToPage(const EvaluationEchantillonsPage()),
        onGestionEchantillons: () => goToPage(const GestionEchantillonsPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoirePage()),
        onSessionsDegustationPage: () => goToPage(const SessionsDegustationPage()),
        onMembredupanel: () => goToPage(const MembresPanelPage()),
        onProfil: () => goToPage(const ProfilePage()),
        onDeconnexion: goToLogin,
      ),

      // ── APPBAR ─────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,

        title: Text(
          'Gestion des échantillons',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDark,
          ),
        ),

        iconTheme: const IconThemeData(color: kDark),

        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _dateFilterActive ? kGreen : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: "Filtrer par date d'enregistrement",
              ),
              if (_dateFilterActive)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),

      // ── FAB ────────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showFormulaireDialog(
          context,
          echantillon: null,
          prochainNumero: _prochainNumero,
          onSaveMultiple: _onAjouter,
        ),
        backgroundColor: const Color.fromARGB(255, 197, 206, 201),
        elevation: 2,
        icon: const Icon(Icons.add, color: kDark),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: kDark, fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        children: [
          // ── UNIFIED HEADER ZONE ─────────────────────────────────────────
          Container(
            color: kHeaderBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _recherche = v.trim()),
                  style: const TextStyle(fontSize: 14, color: kDark),
                  decoration: InputDecoration(
                    hintText: 'Réf · fournisseur · gouvernorat · collecteur…',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B8E7A),
                      fontSize: 11,
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
                      borderSide: const BorderSide(color: kGreen, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                // ── Statut filter chips ─────────────────────────────────
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      StatutChip(
                        label: 'Tous',
                        activeColor: const Color(0xFF616161),
                        inactiveColor: const Color(0xFFF0F0F0),
                        inactiveTextColor: const Color(0xFF757575),
                        selected: _filtreStatut == null,
                        onTap: () => setState(() => _filtreStatut = null),
                      ),
                      const SizedBox(width: 7),
                      StatutChip(
                        label: '	Non évaluée',
                        activeColor: const Color(0xFF3A6EA5),
                        inactiveColor: const Color(0xFFE8F1FB),
                        inactiveTextColor: const Color(0xFF3A6EA5),
                        selected: _filtreStatut == 'Non évaluée',
                        onTap: () =>
                            setState(() => _filtreStatut = 'Non évaluée'),
                      ),
                      const SizedBox(width: 7),
                      StatutChip(
                        label: 'Évaluation en cours',
                        activeColor: const Color(0xFFD07B2F),
                        inactiveColor: const Color(0xFFFEF3E8),
                        inactiveTextColor: const Color(0xFFD07B2F),
                        selected: _filtreStatut == 'Évaluation en cours',
                        onTap: () => setState(
                          () => _filtreStatut = 'Évaluation en cours',
                        ),
                      ),
                      const SizedBox(width: 7),
                      StatutChip(
                        label: '	Évaluation soumise',
                        activeColor: const Color(0xFF38835A),
                        inactiveColor: const Color(0xFFE6F4ED),
                        inactiveTextColor: const Color(0xFF38835A),
                        selected: _filtreStatut == '	Évaluation soumise',
                        onTap: () => setState(
                          () => _filtreStatut = '	Évaluation soumise',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Thin separator shadow
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── STATS STRIP ───────────────────────────────────────────────────
          Container(
            color: kBg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 13,
                  color: const Color.fromARGB(255, 156, 156, 156),
                ),
                const SizedBox(width: 6),
                Text(
                  '${items.length} échantillon${items.length > 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color.fromARGB(255, 156, 156, 156),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── FLAT LIST ─────────────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? const EmptyState()
                : Scrollbar(
                    thumbVisibility: true,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final e = items[i];
                        return EchantillonCard(
                          echantillon: e,
                          onModifier: () => showFormulaireDialog(
                            context,
                            echantillon: e,
                            prochainNumero: _prochainNumero,
                            onSaveMultiple: _onModifier,
                          ),
                          onSupprimer: () => showSuppressionDialog(
                            context,
                            echantillon: e,
                            onConfirmer: () => _onSupprimer(e),
                          ),
                          onToggleRecu: () => _onToggleRecu(e),
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
