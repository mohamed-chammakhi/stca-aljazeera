import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'evaluation_echantillons/widgets/evaluation_slider.dart';
import 'evaluation_echantillons/widgets/classification_card.dart';

// PAGE — Formulaire de dégustation COI (StatefulWidget — sliders + classification temps réel)
class FormulaireEvaluationPage extends StatefulWidget {
  final String echantillonId;
  final String fournisseur;
  final String variete;
  final String origine;
  final String dateArrivee;
  final String? photoUrl;
  /// When true, all fields are locked — used to view a submitted evaluation.
  final bool readOnly;
  /// Pre-filled classification label when opened in read-only mode.
  final String? classification;

  const FormulaireEvaluationPage({
    super.key,
    required this.echantillonId,
    required this.fournisseur,
    required this.variete,
    required this.origine,
    required this.dateArrivee,
    this.photoUrl,
    this.readOnly = false,
    this.classification,
  });

  @override
  _FormulaireEvaluationPageState createState() =>
      _FormulaireEvaluationPageState();
}

class _FormulaireEvaluationPageState extends State<FormulaireEvaluationPage> {
  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color _headerBg = Color.fromARGB(255, 220, 233, 226);
  static const Color green = Color(0xFF38835A);
  static const Color oliveGreen = Color(0xFF6B8143);
  static const Color darkText = Color(0xFF1A2E1F);
  static const Color _bg = Color.fromARGB(255, 255, 255, 255);

  // ── Soumis → verrouille tout ──────────────────────────────────────────────
  late bool _estSoumis;

  @override
  void initState() {
    super.initState();
    _estSoumis = widget.readOnly;
  }

  // ── TYPE de fruité (Vert / Mûr) ──────────────────────────────────────────
  bool _fruiteVert = true; // true = Vert, false = Mûr

  // ── Attributs négatifs (défauts) ─────────────────────────────────────────
  double _chome = 0.0; // Chômé / Lie de boue
  double _moisi = 0.0; // Moisi / Humide / Terreux
  double _vinaigre = 0.0; // Vinaigré / Acide-Aigre
  double _gele = 0.0; // Gelé (bois mouillé)
  double _rance = 0.0; // Rance
  double _autresDefaut = 0.0; // Autres défauts

  // ── Attributs positifs ───────────────────────────────────────────────────
  double _fruite = 0.0; // Fruité
  double _amer = 0.0; // Amer
  double _piquant = 0.0; // Piquant

  // ── Notes libres du dégustateur ──────────────────────────────────────────
  final TextEditingController _notesController = TextEditingController();

  // ── Autres défauts texte libre ────────────────────────────────────────────
  final TextEditingController _autresDefautNomController =
      TextEditingController();

  // ── Médiane défauts COI (max des défauts perçus) ─────────────────────────
  double get _medianeDefauts {
    final defauts = [_chome, _moisi, _vinaigre, _gele, _rance, _autresDefaut];
    // On prend le max comme défaut dominant (norme COI)
    return defauts.reduce((a, b) => a > b ? a : b);
  }

