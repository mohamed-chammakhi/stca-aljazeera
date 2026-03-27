// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/panel_degustation/panel_degustation_ceo_page.dart
// PURPOSE : CEO view of all tasting sessions — create, monitor, close, reports
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ceo_drawer.dart';
import 'models/session_ceo.dart';
import 'widgets/session_ceo_card.dart';
import 'widgets/dialogs/formulaire_session_ceo_dialog.dart';

import '../homepage/homepage_ceo_page.dart';
import '../laboratoire/laboratoire_ceo_page.dart';
import '../panel_degustation/panel_degustation_ceo_page.dart';
import '../utilisateurs/utilisateurs_ceo_page.dart';
import '../echantillons/echantillons_ceo_page.dart';
import '../../../main.dart';
import '../collecteurs/collecteurs_ceo_page.dart';

class PanelDegustationCeoPage extends StatefulWidget {
  const PanelDegustationCeoPage({super.key});

  @override
  State<PanelDegustationCeoPage> createState() =>
      _PanelDegustationCeoPageState();
}

class _PanelDegustationCeoPageState extends State<PanelDegustationCeoPage> {
  static const Color _green = Color(0xFF38835A);
  static const Color _cream = Color(0xFFF9F6EF);
  static const Color _gray = Color.fromARGB(255, 81, 82, 81);

  StatutSessionCeo? _filtreStatut;

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ── Mock data — replace with API ──────────────────────────────────────────
  final List<SessionCeo> _sessions = [
    SessionCeo(
      id: 'S-08',
      titre: 'Session Mars 2026 — Lot A',
      date: '10/03/2026',
      heure: '10:00',
      lieu: 'Salle de dégustation — Siège',
      echantillonIds: ['ECH-001', 'ECH-002'],
      membreIds: ['D01', 'D02', 'D03', 'D04', 'D05'],
      membreNoms: ['Ali B.', 'Sara M.', 'Hedi R.', 'Leila K.', 'Karim T.'],
      soumissions: 3,
      statut: StatutSessionCeo.active,
      createdAt: DateTime(2026, 3, 8),
    ),
    SessionCeo(
      id: 'S-07',
      titre: 'Session Février 2026 — Lot B',
      date: '22/02/2026',
      heure: '14:00',
      lieu: 'Salle de dégustation — Siège',
      echantillonIds: ['ECH-003'],
      membreIds: ['D01', 'D02', 'D03', 'D04'],
      membreNoms: ['Ali B.', 'Sara M.', 'Hedi R.', 'Leila K.'],
      soumissions: 4,
      statut: StatutSessionCeo.cloturee,
      rapportAi:
          'Profil aromatique excellent. Chemlali Sfax — Extra Vierge confirmé. Cohérence du panel: 94%.',
      createdAt: DateTime(2026, 2, 20),
    ),
    SessionCeo(
      id: 'S-09',
      titre: 'Session Mars 2026 — Lot C',
      date: '20/03/2026',
      heure: '09:30',
      lieu: 'Salle de dégustation — Siège',
      echantillonIds: ['ECH-004', 'ECH-005', 'ECH-006'],
      membreIds: ['D01', 'D02', 'D03', 'D04', 'D05'],
      membreNoms: ['Ali B.', 'Sara M.', 'Hedi R.', 'Leila K.', 'Karim T.'],
      soumissions: 0,
      statut: StatutSessionCeo.planifiee,
      createdAt: DateTime(2026, 3, 15),
    ),
  ];

  List<SessionCeo> get _filtrees {
    if (_filtreStatut == null) return _sessions;
    return _sessions.where((s) => s.statut == _filtreStatut).toList();
  }

  static const _chips = [
    _ChipData(null, 'Toutes'),
    _ChipData(StatutSessionCeo.active, 'En cours'),
    _ChipData(StatutSessionCeo.planifiee, 'Planifiées'),
    _ChipData(StatutSessionCeo.cloturee, 'Clôturées'),
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
          'Panel de Dégustation',
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
              '${_sessions.length} session(s)',
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
        onPressed: () => showFormulaireSessionCeoDialog(
          context,
          onSave: (session) {
            setState(() => _sessions.insert(0, session));
            _showSuccess('"${session.titre}" créée');
          },
        ),
        backgroundColor: _green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle session',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // ── Filter chips ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: _filtrees.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wine_bar_outlined,
                          size: 52,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aucune session trouvée',
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
                        itemCount: _filtrees.length,
                        itemBuilder: (_, i) {
                          final s = _filtrees[i];
                          return SessionCeoCard(
                            session: s,
                            onCloturer: s.statut == StatutSessionCeo.active
                                ? () {
                                    setState(
                                      () =>
                                          s.statut = StatutSessionCeo.cloturee,
                                    );
                                    _showSuccess(
                                      '"${s.titre}" clôturée — rapport IA en cours de génération',
                                    );
                                  }
                                : null,
                            onVoirRapport: () {},
                            onVoirEvaluations: () {},
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
  final StatutSessionCeo? statut;
  final String label;
  const _ChipData(this.statut, this.label);
}
