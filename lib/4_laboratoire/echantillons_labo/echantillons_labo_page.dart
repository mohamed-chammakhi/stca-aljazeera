// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/echantillons_labo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'models/echantillon_labo.dart';
import 'widgets/echantillon_labo_card.dart';
import 'widgets/statut_analyse_badge.dart';
import 'widgets/dialogs/analyse_dialog.dart';
import '../analyse_labo.dart';
import '../labo_drawer.dart';
import '../profil_labo_page.dart';
import '../../main.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
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
      quantiteEstimee: '10T',
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
      quantiteEstimee: '8T',
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
      quantiteEstimee: '30T',
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
      quantiteEstimee: '15T',
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

  // ── Summary stats ──────────────────────────────────────────────────────────
  int get _total => _echantillons.length;
  int get _analysesSoumises => _echantillons
      .where((e) => e.statutAnalyse == StatutAnalyse.soumis)
      .length;
  int get _enAttente => _echantillons
      .where((e) => e.statutAnalyse == StatutAnalyse.enAttente)
      .length;

  static const List<_ChipData> _chips = [
    _ChipData(null, 'Tous'),
    _ChipData(StatutAnalyse.enAttente, 'En attente'),
    _ChipData(StatutAnalyse.enCours, 'En cours'),
    _ChipData(StatutAnalyse.soumis, 'Soumis'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      drawer: LaboDrawer(
        onEchantillons: () => _goTo(const EchantillonsLaboPage()),
        onProfil: () => _goTo(const ProfilLaboPage()),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: const Text(
          'Échantillons à analyser',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_echantillons.length} échantillon(s)',
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
          // ── Stats strip ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _StatPill(
                  value: _total.toString(),
                  label: 'Total',
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 10),
                _StatPill(
                  value: _enAttente.toString(),
                  label: 'En attente',
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 10),
                _StatPill(
                  value: _analysesSoumises.toString(),
                  label: 'Analysés',
                  color: _green,
                ),
              ],
            ),
          ),

          // ── Search ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _recherche = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher par référence, fournisseur, région...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: _green, size: 20),
                suffixIcon: _recherche.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() {
                          _recherche = '';
                          _searchCtrl.clear();
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _green, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _chips.length,
                itemBuilder: (_, i) {
                  final chip = _chips[i];
                  final selected = _filtreStatut == chip.statut;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filtreStatut = chip.statut),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? _green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? _green : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          chip.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: _filtres.isEmpty
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
                        itemCount: _filtres.length,
                        itemBuilder: (_, i) {
                          final e = _filtres[i];
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
                color: classifColor.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: classifColor.withOpacity(0.25)),
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

// ── Small stat pill ───────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}

class _ChipData {
  final StatutAnalyse? statut;
  final String label;
  const _ChipData(this.statut, this.label);
}
