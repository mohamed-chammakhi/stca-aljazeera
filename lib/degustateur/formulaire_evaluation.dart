import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'EvaluationEchantillonsPage.dart'; // ← pour EchantillonEval (le modèle)

// ─────────────────────────────────────────────────────────────────────────────
// PAGE — FormulaireEvaluationPage
// Formulaire de dégustation conforme aux normes COI
// StatefulWidget car : sliders changent, classification recalculée en temps réel
// ─────────────────────────────────────────────────────────────────────────────
class FormulaireEvaluationPage extends StatefulWidget {
  final String echantillonId;
  final String fournisseur;
  final String variete;
  final String origine;
  final String dateArrivee;
  final String? photoUrl;

  const FormulaireEvaluationPage({
    super.key,
    required this.echantillonId,
    required this.fournisseur,
    required this.variete,
    required this.origine,
    required this.dateArrivee,
    this.photoUrl,
  });

  @override
  _FormulaireEvaluationPageState createState() =>
      _FormulaireEvaluationPageState();
}

class _FormulaireEvaluationPageState extends State<FormulaireEvaluationPage> {
  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color green = Color(0xFF38835A);
  static const Color oliveGreen = Color(0xFF6B8143);
  static const Color cream = Color(0xFFF9F6EF);
  static const Color darkText = Color(0xFF1A2E1F);

  // ── Soumis → verrouille tout ──────────────────────────────────────────────
  bool _estSoumis = false;

  // ── TYPE de fruité (Vert / Mûr) ──────────────────────────────────────────
  bool _fruiteVert = true; // true = Vert, false = Mûr

  // ─────────────────────────────────────────────────────────────────────────
  // ATTRIBUTS NÉGATIFS (défauts) — tous initialisés à 0.0
  // ─────────────────────────────────────────────────────────────────────────
  double _chome = 0.0; // Chômé / Lie de boue
  double _moisi = 0.0; // Moisi / Humide / Terreux
  double _vinaigre = 0.0; // Vinaigré / Acide-Aigre
  double _gele = 0.0; // Gelé (bois mouillé)
  double _rance = 0.0; // Rance
  double _autresDefaut = 0.0; // Autres défauts

  // ─────────────────────────────────────────────────────────────────────────
  // ATTRIBUTS POSITIFS — tous initialisés à 0.0
  // ─────────────────────────────────────────────────────────────────────────
  double _fruite = 0.0; // Fruité
  double _amer = 0.0; // Amer
  double _piquant = 0.0; // Piquant

  // ── Notes libres du dégustateur ──────────────────────────────────────────
  final TextEditingController _notesController = TextEditingController();

  // ── Autres défauts texte libre ────────────────────────────────────────────
  final TextEditingController _autresDefautNomController =
      TextEditingController();

