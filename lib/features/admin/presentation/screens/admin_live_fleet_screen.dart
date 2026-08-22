import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class _AdminLiveFleetScreenState extends ConsumerState<AdminLiveFleetScreen> {
  static const CameraPosition _initial = CameraPosition(
    target: LatLng(40.7128, -74.0060),
    zoom: 12.0,
  );

  static const _mapStyle =
      '[{"elementType":"geometry","stylers":[{"color":"#212121"}]},'
      '{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},'
      '{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},'
      '{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},'
      '{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]';

  // _mapCtrl is intentionally kept: used in onMapCreated for future camera
  // animations when a bus is tapped. Suppress lint with ignore comment.
  // ignore: unused_field
  GoogleMapController? _mapCtrl;
  BusLocationSnapshot? _selected;

  @override
  Widget build(BuildContext context) {
    final fleetAsync = ref.watch(liveFleetProvider);

    return AdminLayout(
      selectedIndex: 4,
      child: Stack(
        children: [
          // ── Map ───────────────────────────────────────────────────
          fleetAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primaryColor)),
            error: (e, _) => Center(
              child: Text('Fleet error: $e',
                  style: const TextStyle(color: AppTheme.errorColor)),
            ),
            data: (buses) => GoogleMap(
              initialCameraPosition: _initial,
              style: _mapStyle,
              myLocationEnabled:    false,
              zoomControlsEnabled:  false,
              onMapCreated: (c) => _mapCtrl = c,
              markers: buses.map((b) {
                return Marker(
                  markerId: MarkerId(b.busId),
                  position: LatLng(b.latitude, b.longitude),
                  infoWindow: InfoWindow(
                    title:   b.plateNumber,
                    snippet: '${b.routeName} • ${b.speedMph.toStringAsFixed(0)} mph',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    b.speedMph > 40
                        ? BitmapDescriptor.hueRed
                        : BitmapDescriptor.hueCyan,
                  ),
                  onTap: () => setState(() => _selected = b),
                );
              }).toSet(),
            ),
          ),

          // ── Top bar ────────────────────────────────────────────────
          Positioned(
            top: 16, left: 16, right: 16,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white54),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Fleet overview — real-time GPS',
                        style: TextStyle(color: Colors.white54)),
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

          // ── Selected bus card ──────────────────────────────────────
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
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
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
                                  color: Colors.white70, fontSize: 14)),
                          Text('Driver: ${_selected!.driverName}',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
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
                          onTap: () => setState(() => _selected = null),
                          child: const Text('dismiss',
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 12)),
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
