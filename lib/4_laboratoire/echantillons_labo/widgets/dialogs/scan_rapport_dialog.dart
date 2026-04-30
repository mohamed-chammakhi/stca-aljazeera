// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/widgets/dialogs/scan_rapport_dialog.dart
// PURPOSE : UI for scanning a paper lab report and reviewing extracted values
//
// FLOW:
//   1. Camera preview / photo pick — user takes a photo of the paper report
//   2. "Analysing" loading state — simulates AI extraction
//   3. Review state — extracted values shown in editable fields
//      Fields with low confidence are highlighted in orange
//   4. Confirm → calls onSave with the AnalyseLabo object
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../analyse_labo.dart';
import '../../models/echantillon_labo.dart';
import 'formulaire_analyse_labo_dialog.dart';
import '../../../../../core/theme/app_colors.dart';

// Scan dialog uses a blue accent distinct from the brand green.
const Color _blue = Color(0xFF1565C0);

void showScanRapportDialog(
  BuildContext context, {
  required EchantillonLabo echantillon,
  required void Function(AnalyseLabo) onSave,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ScanRapportDialog(echantillon: echantillon, onSave: onSave),
  );
}

enum _ScanPhase { capture, analysing, review }

class ScanRapportDialog extends StatefulWidget {
  final EchantillonLabo echantillon;
  final void Function(AnalyseLabo) onSave;

  const ScanRapportDialog({
    super.key,
    required this.echantillon,
    required this.onSave,
  });

  @override
  State<ScanRapportDialog> createState() => _ScanRapportDialogState();
}

