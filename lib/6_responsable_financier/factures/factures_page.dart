// ═════════════════════════════════════════════════════════════════════════════
// FILE : 6_responsable_financier/factures/factures_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/rf_drawer.dart';
import '../profil_rf_page.dart';
import '../achats_confirmes/achats_confirmes_rf_page.dart';
import '../../main.dart';
import 'models/facture.dart';
import 'widgets/facture_card.dart';
import 'formulaire_facture_dialog.dart';
import '../../1_ceo/utilisateurs/models/echantillon_ceo_view.dart';
import '../../1_ceo/utilisateurs/models/mock_data_patch.dart';

const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _green    = Color(0xFF38835A);
const Color _dark     = Color(0xFF1A2E1F);
const Color _bg       = Color(0xFFFFFFFF);

class FacturesPage extends StatefulWidget {
  const FacturesPage({super.key});

  @override
  State<FacturesPage> createState() => _FacturesPageState();
}

class _FacturesPageState extends State<FacturesPage> {
  final List<Facture> _factures = List.from(mockFactures);
  String _activeFilter = 'tout';
  String _searchQuery  = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Facture> get _filtered {
    var list = _factures;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((f) =>
        f.numeroFacture.toLowerCase().contains(q) ||
        f.referenceBouteille.toLowerCase().contains(q) ||
        f.fournisseur.toLowerCase().contains(q) ||
        f.gouvernorat.toLowerCase().contains(q),
      ).toList();
    }
    switch (_activeFilter) {
      case 'brouillon':
        return list.where((f) => f.statut == StatutFacture.brouillon).toList();
      case 'emise':
        return list.where((f) => f.statut == StatutFacture.emise).toList();
      case 'payee':
        return list.where((f) => f.statut == StatutFacture.payee).toList();
      default:
        return list;
    }
  }

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  void _onModifier(Facture f) {
    // Find any confirmed purchase to pre-fill the dialog
    final achat = mockAchatsConfirmes.cast<EchantillonCeoView?>()
        .firstWhere((e) => e?.id == f.achatId, orElse: () => null);
    if (achat == null) return;
    showFormulaireFactureDialog(
      context,
      echantillon: achat,
      facture: f,
      onSave: (updated) {
        setState(() {
          final idx = _factures.indexWhere((x) => x.id == updated.id);
          if (idx != -1) _factures[idx] = updated;
        });
        _showSnack('Facture modifiée');
      },
    );
  }

  void _onSupprimer(Facture f) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Supprimer la facture ?',
          style: GoogleFonts.domine(fontSize: 16, fontWeight: FontWeight.w700, color: _dark),
        ),
        content: Text('${f.numeroFacture} sera supprimée définitivement.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _factures.remove(f));
              _showSnack('Facture supprimée');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: _green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(20),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: _bg,
      drawer: RfDrawer(
        onAchatsConfirmes: () => _goTo(const AchatsConfirmesRfPage()),
        onFactures: () => Navigator.pop(context),
        onProfil: () => _goTo(const ProfilRfPage()),
        onDeconnexion: () => _goTo(LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Factures',
          style: GoogleFonts.domine(fontSize: 18, fontWeight: FontWeight.w700, color: _dark),
        ),
        iconTheme: const IconThemeData(color: _dark),
      ),
      body: Column(
        children: [
          // ── Header zone ────────────────────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  style: const TextStyle(fontSize: 14, color: _dark),
                  decoration: InputDecoration(
                    hintText: 'Rechercher N° facture, fournisseur, réf…',
                    hintStyle: const TextStyle(color: Color(0xFF6B8E7A), fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6B8E7A), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 17, color: Color(0xFF6B8E7A)),
                            onPressed: () => setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            }),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _green, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _Chip(label: 'Tout',      active: _activeFilter == 'tout',      color: const Color(0xFF757575), onTap: () => setState(() => _activeFilter = 'tout')),
                      const SizedBox(width: 7),
                      _Chip(label: 'Brouillon', active: _activeFilter == 'brouillon', color: const Color(0xFF757575), onTap: () => setState(() => _activeFilter = 'brouillon')),
                      const SizedBox(width: 7),
                      _Chip(label: 'Émise',     active: _activeFilter == 'emise',     color: const Color(0xFFD07B2F), onTap: () => setState(() => _activeFilter = 'emise')),
                      const SizedBox(width: 7),
                      _Chip(label: 'Payée',     active: _activeFilter == 'payee',     color: _green,                  onTap: () => setState(() => _activeFilter = 'payee')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                Icon(Icons.receipt_long_outlined, size: 13, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(
                  '${items.length} facture${items.length > 1 ? "s" : ""}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                // Total amount for filtered list
                Text(
                  'Total : ${items.fold(0.0, (s, f) => s + f.montantTotal).toStringAsFixed(0)} DT',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _green),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 52, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text('Aucune facture', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
                    itemCount: items.length,
                    itemBuilder: (_, i) => FactureCard(
                      facture: items[i],
                      onModifier: items[i].statut != StatutFacture.payee
                          ? () => _onModifier(items[i])
                          : null,
                      onSupprimer: items[i].statut == StatutFacture.brouillon
                          ? () => _onSupprimer(items[i])
                          : null,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bg     = active ? color : const Color(0xFFF0F0F0);
    final fg     = active ? Colors.white : const Color(0xFF9E9E9E);
    final border = active ? color.withValues(alpha: 0.4) : const Color(0xFFE0E0E0);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.2),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      ),
    );
  }
}
