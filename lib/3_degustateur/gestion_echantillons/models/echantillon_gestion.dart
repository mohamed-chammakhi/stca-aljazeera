// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/models/echantillon_gestion.dart
// PURPOSE : Re-exports the shared Echantillon model and provides a role-local
//           alias so the rest of this module can keep using EchantillonGestion.
// ─────────────────────────────────────────────────────────────────────────────

export '../../../core/models/echantillon.dart';
import '../../../core/models/echantillon.dart';

/// Alias kept for backwards-compatibility inside the gestion_echantillons module.
/// All new code should import Echantillon directly from core/models/echantillon.dart.
typedef EchantillonGestion = Echantillon;
