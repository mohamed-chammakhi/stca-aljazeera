// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../utilisateurs/models/echantillon_ceo_view.dart';
import '../utilisateurs/widgets/analyse_labo_sheet.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import 'analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../profil_ceo_page.dart';
import '../../main.dart';
import '../utilisateurs/models/mock_data_patch.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../widgets/search_date_filter_bar.dart';
import '../widgets/sample_card_widgets.dart';
import '../widgets/base_sample_card.dart'; // ← shared card

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _dark = Color(0xFF1A2E1F);
const Color _teal = Color(0xFF00796B);

// ─────────────────────────────────────────────────────────────────────────────
class AnalyseLaboratoireCeoPage extends StatefulWidget {
  const AnalyseLaboratoireCeoPage({super.key});
  @override
  State<AnalyseLaboratoireCeoPage> createState() =>
      _AnalyseLaboratoireCeoPageState();
}

class _AnalyseLaboratoireCeoPageState extends State<AnalyseLaboratoireCeoPage> {
  final Set<String> _expandedRapport = {};

  DateTime? _dateDebut;
  DateTime? _dateFin;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<EchantillonCeoView> get _allSamples => mockEchantillonsLabo;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EchantillonCeoView> get _samples {
    var result = _allSamples;
    if (_dateDebut != null) {
      result = result.where((e) {
        final d = _parseDate(e.dateAjout);
        if (d == null) return false;
        final day = DateTime(d.year, d.month, d.day);
        final debut = DateTime(
          _dateDebut!.year,
          _dateDebut!.month,
          _dateDebut!.day,
        );
        if (_dateFin != null) {
          final fin = DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day);
          return !day.isBefore(debut) && !day.isAfter(fin);
        }
        return day == debut;
      }).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (e) =>
                e.referenceBouteille.toLowerCase().contains(q) ||
                e.id.toLowerCase().contains(q) ||
                e.codeFournisseur.toLowerCase().contains(q) ||
                e.gouvernorat.toLowerCase().contains(q) ||
                (e.variete?.toLowerCase().contains(q) ?? false) ||
                (e.collecteurNom?.toLowerCase().contains(q) ?? false) ||
                (e.analyse?.classificationAuto.toLowerCase().contains(q) ??
                    false),
          )
          .toList();
    }
    return result;
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

  bool get _anyFilter => _dateDebut != null || _searchQuery.isNotEmpty;

  Future<void> _showDateFilter() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateFilterSheet(
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        onApply: (d, f) => setState(() {
          _dateDebut = d;
          _dateFin = f;
        }),
        onClear: () => setState(() {
          _dateDebut = null;
          _dateFin = null;
        }),
      ),
    );
  }

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  Color _classifColor(String c) {
    if (c == 'Extra Vierge') return _green;
    if (c == 'Vierge') return Colors.orange.shade700;
    if (c == 'Lampante') return Colors.red.shade600;
    return Colors.grey.shade500;
  }

  Color _headerTint(bool hasAnalyse, String classif) {
    if (!hasAnalyse) return const Color(0xFFFAF0E6);
    if (classif == 'Extra Vierge') return const Color(0xFFEAF4EE);
    if (classif == 'Vierge') return const Color(0xFFFFF3E0);
    if (classif == 'Lampante') return const Color(0xFFFFEBEE);
    return const Color(0xFFF5F5F5);
  }

  @override
  Widget build(BuildContext context) {
    final samples = _samples;
    return Scaffold(
      backgroundColor: _cream,
      drawer: CeoDrawer(
        onEchantillons: () => _goTo(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () =>
            _goTo(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire: () => _goTo(const AnalyseLaboratoireCeoPage()),
        onAchatsConfirmes: () => _goTo(const AchatsConfirmesCeoPage()),
        onTableauDeBord: () => Navigator.pop(context),
        onProfil: () => _goTo(const ProfilceoPage()),
        onutilisiateurs: () => _goTo(const UtilisateursCeoPage()),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Analyse laboratoire',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          DateFilterButton(
            dateDebut: _dateDebut,
            dateFin: _dateFin,
            onTap: _showDateFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            searchQuery: _searchQuery,
            onChanged: (v) => setState(() => _searchQuery = v),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),
          // Stats strip
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _StatPill(
                  value: samples
                      .where((e) => e.analyse != null)
                      .length
                      .toString(),
                  label: 'Soumises',
                  color: _green,
                ),
                const SizedBox(width: 10),
                _StatPill(
                  value: samples
                      .where((e) => e.analyse == null)
                      .length
                      .toString(),
                  label: 'En attente',
                  color: Colors.orange.shade700,
                ),
                if (_anyFilter) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _dateDebut = null;
                        _dateFin = null;
                      });
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_off_outlined,
                          size: 13,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Effacer filtres',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // List
          Expanded(
            child: samples.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 10),
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
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
                    itemCount: samples.length,
                    itemBuilder: (_, i) {
                      final e = samples[i];
                      final hasAnalyse = e.analyse != null;
                      final classif = e.analyse?.classificationAuto ?? '—';
                      final classifColor = _classifColor(classif);
                      final rapportExp = _expandedRapport.contains(e.id);

                      return BaseSampleCard(
                        referenceBouteille: e.referenceBouteille,
                        id: e.id,
                        tintColor: _headerTint(hasAnalyse, classif),
                        badge: hasAnalyse
                            ? CardBadge(label: classif, color: classifColor)
                            : CardBadge(
                                label: 'En attente',
                                color: Colors.orange.shade700,
                              ),
                        detailItems: [
                          DetailItem('N° échantillon', e.id),
                          DetailItem('Ref. bouteille', e.referenceBouteille),
                          DetailItem(
                            'Gouvernorat',
                            '${e.gouvernorat}${e.delegation != null ? " — ${e.delegation}" : ""}',
                          ),
                          DetailItem('Fournisseur', e.codeFournisseur),
                          if (e.variete != null)
                            DetailItem('Variété', e.variete!),
                          if (e.quantiteEstimee != null)
                            DetailItem('Quantité', '${e.quantiteEstimee} T'),
                          DetailItem('Date ajout', e.dateAjout),
                          if (e.collecteurNom != null)
                            DetailItem('Collecteur', e.collecteurNom!),
                          DetailItem(
                            'Reçu physiquement',
                            e.recuPhysiquement ? 'Oui' : 'Non',
                          ),
                        ],
                        deliveryWidget: SampleDeliveryIndicator(e: e),
                        bottomSection: _RapportSection(
                          echantillon: e,
                          hasAnalyse: hasAnalyse,
                          isExpanded: rapportExp,
                          onToggle: () => setState(
                            () => rapportExp
                                ? _expandedRapport.remove(e.id)
                                : _expandedRapport.add(e.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RAPPORT SECTION  — bottom slot for labo cards
// ─────────────────────────────────────────────────────────────────────────────
class _RapportSection extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final bool hasAnalyse;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _RapportSection({
    required this.echantillon,
    required this.hasAnalyse,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  Icons.biotech_outlined,
                  size: 13,
                  color: hasAnalyse ? _teal : Colors.grey.shade300,
                ),
                const SizedBox(width: 6),
                Text(
                  'Rapport laboratoire',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasAnalyse ? _teal : Colors.grey.shade300,
                  ),
                ),
                if (hasAnalyse && e.analyse!.dateAnalyse != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    e.analyse!.dateAnalyse!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
                const Spacer(),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: hasAnalyse ? _teal : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: hasAnalyse
              ? _RapportBlock(analyse: e.analyse!)
              : _EnAttenteHint(),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RAPPORT BLOCK  (unchanged content)
// ─────────────────────────────────────────────────────────────────────────────
class _RapportBlock extends StatelessWidget {
  final AnalyseLaboCeoView analyse;
  const _RapportBlock({required this.analyse});

  Color _classifColor(String c) {
    if (c == 'Extra Vierge') return const Color(0xFF38835A);
    if (c == 'Vierge') return Colors.orange.shade700;
    if (c == 'Lampante') return Colors.red.shade600;
    return Colors.grey.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final a = analyse;
    final classifColor = _classifColor(a.classificationAuto);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 13,
                color: classifColor,
              ),
              const SizedBox(width: 5),
              Text(
                a.classificationAuto,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: classifColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 8),
          if (a.aciditeLibre != null)
            _AnalRow(
              'Acidité libre',
              '${a.aciditeLibre!.toStringAsFixed(2)} %',
              norm: '≤ 0.80',
              warn: a.aciditeLibre! > 0.8,
            ),
          if (a.indicePeroxyde != null)
            _AnalRow(
              'Indice de peroxyde',
              '${a.indicePeroxyde!.toStringAsFixed(1)} meqO₂/kg',
              norm: '≤ 20',
              warn: a.indicePeroxyde! > 20,
            ),
          if (a.k232 != null)
            _AnalRow(
              'K₂₃₂',
              a.k232!.toStringAsFixed(2),
              norm: '≤ 2.50',
              warn: a.k232! > 2.50,
            ),
          if (a.k270 != null)
            _AnalRow(
              'K₂₇₀',
              a.k270!.toStringAsFixed(2),
              norm: '≤ 0.22',
              warn: a.k270! > 0.22,
            ),
          if (a.deltaK != null)
            _AnalRow(
              'ΔK',
              a.deltaK!.toStringAsFixed(3),
              norm: '≤ 0.01',
              warn: a.deltaK! > 0.01,
            ),
          if (a.polyphenolsTotaux != null)
            _AnalRow(
              'Polyphénols totaux',
              '${a.polyphenolsTotaux!.toStringAsFixed(0)} mg/kg',
            ),
          if (a.humidite != null)
            _AnalRow(
              'Humidité',
              '${a.humidite!.toStringAsFixed(2)} %',
              norm: '≤ 0.20',
              warn: a.humidite! > 0.2,
            ),
          if (a.acideOleique != null)
            _AnalRow(
              'Acide oléique',
              '${a.acideOleique!.toStringAsFixed(1)} %',
            ),
          if (a.notes != null && a.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Notes : ${a.notes}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalRow extends StatelessWidget {
  final String label, value;
  final String? norm;
  final bool warn;
  const _AnalRow(this.label, this.value, {this.norm, this.warn = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              if (norm != null)
                Text(
                  'Norme : $norm',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
            ],
          ),
        ),
        if (warn)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 13,
              color: Colors.red.shade400,
            ),
          ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: warn ? Colors.red.shade600 : _dark,
          ),
        ),
      ],
    ),
  );
}

class _EnAttenteHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange.shade100),
    ),
    child: Row(
      children: [
        Icon(
          Icons.hourglass_empty_rounded,
          size: 13,
          color: Colors.orange.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          'Analyse non encore soumise par le technicien',
          style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT PILL
// ─────────────────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String value, label;
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
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.2)),
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
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}
