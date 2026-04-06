// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/homepage/homepage_ceo_page.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import 'models/action_item_ceo.dart';
import 'widgets/kpi_card.dart';
import 'widgets/action_card_ceo.dart';
import '../profil_ceo_page.dart';
import '../../../main.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../analyse_organoleptique/analyse_organoleptique_ceo_page.dart';
import '../analyse_laboratoire/analyse_laboratoire_ceo_page.dart';
import '../achats_confirmes/achats_confirmes_ceo_page.dart';
import '../utilisateurs/widgets/utilisateurs_ceo_page.dart';

class HomePageCeo extends StatefulWidget {
  // onToggleTheme removed — theme is now controlled via global themeNotifier
  const HomePageCeo({super.key});

  @override
  State<HomePageCeo> createState() => _HomePageCeoState();
}

class _HomePageCeoState extends State<HomePageCeo> {
  static const Color _green = Color(0xFF38835A);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _darkText = Color(0xFF1A2E1F);

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static final List<ActionItemCeo> _actionsUrgentes = [
    ActionItemCeo(
      id: 'a1',
      type: ActionTypeCeo.approbationEchantillon,
      titre: 'Approbation requise',
      description: 'ECH-012 — Chemlali, Sfax — soumis par Ahmed D.',
      acteur: 'Ahmed D.',
      date: DateTime(2026, 3, 28),
      urgent: false,
    ),
    ActionItemCeo(
      id: 'a2',
      type: ActionTypeCeo.demandeSuppressionCollecteur,
      titre: 'Demande de suppression',
      description: 'ECH-009 — demande soumise par Sami K. avec justification.',
      acteur: 'Sami K.',
      date: DateTime(2026, 3, 28),
      urgent: true,
    ),
    ActionItemCeo(
      id: 'a3',
      type: ActionTypeCeo.sessionEnCours,
      titre: 'Session active',
      description:
          'Session #S-08 — 3/5 dégustateurs ont soumis leurs évaluations.',
      date: DateTime(2026, 3, 28),
      urgent: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        onDeconnexion: () => _goTo(const LoginPage()),
      ),
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        title: Text(
          'Tableau de Bord',
          style: GoogleFonts.domine(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () => _goTo(const Placeholder()),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, Directeur 👋',
              style: GoogleFonts.domine(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Voici l\'état de la pipeline en temps réel.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),

            // KPI Strip
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  KpiCard(
                    label: 'En traitement',
                    value: '8',
                    icon: Icons.hourglass_empty_rounded,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 10),
                  KpiCard(
                    label: 'À approuver',
                    value: '3',
                    icon: Icons.pending_actions_outlined,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 10),
                  KpiCard(
                    label: 'Sessions aujourd\'hui',
                    value: '2',
                    icon: Icons.wine_bar_outlined,
                    color: _green,
                  ),
                  const SizedBox(width: 10),
                  KpiCard(
                    label: 'Conformité labo',
                    value: '94%',
                    icon: Icons.biotech_outlined,
                    color: Colors.teal.shade600,
                  ),
                  const SizedBox(width: 10),
                  KpiCard(
                    label: 'Refusés (30j)',
                    value: '5',
                    icon: Icons.cancel_outlined,
                    color: Colors.red.shade500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSessionProgressCard(),
            const SizedBox(height: 24),

            Row(
              children: [
                Text(
                  'Actions requises',
                  style: GoogleFonts.domine(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    '${_actionsUrgentes.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._actionsUrgentes.map(
              (item) => ActionCardCeo(
                item: item,
                primaryLabel: _primaryLabel(item.type),
                secondaryLabel: 'Voir détails',
                onPrimaryAction: () {},
                onSecondaryAction: () {},
              ),
            ),

            const SizedBox(height: 24),
            _buildUpcomingDeliveriesSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.wine_bar_outlined,
                  color: _green,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Session Active — S-08',
                style: GoogleFonts.domine(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  'EN COURS',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                '3 / 5',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _green,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'dégustateurs ont soumis',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 3 / 5,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.close, size: 14),
                label: const Text(
                  'Clôturer la session',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade500,
                  padding: EdgeInsets.zero,
                ),
              ),
              const Spacer(),
              Text(
                'Mise à jour il y a 30s',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeliveriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livraisons à venir',
          style: GoogleFonts.domine(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _darkText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
            children: [
              _deliveryRow(
                ref: 'ECH-003',
                date: '15/03/2026',
                heure: '9:00',
                lieu: 'Entrepôt Sfax',
                collecteur: 'Ahmed D.',
              ),
              const Divider(height: 20),
              _deliveryRow(
                ref: 'ECH-007',
                date: '18/03/2026',
                heure: '14:00',
                lieu: 'Dépôt Tunis Nord',
                collecteur: 'Sami K.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deliveryRow({
    required String ref,
    required String date,
    required String heure,
    required String lieu,
    required String collecteur,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_shipping_outlined,
            color: _green,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _darkText,
                ),
              ),
              Text(
                '$date à $heure — $lieu',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        Text(
          collecteur,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  String _primaryLabel(ActionTypeCeo type) {
    switch (type) {
      case ActionTypeCeo.approbationEchantillon:
        return 'Approuver';
      case ActionTypeCeo.demandeSuppressionCollecteur:
        return 'Examiner';
      case ActionTypeCeo.sessionEnCours:
        return 'Voir session';
      case ActionTypeCeo.livraisonNonPlanifiee:
        return 'Alerter';
    }
  }
}
