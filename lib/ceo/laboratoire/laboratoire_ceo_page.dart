// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/laboratoire/laboratoire_ceo_page.dart
// PURPOSE : CEO view of all lab analyses — conformity flags, per-sample reports
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';

import '../homepage/homepage_ceo_page.dart';
import '../laboratoire/laboratoire_ceo_page.dart';
import '../panel_degustation/panel_degustation_ceo_page.dart';
import '../utilisateurs/utilisateurs_ceo_page.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../../../main.dart';
import '../collecteurs/collecteurs_ceo_page.dart';

class LaboratoireCeoPage extends StatefulWidget {
  const LaboratoireCeoPage({super.key});

  @override
  State<LaboratoireCeoPage> createState() => _LaboratoireCeoPageState();
}

class _LaboratoireCeoPageState extends State<LaboratoireCeoPage> {
  static const Color _green = Color(0xFF38835A);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _darkText = Color(0xFF1A2E1F);
  static const Color _gray = Color.fromARGB(255, 81, 82, 81);

  final TextEditingController _searchCtrl = TextEditingController();
  String _recherche = '';
  bool? _filtreConforte; // null = all, true = conforme, false = non-conforme

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Mock data — replace with API ──────────────────────────────────────────
  final List<_AnalyseMock> _analyses = [
    _AnalyseMock(
      echantillonRef: '2026/0001',
      fournisseur: 'SF-42 — Chemlali',
      acidite: 0.22,
      peroxyde: 8.1,
      polyphenols: 312,
      conformeCoi: true,
      dateAnalyse: '05/03/2026',
      technicien: 'Tarek L.',
    ),
    _AnalyseMock(
      echantillonRef: '2026/0002',
      fournisseur: 'BJ-15 — Chetoui',
      acidite: 0.45,
      peroxyde: 12.3,
      polyphenols: 198,
      conformeCoi: true,
      dateAnalyse: '04/03/2026',
      technicien: 'Tarek L.',
    ),
    _AnalyseMock(
      echantillonRef: '2026/0004',
      fournisseur: 'TN-07 — Zalmati',
      acidite: 2.1,
      peroxyde: 22.5,
      polyphenols: 85,
      conformeCoi: false,
      dateAnalyse: '03/03/2026',
      technicien: 'Tarek L.',
    ),
  ];

  List<_AnalyseMock> get _filtrees {
    return _analyses.where((a) {
      final q = _recherche.toLowerCase();
      final matchSearch =
          _recherche.isEmpty ||
          a.echantillonRef.toLowerCase().contains(q) ||
          a.fournisseur.toLowerCase().contains(q);
      final matchConforte =
          _filtreConforte == null || a.conformeCoi == _filtreConforte;
      return matchSearch && matchConforte;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conformes = _analyses.where((a) => a.conformeCoi).length;
    final nonConformes = _analyses.length - conformes;

    return Scaffold(
      backgroundColor: _cream,
      drawer: CeoDrawer(
        onAccueil: () => _goTo(const HomePageCeo()),
        onEchantillons: () => _goTo(const EchantillonsCeoPage()),
        onPanelDegustation: () => _goTo(const PanelDegustationCeoPage()),
        onCollecteurs: () => _goTo(const CollecteursCeoPage()),
        onLaboratoire: () => _goTo(const LaboratoireCeoPage()),
        onUtilisateurs: () => _goTo(const UtilisateursCeoPage()),
        onTableauDeBord: () => _goTo(const Placeholder()),
        onNotifications: () => _goTo(const Placeholder()),
        onProfil: () => _goTo(const Placeholder()),
        onDeconnexion: () => _goTo(const LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Laboratoire',
          style: GoogleFonts.domine(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Conformity summary strip ────────────────────────────────────
          Container(
            color: _green,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _ConformityPill(
                  label: 'Conformes COI',
                  value: '$conformes',
                  color: Colors.green.shade300,
                  onTap: () => setState(
                    () =>
                        _filtreConforte = _filtreConforte == true ? null : true,
                  ),
                  selected: _filtreConforte == true,
                ),
                const SizedBox(width: 10),
                _ConformityPill(
                  label: 'Non conformes',
                  value: '$nonConformes',
                  color: Colors.red.shade300,
                  onTap: () => setState(
                    () => _filtreConforte = _filtreConforte == false
                        ? null
                        : false,
                  ),
                  selected: _filtreConforte == false,
                ),
                const Spacer(),
                Text(
                  '${(_analyses.isEmpty ? 0 : (conformes / _analyses.length * 100)).toStringAsFixed(0)}% taux',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // ── Search ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _recherche = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Référence, fournisseur...',
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

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(_gray),
                ),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                  itemCount: _filtrees.length,
                  itemBuilder: (_, i) => _AnalyseCard(a: _filtrees[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lab analysis card ─────────────────────────────────────────────────────────
class _AnalyseCard extends StatelessWidget {
  final _AnalyseMock a;
  const _AnalyseCard({required this.a});

  static const Color _green = Color(0xFF38835A);
  static const Color _darkText = Color(0xFF1A2E1F);

  @override
  Widget build(BuildContext context) {
    final conformeColor = a.conformeCoi
        ? Colors.green.shade600
        : Colors.red.shade600;
    final conformeBg = a.conformeCoi
        ? Colors.green.shade50
        : Colors.red.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: a.conformeCoi ? Colors.green.shade100 : Colors.red.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.biotech_outlined,
                  color: _green,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.echantillonRef,
                      style: GoogleFonts.domine(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    Text(
                      a.fournisseur,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: conformeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a.conformeCoi ? 'CONFORME COI' : 'NON CONFORME',
                  style: TextStyle(
                    fontSize: 10,
                    color: conformeColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 10),

          // Values table
          Row(
            children: [
              Expanded(
                child: _ValueItem(
                  label: 'Acidité',
                  value: '${a.acidite}%',
                  alert: a.acidite > 0.8,
                ),
              ),
              Expanded(
                child: _ValueItem(
                  label: 'Peroxyde',
                  value: '${a.peroxyde} meq/kg',
                  alert: a.peroxyde > 20,
                ),
              ),
              Expanded(
                child: _ValueItem(
                  label: 'Polyphénols',
                  value: '${a.polyphenols} mg/kg',
                  alert: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.person_outline, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                a.technicien,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Text(
                a.dateAnalyse,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueItem extends StatelessWidget {
  final String label;
  final String value;
  final bool alert;
  const _ValueItem({
    required this.label,
    required this.value,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    final color = alert ? Colors.red.shade600 : const Color(0xFF1A2E1F);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (alert)
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 12,
                  color: Colors.red.shade400,
                ),
              ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConformityPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final bool selected;

  const _ConformityPill({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Colors.white : Colors.white30),
        ),
        child: Row(
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
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyseMock {
  final String echantillonRef;
  final String fournisseur;
  final double acidite;
  final double peroxyde;
  final int polyphenols;
  final bool conformeCoi;
  final String dateAnalyse;
  final String technicien;

  const _AnalyseMock({
    required this.echantillonRef,
    required this.fournisseur,
    required this.acidite,
    required this.peroxyde,
    required this.polyphenols,
    required this.conformeCoi,
    required this.dateAnalyse,
    required this.technicien,
  });
}
