import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/collecteur_drawer.dart';
import '../../../main.dart';
import '../profilcom.dart';

import '../mes_echantillons/mes_echantillons_page.dart';

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _cream = Color(0xFFF9F6EF);
const Color _darkText = Color(0xFF1A2E1F);

class TableauDeBordCollecteurPage extends StatelessWidget {
  const TableauDeBordCollecteurPage({super.key});

  // ── Navigation helpers ────────────────────────────────────────────────────
  void _goTo(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goToLogin(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      drawer: CollecteurDrawer(
        onMesEchantillons: () => _goTo(context, const MesEchantillonsPage()),
        onCarte: () => _goTo(context, const Placeholder()), // TODO: CartePage()
        onMessagerie: () =>
            _goTo(context, const Placeholder()), // TODO: MessageriePage()
        onPreferencesCeo: () =>
            _goTo(context, const Placeholder()), // TODO: PreferencesCeoPage()
        onTableauDeBord: () => Navigator.pop(context),
        onProfil: () => _goTo(context, const ProfileCollecteurPage()),
        onDeconnexion: () => _goToLogin(context),
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Bonjour, Ahmed',
              style: GoogleFonts.domine(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Voici un résumé de votre activité',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),

            // ── KPI cards ─────────────────────────────────────────────────
            Text(
              'Aperçu global',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _oliveGreen,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: const [
                _KpiCard(
                  label: 'Total échantillons',
                  value: '24',
                  icon: Icons.inventory_2_outlined,
                  color: Color(0xFF1565C0),
                  bg: Color(0xFFE3F2FD),
                ),
                _KpiCard(
                  label: 'Achats confirmés',
                  value: '9',
                  icon: Icons.check_circle_outline,
                  color: Color(0xFF38835A),
                  bg: Color(0xFFE8F5E9),
                ),
                _KpiCard(
                  label: 'En cours / négociation',
                  value: '7',
                  icon: Icons.hourglass_empty_outlined,
                  color: Color(0xFFF57C00),
                  bg: Color(0xFFFFF3E0),
                ),
                _KpiCard(
                  label: 'Refusés',
                  value: '5',
                  icon: Icons.cancel_outlined,
                  color: Color(0xFFC62828),
                  bg: Color(0xFFFFEBEE),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Répartition statuts ───────────────────────────────────────
            Text(
              'Répartition par statut',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _oliveGreen,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _green.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  _BarItem(
                    label: 'En traitement',
                    value: 8,
                    total: 24,
                    color: Color(0xFF1565C0),
                  ),
                  SizedBox(height: 10),
                  _BarItem(
                    label: 'Approuvé — Négociation',
                    value: 5,
                    total: 24,
                    color: Color(0xFFF57C00),
                  ),
                  SizedBox(height: 10),
                  _BarItem(
                    label: 'Achat confirmé',
                    value: 9,
                    total: 24,
                    color: Color(0xFF38835A),
                  ),
                  SizedBox(height: 10),
                  _BarItem(
                    label: 'Refusés',
                    value: 5,
                    total: 24,
                    color: Color(0xFFC62828),
                  ),
                  SizedBox(height: 10),
                  _BarItem(
                    label: 'Archivés',
                    value: 3,
                    total: 24,
                    color: Color(0xFF9E9E9E),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Top fournisseurs ──────────────────────────────────────────
            Text(
              'Fournisseurs les plus actifs',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _oliveGreen,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _green.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  _FournisseurRow(
                    nom: 'Ben Salah Huiles',
                    region: 'Sfax',
                    nbEch: 8,
                    nbAchat: 4,
                  ),
                  Divider(height: 1, color: Color(0xFFF1F1F1)),
                  _FournisseurRow(
                    nom: 'Ferme Trabelsi',
                    region: 'Béja',
                    nbEch: 5,
                    nbAchat: 2,
                  ),
                  Divider(height: 1, color: Color(0xFFF1F1F1)),
                  _FournisseurRow(
                    nom: 'Coopérative Gafsa',
                    region: 'Gafsa',
                    nbEch: 4,
                    nbAchat: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// ── KPI card ──────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Progress bar item ─────────────────────────────────────────────────────────
class _BarItem extends StatelessWidget {
  final String label;
  final int value;
  final int total;
  final Color color;
  const _BarItem({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: _darkText)),
            Text(
              '$value / $total',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Fournisseur row ───────────────────────────────────────────────────────────
class _FournisseurRow extends StatelessWidget {
  final String nom;
  final String region;
  final int nbEch;
  final int nbAchat;
  const _FournisseurRow({
    required this.nom,
    required this.region,
    required this.nbEch,
    required this.nbAchat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.store_outlined, color: _green, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _darkText,
                  ),
                ),
                Text(
                  region,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$nbEch échantillons',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              Text(
                '$nbAchat achat(s)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
