// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/echantillons_labo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/echantillon_labo.dart';
import 'widgets/echantillon_labo_card.dart';
import 'widgets/statut_analyse_badge.dart';
import 'widgets/dialogs/analyse_dialog.dart';
import '../analyse_labo.dart';
import '../labo_drawer.dart';
import '../profil_labo_page.dart';
import '../../main.dart';

const Color _green = Color(0xFF38835A);
const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _dark = Color(0xFF1A2E1F);
const Color _bg = Color.fromARGB(255, 255, 255, 255);
const Color _gray = Color.fromARGB(255, 81, 82, 81);

class EchantillonsLaboPage extends StatefulWidget {
  const EchantillonsLaboPage({super.key});

  @override
  State<EchantillonsLaboPage> createState() => _EchantillonsLaboPageState();
}

class _EchantillonsLaboPageState extends State<EchantillonsLaboPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _recherche = '';
  StatutAnalyse? _filtreStatut;

  // ── MOCK DATA ─────────────────────────────────────────────────────────────
  final List<EchantillonLabo> _echantillons = [
    EchantillonLabo(
      id: 'ECH-001',
      ref: '2026/0001',
      gouvernorat: 'Sfax',
      codeFournisseur: 'SF-42',
      collecteurNom: 'Ahmed D.',
      referenceBouteille: 'CHEMLALI-C1',
      variete: 'Chemlali',
      quantiteEstimee: '10',
      dateArrivee: '01/03/2026',
      origineCampagne: '2025/2026',
    ),
    EchantillonLabo(
      id: 'ECH-002',
      ref: '2026/0002',
      gouvernorat: 'Béja',
      codeFournisseur: 'BJ-15',
      collecteurNom: 'Ahmed D.',
      referenceBouteille: 'CHETOUI-C3',
      variete: 'Chetoui',
      quantiteEstimee: '8',
      dateArrivee: '28/02/2026',
      analyse: AnalyseLabo(
        echantillonId: 'ECH-002',
        echantillonRef: '2026/0002',
        aciditeLibre: 0.42,
        indicePeroxyde: 8.6,
        k232: 1.92,
        k270: 0.14,
        polyphenolsTotaux: 318,
        statut: StatutAnalyse.soumis,
        dateAnalyse: '28/02/2026',
      ),
    ),
    EchantillonLabo(
      id: 'ECH-003',
      ref: '2026/0003',
      gouvernorat: 'Gafsa',
      codeFournisseur: 'GF-08',
      collecteurNom: 'Sami B.',
      referenceBouteille: 'ZALMATI-C7',
      variete: 'Zalmati',
      quantiteEstimee: '30',
      dateArrivee: '20/02/2026',
      priorite: PrioriteLabo.urgente,
      analyse: AnalyseLabo(
        echantillonId: 'ECH-003',
        echantillonRef: '2026/0003',
        aciditeLibre: 1.8,
        indicePeroxyde: 18.0,
        k270: 0.19,
        k232: 2.40,
        statut: StatutAnalyse.soumis,
        dateAnalyse: '21/02/2026',
      ),
    ),
    EchantillonLabo(
      id: 'ECH-004',
      ref: '2026/0004',
      gouvernorat: 'Kairouan',
      codeFournisseur: 'KR-22',
      collecteurNom: 'Leila M.',
      referenceBouteille: 'OUESLATI-C2',
      variete: 'Oueslati',
      quantiteEstimee: '15',
      dateArrivee: '25/02/2026',
    ),
  ];

  // ── Navigation helpers ─────────────────────────────────────────────────────
  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Filter logic ───────────────────────────────────────────────────────────
  List<EchantillonLabo> get _filtres {
    return _echantillons.where((e) {
      final q = _recherche.toLowerCase();
      final matchSearch =
          _recherche.isEmpty ||
          e.referenceBouteille.toLowerCase().contains(q) ||
          e.codeFournisseur.toLowerCase().contains(q) ||
          e.gouvernorat.toLowerCase().contains(q) ||
          (e.variete?.toLowerCase().contains(q) ?? false) ||
          e.ref.toLowerCase().contains(q) ||
          e.collecteurNom.toLowerCase().contains(q);
      final matchStatut =
          _filtreStatut == null || e.statutAnalyse == _filtreStatut;
      return matchSearch && matchStatut;
    }).toList();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _onAjouterAnalyse(EchantillonLabo e) {
    showAnalyseChoiceSheet(
      context,
      echantillon: e,
      onSave: (analyse) {
        setState(() => e.analyse = analyse);
        _showSnack('Analyse soumise pour ${e.referenceBouteille}');
      },
    );
  }

  void _onModifierAnalyse(EchantillonLabo e) {
    showAnalyseChoiceSheet(
      context,
      echantillon: e,
      onSave: (analyse) {
        setState(() => e.analyse = analyse);
        _showSnack('Analyse modifiée');
      },
    );
  }

  void _showSnack(String msg) {
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

  bool get _anyFilter => _recherche.isNotEmpty || _filtreStatut != null;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtres;

    return Scaffold(
      backgroundColor: _bg,
      drawer: LaboDrawer(
        onEchantillons: () => _goTo(const EchantillonsLaboPage()),
        onProfil: () => _goTo(const ProfilLaboPage()),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Échantillons à analyser',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        iconTheme: const IconThemeData(color: _dark),
      ),
      body: Column(
        children: [
          // ── Header zone ──────────────────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _recherche = v),
                  style: const TextStyle(fontSize: 14, color: _dark),
                  decoration: InputDecoration(
                    hintText: 'Rechercher réf, fournisseur, gouvernorat…',
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
                              _searchCtrl.clear();
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
                // Filter chips
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
                        selected: _filtreStatut == null,
                        onTap: () => setState(() => _filtreStatut = null),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'En attente',
                        activeColor: const Color(0xFF3A6EA5),
                        inactiveColor: const Color(0xFFE8F1FB),
                        inactiveTextColor: const Color(0xFF3A6EA5),
                        selected: _filtreStatut == StatutAnalyse.enAttente,
                        onTap: () => setState(
                          () => _filtreStatut = StatutAnalyse.enAttente,
                        ),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'En cours',
                        activeColor: const Color(0xFFD07B2F),
                        inactiveColor: const Color(0xFFFEF3E8),
                        inactiveTextColor: const Color(0xFFD07B2F),
                        selected: _filtreStatut == StatutAnalyse.enCours,
                        onTap: () => setState(
                          () => _filtreStatut = StatutAnalyse.enCours,
                        ),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'Soumis',
                        activeColor: const Color(0xFF38835A),
                        inactiveColor: const Color(0xFFE6F4ED),
                        inactiveTextColor: const Color(0xFF38835A),
                        selected: _filtreStatut == StatutAnalyse.soumis,
                        onTap: () => setState(
                          () => _filtreStatut = StatutAnalyse.soumis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── Stats strip ──────────────────────────────────────────────────
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  size: 13,
                  color: const Color.fromARGB(255, 156, 156, 156),
                ),
                const SizedBox(width: 6),
                Text(
                  '${items.length} échantillon${items.length > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 156, 156, 156),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun échantillon trouvé',
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
                        thumbColor: WidgetStateProperty.all(_gray),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final e = items[i];
                          return EchantillonLaboCard(
                            echantillon: e,
                            onAjouterAnalyse: e.analyse == null
                                ? () => _onAjouterAnalyse(e)
                                : null,
                            onVoirAnalyse: e.analyse != null
                                ? () => _showAnalyseReadOnly(e)
                                : null,
                            onModifierAnalyse: e.analyse != null
                                ? () => _onModifierAnalyse(e)
                                : null,
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

  void _showAnalyseReadOnly(EchantillonLabo e) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AnalyseReadOnlySheet(echantillon: e),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Read-only analysis bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyseReadOnlySheet extends StatelessWidget {
  final EchantillonLabo echantillon;
  const _AnalyseReadOnlySheet({required this.echantillon});

  @override
  Widget build(BuildContext context) {
    final a = echantillon.analyse!;
    final classif = a.classificationAuto;
    final classifColor = classif == 'Extra Vierge'
        ? _green
        : classif == 'Vierge'
        ? Colors.orange.shade700
        : Colors.red.shade700;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: ListView(
          controller: ctrl,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Rapport d\'analyse — ${echantillon.referenceBouteille}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A2E1F),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Soumis le ${a.dateAnalyse ?? "—"}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: classifColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: classifColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined, color: classifColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    classif,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: classifColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _ReadOnlyRow('Acidité libre', a.aciditeLibre, '% ac. oléique'),
            _ReadOnlyRow('Indice de peroxyde', a.indicePeroxyde, 'meqO₂/kg'),
            _ReadOnlyRow('K₂₃₂', a.k232, ''),
            _ReadOnlyRow('K₂₇₀', a.k270, ''),
            _ReadOnlyRow('ΔK', a.deltaK, ''),
            _ReadOnlyRow('Humidité', a.humidite, '%'),
            _ReadOnlyRow('Impuretés', a.impuretes, '%'),
            _ReadOnlyRow('Polyphénols totaux', a.polyphenolsTotaux, 'mg/kg'),
            _ReadOnlyRow('Tocophérols', a.tocopherols, 'mg/kg'),
            _ReadOnlyRow('Acide oléique', a.acideOleique, '%'),
            _ReadOnlyRow('Acide linoléique', a.acideLinoleique, '%'),
            _ReadOnlyRow('Acide palmitique', a.acidePalmitique, '%'),
            if (a.notes != null && a.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_outlined,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  const _ReadOnlyRow(this.label, this.value, this.unit);

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Text(
            '${value!.toStringAsFixed(value! == value!.roundToDouble() ? 0 : 2)} $unit'
                .trim(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2E1F),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Statut chip — soft pastel inactive, tinted active (matches taster design) ──
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
      bg = inactiveColor; // pastel tinted bg
      fg = inactiveTextColor; // colored text
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
