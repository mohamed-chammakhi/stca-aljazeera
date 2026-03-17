// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/carte_geo/carte_geo_page.dart
//
// PURPOSE : Map page for the collecteur — shows all Tunisian délégations,
//   green  = at least one échantillon registered from this délégation
//   gray   = never visited
//
// REQUIRES (pubspec.yaml) :
//   flutter_map: ^7.0.2
//   latlong2: ^0.9.1
//   flutter_map_cancellable_tile_provider: ^3.0.0
//
// REQUIRES (assets) :
//   assets/geo/delegations.geojson
//   assets/geo/state_municipality_areas.json
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'services/geo_service.dart';

const Color _green      = Color(0xFF38835A);
const Color _greenLight = Color(0xFF4CAF7D);
const Color _cream      = Color(0xFFF9F6EF);
const Color _darkText   = Color(0xFF1A2E1F);

class CarteGeoPage extends StatefulWidget {
  const CarteGeoPage({super.key});

  @override
  State<CarteGeoPage> createState() => _CarteGeoPageState();
}

class _CarteGeoPageState extends State<CarteGeoPage> {
  final GeoService _geo = GeoService.instance;
  final MapController _mapCtrl = MapController();

  bool _loading = true;
  DelegationZone? _selected; // tapped zone — shows bottom sheet

  // ── Filter ────────────────────────────────────────────────────────────────
  bool _showVisitedOnly = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _geo.load();
    if (mounted) setState(() => _loading = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: _buildAppBar(),
      body: _loading ? _buildLoader() : _buildMap(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _green,
      elevation: 0,
      title: const Text(
        'Carte des visites',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      actions: [
        // Stats chip
        if (!_loading)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_geo.visitedCount} / ${_geo.totalZones}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        // Filter toggle
        IconButton(
          icon: Icon(
            _showVisitedOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
            color: Colors.white,
          ),
          tooltip: 'Visitées seulement',
          onPressed: () => setState(() => _showVisitedOnly = !_showVisitedOnly),
        ),
      ],
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────
  Widget _buildLoader() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: _green),
        SizedBox(height: 16),
        Text('Chargement de la carte...', style: TextStyle(color: _green)),
      ],
    ),
  );

  // ── Map ────────────────────────────────────────────────────────────────────
  Widget _buildMap() {
    final zones = _showVisitedOnly
        ? _geo.zones.where(_geo.isZoneVisited).toList()
        : _geo.zones;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: const LatLng(33.8869, 9.5375), // center of Tunisia
            initialZoom: 6.0,
            minZoom: 5.0,
            maxZoom: 14.0,
            onTap: (_, __) => setState(() => _selected = null),
          ),
          children: [
            // ── Tile layer — OpenStreetMap ──────────────────────────────────
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.aljazira.tasting_panel',
              // For offline caching, add flutter_map_tile_caching and replace
              // with a CachedTileProvider() here
            ),

            // ── Polygon layer — all délégations ────────────────────────────
            PolygonLayer(
              polygons: zones.map((zone) {
                final visited = _geo.isZoneVisited(zone);
                final isSelected = _selected?.name == zone.name;

                return Polygon(
                  points: zone.polygon,
                  color: isSelected
                      ? _green.withOpacity(0.7)
                      : visited
                          ? _greenLight.withOpacity(0.45)
                          : Colors.grey.withOpacity(0.18),
                  borderColor: isSelected
                      ? _green
                      : visited
                          ? _green.withOpacity(0.6)
                          : Colors.grey.withOpacity(0.35),
                  borderStrokeWidth: isSelected ? 2.5 : 1.0,
                );
              }).toList(),
            ),

            // ── Tap detector layer ─────────────────────────────────────────
            // flutter_map doesn't have built-in polygon tap — we use a
            // GestureDetector overlay and point-in-polygon check
          ],
        ),

        // ── Tap overlay ───────────────────────────────────────────────────
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) => _onMapTap(details, context),
          ),
        ),

        // ── Legend ────────────────────────────────────────────────────────
        Positioned(
          bottom: _selected != null ? 180 : 24,
          left: 16,
          child: _Legend(),
        ),

        // ── Recenter button ───────────────────────────────────────────────
        Positioned(
          top: 16,
          right: 16,
          child: _MapButton(
            icon: Icons.my_location,
            onTap: () => _mapCtrl.move(
              const LatLng(33.8869, 9.5375),
              6.0,
            ),
          ),
        ),

        // ── Bottom info sheet — tapped zone ───────────────────────────────
        if (_selected != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ZoneInfoSheet(
              zone: _selected!,
              visited: _geo.isZoneVisited(_selected!),
              onClose: () => setState(() => _selected = null),
            ),
          ),
      ],
    );
  }

  // ── Point-in-polygon tap detection ────────────────────────────────────────
  void _onMapTap(TapUpDetails details, BuildContext context) {
    // Convert screen position to lat/lng using the map controller
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(details.globalPosition);
    final mapSize = box.size;

    // Use MapController.camera to convert screen → LatLng
    final camera = _mapCtrl.camera;
    final tappedLatLng = camera.offsetToCrs(
      Offset(localPos.dx, localPos.dy),
    );

    // Point-in-polygon check (ray casting)
    DelegationZone? hit;
    for (final zone in _geo.zones) {
      if (_pointInPolygon(tappedLatLng, zone.polygon)) {
        hit = zone;
        break;
      }
    }

    setState(() => _selected = hit);
  }

  // ── Ray casting algorithm ─────────────────────────────────────────────────
  bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    final n = polygon.length;

    for (int i = 0, j = n - 1; i < n; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      final intersect = ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);

      if (intersect) intersections++;
    }

    return intersections.isOdd;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ZONE INFO SHEET — slides up when a polygon is tapped
// ─────────────────────────────────────────────────────────────────────────────
class _ZoneInfoSheet extends StatelessWidget {
  final DelegationZone zone;
  final bool visited;
  final VoidCallback onClose;

  const _ZoneInfoSheet({
    required this.zone,
    required this.visited,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: visited ? _green : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _capitalize(zone.name),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 13, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(
              _capitalize(zone.gouvernorat),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ]),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: visited
                  ? _green.withOpacity(0.08)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(
                visited ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                size: 16,
                color: visited ? _green : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                visited
                    ? 'Délégation visitée — échantillon(s) enregistré(s)'
                    : 'Aucun échantillon enregistré dans cette délégation',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: visited ? _green : Colors.grey.shade500,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LEGEND
// ─────────────────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LegendItem(color: _greenLight.withOpacity(0.7), label: 'Visitée'),
          const SizedBox(height: 6),
          _LegendItem(color: Colors.grey.withOpacity(0.4), label: 'Non visitée'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: color.withOpacity(0.8), width: 1),
        ),
      ),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(fontSize: 12, color: _darkText, fontWeight: FontWeight.w500)),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MAP BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: _green, size: 22),
    ),
  );
}
