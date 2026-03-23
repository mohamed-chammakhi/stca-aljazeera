// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/mes_echantillons_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'models/echantillon_collecteur.dart';
import 'widgets/card/echantillon_collecteur_card.dart' show EchantillonComCard;
import 'widgets/dialogs/collecteur_dialogs.dart';
import 'widgets/dialogs/formulaire/formulaire_collecteur_dialog.dart';
import '../widgets/collecteur_drawer.dart';
import '../../../main.dart';
import '../profilcom.dart';
import '../carte_geo/carte_geo_page.dart';
import '../carte_geo/services/geo_service.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _gray = Color.fromARGB(255, 81, 82, 81);

class MesEchantillonsPage extends StatefulWidget {
  const MesEchantillonsPage({super.key});
  @override
  State<MesEchantillonsPage> createState() => _MesEchantillonsPageState();
}

class _MesEchantillonsPageState extends State<MesEchantillonsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _recherche = '';
  StatutCollecteur? _filtreStatut;
  int _compteur = 5;

  // ── Navigation ────────────────────────────────────────────────────────────
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

  // ── Mock data ─────────────────────────────────────────────────────────────
  final List<EchantillonCollecteur> _echantillons = [
    EchantillonCollecteur(
      id: 'ECH-001',
      ref: '2026/0001',
      gouvernorat: 'Sfax',
      codeFournisseur: 'SF-42',
      referenceBouteille: 'CHEMLALI-C1',
      scellage: 'Z1',
      achatConfirme: false,
      camionReservee: null,
      remarques: null,
      dateAjout: '01/03/2026',
      quantiteEstimee: '10T',
      variete: 'Chemlali',
      statut: StatutCollecteur.receptionne,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
    ),
    EchantillonCollecteur(
      id: 'ECH-002',
      ref: '2026/0002',
      gouvernorat: 'Béja',
      codeFournisseur: 'BJ-15',
      referenceBouteille: 'CHETOUI-C3',
      scellage: 'Z2',
      achatConfirme: false,
      camionReservee: null,
      remarques: 'Récolte précoce',
      dateAjout: '28/02/2026',
      quantiteEstimee: '10T',
      variete: 'Chetoui',
      statut: StatutCollecteur.enNegociation,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
    ),
    EchantillonCollecteur(
      id: 'ECH-003',
      ref: '2026/0003',
      gouvernorat: 'Gafsa',
      codeFournisseur: 'GF-08',
      referenceBouteille: 'ZALMATI-C7',
      scellage: 'Z1',
      achatConfirme: true,
      camionReservee: 'CAM-03',
      remarques: null,
      dateAjout: '20/02/2026',
      quantiteEstimee: '30T',
      variete: 'Zalmati',
      statut: StatutCollecteur.achatConfirme,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      livraison: LivraisonInfo(
        date: DateTime(2026, 3, 15),
        heure: '09:00',
        lieu: 'Entrepôt principal Sfax',
      ),
    ),
  ];

  // ── Rebuild map visited set from the current list ─────────────────────────
  // Called after every add / modify / delete so the map is always in sync.
  void _rebuildMap() {
    GeoService.instance.rebuildFromEchantillons(
      _echantillons
          .map((e) => (gouvernorat: e.gouvernorat, delegation: e.delegation))
          .toList(),
    );
  }

  // ── Filter ────────────────────────────────────────────────────────────────
  List<EchantillonCollecteur> get _filtres {
    return _echantillons.where((e) {
      final q = _recherche.toLowerCase();
      final matchRecherche =
          _recherche.isEmpty ||
          e.referenceBouteille.toLowerCase().contains(q) ||
          e.codeFournisseur.toLowerCase().contains(q) ||
          e.gouvernorat.toLowerCase().contains(q) ||
          (e.variete?.toLowerCase().contains(q) ?? false);
      final matchStatut = _filtreStatut == null || e.statut == _filtreStatut;
      return matchRecherche && matchStatut;
    }).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void _onModifier(EchantillonCollecteur e) {
    showFormulaireCollecteurDialog(
      context,
      echantillon: e,
      prochainNumero: _compteur,
      onSaveMultiple: (_) {
        setState(() {});
        _rebuildMap(); // old location removed, new one added
        _showSuccess('"${e.referenceBouteille}" modifié');
      },
    );
  }

  void _onSupprimer(EchantillonCollecteur e) {
    showSuppressionCollecteurDialog(
      context,
      echantillon: e,
      onConfirmer: () {
        setState(() => _echantillons.remove(e));
        _rebuildMap(); // removed sample's delegation may no longer be visited
        _showSuccess('"${e.referenceBouteille}" supprimé');
      },
    );
  }

  void _onConfirmerAchat(EchantillonCollecteur e) {
    showConfirmationAchatDialog(
      context,
      echantillon: e,
      onConfirmer: () {
        setState(() {
          e.statut = StatutCollecteur.achatConfirme;
          e.achatConfirme = true;
        });
        _showSuccess('Achat confirmé pour "${e.referenceBouteille}"');
      },
    );
  }

  void _onPlanifierLivraison(EchantillonCollecteur e) {
    showPlanificationLivraisonDialog(
      context,
      echantillon: e,
      onSave: (livraison) {
        setState(() => e.livraison = livraison);
        _showSuccess('Livraison planifiée');
      },
    );
  }

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

  // ── Filter chips ──────────────────────────────────────────────────────────
  static const List<_ChipData> _chips = [
    _ChipData(null, 'Tous'),
    _ChipData(StatutCollecteur.receptionne, 'Réceptionné'),
    _ChipData(StatutCollecteur.enNegociation, 'En négociation'),
    _ChipData(StatutCollecteur.achatConfirme, 'Achat confirmé'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      drawer: CollecteurDrawer(
        onMesEchantillons: () => Navigator.pop(context),
        onCarte: () => _goTo(CarteGeoPage(echantillons: _echantillons)),
        onMessagerie: () => _goTo(const Placeholder()),
        onTableauDeBord: () => _goTo(const Placeholder()),
        onProfil: () => _goTo(const ProfileCollecteurPage()),
        onDeconnexion: _goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: const Text(
          'Mes échantillons',
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
              color: Colors.white.withValues(alpha: 0.2),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showFormulaireCollecteurDialog(
            context,
            prochainNumero: _compteur + 1,
            onSaveMultiple: (nouveaux) {
              setState(() {
                for (final s in nouveaux) {
                  _echantillons.insert(0, s);
                }
                _compteur += nouveaux.length;
              });
              _rebuildMap(); // new delegations added to visited set
              final label = nouveaux.length == 1
                  ? '"${nouveaux.first.referenceBouteille}" ajouté'
                  : '${nouveaux.length} échantillons ajoutés';
              _showSuccess(label);
            },
          );
        },
        backgroundColor: _green,
        icon: const Icon(Icons.add_a_photo_outlined, color: Colors.white),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // ── Search ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

          const SizedBox(height: 8),

          // ── List ──────────────────────────────────────────────────────────
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _filtres.length,
                        itemBuilder: (_, i) {
                          final e = _filtres[i];
                          return EchantillonComCard(
                            echantillon: e,
                            onModifier: e.canModify
                                ? () => _onModifier(e)
                                : null,
                            onSupprimer: e.canDelete
                                ? () => _onSupprimer(e)
                                : null,
                            onConfirmerAchat: e.canConfirm
                                ? () => _onConfirmerAchat(e)
                                : null,
                            onPlanifierLivraison: e.canPlanifier
                                ? () => _onPlanifierLivraison(e)
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
}

class _ChipData {
  final StatutCollecteur? statut;
  final String label;
  const _ChipData(this.statut, this.label);
}
