// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/echantillons/echantillons_ceo_page.dart
// PURPOSE : Global sample list for the CEO — all collectors, all statuses
//           Approve, refuse, review deletion requests, see delivery info
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import '../widgets/statut_echantillon_badge.dart';
import 'models/echantillon_ceo.dart';
import 'widgets/card/echantillon_ceo_card.dart';
import 'widgets/dialogs/approbation_dialog.dart';
import 'widgets/dialogs/refus_dialog.dart';

import '../homepage/homepage_ceo_page.dart';
import '../laboratoire/laboratoire_ceo_page.dart';
import '../panel_degustation/panel_degustation_ceo_page.dart';
import '../utilisateurs/utilisateurs_ceo_page.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../../../main.dart';
import '../collecteurs/collecteurs_ceo_page.dart';

class EchantillonsCeoPage extends StatefulWidget {
  const EchantillonsCeoPage({super.key});

  @override
  State<EchantillonsCeoPage> createState() => _EchantillonsCeoPageState();
}

class _EchantillonsCeoPageState extends State<EchantillonsCeoPage> {
  static const Color _green = Color(0xFF38835A);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _gray = Color.fromARGB(255, 81, 82, 81);

  final TextEditingController _searchCtrl = TextEditingController();
  String _recherche = '';
  StatutEchantillonCeo? _filtreStatut;
  String? _filtreCollecteur;
  DateTime? _dateDebut;
  DateTime? _dateFin;

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Mock data — replace with API ──────────────────────────────────────────
  final List<EchantillonCeo> _echantillons = [
    EchantillonCeo(
      id: 'ECH-001',
      ref: '2026/0001',
      gouvernorat: 'Sfax',
      codeFournisseur: 'SF-42',
      referenceBouteille: 'CHEMLALI-C1',
      scellage: 'Z1',
      variete: 'Chemlali',
      quantiteEstimee: '10T',
      dateAjout: '01/03/2026',
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      statut: StatutEchantillonCeo.enCours,
    ),
    EchantillonCeo(
      id: 'ECH-002',
      ref: '2026/0002',
      gouvernorat: 'Béja',
      codeFournisseur: 'BJ-15',
      referenceBouteille: 'CHETOUI-C3',
      scellage: 'Z2',
      variete: 'Chetoui',
      quantiteEstimee: '25T',
      remarques: 'Récolte précoce',
      dateAjout: '28/02/2026',
      collecteurId: 'COL-002',
      collecteurNom: 'Sami K.',
      statut: StatutEchantillonCeo.aNegocier,
    ),
    EchantillonCeo(
      id: 'ECH-003',
      ref: '2026/0003',
      gouvernorat: 'Gafsa',
      codeFournisseur: 'GF-08',
      referenceBouteille: 'ZALMATI-C7',
      scellage: 'Z1',
      variete: 'Zalmati',
      quantiteEstimee: '30T',
      dateAjout: '20/02/2026',
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      statut: StatutEchantillonCeo.achatConfirme,
      livraisonDate: '15/03/2026',
      livraisonHeure: '9:00',
      livraisonLieu: 'Entrepôt Sfax',
    ),
  ];

  List<EchantillonCeo> get _filtres {
    return _echantillons.where((e) {
      final q = _recherche.toLowerCase();
      final matchRecherche =
          _recherche.isEmpty ||
          e.ref.toLowerCase().contains(q) ||
          e.codeFournisseur.toLowerCase().contains(q) ||
          e.gouvernorat.toLowerCase().contains(q) ||
          e.collecteurNom.toLowerCase().contains(q);
      final matchStatut = _filtreStatut == null || e.statut == _filtreStatut;
      final matchCollecteur =
          _filtreCollecteur == null || e.collecteurNom == _filtreCollecteur;
      return matchRecherche && matchStatut && matchCollecteur;
    }).toList();
  }

  static const List<_ChipData> _chips = [
    _ChipData(null, 'Tous'),
    _ChipData(StatutEchantillonCeo.enCours, 'En cours'),
    _ChipData(StatutEchantillonCeo.aNegocier, 'À négocier'),
    _ChipData(StatutEchantillonCeo.achatConfirme, 'Achat confirmé'),
    _ChipData(StatutEchantillonCeo.refuse, 'Refusé'),
  ];

  void _showSuccess(String msg) => ScaffoldMessenger.of(context).showSnackBar(
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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'Échantillons',
          style: GoogleFonts.domine(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
              '${_filtres.length} échantillon(s)',
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
          // ── Search ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _recherche = v),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Référence, fournisseur, région, collecteur...',
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

          // ── Status filter chips ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _chips.length,
                itemBuilder: (_, i) {
                  final chip = _chips[i];
                  final isSelected = _filtreStatut == chip.statut;
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
                          color: isSelected ? _green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? _green : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          chip.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
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

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: _filtres.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                        itemCount: _filtres.length,
                        itemBuilder: (_, i) {
                          final e = _filtres[i];
                          return EchantillonCeoCard(
                            echantillon: e,
                            onApprouver:
                                e.statut == StatutEchantillonCeo.enCours
                                ? () => showApprobationDialog(
                                    context,
                                    echantillon: e,
                                    onConfirmer: () {
                                      setState(
                                        () => e.statut =
                                            StatutEchantillonCeo.aNegocier,
                                      );
                                      _showSuccess(
                                        '${e.ref} approuvé — collecteur notifié',
                                      );
                                    },
                                  )
                                : null,
                            onRefuser: e.statut == StatutEchantillonCeo.enCours
                                ? () => showRefusDialog(
                                    context,
                                    echantillon: e,
                                    onConfirmer: () {
                                      setState(
                                        () => e.statut =
                                            StatutEchantillonCeo.refuse,
                                      );
                                      _showSuccess('${e.ref} refusé');
                                    },
                                  )
                                : null,
                            onVoirDetails: () {},
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

class _ChipData {
  final StatutEchantillonCeo? statut;
  final String label;
  const _ChipData(this.statut, this.label);
}