class _ScanRapportDialogState extends State<ScanRapportDialog>
    with TickerProviderStateMixin {
  _ScanPhase _phase = _ScanPhase.capture;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // ── Extracted field controllers ───────────────────────────────────────────
  final _aciditeCtrl = TextEditingController();
  final _peroxydeCtrl = TextEditingController();
  final _k232Ctrl = TextEditingController();
  final _k270Ctrl = TextEditingController();
  final _deltaKCtrl = TextEditingController();
  final _humiditeCtrl = TextEditingController();
  final _impuretesCtrl = TextEditingController();
  final _polyphenolsCtrl = TextEditingController();

  // ── Confidence map — field key → confidence 0.0–1.0 ─────────────────────
  // In production, these come from the AI response JSON.
  // Here we simulate them after "scanning".
  Map<String, double> _confidence = {};

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    for (final c in [
      _aciditeCtrl,
      _peroxydeCtrl,
      _k232Ctrl,
      _k270Ctrl,
      _deltaKCtrl,
      _humiditeCtrl,
      _impuretesCtrl,
      _polyphenolsCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  // ── Simulate AI scan (replace with actual camera + API call) ─────────────
  void _startScan() {
    setState(() => _phase = _ScanPhase.analysing);
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      // Simulate extracted values with varying confidence
      _aciditeCtrl.text = '0.42';
      _peroxydeCtrl.text = '8.6';
      _k232Ctrl.text = '1.92';
      _k270Ctrl.text = '0.14';
      _deltaKCtrl.text = '0.004';
      _humiditeCtrl.text = '0.16';
      _impuretesCtrl.text = ''; // not found
      _polyphenolsCtrl.text = '318';

      _confidence = {
        'acidite': 0.97,
        'peroxyde': 0.95,
        'k232': 0.88,
        'k270': 0.91,
        'deltaK': 0.72, // uncertain → orange
        'humidite': 0.85,
        'impuretes': 0.0, // not found → red/empty
        'polyphenols': 0.78,
      };

      setState(() => _phase = _ScanPhase.review);
    });
  }

  void _confirm() {
    final analyse = AnalyseLabo(
      echantillonId: widget.echantillon.id,
      echantillonRef: widget.echantillon.ref,
      aciditeLibre: double.tryParse(_aciditeCtrl.text),
      indicePeroxyde: double.tryParse(_peroxydeCtrl.text),
      k232: double.tryParse(_k232Ctrl.text),
      k270: double.tryParse(_k270Ctrl.text),
      deltaK: double.tryParse(_deltaKCtrl.text),
      humidite: double.tryParse(_humiditeCtrl.text),
      impuretes: double.tryParse(_impuretesCtrl.text),
      polyphenolsTotaux: double.tryParse(_polyphenolsCtrl.text),
      statut: StatutAnalyse.soumis,
      dateAnalyse: _today(),
    );
    Navigator.pop(context);
    widget.onSave(analyse);
  }

  String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: kCream,
        appBar: AppBar(
          backgroundColor: _blue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scanner le rapport',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                widget.echantillon.referenceBouteille,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
        body: switch (_phase) {
          _ScanPhase.capture => _CapturePhase(onScan: _startScan),
          _ScanPhase.analysing => _AnalysingPhase(pulse: _pulse),
          _ScanPhase.review => _ReviewPhase(
            aciditeCtrl: _aciditeCtrl,
            peroxydeCtrl: _peroxydeCtrl,
            k232Ctrl: _k232Ctrl,
            k270Ctrl: _k270Ctrl,
            deltaKCtrl: _deltaKCtrl,
            humiditeCtrl: _humiditeCtrl,
            impuretesCtrl: _impuretesCtrl,
            polyphenolsCtrl: _polyphenolsCtrl,
            confidence: _confidence,
            onConfirm: _confirm,
            onEditManually: () {
              Navigator.pop(context);
              showFormulaireAnalyseLaboDialog(
                context,
                echantillonRef: widget.echantillon.referenceBouteille,
                echantillonId:  widget.echantillon.id,
                onSave:         widget.onSave,
              );
            },
          ),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHASE 1 — Capture
// ─────────────────────────────────────────────────────────────────────────────
class _CapturePhase extends StatelessWidget {
  final VoidCallback onScan;
  const _CapturePhase({required this.onScan});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Viewfinder illustration
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _blue.withOpacity(0.5), width: 2),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Corner guides
              ..._corners(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 56,
                    color: Colors.white54,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Positionnez le rapport\nà l\'intérieur du cadre',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Le rapport papier sera analysé\nautomatiquement par l\'IA',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 32),
        // Scan button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.camera_alt_outlined, size: 22),
            label: const Text(
              'Prendre une photo',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onScan, // same handler, in production: gallery pick
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text('Importer depuis la galerie'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _blue,
              side: BorderSide(color: _blue.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  List<Widget> _corners() {
    const s = 24.0;
    const t = 3.0;
    const c = Colors.white;
    return [
      Positioned(
        top: 16,
        left: 16,
        child: _Corner(s, t, c, top: true, left: true),
      ),
      Positioned(
        top: 16,
        right: 16,
        child: _Corner(s, t, c, top: true, left: false),
      ),
      Positioned(
        bottom: 16,
        left: 16,
        child: _Corner(s, t, c, top: false, left: true),
      ),
      Positioned(
        bottom: 16,
        right: 16,
        child: _Corner(s, t, c, top: false, left: false),
      ),
    ];
  }
}

class _Corner extends StatelessWidget {
  final double size, thickness;
  final Color color;
  final bool top, left;

  const _Corner(
    this.size,
    this.thickness,
    this.color, {
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _CornerPainter(
        thickness: thickness,
        color: color,
        top: top,
        left: left,
      ),
    ),
  );
}

class _CornerPainter extends CustomPainter {
  final double thickness;
  final Color color;
  final bool top, left;

  _CornerPainter({
    required this.thickness,
    required this.color,
    required this.top,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    canvas.drawLine(
      Offset(x, y),
      Offset(left ? size.width * .6 : size.width * .4, y),
      p,
    );
    canvas.drawLine(
      Offset(x, y),
      Offset(x, top ? size.height * .6 : size.height * .4),
      p,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// PHASE 2 — Analysing
// ─────────────────────────────────────────────────────────────────────────────
class _AnalysingPhase extends StatelessWidget {
  final Animation<double> pulse;
  const _AnalysingPhase({required this.pulse});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Opacity(
            opacity: pulse.value,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.document_scanner_outlined,
                size: 48,
                color: _blue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Analyse en cours...',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kDark,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'L\'IA extrait les valeurs du rapport',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 32),
        // Animated steps
        ...[
          'Détection du document...',
          'Extraction des valeurs...',
          'Vérification des normes COI...',
        ].asMap().entries.map(
          (e) => _Step(
            label: e.value,
            delay: Duration(milliseconds: e.key * 800),
            pulse: pulse,
          ),
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  final String label;
  final Duration delay;
  final Animation<double> pulse;
  const _Step({required this.label, required this.delay, required this.pulse});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 32),
    child: Row(
      children: [
        AnimatedBuilder(
          animation: pulse,
          builder: (_, __) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _blue.withOpacity(pulse.value),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PHASE 3 — Review extracted values
// ─────────────────────────────────────────────────────────────────────────────
class _ReviewPhase extends StatelessWidget {
  final TextEditingController aciditeCtrl;
  final TextEditingController peroxydeCtrl;
  final TextEditingController k232Ctrl;
  final TextEditingController k270Ctrl;
  final TextEditingController deltaKCtrl;
  final TextEditingController humiditeCtrl;
  final TextEditingController impuretesCtrl;
  final TextEditingController polyphenolsCtrl;
  final Map<String, double> confidence;
  final VoidCallback onConfirm;
  final VoidCallback onEditManually;

  const _ReviewPhase({
    required this.aciditeCtrl,
    required this.peroxydeCtrl,
    required this.k232Ctrl,
    required this.k270Ctrl,
    required this.deltaKCtrl,
    required this.humiditeCtrl,
    required this.impuretesCtrl,
    required this.polyphenolsCtrl,
    required this.confidence,
    required this.onConfirm,
    required this.onEditManually,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: const Color(0xFFE3F2FD),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: _blue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vérifiez les valeurs extraites. Les champs en orange nécessitent votre attention.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade800),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            child: Column(
              children: [
                _ExtractedField(
                  label: 'Acidité libre (%)',
                  controller: aciditeCtrl,
                  confidence: confidence['acidite'] ?? 0,
                  norm: '≤ 0.80',
                ),
                _ExtractedField(
                  label: 'Indice de peroxyde (meqO₂/kg)',
                  controller: peroxydeCtrl,
                  confidence: confidence['peroxyde'] ?? 0,
                  norm: '≤ 20',
                ),
                _ExtractedField(
                  label: 'K₂₃₂',
                  controller: k232Ctrl,
                  confidence: confidence['k232'] ?? 0,
                  norm: '≤ 2.50',
                ),
                _ExtractedField(
                  label: 'K₂₇₀',
                  controller: k270Ctrl,
                  confidence: confidence['k270'] ?? 0,
                  norm: '≤ 0.22',
                ),
                _ExtractedField(
                  label: 'ΔK',
                  controller: deltaKCtrl,
                  confidence: confidence['deltaK'] ?? 0,
                  norm: '≤ 0.01',
                ),
                _ExtractedField(
                  label: 'Humidité (%)',
                  controller: humiditeCtrl,
                  confidence: confidence['humidite'] ?? 0,
                  norm: '≤ 0.20',
                ),
                _ExtractedField(
                  label: 'Impuretés insolubles (%)',
                  controller: impuretesCtrl,
                  confidence: confidence['impuretes'] ?? 0,
                  norm: '≤ 0.10',
                ),
                _ExtractedField(
                  label: 'Polyphénols totaux (mg/kg)',
                  controller: polyphenolsCtrl,
                  confidence: confidence['polyphenols'] ?? 0,
                  norm: 'Indicateur',
                ),
                const SizedBox(height: 8),
                // Edit manually link
                Center(
                  child: TextButton.icon(
                    onPressed: onEditManually,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Modifier manuellement tous les champs'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text(
                'Confirmer et soumettre',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExtractedField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final double confidence; // 0.0 – 1.0
  final String norm;

  const _ExtractedField({
    required this.label,
    required this.controller,
    required this.confidence,
    required this.norm,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color labelColor;
    Widget? badge;

    if (confidence == 0.0) {
      borderColor = Colors.red.shade300;
      labelColor = Colors.red.shade700;
      badge = _ConfidenceBadge(
        label: 'Non détecté',
        color: Colors.red.shade600,
      );
    } else if (confidence < 0.80) {
      borderColor = Colors.orange.shade400;
      labelColor = Colors.orange.shade800;
      badge = _ConfidenceBadge(
        label: '${(confidence * 100).round()}% confiance',
        color: Colors.orange.shade700,
      );
    } else {
      borderColor = kGreen.withOpacity(0.3);
      labelColor = kDark;
      badge = _ConfidenceBadge(
        label: '${(confidence * 100).round()}%',
        color: kGreen,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                ),
              ),
              const Spacer(),
              if (badge != null) badge,
            ],
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: confidence == 0.0 ? 'Saisir manuellement...' : '',
              filled: true,
              fillColor: confidence == 0.0
                  ? Colors.red.shade50
                  : confidence < 0.80
                  ? Colors.orange.shade50
                  : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor, width: 1.5),
              ),
            ),
          ),
          Text(
            norm,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _ConfidenceBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
    ),
  );
}
