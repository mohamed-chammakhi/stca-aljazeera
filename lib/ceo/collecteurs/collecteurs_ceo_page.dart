// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/collecteurs/collecteurs_ceo_page.dart
// PURPOSE : CEO view of all collectors — activity, samples, map, messaging
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

class CollecteursCeoPage extends StatefulWidget {
  const CollecteursCeoPage({super.key});

  @override
  State<CollecteursCeoPage> createState() => _CollecteursCeoPageState();
}

class _CollecteursCeoPageState extends State<CollecteursCeoPage>
    with SingleTickerProviderStateMixin {
  static const Color _green = Color(0xFF38835A);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _darkText = Color(0xFF1A2E1F);

  late TabController _tabController;

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Mock collectors — replace with API ───────────────────────────────────
  final List<_CollecteurMock> _collecteurs = [
    _CollecteurMock(
      id: 'COL-001',
      nom: 'Ahmed Dridi',
      region: 'Sfax / Gafsa',
      totalEchantillons: 12,
      approuves: 8,
      enCours: 3,
      refuses: 1,
      derniereActivite: 'Il y a 2h',
    ),
    _CollecteurMock(
      id: 'COL-002',
      nom: 'Sami Khaled',
      region: 'Béja / Jendouba',
      totalEchantillons: 7,
      approuves: 5,
      enCours: 2,
      refuses: 0,
      derniereActivite: 'Il y a 1 jour',
    ),
    _CollecteurMock(
      id: 'COL-003',
      nom: 'Mounir Zouaghi',
      region: 'Nabeul / Zaghouan',
      totalEchantillons: 4,
      approuves: 3,
      enCours: 1,
      refuses: 0,
      derniereActivite: 'Il y a 3 jours',
    ),
  ];

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
          'Collecteurs',
          style: GoogleFonts.domine(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Liste'),
            Tab(text: 'Carte globale'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: List ────────────────────────────────────────────────
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _collecteurs.length,
            itemBuilder: (_, i) => _CollecteurCard(c: _collecteurs[i]),
          ),

          // ── Tab 2: Map placeholder ─────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 60, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Carte globale des visites',
                  style: GoogleFonts.domine(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Zones visitées (vert) — Non visitées (gris)',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 8),
                Text(
                  'TODO: Intégrer google_maps_flutter ou flutter_map',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Collector card ────────────────────────────────────────────────────────────
class _CollecteurCard extends StatelessWidget {
  final _CollecteurMock c;
  const _CollecteurCard({required this.c});

  static const Color _green = Color(0xFF38835A);
  static const Color _darkText = Color(0xFF1A2E1F);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.07),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _green.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: _green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nom,
                      style: GoogleFonts.domine(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _darkText,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          c.region,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                c.derniereActivite,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 10),

          // Stats row
          Row(
            children: [
              _StatPill(
                label: 'Total',
                value: '${c.totalEchantillons}',
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Approuvés',
                value: '${c.approuves}',
                color: _green,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'En cours',
                value: '${c.enCours}',
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              _StatPill(
                label: 'Refusés',
                value: '${c.refuses}',
                color: Colors.red.shade500,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.science_outlined, size: 14),
                  label: const Text(
                    'Échantillons',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map_outlined, size: 14),
                  label: const Text(
                    'Carte',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade600,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Icon(Icons.message_outlined, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _CollecteurMock {
  final String id;
  final String nom;
  final String region;
  final int totalEchantillons;
  final int approuves;
  final int enCours;
  final int refuses;
  final String derniereActivite;

  const _CollecteurMock({
    required this.id,
    required this.nom,
    required this.region,
    required this.totalEchantillons,
    required this.approuves,
    required this.enCours,
    required this.refuses,
    required this.derniereActivite,
  });
}