  // ── Classification COI automatique ───────────────────────────────────────
  Map<String, dynamic> get _classification {
    final med = _medianeDefauts;
    final fruit = _fruite;

    if (med == 0.0 && fruit > 0.0) {
      return {
        'label': 'Extra Vierge',
        'color': green,
        'icon': Icons.workspace_premium_outlined,
        'bg': green.withValues(alpha: 0.06),
        'border': green.withValues(alpha: 0.28),
        'description': 'Médiane défauts = 0.0 et Fruité > 0.0',
      };
    } else if (med > 0.0 && med <= 3.5 && fruit > 0.0) {
      return {
        'label': 'Vierge',
        'color': Colors.orange.shade700,
        'icon': Icons.verified_outlined,
        'bg': Colors.orange.shade50,
        'border': Colors.orange.shade200,
        'description': '0.0 < Médiane défauts ≤ 3.5 et Fruité > 0.0',
      };
    } else if ((med > 3.5 && med <= 6.0) || (med <= 3.5 && fruit == 0.0)) {
      return {
        'label': 'Vierge Ordinaire',
        'color': Colors.deepOrange.shade600,
        'icon': Icons.info_outline,
        'bg': Colors.deepOrange.shade50,
        'border': Colors.deepOrange.shade200,
        'description': 'Médiane défauts entre 3.5 et 6.0',
      };
    } else if (med > 6.0) {
      return {
        'label': 'Lampante',
        'color': Colors.red.shade700,
        'icon': Icons.warning_amber_rounded,
        'bg': Colors.red.shade50,
        'border': Colors.red.shade200,
        'description': 'Médiane défauts > 6.0 — Non comestible en l\'état',
      };
    } else {
      // Aucune valeur saisie
      return {
        'label': 'En attente d\'évaluation',
        'color': Colors.grey.shade500,
        'icon': Icons.hourglass_empty_rounded,
        'bg': Colors.grey.shade50,
        'border': Colors.grey.shade200,
        'description': 'Saisir au moins le fruité pour classifier',
      };
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _autresDefautNomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cl = _classification;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _headerBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fiche d\'Évaluation',
              style: GoogleFonts.domine(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: darkText,
              ),
            ),
            Text(
              widget.echantillonId,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          // ── Badge soumis ──
          if (_estSoumis)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: green.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: green, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Verrouillé',
                    style: TextStyle(
                      color: green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ══════════════════════════════════════════════════════════════
            // SECTION 1 — INFORMATIONS DE L'ÉCHANTILLON
            // ══════════════════════════════════════════════════════════════
            _buildSectionCard(
              title: '📋 Informations de l\'Échantillon',
              child: _buildInfoContent(),
            ),

            const SizedBox(height: 16),

            // ══════════════════════════════════════════════════════════════
            // SECTION 2 — CLASSIFICATION EN TEMPS RÉEL
            // ══════════════════════════════════════════════════════════════
            ClassificationCard(
              classificationLabel: cl['label'] as String,
              classificationDescription: cl['description'] as String,
              classificationColor: cl['color'] as Color,
              classificationBg: cl['bg'] as Color,
              classificationBorder: cl['border'] as Color,
              classificationIcon: cl['icon'] as IconData,
              fruite: _fruite,
              fruiteVert: _fruiteVert,
              amer: _amer,
              piquant: _piquant,
              chome: _chome,
              moisi: _moisi,
              vinaigre: _vinaigre,
              gele: _gele,
              rance: _rance,
              autresDefaut: _autresDefaut,
              medianeDefauts: _medianeDefauts,
            ),

            const SizedBox(height: 16),

            // ══════════════════════════════════════════════════════════════
            // SECTION 4 — ATTRIBUTS POSITIFS
            // ══════════════════════════════════════════════════════════════
            _buildSectionCard(
              title: '✅ Attributs Positifs',
              subtitle: 'Tous les champs sont optionnels',
              child: Column(
                children: [
                  // ── Fruité avec toggle Vert / Mûr ──
                  _buildFruiteRow(),

                  EvaluationSlider(
                    label: 'Amer',
                    description: 'Goût primaire — olives vertes ou en véraison',
                    value: _amer,
                    onChanged: (v) => setState(() => _amer = v),
                    isPositif: true,
                    readOnly: _estSoumis,
                  ),
                  EvaluationSlider(
                    label: 'Piquant',
                    description:
                        'Sensation tactile — olives en début de campagne',
                    value: _piquant,
                    onChanged: (v) => setState(() => _piquant = v),
                    isPositif: true,
                    readOnly: _estSoumis,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ══════════════════════════════════════════════════════════════
            // SECTION 3 — ATTRIBUTS NÉGATIFS (DÉFAUTS)
            // ══════════════════════════════════════════════════════════════
            _buildSectionCard(
              title: '⚠️ Attributs Négatifs — Défauts',
              subtitle: 'Tous les champs sont optionnels',
              child: Column(
                children: [
                  EvaluationSlider(
                    label: 'Chômé / Lie de boue',
                    description: 'Huile d\'olives en fermentation anaérobie',
                    value: _chome,
                    onChanged: (v) => setState(() => _chome = v),
                    readOnly: _estSoumis,
                  ),
                  EvaluationSlider(
                    label: 'Moisi / Humide / Terreux',
                    description: 'Olives stockées en conditions humides',
                    value: _moisi,
                    onChanged: (v) => setState(() => _moisi = v),
                    readOnly: _estSoumis,
                  ),
                  EvaluationSlider(
                    label: 'Vinaigré / Acide-Aigre',
                    description: 'Fermentation aérobie — acide acétique',
                    value: _vinaigre,
                    onChanged: (v) => setState(() => _vinaigre = v),
                    readOnly: _estSoumis,
                  ),
                  EvaluationSlider(
                    label: 'Gelé (Bois Mouillé)',
                    description: 'Olives blessées par le gel',
                    value: _gele,
                    onChanged: (v) => setState(() => _gele = v),
                    readOnly: _estSoumis,
                  ),
                  EvaluationSlider(
                    label: 'Rance',
                    description: 'Processus d\'oxydation intense',
                    value: _rance,
                    onChanged: (v) => setState(() => _rance = v),
                    readOnly: _estSoumis,
                  ),

                  // ── Autres défauts avec nom libre ──
                  const SizedBox(height: 8),
                  TextField(
                    controller: _autresDefautNomController,
                    enabled: !_estSoumis,
                    style: const TextStyle(fontSize: 13, color: darkText),
                    decoration: InputDecoration(
                      hintText: 'Autre défaut (Métallique, Grillé, Esparto...)',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.add_circle_outline,
                        color: oliveGreen,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: green, width: 1.5),
                      ),
                    ),
                  ),
                  if (_autresDefautNomController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    EvaluationSlider(
                      label: 'Intensité — Autre défaut',
                      description: _autresDefautNomController.text,
                      value: _autresDefaut,
                      onChanged: (v) => setState(() => _autresDefaut = v),
                      readOnly: _estSoumis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ══════════════════════════════════════════════════════════════
            // SECTION 5 — NOTES LIBRES
            // ══════════════════════════════════════════════════════════════
            _buildSectionCard(
              title: '📝 Notes du Dégustateur',
              subtitle: 'Observations, remarques, impressions générales',
              child: TextField(
                controller: _notesController,
                enabled: !_estSoumis,
                maxLines: 5,
                style: const TextStyle(fontSize: 14, color: darkText),
                decoration: InputDecoration(
                  hintText:
                      'Ex: Profil aromatique dominé par des notes vertes (herbe coupée, artichaut). Bonne cohérence entre fruité et piquant...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(14),
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
                    borderSide: const BorderSide(color: green, width: 1.8),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ══════════════════════════════════════════════════════════════
            // SECTION 6 — ACTIONS
            // ══════════════════════════════════════════════════════════════
            if (!_estSoumis) ..._buildActionButtons(),

            // ── Message si déjà soumis ──
            if (_estSoumis) _buildSoumisBanner(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Photo + infos côte à côte ────────────────────────────────────────────
  Widget _buildInfoContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Photo ──
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _headerBg.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: widget.photoUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.network(widget.photoUrl!, fit: BoxFit.cover),
                )
              : Icon(Icons.image_outlined, size: 36, color: Colors.grey.shade400),
        ),
        const SizedBox(width: 14),
        // ── Infos ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.echantillonId,
                style: GoogleFonts.domine(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              _infoRow(Icons.store_outlined, widget.fournisseur),
              _infoRow(Icons.eco_outlined, widget.variete),
              _infoRow(Icons.location_on_outlined, widget.origine),
              _infoRow(Icons.calendar_today_outlined, widget.dateArrivee),
            ],
          ),
        ),
      ],
    );
  }

  // ── Boutons Brouillon + Soumettre & Verrouiller ──────────────────────────
  List<Widget> _buildActionButtons() {
    return [
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _enregistrerBrouillon,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Enregistrer le brouillon'),
          style: OutlinedButton.styleFrom(
            foregroundColor: green,
            side: const BorderSide(color: green, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _confirmerSoumission,
          icon: const Icon(Icons.lock_outline, size: 18),
          label: const Text(
            'Soumettre & Verrouiller',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          'Une fois soumis, la fiche ne peut plus être modifiée',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
      ),
    ];
  }

  // ── Slider Fruité + toggle Vert/Mûr ─────────────────────────────────────
  Widget _buildFruiteRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EvaluationSlider(
          label: 'Fruité',
          description: 'Sensations olfactives caractéristiques',
          value: _fruite,
          onChanged: (v) => setState(() => _fruite = v),
          isPositif: true,
          readOnly: _estSoumis,
        ),
        if (_fruite > 0.0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Type de fruité :',
                style: TextStyle(
                  fontSize: 12,
                  color: oliveGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              _fruiteToggleChip('🌿 Vert', isSelected: _fruiteVert, color: green,
                  onTap: () => setState(() => _fruiteVert = true)),
              const SizedBox(width: 8),
              _fruiteToggleChip('🫒 Mûr', isSelected: !_fruiteVert, color: oliveGreen,
                  onTap: () => setState(() => _fruiteVert = false)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _fruiteToggleChip(
    String label, {
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _estSoumis ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Bannière lecture seule ───────────────────────────────────────────────
  Widget _buildSoumisBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: green.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Évaluation soumise et verrouillée',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                Text(
                  'Cette fiche est en lecture seule',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Carte section avec titre ────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.domine(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ── Ligne d'info avec icône ──────────────────────────────────────────────
  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: oliveGreen),
          const SizedBox(width: 5),
          Text(value, style: const TextStyle(fontSize: 13, color: darkText)),
        ],
      ),
    );
  }

  // ── Action: brouillon ───────────────────────────────────────────────────
  void _enregistrerBrouillon() {
    // TODO: POST /api/evaluations/brouillon
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Brouillon enregistré',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: oliveGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  // ── Action: confirmer soumission ────────────────────────────────────────
  void _confirmerSoumission() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: green, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Soumettre ?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: darkText, height: 1.5),
            children: [
              const TextSpan(
                text:
                    'Vous êtes sur le point de soumettre votre évaluation pour ',
              ),
              TextSpan(
                text: widget.echantillonId,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: green,
                ),
              ),
              const TextSpan(text: '.\n\nAprès soumission, la fiche sera '),
              const TextSpan(
                text: 'verrouillée et ne pourra plus être modifiée.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Close the confirm dialog
              Navigator.pop(context);
              setState(() => _estSoumis = true);
              // TODO: POST /api/evaluations/soumettre
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Évaluation soumise et verrouillée ✅',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(20),
                ),
              );
              // Return the classification label to the calling page
              final classif = _classification['label'] as String;
              Navigator.pop(context, classif);
            },
            icon: const Icon(Icons.lock_outline, size: 16),
            label: const Text('Soumettre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
