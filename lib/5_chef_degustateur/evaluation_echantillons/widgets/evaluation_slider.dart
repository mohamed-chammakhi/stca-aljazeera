import 'package:flutter/material.dart';
import '../../widgets/chef_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET — EvaluationSlider
// Slider COI avec boutons +/− et graduation colorée
// Extrait de FormulaireEvaluationPage._buildSlider()
// ─────────────────────────────────────────────────────────────────────────────
class EvaluationSlider extends StatelessWidget {
  final String label;
  final String description;
  final double value;
  final ValueChanged<double> onChanged;
  final bool isPositif;
  /// When true, all controls are locked (read-only / submitted evaluation).
  final bool readOnly;

  const EvaluationSlider({
    super.key,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    this.isPositif = false,
    this.readOnly = false,
  });

  // ── COI intensity label ─────────────────────────────────────────────────
  String get _intensiteLabel {
    if (value == 0.0) return '';
    if (value <= 3.0) return 'Délicat';
    if (value <= 6.0) return 'Moyen';
    return 'Robuste';
  }

  // ── Color for negative attributes ──────────────────────────────────────
  Color get _sliderColor {
    if (value <= 3.0) return chefGreen;
    if (value <= 6.0) return Colors.orange.shade500;
    return Colors.red.shade500;
  }

  // ── Color for positive attributes (stays in greens) ─────────────────────
  Color get _sliderPositifColor {
    if (value <= 3.0) return chefGreen;
    if (value <= 6.0) return chefOlive;
    return Colors.teal.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final color = isPositif ? _sliderPositifColor : _sliderColor;
    final intensite = _intensiteLabel;

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
                        color: isPositif ? chefGreen : chefDark,
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
                      ? color.withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: value > 0
                        ? color.withValues(alpha: 0.4)
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
                    color: color.withValues(alpha: 0.1),
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
                onTap: readOnly
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
                    color: value > 0 && !readOnly
                        ? color.withValues(alpha:0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value > 0 && !readOnly
                          ? color.withValues(alpha:0.4)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: value > 0 && !readOnly
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
                        activeTrackColor: readOnly
                            ? Colors.grey.shade300
                            : color,
                        inactiveTrackColor: Colors.grey.shade200,
                        thumbColor: readOnly ? Colors.grey.shade400 : color,
                        overlayColor: color.withValues(alpha:0.15),
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
                        onChanged: readOnly ? null : onChanged,
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
                              color: isActive && !readOnly
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
                onTap: readOnly
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
                    color: value < 10.0 && !readOnly
                        ? color.withValues(alpha:0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: value < 10.0 && !readOnly
                          ? color.withValues(alpha:0.4)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: value < 10.0 && !readOnly
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
}
