// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/analyse_laboratoire/analyse_laboratoire_ceo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:project3/core/utils/date_utils.dart';
import 'models/lab_row.dart';
import '../widgets/ceo_nav_mixin.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../utilisateurs/models/echantillon_ceo_view.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../profil_ceo_page.dart';
import '../../main.dart';
import '../utilisateurs/models/mock_data_patch.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';
import '../widgets/search_date_filter_bar.dart';
import '../widgets/sample_card_echantillon.dart';
import '../widgets/base_sample_card.dart';
import '../widgets/status_filter_chip.dart';
import 'widgets/rapport_section.dart';

const Color _teal = Color(0xFF00796B);
const Color _dark = Color(0xFF1A2E1F);

// ─────────────────────────────────────────────────────────────────────────────
class AnalyseLaboratoireCeoPage extends StatefulWidget {
  const AnalyseLaboratoireCeoPage({super.key});
  @override
  State<AnalyseLaboratoireCeoPage> createState() =>
      _AnalyseLaboratoireCeoPageState();
}

class _AnalyseLaboratoireCeoPageState extends State<AnalyseLaboratoireCeoPage> with CeoNavMixin {
  final Set<String> _expandedRapport = {};

  // ── ADDED: active filter state (mirrors achats confirmes pattern) ──────────
  String _activeFilter = 'tout';

  DateTime? _dateDebut;
  DateTime? _dateFin;
  DateFilterType _dateType = DateFilterType.enregistrement;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<EchantillonCeoView> get _allSamples => mockEchantillonsLabo;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? _dateFieldFor(EchantillonCeoView e) {
    switch (_dateType) {
      case DateFilterType.enregistrement:
        return e.dateAjout;
      case DateFilterType.livraisonEchantillon:
        return e.dateArriveeEchantillon ?? e.dateLivraisonPrevue;
      case DateFilterType.arriveeStock:
        return e.dateLivraisonStock;
    }
  }

  List<EchantillonCeoView> get _samples {
    var result = _allSamples;
    if (_dateDebut != null) {
      result = result.where((e) {
        final dateStr = _dateFieldFor(e);
        if (dateStr == null) return false;
        final d = DegDateUtils.parseDate(dateStr);
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
    // ── ADDED: apply status filter ────────────────────────────────────────────
    if (_activeFilter == 'Analyse soumise') {
      result = result.where((e) => e.analyse != null).toList();
    } else if (_activeFilter == 'Analyse en attente') {
      result = result.where((e) => e.analyse == null).toList();
    }
    return result;
  }


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
        availableTypes: const [
          DateFilterType.enregistrement,
          DateFilterType.livraisonEchantillon,
        ],
        initialType: _dateType,
        onApplyTyped: (d, f, type) => setState(() {
          _dateDebut = d;
          _dateFin = f;
          _dateType = type;
        }),
      ),
    );
  }


