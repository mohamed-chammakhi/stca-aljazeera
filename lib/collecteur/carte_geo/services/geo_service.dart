// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/carte_geo/services/geo_service.dart
//
// DATA SOURCE : assets/geo/cities.json
//   Structure : FR > Tunisie > governorates[]
//                 > nom, code, latitude, longitude
//                 > delegations[]
//                   > nom
//                   > cites[]
//
// Provides :
//   • gouvernorats()          → List<String>          (24 names)
//   • delegationsFor(gov)     → List<String>          (cascades from gov)
//   • citesFor(gov, del)      → List<String>          (cascades from del)
//   • markVisited(gov, del)   → colors that delegation on the map
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

// ── Delegation zone — one polygon on the map ──────────────────────────────────
class DelegationZone {
  final String name;
  final String gouvernorat;
  final List<LatLng> polygon;
  const DelegationZone({
    required this.name,
    required this.gouvernorat,
    required this.polygon,
  });
}

// ═════════════════════════════════════════════════════════════════════════════
// GEO SERVICE — singleton
// ═════════════════════════════════════════════════════════════════════════════
class GeoService {
  GeoService._();
  static final GeoService instance = GeoService._();

  // ── Internal data ─────────────────────────────────────────────────────────
  // Map<gouvernorat, Map<delegation, List<cite>>>
  final Map<String, Map<String, List<String>>> _data = {};

  List<DelegationZone> _zones = [];
  final Set<String> _visited = {};

  bool _loaded = false;

  // ── Load — safe to call multiple times ────────────────────────────────────
  Future<void> load() async {
    if (_loaded) return;
    await Future.wait([_loadCitiesJson(), _loadGeoJson()]);
    _loaded = true;
  }

  // ── Parse cities.json ─────────────────────────────────────────────────────
  Future<void> _loadCitiesJson() async {
    try {
      final raw = await rootBundle.loadString('assets/img/cities_fixed.json');

      // The file has a trailing comma bug — strip it before parsing
      final fixed = raw.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');
      final json = jsonDecode(fixed) as Map<String, dynamic>;

      final govs = (json['FR']['Tunisie']['governorates'] as List<dynamic>);

      for (final g in govs) {
        final govName = (g['nom'] as String).trim();
        final Map<String, List<String>> delMap = {};

        for (final d in (g['delegations'] as List<dynamic>? ?? [])) {
          final delName = (d['nom'] as String).trim();
          final cites = (d['cites'] as List<dynamic>? ?? [])
              .map((c) => c.toString().trim())
              .where((c) => c.isNotEmpty)
              .toList();
          delMap[delName] = cites;
        }

        _data[govName] = delMap;
      }
    } catch (e) {
      // File missing — dropdowns will be empty
    }
  }

  // ── Parse delegations.geojson for map polygons ────────────────────────────
  Future<void> _loadGeoJson() async {
    try {
      final raw = await rootBundle.loadString('assets/img/delegations.geojson');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>;
      final List<DelegationZone> zones = [];

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>? ?? {};
        final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};

        final name = _firstNonEmpty(props, [
          'delegation',
          'name',
          'NAME',
          'shapeName',
          'DELEG_NAME',
        ]);
        final gov = _firstNonEmpty(props, [
          'governorate',
          'gov',
          'GOV',
          'ADM2_EN',
        ]);

        if (name.isEmpty) continue;

        final type = geometry['type'] as String? ?? '';
        final coords = geometry['coordinates'];

        if (type == 'Polygon') {
          final poly = _parseRing(coords[0] as List<dynamic>);
          if (poly.length >= 3) {
            zones.add(
              DelegationZone(name: name, gouvernorat: gov, polygon: poly),
            );
          }
        } else if (type == 'MultiPolygon') {
          List<LatLng> largest = [];
          for (final part in coords as List<dynamic>) {
            final ring = _parseRing(part[0] as List<dynamic>);
            if (ring.length > largest.length) largest = ring;
          }
          if (largest.length >= 3) {
            zones.add(
              DelegationZone(name: name, gouvernorat: gov, polygon: largest),
            );
          }
        }
      }
      _zones = zones;
    } catch (_) {
      _zones = [];
    }
  }

  String _firstNonEmpty(Map<String, dynamic> props, List<String> keys) {
    for (final k in keys) {
      final v = props[k]?.toString().trim() ?? '';
      if (v.isNotEmpty) return v;
    }
    return '';
  }

  List<LatLng> _parseRing(List<dynamic> ring) {
    return ring
        .whereType<List>()
        .where((c) => c.length >= 2)
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  }

  // ── Public API — 3-level cascade ──────────────────────────────────────────

  bool get isLoaded => _loaded;

  /// All 24 gouvernorat names — sorted alphabetically
  List<String> get gouvernorats => _data.keys.toList()..sort();

  /// Delegations for a given gouvernorat
  /// Case-insensitive fallback for robustness
  List<String> delegationsFor(String gouvernorat) {
    final direct = _data[gouvernorat];
    if (direct != null) return direct.keys.toList()..sort();

    final lower = gouvernorat.toLowerCase();
    for (final entry in _data.entries) {
      if (entry.key.toLowerCase() == lower) {
        return entry.value.keys.toList()..sort();
      }
    }
    return const [];
  }

  /// Cities for a given gouvernorat + delegation
  List<String> citesFor(String gouvernorat, String delegation) {
    final delMap =
        _data[gouvernorat] ??
        _data.entries
            .firstWhere(
              (e) => e.key.toLowerCase() == gouvernorat.toLowerCase(),
              orElse: () => MapEntry('', {}),
            )
            .value;

    final direct = delMap[delegation];
    if (direct != null) return List.unmodifiable(direct);

    final lower = delegation.toLowerCase();
    for (final entry in delMap.entries) {
      if (entry.key.toLowerCase() == lower) {
        return List.unmodifiable(entry.value);
      }
    }
    return const [];
  }

  // ── Map coloring ──────────────────────────────────────────────────────────

  List<DelegationZone> get zones => List.unmodifiable(_zones);

  void markVisited({required String gouvernorat, required String delegation}) =>
      _visited.add(_key(gouvernorat, delegation));

  void unmarkVisited({
    required String gouvernorat,
    required String delegation,
  }) => _visited.remove(_key(gouvernorat, delegation));

  bool isVisited(String gouvernorat, String delegation) =>
      _visited.contains(_key(gouvernorat, delegation));

  bool isZoneVisited(DelegationZone zone) =>
      isVisited(zone.gouvernorat, zone.name);

  int get visitedCount => _visited.length;
  int get totalZones => _zones.isNotEmpty
      ? _zones.length
      : _data.values.fold(0, (s, m) => s + m.length);

  String _key(String gov, String del) =>
      '${gov.trim().toUpperCase()}||${del.trim().toUpperCase()}';

  void loadFromEchantillons(
    List<({String? gouvernorat, String? delegation})> list,
  ) {
    for (final e in list) {
      if (e.gouvernorat != null && e.delegation != null) {
        markVisited(gouvernorat: e.gouvernorat!, delegation: e.delegation!);
      }
    }
  }
}
