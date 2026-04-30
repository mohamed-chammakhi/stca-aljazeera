class LabRow {
  final String label;
  final String value;
  final String norm;
  final bool? conforme;
  const LabRow({
    required this.label,
    required this.value,
    required this.norm,
    this.conforme,
  });
}