  // ─────────────────────────────────────────────────────────────────────────
  // CALCUL — Médiane des défauts (valeur max parmi les défauts perçus)
  // Selon normes COI : médiane du défaut perçu avec la plus grande intensité
  // ─────────────────────────────────────────────────────────────────────────
  double get _medianeDefauts {
    final defauts = [_chome, _moisi, _vinaigre, _gele, _rance, _autresDefaut];
    // On prend le max comme défaut dominant (norme COI)
    return defauts.reduce((a, b) => a > b ? a : b);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CALCUL — Classification automatique selon normes COI
  // ─────────────────────────────────────────────────────────────────────────
  Map<String, dynamic> get _classification {
    final med = _medianeDefauts;
    final fruit = _fruite;

    if (med == 0.0 && fruit > 0.0) {
      return {
        'label': 'Extra Vierge',
        'color': Colors.green.shade600,
        'icon': Icons.workspace_premium_outlined,
        'bg': Colors.green.shade50,
        'border': Colors.green.shade200,
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

  // ─────────────────────────────────────────────────────────────────────────
  // CALCUL — Intensité selon COI
  // Délicat ≤ 3.0 | Moyen 3.0–6.0 | Robuste > 6.0
  // ─────────────────────────────────────────────────────────────────────────
  String _intensiteLabel(double val) {
    if (val == 0.0) return '';
    if (val <= 3.0) return 'Délicat';
    if (val <= 6.0) return 'Moyen';
    return 'Robuste';
  }

  Color _sliderColor(double val) {
    if (val <= 3.0) return Colors.green.shade500;
    if (val <= 6.0) return Colors.orange.shade500;
    return Colors.red.shade500;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _autresDefautNomController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                color: Colors.white,
              ),
            ),
            Text(
              widget.echantillonId,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
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
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Verrouillé',
                    style: TextStyle(
                      color: Colors.white,
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
              child: Column(
                children: [
                  // Photo + infos côte à côte
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Photo ──
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: green.withOpacity(0.3)),
                        ),
                        child: widget.photoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  widget.photoUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.image_outlined,
                                size: 36,
                                color: green.withOpacity(0.4),
                              ),
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
                            _infoRow(
                              Icons.location_on_outlined,
                              widget.origine,
                            ),
                            _infoRow(
                              Icons.calendar_today_outlined,
                              widget.dateArrivee,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ══════════════════════════════════════════════════════════════
            // SECTION 2 — CLASSIFICATION EN TEMPS RÉEL
            // ══════════════════════════════════════════════════════════════
            _buildClassificationCard(),

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSlider(
                        label: 'Fruité',
                        description: 'Sensations olfactives caractéristiques',
                        value: _fruite,
                        onChanged: (v) => setState(() => _fruite = v),
                        isPositif: true,
                      ),
                      // Toggle Vert / Mûr
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
                            GestureDetector(
                              onTap: _estSoumis
                                  ? null
                                  : () => setState(() => _fruiteVert = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _fruiteVert
                                      ? green
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _fruiteVert
                                        ? green
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  '🌿 Vert',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _fruiteVert
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _estSoumis
                                  ? null
                                  : () => setState(() => _fruiteVert = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: !_fruiteVert
                                      ? oliveGreen
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: !_fruiteVert
                                        ? oliveGreen
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  '🫒 Mûr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: !_fruiteVert
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  _buildSlider(
                    label: 'Amer',
                    description: 'Goût primaire — olives vertes ou en véraison',
                    value: _amer,
                    onChanged: (v) => setState(() => _amer = v),
                    isPositif: true,
                  ),
                  _buildSlider(
                    label: 'Piquant',
                    description:
                        'Sensation tactile — olives en début de campagne',
                    value: _piquant,
                    onChanged: (v) => setState(() => _piquant = v),
                    isPositif: true,
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
                  _buildSlider(
                    label: 'Chômé / Lie de boue',
                    description: 'Huile d\'olives en fermentation anaérobie',
                    value: _chome,
                    onChanged: (v) => setState(() => _chome = v),
                  ),
                  _buildSlider(
                    label: 'Moisi / Humide / Terreux',
                    description: 'Olives stockées en conditions humides',
                    value: _moisi,
                    onChanged: (v) => setState(() => _moisi = v),
                  ),
                  _buildSlider(
                    label: 'Vinaigré / Acide-Aigre',
                    description: 'Fermentation aérobie — acide acétique',
                    value: _vinaigre,
                    onChanged: (v) => setState(() => _vinaigre = v),
                  ),
                  _buildSlider(
                    label: 'Gelé (Bois Mouillé)',
                    description: 'Olives blessées par le gel',
                    value: _gele,
                    onChanged: (v) => setState(() => _gele = v),
                  ),
                  _buildSlider(
                    label: 'Rance',
                    description: 'Processus d\'oxydation intense',
                    value: _rance,
                    onChanged: (v) => setState(() => _rance = v),
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
                    _buildSlider(
                      label: 'Intensité — Autre défaut',
                      description: _autresDefautNomController.text,
                      value: _autresDefaut,
                      onChanged: (v) => setState(() => _autresDefaut = v),
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
            if (!_estSoumis) ...[
              // ── Enregistrer brouillon ──
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Soumettre et verrouiller ──
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
            ],

            // ── Message si déjà soumis ──
            if (_estSoumis)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Évaluation soumise et verrouillée',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.green.shade700,
                            ),
                          ),
                          Text(
                            'Cette fiche est en lecture seule',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGET — _buildSlider
  // Slider avec boutons +/- et graduation colorée selon COI
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSlider({
    required String label,
    required String description,
    required double value,
    required ValueChanged<double> onChanged,
    bool isPositif = false,
  }) {
    final color = isPositif ? _sliderPositifColor(value) : _sliderColor(value);
    final intensite = _intensiteLabel(value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label + valeur + intensité ──
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isPositif ? green : darkText,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Valeur numérique ──
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: value > 0
                      ? color.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: value > 0
                        ? color.withOpacity(0.4)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: value > 0 ? color : Colors.grey.shade400,
                  ),
                ),
              ),

              // ── Intensité label ──
              if (intensite.isNotEmpty) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    intensite,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // ── [ - ] Slider [ + ] ──
          Row(
            children: [
              // ── Bouton MOINS ──
              GestureDetector(
                onTap: _estSoumis
                    ? null
                    : () {
                        if (value > 0.0) {
                          onChanged(
                            double.parse(
                              (value - 0.5).clamp(0.0, 10.0).toStringAsFixed(1),
                            ),
                          );
                        }
                      },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: value > 0 && !_estSoumis
                        ? color.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value > 0 && !_estSoumis
                          ? color.withOpacity(0.4)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: value > 0 && !_estSoumis
                        ? color
                        : Colors.grey.shade400,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ── Slider ──
              Expanded(
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _estSoumis
                            ? Colors.grey.shade300
                            : color,
                        inactiveTrackColor: Colors.grey.shade200,
                        thumbColor: _estSoumis ? Colors.grey.shade400 : color,
                        overlayColor: color.withOpacity(0.15),
                        trackHeight: 5.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 9,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 18,
                        ),
                      ),
                      child: Slider(
                        value: value,
                        min: 0.0,
                        max: 10.0,
                        divisions: 20, // pas de 0.5
                        onChanged: _estSoumis ? null : onChanged,
                      ),
                    ),

                    // ── Graduation 0 à 10 ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(11, (i) {
                          final isActive = value >= i.toDouble();
                          return Text(
                            '$i',
                            style: TextStyle(
                              fontSize: 9,
                              color: isActive && !_estSoumis
                                  ? color
                                  : Colors.grey.shade400,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // ── Bouton PLUS ──
              GestureDetector(
                onTap: _estSoumis
                    ? null
                    : () {
                        if (value < 10.0) {
                          onChanged(
                            double.parse(
                              (value + 0.5).clamp(0.0, 10.0).toStringAsFixed(1),
                            ),
                          );
                        }
                      },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: value < 10.0 && !_estSoumis
                        ? color.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value < 10.0 && !_estSoumis
                          ? color.withOpacity(0.4)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: value < 10.0 && !_estSoumis
                        ? color
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGET — _buildClassificationCard
  // Affiche la classification en temps réel
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildClassificationCard() {
    final cl = _classification;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (cl['bg'] as Color),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cl['border'] as Color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                cl['icon'] as IconData,
                color: cl['color'] as Color,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Classification COI',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // ── Médiane défaut ──
              Text(
                'Méd. défaut: ${_medianeDefauts.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cl['label'] as String,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cl['color'] as Color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cl['description'] as String,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 12),

          // ── Résumé des valeurs ──
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (_fruite > 0)
                _valuePill(
                  'Fruité ${_fruiteVert ? "Vert" : "Mûr"}',
                  _fruite,
                  green,
                ),
              if (_amer > 0) _valuePill('Amer', _amer, oliveGreen),
              if (_piquant > 0) _valuePill('Piquant', _piquant, oliveGreen),
              if (_chome > 0) _valuePill('Chômé', _chome, Colors.orange),
              if (_moisi > 0) _valuePill('Moisi', _moisi, Colors.orange),
              if (_vinaigre > 0) _valuePill('Vinaigré', _vinaigre, Colors.red),
              if (_gele > 0) _valuePill('Gelé', _gele, Colors.red),
              if (_rance > 0) _valuePill('Rance', _rance, Colors.red),
              if (_autresDefaut > 0)
                _valuePill('Autre', _autresDefaut, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGET — _valuePill
  // Petit badge avec nom + valeur
  // ─────────────────────────────────────────────────────────────────────────
  Widget _valuePill(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGET — _buildSectionCard
  // Carte section avec titre et contenu
  // ─────────────────────────────────────────────────────────────────────────
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
            color: green.withOpacity(0.07),
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

  // ─────────────────────────────────────────────────────────────────────────
  // WIDGET — _infoRow
  // Ligne d'info avec icône
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // COULEUR — slider positif (vert uniquement)
  // ─────────────────────────────────────────────────────────────────────────
  Color _sliderPositifColor(double val) {
    if (val <= 3.0) return green;
    if (val <= 6.0) return oliveGreen;
    return Colors.teal.shade600;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION — Enregistrer brouillon
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // ACTION — Confirmer soumission
  // ─────────────────────────────────────────────────────────────────────────
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
