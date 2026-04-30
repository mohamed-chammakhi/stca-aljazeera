// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/carte_geo/carte_geo_page.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'services/geo_service.dart';
import '../mes_echantillons/models/echantillon_collecteur.dart';
import '../../../../config.dart'; // adjust path as needed

import '../widgets/col_colors.dart';

class CarteGeoPage extends StatefulWidget {
  final List<EchantillonCollecteur> echantillons;
  const CarteGeoPage({super.key, required this.echantillons});

  @override
  State<CarteGeoPage> createState() => _CarteGeoPageState();
}

class _CarteGeoPageState extends State<CarteGeoPage> {
  final GeoService _geo = GeoService.instance;
  final MapController _mapCtrl = MapController();

  bool _loading = true;
  DelegationZone? _selected;
  bool _showVisitedOnly = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _geo.load();
    // Sync visited zones from the samples passed in from the list page
    _geo.loadFromEchantillons(
      widget.echantillons
          .map((e) => (gouvernorat: e.gouvernorat, delegation: e.delegation))
          .toList(),
    );
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colCream,
      appBar: _buildAppBar(),
      body: _loading ? _buildLoader() : _buildMap(),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: colGreen,
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
      if (!_loading)
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
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

  Widget _buildLoader() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(color: colGreen),
        SizedBox(height: 16),
        Text('Chargement de la carte...', style: TextStyle(color: colGreen)),
      ],
    ),
  );

  Widget _buildMap() {
    final zones = _showVisitedOnly
        ? _geo.zones.where(_geo.isZoneVisited).toList()
        : _geo.zones;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: const LatLng(33.8869, 9.5375),
            initialZoom: 6.0,
            minZoom: 5.0,
            maxZoom: 14.0,
            cameraConstraint: CameraConstraint.containCenter(
              bounds: LatLngBounds(
                const LatLng(30.2, 7.5),
                const LatLng(37.5, 11.6),
              ),
            ),
            onTap: (_, __) => setState(() => _selected = null),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$kMapTilerKey',
              userAgentPackageName: 'com.aljazira.tasting_panel',
            ),
            PolygonLayer(
              polygons: zones.map((zone) {
                final visited = _geo.isZoneVisited(zone);
                final selected = _selected?.name == zone.name;
                return Polygon(
                  points: zone.polygon,
                  color: selected
                      ? colPinky.withValues(alpha: 0.55)
                      : visited
                      ? colPinky.withValues(alpha: 0.30)
                      : Colors.transparent,
                  borderColor: selected
                      ? colPinkyDark
                      : visited
                      ? colPinky.withValues(alpha: 0.70)
                      : Colors.transparent,
                  borderStrokeWidth: selected
                      ? 2.5
                      : visited
                      ? 1.2
                      : 0,
                );
              }).toList(),
            ),
          ],
        ),

        // Invisible tap detector
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) => _onMapTap(details, context),
          ),
        ),

        // Legend
        Positioned(
          bottom: _selected != null ? 180 : 24,
          left: 16,
          child: const _Legend(),
        ),

        // Recenter button
        Positioned(
          top: 16,
          right: 16,
          child: _MapButton(
            icon: Icons.my_location,
            onTap: () => _mapCtrl.move(const LatLng(33.8869, 9.5375), 6.0),
          ),
        ),

        // Info sheet
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

  void _onMapTap(TapUpDetails details, BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localPos = box.globalToLocal(details.globalPosition);
    final tapped = _mapCtrl.camera.offsetToCrs(
      Offset(localPos.dx, localPos.dy),
    );

    DelegationZone? hit;
    for (final zone in _geo.zones) {
      if (_pointInPolygon(tapped, zone.polygon)) {
        hit = zone;
        break;
      }
    }
    setState(() => _selected = hit);
  }

  bool _pointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    final n = polygon.length;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;
      final intersect =
          ((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / (yj - yi) + xi);
      if (intersect) intersections++;
    }
    return intersections.isOdd;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ZONE INFO SHEET
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
  Widget build(BuildContext context) => Container(
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
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: visited ? colPinky : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _cap(zone.name),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: colDark,
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
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 13,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              _cap(zone.gouvernorat),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: visited
                ? colPinky.withValues(alpha: 0.08)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                visited
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                size: 16,
                color: visited ? colPinky : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  visited
                      ? 'Délégation visitée — échantillon(s) enregistré(s)'
                      : 'Aucun échantillon enregistré dans cette délégation',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: visited ? colPinkyDark : Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String _cap(String s) => s
      .split(' ')
      .map(
        (w) =>
            w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
      )
      .join(' ');
}

// ─────────────────────────────────────────────────────────────────────────────
// LEGEND
// ─────────────────────────────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: colPinky.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: colPinky.withValues(alpha: 0.80), width: 1),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Délégation visitée',
          style: TextStyle(
            fontSize: 12,
            color: colDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
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
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: colGreen, size: 22),
    ),
  );
}
