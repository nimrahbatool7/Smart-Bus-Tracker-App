import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/providers/admin_providers.dart';
import 'admin_layout.dart';

class AdminLiveFleetScreen extends ConsumerStatefulWidget {
  const AdminLiveFleetScreen({super.key});

  @override
  ConsumerState<AdminLiveFleetScreen> createState() =>
      _AdminLiveFleetScreenState();
}

class _AdminLiveFleetScreenState
    extends ConsumerState<AdminLiveFleetScreen> {
  static const _defaultCenter = LatLng(40.7128, -74.0060);
  static const _defaultZoom   = 12.0;

  final MapController _mapCtrl = MapController();
  BusLocationSnapshot? _selected;

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fleetAsync = ref.watch(liveFleetProvider);

    return AdminLayout(
      selectedIndex: 4,
      child: Stack(
        children: [
          // ── OpenStreetMap tile layer + fleet markers ──────────────
          fleetAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primaryColor)),
            error: (e, _) => Center(
              child: Text('Fleet error: $e',
                  style:
                      const TextStyle(color: AppTheme.errorColor)),
            ),
            data: (buses) => FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: buses.isNotEmpty
                    ? LatLng(buses.first.latitude,
                             buses.first.longitude)
                    : _defaultCenter,
                initialZoom: _defaultZoom,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                // ── Tile layer ──────────────────────────────────────
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.smart_bus_tracking_app',
                  maxZoom: 19,
                ),

                // ── Fleet markers ───────────────────────────────────
                MarkerLayer(
                  markers: buses.map((b) {
                    final isSpeeding = b.speedMph > 40;
                    final isSelected =
                        _selected?.busId == b.busId;
                    final markerColor = isSpeeding
                        ? Colors.red
                        : Colors.cyan.shade700;

                    return Marker(
                      point:  LatLng(b.latitude, b.longitude),
                      width:  isSelected ? 52 : 42,
                      height: isSelected ? 52 : 42,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selected = b),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: markerColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: markerColor
                                        .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_bus,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                              child: Text(
                                b.plateNumber,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // ── OSM attribution ─────────────────────────────────
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                        '© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),

          // ── Top search bar + active count ─────────────────────────
          Positioned(
            top: 16, left: 16, right: 16,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white54),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Fleet overview — real-time GPS',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                  fleetAsync.maybeWhen(
                    data: (buses) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.circle,
                              color: Colors.green, size: 10),
                          const SizedBox(width: 6),
                          Text('${buses.length} Active',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    orElse: () => const SizedBox(),
                  ),
                ],
              ),
            ),
          ),

          // ── Selected bus info card ────────────────────────────────
          if (_selected != null)
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.directions_bus,
                          color: AppTheme.primaryColor, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selected!.plateNumber,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          Text('Route: ${_selected!.routeName}',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14)),
                          Text('Driver: ${_selected!.driverName}',
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_selected!.speedMph.toStringAsFixed(0)} mph',
                          style: TextStyle(
                            color: _selected!.speedMph > 40
                                ? Colors.red
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _selected = null),
                          child: const Text('dismiss',
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
