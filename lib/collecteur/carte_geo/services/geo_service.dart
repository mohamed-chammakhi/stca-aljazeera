// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/carte_geo/services/geo_service.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

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

class GeoService {
  GeoService._();
  static final GeoService instance = GeoService._();

  List<DelegationZone> _zones = [];
  final Map<String, List<String>> _govToDels = {};
  final Set<String> _visited = {};
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    await _loadGeoJson();
    _buildGovIndex();
    _loaded = true;
  }

  Future<void> _loadGeoJson() async {
    try {
      final raw = await rootBundle.loadString('assets/img/delegations.geojson');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>;
      final List<DelegationZone> zones = [];

      for (final feature in features) {
        final props = feature['properties'] as Map<String, dynamic>? ?? {};
        final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};

        final name = (props['del_fr'] as String? ?? '').trim();
        final gov = (props['gouv_fr'] as String? ?? '').trim();
        if (name.isEmpty || gov.isEmpty) continue;

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

  void _buildGovIndex() {
    final Map<String, Set<String>> temp = {};
    for (final zone in _zones) {
      temp.putIfAbsent(zone.gouvernorat, () => {}).add(zone.name);
    }
    _govToDels.clear();
    for (final entry in temp.entries) {
      final sorted = entry.value.toList()..sort();
      _govToDels[entry.key] = sorted;
    }
  }

  List<LatLng> _parseRing(List<dynamic> ring) {
    return ring
        .whereType<List>()
        .where((c) => c.length >= 2)
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  }

  // ── Public API — dropdowns ─────────────────────────────────────────────────

  bool get isLoaded => _loaded;

  List<String> get gouvernorats => _govToDels.keys.toList()..sort();

  List<String> delegationsFor(String gouvernorat) =>
      _govToDels[gouvernorat] ?? const [];

  // ── Public API — map coloring ──────────────────────────────────────────────

  List<DelegationZone> get zones => List.unmodifiable(_zones);

  void markVisited({required String gouvernorat, required String delegation}) {
    if (gouvernorat.trim().isNotEmpty && delegation.trim().isNotEmpty) {
      _visited.add(_key(gouvernorat, delegation));
    }
  }

  void unmarkVisited({
    required String gouvernorat,
    required String delegation,
  }) => _visited.remove(_key(gouvernorat, delegation));

  bool isZoneVisited(DelegationZone zone) =>
      _visited.contains(_key(zone.gouvernorat, zone.name));

  int get visitedCount => _visited.length;
  int get totalZones => _zones.length;

  void loadFromEchantillons(
    List<({String? gouvernorat, String? delegation})> list,
  ) {
    for (final e in list) {
      if (e.gouvernorat != null &&
          e.delegation != null &&
          e.gouvernorat!.trim().isNotEmpty &&
          e.delegation!.trim().isNotEmpty) {
        markVisited(gouvernorat: e.gouvernorat!, delegation: e.delegation!);
      }
    }
  }

  /// Tears down ALL sticky notes and re-sticks them from the current list.
  /// Call this after every add / modify / delete.
  void rebuildFromEchantillons(
    List<({String? gouvernorat, String? delegation})> list,
  ) {
    _visited.clear();
    loadFromEchantillons(list);
  }

  String _key(String gov, String del) =>
      '${gov.trim().toUpperCase()}||${del.trim().toUpperCase()}';
}
