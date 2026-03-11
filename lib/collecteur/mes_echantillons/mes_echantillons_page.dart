import 'package:flutter/material.dart';
import 'models/echantillon_collecteur.dart';
import 'widgets/echantillon_collecteur_card.dart';
import 'widgets/dialogs/collecteur_dialogs.dart';
import '../widgets/collecteur_drawer.dart';
import '../../../main.dart';
import '../../../profil.dart';

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

  // ── Navigation helpers ────────────────────────────────────────────────────
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
      id: 'ECH-COL-001',
      reference: 'REF-2026-CHEMLALI-A',
      dateAjout: '01/03/2026',
      fournisseurNom: 'Ben Salah Huiles',
      fournisseurId: 'FOUR-001',
      region: 'Sfax',
      variete: 'Chemlali',
      quantiteEstimee: '500L',
      statut: StatutCollecteur.enTraitement,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      notes: 'Récolte précoce, couleur verte',
    ),
    EchantillonCollecteur(
      id: 'ECH-COL-002',
      reference: 'REF-2026-CHETOUI-B',
      dateAjout: '28/02/2026',
      fournisseurNom: 'Ferme Trabelsi',
      fournisseurId: 'FOUR-002',
      region: 'Béja',
      variete: 'Chetoui',
      statut: StatutCollecteur.approuveEnNegociation,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
    ),
    EchantillonCollecteur(
      id: 'ECH-COL-003',
      reference: 'REF-2026-ZALMATI-C',
      dateAjout: '20/02/2026',
      fournisseurNom: 'Coopérative Gafsa',
      fournisseurId: 'FOUR-003',
      region: 'Gafsa',
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
    EchantillonCollecteur(
      id: 'ECH-COL-004',
      reference: 'REF-2026-OUESLATI-D',
      dateAjout: '15/02/2026',
      fournisseurNom: 'Domaine Kairouan',
      fournisseurId: 'FOUR-004',
      region: 'Kairouan',
      statut: StatutCollecteur.refus,
      typeRefus: TypeRefus.refusCEO,
      raisonRefus: 'Acidité trop élevée — hors norme COI',
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
    ),
    EchantillonCollecteur(
      id: 'ECH-COL-005',
      reference: 'REF-2025-CHEMLALI-Z',
      dateAjout: '10/01/2026',
      fournisseurNom: 'Ben Salah Huiles',
      fournisseurId: 'FOUR-001',
      region: 'Sfax',
      variete: 'Chemlali',
      statut: StatutCollecteur.archive,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
    ),
  ];

  // ── Filter logic ──────────────────────────────────────────────────────────
  List<EchantillonCollecteur> get _filtres {
    return _echantillons.where((e) {
      final matchRecherche =
          _recherche.isEmpty ||
          e.reference.toLowerCase().contains(_recherche.toLowerCase()) ||
          e.fournisseurNom.toLowerCase().contains(_recherche.toLowerCase()) ||
          e.region.toLowerCase().contains(_recherche.toLowerCase());
      final matchStatut = _filtreStatut == null || e.statut == _filtreStatut;
      return matchRecherche && matchStatut;
    }).toList();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void _onModifier(EchantillonCollecteur e) {
    // TODO: open formulaire dialog in edit mode
    _showSuccess('Échantillon modifié');
  }

  void _onSupprimer(EchantillonCollecteur e) {
    showSuppressionCollecteurDialog(
      context,
      echantillon: e,
      onConfirmer: () {
        setState(() => _echantillons.remove(e));
        _showSuccess('"${e.reference}" supprimé');
      },
    );
  }

  void _onConfirmerAchat(EchantillonCollecteur e) {
    showConfirmationAchatDialog(
      context,
      echantillon: e,
      onConfirmer: () {
        setState(() => e.statut = StatutCollecteur.achatConfirme);
        _showSuccess('Achat confirmé pour "${e.reference}"');
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

  // ── Filter chips data ─────────────────────────────────────────────────────
  static const List<_ChipData> _chips = [
    _ChipData(null, 'Tous'),
    _ChipData(StatutCollecteur.enTraitement, 'En traitement'),
    _ChipData(StatutCollecteur.approuveEnNegociation, 'En négociation'),
    _ChipData(StatutCollecteur.achatConfirme, 'Achat confirmé'),
    _ChipData(StatutCollecteur.refus, 'Refusés'),
    _ChipData(StatutCollecteur.archive, 'Archivés'),
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
        onCarte: () => _goTo(const Placeholder()), // TODO: CartePage()
        onMessagerie: () =>
            _goTo(const Placeholder()), // TODO: MessageriePage()
        onPreferencesCeo: () =>
            _goTo(const Placeholder()), // TODO: PreferencesCeoPage()
        onTableauDeBord: () =>
            _goTo(const Placeholder()), // TODO: TableauDeBordPage()
        onProfil: () => _goTo(const ProfilePage()),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: open formulaire with scan
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
          // ── Search bar ───────────────────────────────────────────────────
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

          // ── Filter chips ─────────────────────────────────────────────────
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
                        thumbColor: MaterialStateProperty.all(_gray),
                      ),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: _filtres.length,
                        itemBuilder: (_, i) {
                          final e = _filtres[i];
                          return EchantillonCollecteurCard(
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