  Color _classifColor(String c) {
    if (c == 'Extra Vierge') return kGreen;
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
      backgroundColor: kBg,
      drawer: CeoDrawer(
        onEchantillons: () => goToPage(const EchantillonsCeoPage()),
        onAnalyseOrganoleptique: () =>
            goToPage(const AnalyseOrganoleptiqueCeoPage()),
        onAnalyseLaboratoire: () => goToPage(const AnalyseLaboratoireCeoPage()),
        onAchatsConfirmes: () => goToPage(const AchatsConfirmesCeoPage()),
        onTableauDeBord: () => Navigator.pop(context),
        onProfil: () => goToPage(const ProfilceoPage()),
        onutilisiateurs: () => goToPage(const UtilisateursCeoPage()),
        onDeconnexion: () => goToPage(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Analyse laboratoire',
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
                  color: (_dateDebut != null || _dateFin != null)
                      ? kGreen
                      : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: _dateDebut != null
                    ? 'Filtré par : ${_dateType.label}'
                    : 'Filtrer par date',
              ),
              if (_dateDebut != null || _dateFin != null)
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
      body: Column(
        children: [
          // ── Unified header zone ──────────────────────────────────────
          Container(
            color: kHeaderBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              style: const TextStyle(fontSize: 14, color: kDark),
              decoration: InputDecoration(
                hintText: 'Réf, fournisseur, gouvernorat, variété, collecteur…',
                hintStyle: const TextStyle(
                  color: Color(0xFF6B8E7A),
                  fontSize: 11,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF6B8E7A),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 17,
                          color: Color(0xFF6B8E7A),
                        ),
                        onPressed: () => setState(() {
                          _searchQuery = '';
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
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── CHANGED: filter chips strip (replaces old stats strip) ───────────
          Container(
            color: kBg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                StatusFilterChip(
                  label: 'Tout',
                  isActive: _activeFilter == 'tout',
                  activeBg: const Color(0xFF757575),
                  activeFg: Colors.white,
                  onTap: () => setState(() => _activeFilter = 'tout'),
                ),
                const SizedBox(width: 8),
                StatusFilterChip(
                  label: 'Analyse soumise',
                  isActive: _activeFilter == 'Analyse soumise',
                  activeBg: kGreen.withValues(alpha: 0.12),
                  activeFg: kGreen,
                  onTap: () =>
                      setState(() => _activeFilter = 'Analyse soumise'),
                ),
                const SizedBox(width: 8),
                StatusFilterChip(
                  label: 'Analyse en attente',
                  isActive: _activeFilter == 'Analyse en attente',
                  activeBg: Colors.orange.shade700.withValues(alpha: 0.12),
                  activeFg: Colors.orange.shade700,
                  onTap: () =>
                      setState(() => _activeFilter = 'Analyse en attente'),
                ),
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
                        accentColor: _teal,
                        badge: CardBadgeRow(
                          badges: [
                            if (e.quantiteEstimee != null)
                              CardBadge(
                                label: 'Qté : ${e.quantiteEstimee}T',
                                color: kOlive,
                              ),
                          ],
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
                        bottomSection: RapportSection(
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
                const Spacer(),
                if (hasAnalyse && e.analyse!.dateAnalyse != null)
                  Text(
                    'Soumis le ${e.analyse!.dateAnalyse!}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                const SizedBox(width: 6),
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
// RAPPORT BLOCK  — criteria table matching taster's AnalyseCard style
// ─────────────────────────────────────────────────────────────────────────────
class _LabRow {
  final String label;
  final String value;
  final String norm;
  final bool? conforme;
  const _LabRow({
    required this.label,
    required this.value,
    required this.norm,
    this.conforme,
  });
}

class _RapportBlock extends StatelessWidget {
  final AnalyseLaboCeoView analyse;
  const _RapportBlock({required this.analyse});

  List<_LabRow> _buildRows(AnalyseLaboCeoView a) {
    final rows = <_LabRow>[];
    if (a.aciditeLibre != null) {
      final v = a.aciditeLibre!;
      rows.add(_LabRow(
        label: 'Acidité libre',
        value: '${v.toStringAsFixed(2)} %',
        norm: '≤ 0.80 %',
        conforme: v <= 0.80,
      ));
    }
    if (a.indicePeroxyde != null) {
      final v = a.indicePeroxyde!;
      rows.add(_LabRow(
        label: 'Ind. de peroxyde',
        value: '${v.toStringAsFixed(1)} meqO₂/kg',
        norm: '≤ 20',
        conforme: v <= 20,
      ));
    }
    if (a.k232 != null) {
      final v = a.k232!;
      rows.add(_LabRow(
        label: 'K₂₃₂',
        value: v.toStringAsFixed(2),
        norm: '≤ 2.50',
        conforme: v <= 2.50,
      ));
    }
    if (a.k270 != null) {
      final v = a.k270!;
      rows.add(_LabRow(
        label: 'K₂₇₀',
        value: v.toStringAsFixed(2),
        norm: '≤ 0.22',
        conforme: v <= 0.22,
      ));
    }
    if (a.deltaK != null) {
      final v = a.deltaK!;
      rows.add(_LabRow(
        label: 'ΔK',
        value: v.toStringAsFixed(3),
        norm: '≤ 0.01',
        conforme: v <= 0.01,
      ));
    }
    if (a.polyphenolsTotaux != null) {
      rows.add(_LabRow(
        label: 'Polyphénols totaux',
        value: '${a.polyphenolsTotaux!.toStringAsFixed(0)} mg/kg',
        norm: '—',
      ));
    }
    if (a.humidite != null) {
      final v = a.humidite!;
      rows.add(_LabRow(
        label: 'Humidité',
        value: '${v.toStringAsFixed(2)} %',
        norm: '≤ 0.20 %',
        conforme: v <= 0.20,
      ));
    }
    if (a.impuretes != null) {
      final v = a.impuretes!;
      rows.add(_LabRow(
        label: 'Impuretés',
        value: '${v.toStringAsFixed(2)} %',
        norm: '≤ 0.10 %',
        conforme: v <= 0.10,
      ));
    }
    if (a.acideOleique != null) {
      rows.add(_LabRow(
        label: 'Acide oléique',
        value: '${a.acideOleique!.toStringAsFixed(1)} %',
        norm: '—',
      ));
    }
    if (a.acideLinoleique != null) {
      rows.add(_LabRow(
        label: 'Acide linoléique',
        value: '${a.acideLinoleique!.toStringAsFixed(1)} %',
        norm: '—',
      ));
    }
    if (a.acidePalmitique != null) {
      rows.add(_LabRow(
        label: 'Acide palmitique',
        value: '${a.acidePalmitique!.toStringAsFixed(1)} %',
        norm: '—',
      ));
    }
    if (a.tocopherols != null) {
      rows.add(_LabRow(
        label: 'Tocophérols',
        value: '${a.tocopherols!.toStringAsFixed(0)} mg/kg',
        norm: '—',
      ));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final a = analyse;
    final rows = _buildRows(a);
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LabTableRow(
            label: 'Critère',
            value: 'Valeur',
            norm: 'Norme',
            conforme: null,
            isHeader: true,
          ),
          const SizedBox(height: 2),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _LabTableRow(
                label: r.label,
                value: r.value,
                norm: r.norm,
                conforme: r.conforme,
              ),
            ),
          ),
          if (a.notes != null && a.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_outlined,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      a.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LabTableRow extends StatelessWidget {
  final String label;
  final String value;
  final String norm;
  final bool? conforme;
  final bool isHeader;

  const _LabTableRow({
    required this.label,
    required this.value,
    required this.norm,
    required this.conforme,
    this.isHeader = false,
  });

  static const Color _redVal = Color(0xFFC62828);
  static const Color _redBg = Color(0xFFFFEBEE);
  static const Color _tableOlive = Color(0xFF6B8143);
  static const Color _tableGreen = Color(0xFF38835A);

  @override
  Widget build(BuildContext context) {
    final bg = isHeader
        ? const Color(0xFFF1F8F4)
        : conforme == false
        ? _redBg
        : Colors.white;

    final barColor = isHeader
        ? Colors.transparent
        : conforme == false
        ? _redVal
        : _tableGreen;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                    color: isHeader ? _tableOlive : _dark,
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade100),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isHeader
                        ? _tableOlive
                        : conforme == false
                        ? _redVal
                        : _tableGreen,
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade100),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Text(
                  norm,
                  style: TextStyle(
                    fontSize: 11,
                    color: isHeader ? _tableOlive : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            if (!isHeader && conforme != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  conforme! ? Icons.check_circle : Icons.cancel,
                  color: conforme! ? _tableGreen : _redVal,
                  size: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }
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
        Text(
          'Analyse non encore soumise',
          style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
        ),
      ],
    ),
  );
}
