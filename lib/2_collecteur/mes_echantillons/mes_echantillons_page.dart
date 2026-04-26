// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/mes_echantillons_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/echantillon_collecteur.dart';
import 'widgets/card/echantillon_collecteur_card.dart' show EchantillonComCard;

import 'widgets/dialogs/formulaire_dialog.dart';
import 'widgets/dialogs/formulaire_sections.dart'
    show DateLivraisonSection, ModePlanificationUI;
import 'widgets/dialogs/confirmer_achat_dialog.dart'
    show showConfirmerAchatDialog;
import '../../1_ceo/widgets/search_date_filter_bar.dart'
    show DateFilterSheet, DateFilterType;
import '../widgets/collecteur_drawer.dart';
import '../notifications/notifications_collecteur_page.dart';
import '../notifications/services/notification_collecteur_service.dart';
import '../../../main.dart';
import '../profilcom.dart';
import '../carte_geo/carte_geo_page.dart';
import '../carte_geo/services/geo_service.dart';

const Color _green = Color(0xFF38835A);
const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
const Color _dark = Color(0xFF1A2E1F);
const Color _bg = Color.fromARGB(255, 255, 255, 255);
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
  DateTime? _dateDebut;
  DateTime? _dateFin;
  DateFilterType _dateFilterType = DateFilterType.enregistrement;

  final _notifService = NotificationCollecteurService();
  int _unreadNotifCount = 0;

  bool get _dateFilterActive => _dateDebut != null || _dateFin != null;
  bool get _anyFilter =>
      _dateFilterActive || _recherche.isNotEmpty || _filtreStatut != null;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notifService.fetchUnreadCount();
    if (mounted) setState(() => _unreadNotifCount = count);
  }

  void _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsCollecteurPage(
          service: _notifService,
          onNavigate: (notification) {
            // Deep-link: all collector notifications navigate to MES_ECHANTILLONS (already here)
          },
        ),
      ),
    );
    _loadUnreadCount();
  }

  void _goTo(Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _goToLogin() {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  final List<EchantillonCollecteur> _echantillons = [
    // ── Scenario 1 : Réceptionné — pas encore reçu, pas d'arrivée planifiée ──
    EchantillonCollecteur(
      id: 'ECH-001',
      ref: '2026/0001',
      gouvernorat: 'Sfax',
      delegation: 'Sfax Sud',
      codeFournisseur: 'SF-42',
      referenceBouteille: 'CHEMLALI-C1',
      scellage: 'Z1',
      achatConfirme: false,
      remarques: null,
      dateAjout: '01/03/2026',
      quantiteEstimee: '10T',
      variete: 'Chemlali',
      statut: StatutCollecteur.receptionne,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      recuPhysiquement: false,
    ),
    // ── Scenario 2 : Réceptionné — arrivée planifiée, pas encore reçu physiquement ──
    EchantillonCollecteur(
      id: 'ECH-002',
      ref: '2026/0002',
      gouvernorat: 'Nabeul',
      delegation: 'Nabeul',
      codeFournisseur: 'NB-07',
      referenceBouteille: 'SAYALI-C2',
      scellage: 'Z3',
      achatConfirme: false,
      remarques: 'Récolte tardive',
      dateAjout: '05/03/2026',
      quantiteEstimee: '15T',
      variete: 'Sayali',
      statut: StatutCollecteur.receptionne,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      recuPhysiquement: false,
      dateArriveeEchantillon: '12/03/2026',
    ),
    // ── Scenario 3 : Réceptionné + reçu physiquement — modifiable, non supprimable ──
    EchantillonCollecteur(
      id: 'ECH-003',
      ref: '2026/0003',
      gouvernorat: 'Béja',
      delegation: 'Béja Nord',
      codeFournisseur: 'BJ-15',
      referenceBouteille: 'CHETOUI-C3',
      scellage: 'Z2',
      achatConfirme: false,
      remarques: null,
      dateAjout: '08/03/2026',
      quantiteEstimee: '20T',
      variete: 'Chetoui',
      statut: StatutCollecteur.receptionne,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      recuPhysiquement: true,
      dateReceptionEchantillon: '10/03/2026',
    ),
    // ── Scenario 4 : En négociation — budget + date souhaitée définis par la direction ──
    EchantillonCollecteur(
      id: 'ECH-004',
      ref: '2026/0004',
      gouvernorat: 'Béja',
      delegation: 'Amdoun',
      codeFournisseur: 'BJ-22',
      referenceBouteille: 'CHETOUI-C4',
      scellage: 'Z2',
      achatConfirme: false,
      remarques: 'Récolte précoce',
      dateAjout: '28/02/2026',
      quantiteEstimee: '25T',
      variete: 'Chetoui',
      statut: StatutCollecteur.enNegociation,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      recuPhysiquement: true,
      dateReceptionEchantillon: '05/03/2026',
      budgetNegociation: '9.50 TND/L',
      dateStockSouhaitee: '01/04/2026 - 15/04/2026',
    ),
    // ── Scenario 5 : En négociation — pas encore de budget défini ──
    EchantillonCollecteur(
      id: 'ECH-005',
      ref: '2026/0005',
      gouvernorat: 'Jendouba',
      delegation: 'Tabarka',
      codeFournisseur: 'JN-09',
      referenceBouteille: 'CHETOUI-C5',
      scellage: 'Z4',
      achatConfirme: false,
      remarques: null,
      dateAjout: '02/03/2026',
      quantiteEstimee: '18T',
      variete: 'Chetoui',
      statut: StatutCollecteur.enNegociation,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      recuPhysiquement: true,
      dateReceptionEchantillon: '07/03/2026',
    ),
    // ── Scenario 6 : Achat confirmé — aucune livraison planifiée ──
    EchantillonCollecteur(
      id: 'ECH-006',
      ref: '2026/0006',
      gouvernorat: 'Gabès',
      delegation: 'Gabès Sud',
      codeFournisseur: 'GB-11',
      referenceBouteille: 'CHÉTOUI-C6',
      scellage: 'Z1',
      achatConfirme: true,
      remarques: null,
      dateAjout: '18/02/2026',
      quantiteEstimee: '12T',
      variete: 'Chetoui',
      statut: StatutCollecteur.achatConfirme,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      recuPhysiquement: true,
      dateReceptionEchantillon: '22/02/2026',
      prixFinal: '8.80 TND/L',
      camionLivraison: 'CAM-05',
    ),
    // ── Scenario 7 : Achat confirmé — livraison planifiée ──
    EchantillonCollecteur(
      id: 'ECH-007',
      ref: '2026/0007',
      gouvernorat: 'Gafsa',
      delegation: 'Gafsa Sud',
      codeFournisseur: 'GF-08',
      referenceBouteille: 'ZALMATI-C7',
      scellage: 'Z1',
      achatConfirme: true,
      remarques: null,
      dateAjout: '20/02/2026',
      quantiteEstimee: '30T',
      variete: 'Zalmati',
      statut: StatutCollecteur.achatConfirme,
      collecteurId: 'COL-001',
      collecteurNom: 'Ahmed D.',
      recuPhysiquement: true,
      dateReceptionEchantillon: '25/02/2026',
      prixFinal: '9.20 TND/L',
      camionLivraison: 'CAM-03',
      livraison: PlanificationLivraison.exact(
        date: DateTime(2026, 3, 15),
        heure: '9:00 AM',
        lieu: 'Entrepôt principal Sfax',
        camion: 'CAM-03',
      ),
    ),
  ];

  void _rebuildMap() {
    GeoService.instance.rebuildFromEchantillons(
      _echantillons
          .map((e) => (gouvernorat: e.gouvernorat, delegation: e.delegation))
          .toList(),
    );
  }

  DateTime? _parseDate(String s) {
    try {
      final p = s.split('/');
      if (p.length != 3) return null;
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return null;
    }
  }

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
      bool matchDate = true;
      if (_dateFilterActive) {
        DateTime? raw;
        switch (_dateFilterType) {
          case DateFilterType.enregistrement:
            raw = _parseDate(e.dateAjout);
            break;
          case DateFilterType.livraisonEchantillon:
            if (e.dateArriveeEchantillon != null) {
              raw =
                  _parseDate(e.dateArriveeEchantillon!) ??
                  DateTime.tryParse(e.dateArriveeEchantillon!);
            }
            break;
          case DateFilterType.arriveeStock:
            raw = e.livraison?.dateExacte;
            break;
        }
        if (raw == null) {
          matchDate = false;
        } else {
          final d = DateTime(raw.year, raw.month, raw.day);
          final debut = _dateDebut != null
              ? DateTime(_dateDebut!.year, _dateDebut!.month, _dateDebut!.day)
              : null;
          final fin = _dateFin != null
              ? DateTime(_dateFin!.year, _dateFin!.month, _dateFin!.day)
              : null;
          if (debut != null && fin != null) {
            matchDate = !d.isBefore(debut) && !d.isAfter(fin);
          } else if (debut != null) {
            matchDate = !d.isBefore(debut);
          } else if (fin != null) {
            matchDate = !d.isAfter(fin);
          }
        }
      }
      return matchRecherche && matchStatut && matchDate;
    }).toList();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  void _onModifier(EchantillonCollecteur e) {
    showFormulaireDialog(
      context,
      echantillon: e,
      prochainNumero: _compteur,
      onSaveMultiple: (_) {
        setState(() {});
        _rebuildMap();
        _showSuccess('"${e.referenceBouteille}" modifié');
      },
    );
  }

  void _onSupprimer(EchantillonCollecteur e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer l\'échantillon'),
        content: Text(
          'Voulez-vous supprimer "${e.referenceBouteille}" (${e.ref}) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _echantillons.remove(e));
              _rebuildMap();
              _showSuccess('"${e.referenceBouteille}" supprimé');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _onConfirmerAchat(EchantillonCollecteur e) {
    showConfirmerAchatDialog(
      context: context,
      echantillon: e,
      onConfirm: (prix, camion, livraison, scellage) {
        setState(() {
          e.statut = StatutCollecteur.achatConfirme;
          e.achatConfirme = true;
          e.prixFinal = prix;
          if (camion != null) e.camionLivraison = camion;
          if (livraison != null) e.livraison = livraison;
          if (scellage != null) e.scellage = scellage;
        });
        _showPropositionEnvoyeeDialog(e.referenceBouteille);
      },
    );
  }

  void _showPropositionEnvoyeeDialog(String reference) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F4EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_outlined, color: _green, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Proposition envoyée',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _dark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Votre proposition pour "$reference" a été transmise à la direction. '
              'L\'achat sera finalisé après validation par le CEO.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B8E7A),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _green),
            child: const Text(
              'Compris',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _onScheduleArrivee(EchantillonCollecteur e) {
    bool active = e.dateArriveeEchantillon != null;
    ModePlanificationUI mode = ModePlanificationUI.dateExacte;
    DateTime? dateExacte;
    DateTime? periodeDebut;
    DateTime? periodeFin;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE9F4EE),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        color: _dark,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Planifier l\'arrivée de l\'échantillon',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Arrivée de la bouteille',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _dark,
                              ),
                            ),
                            Switch(
                              value: active,
                              onChanged: (_) =>
                                  setDialogState(() => active = !active),
                              activeThumbColor: _green,
                            ),
                          ],
                        ),
                        if (active) ...[
                          const SizedBox(height: 8),
                          DateLivraisonSection(
                            mode: mode,
                            onModeChanged: (m) =>
                                setDialogState(() => mode = m),
                            dateExacte: dateExacte,
                            periodeDebut: periodeDebut,
                            periodeFin: periodeFin,
                            onDateExacteChanged: (dt) =>
                                setDialogState(() => dateExacte = dt),
                            onPeriodeDebutChanged: (dt) =>
                                setDialogState(() => periodeDebut = dt),
                            onPeriodeFinChanged: (dt) =>
                                setDialogState(() => periodeFin = dt),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6EF),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade600,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            if (!active) {
                              setState(() => e.dateArriveeEchantillon = null);
                              return;
                            }
                            final dt = mode == ModePlanificationUI.dateExacte
                                ? dateExacte
                                : periodeDebut;
                            if (dt == null) return;
                            final formatted =
                                '${dt.day.toString().padLeft(2, '0')}/'
                                '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
                            setState(
                              () => e.dateArriveeEchantillon = formatted,
                            );
                            _showSuccess(
                              'Arrivée planifiée pour "${e.referenceBouteille}"',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              197,
                              206,
                              201,
                            ),
                            foregroundColor: _dark,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Enregistrer',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPlanifierLivraison(EchantillonCollecteur e) {
    showConfirmerAchatDialog(
      context: context,
      echantillon: e,
      onConfirm: (prix, camion, livraison, scellage) {
        setState(() {
          e.prixFinal = prix;
          if (camion != null) e.camionLivraison = camion;
          if (livraison != null) e.livraison = livraison;
          if (scellage != null) e.scellage = scellage;
        });
        _showSuccess('Livraison mise à jour pour "${e.referenceBouteille}"');
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

  void _showDateFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DateFilterSheet(
        dateDebut: _dateDebut,
        dateFin: _dateFin,
        onApply: (debut, fin) => setState(() {
          _dateDebut = debut;
          _dateFin = fin;
        }),
        onClear: () => setState(() {
          _dateDebut = null;
          _dateFin = null;
        }),
        availableTypes: const [
          DateFilterType.enregistrement,
          DateFilterType.livraisonEchantillon,
          DateFilterType.arriveeStock,
        ],
        initialType: _dateFilterType,
        onApplyTyped: (debut, fin, type) => setState(() {
          _dateDebut = debut;
          _dateFin = fin;
          _dateFilterType = type;
        }),
      ),
    );
  }

  int get _totalFiltered => _filtres.length;

  int _countStatut(StatutCollecteur s) =>
      _filtres.where((e) => e.statut == s).length;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtres;

    return Scaffold(
      backgroundColor: _bg,
      drawer: CollecteurDrawer(
        onMesEchantillons: () => Navigator.pop(context),
        onCarte: () => _goTo(CarteGeoPage(echantillons: _echantillons)),
        onMessagerie: () => _goTo(const Placeholder()),
        onProfil: () => _goTo(const ProfileCollecteurPage()),
        onDeconnexion: _goToLogin,
      ),
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Text(
          'Mes échantillons',
          style: GoogleFonts.domine(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _dark,
          ),
        ),
        iconTheme: const IconThemeData(color: _dark),
        actions: [
          // ── Bell icon with unread badge ──────────────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: Color(0xFF6B8E7A),
                ),
                onPressed: _openNotifications,
                tooltip: 'Notifications',
              ),
              if (_unreadNotifCount > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      _unreadNotifCount > 9 ? '9+' : '$_unreadNotifCount',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // ── Date filter ──────────────────────────────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: _dateFilterActive ? _green : const Color(0xFF6B8E7A),
                ),
                onPressed: _showDateFilter,
                tooltip: 'Filtrer par date',
              ),
              if (_dateFilterActive)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showFormulaireDialog(
            context,
            prochainNumero: _compteur + 1,
            onSaveMultiple: (nouveaux) {
              setState(() {
                for (final s in nouveaux) {
                  _echantillons.insert(0, s);
                }
                _compteur += nouveaux.length;
              });
              _rebuildMap();
              final label = nouveaux.length == 1
                  ? '"${nouveaux.first.referenceBouteille}" ajouté'
                  : '${nouveaux.length} échantillons ajoutés';
              _showSuccess(label);
            },
          );
        },
        backgroundColor: const Color.fromARGB(255, 197, 206, 201),
        elevation: 2,
        icon: const Icon(Icons.add_a_photo_outlined, color: _dark),
        label: const Text(
          'Ajouter',
          style: TextStyle(color: _dark, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // ── Header zone ──────────────────────────────────────────────────
          Container(
            color: _headerBg,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _recherche = v.trim()),
                  style: const TextStyle(fontSize: 14, color: _dark),
                  decoration: InputDecoration(
                    hintText: 'Rechercher réf, fournisseur, gouvernorat…',
                    hintStyle: const TextStyle(
                      color: Color(0xFF6B8E7A),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B8E7A),
                      size: 20,
                    ),
                    suffixIcon: _recherche.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 17,
                              color: Color(0xFF6B8E7A),
                            ),
                            onPressed: () => setState(() {
                              _recherche = '';
                              _searchCtrl.clear();
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
                      borderSide: const BorderSide(color: _green, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                // Filter chips
                SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _StatutChip(
                        label: 'Tous',
                        activeBg: const Color(0xFF757575),
                        activeFg: Colors.white,
                        inactiveBg: const Color(0xFFF0F0F0),
                        inactiveFg: const Color(0xFF9E9E9E),
                        selected: _filtreStatut == null,
                        onTap: () => setState(() => _filtreStatut = null),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'Enregistré',
                        activeBg: const Color(
                          0xFF3A6EA5,
                        ).withValues(alpha: 0.12),
                        activeFg: const Color(0xFF3A6EA5),
                        inactiveBg: const Color(0xFFF0F0F0),
                        inactiveFg: const Color(0xFF9E9E9E),
                        selected: _filtreStatut == StatutCollecteur.receptionne,
                        onTap: () => setState(
                          () => _filtreStatut = StatutCollecteur.receptionne,
                        ),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'Négociation',
                        activeBg: const Color(
                          0xFFD07B2F,
                        ).withValues(alpha: 0.12),
                        activeFg: const Color(0xFFD07B2F),
                        inactiveBg: const Color(0xFFF0F0F0),
                        inactiveFg: const Color(0xFF9E9E9E),
                        selected:
                            _filtreStatut == StatutCollecteur.enNegociation,
                        onTap: () => setState(
                          () => _filtreStatut = StatutCollecteur.enNegociation,
                        ),
                      ),
                      const SizedBox(width: 7),
                      _StatutChip(
                        label: 'Achat conclu',
                        activeBg: const Color(
                          0xFF38835A,
                        ).withValues(alpha: 0.12),
                        activeFg: const Color(0xFF38835A),
                        inactiveBg: const Color(0xFFF0F0F0),
                        inactiveFg: const Color(0xFF9E9E9E),
                        selected:
                            _filtreStatut == StatutCollecteur.achatConfirme,
                        onTap: () => setState(
                          () => _filtreStatut = StatutCollecteur.achatConfirme,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),

          // ── Stats strip ──────────────────────────────────────────────────
          Container(
            color: _bg,
            padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 13,
                  color: Color.fromARGB(255, 156, 156, 156),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_totalFiltered échantillon${_totalFiltered > 1 ? "s" : ""}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 156, 156, 156),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (_dateFilterActive) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.filter_alt_outlined,
                    color: Colors.grey.shade400,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _dateDebut != null &&
                              _dateFin != null &&
                              _dateDebut!.isAtSameMomentAs(_dateFin!)
                          ? 'Le ${_fmt(_dateDebut!)}'
                          : 'Du ${_fmt(_dateDebut!)}  →  ${_fmt(_dateFin!)}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: items.isEmpty
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
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final e = items[i];
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
                            onScheduleArrivee: e.canScheduleArrivee
                                ? () => _onScheduleArrivee(e)
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

// ── Tiny colored dot pill — shows per-status count in the stats strip ─────────
class _StripPill extends StatelessWidget {
  final int count;
  final Color color;
  const _StripPill({required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: 0.22)),
    ),
    child: Text(
      '$count',
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

// ── Statut chip — matches _FilterChip behavior from achats_confirmes_ceo_page
// Active   : solid colored background + white text, no shadow
// Inactive : pastel tinted background + colored text
// ─────────────────────────────────────────────────────────────────────────────
class _StatutChip extends StatelessWidget {
  final String label;
  final Color activeBg;
  final Color activeFg;
  final Color inactiveBg;
  final Color inactiveFg;
  final bool selected;
  final VoidCallback onTap;

  const _StatutChip({
    required this.label,
    required this.activeBg,
    required this.activeFg,
    required this.inactiveBg,
    required this.inactiveFg,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? activeBg : inactiveBg;
    final fg = selected ? activeFg : inactiveFg;
    final borderColor = selected
        ? activeFg.withValues(alpha: activeFg == Colors.white ? 0.0 : 0.3)
        : const Color(0xFFE0E0E0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
