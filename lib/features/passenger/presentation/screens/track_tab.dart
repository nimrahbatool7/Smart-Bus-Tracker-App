import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

// ── Live bus model ────────────────────────────────────────────────────────

class _LiveBus {
  const _LiveBus({
    required this.busId,
    required this.plateNumber,
    required this.routeName,
    required this.latitude,
    required this.longitude,
    required this.speedMph,
  });

  final String busId;
  final String plateNumber;
  final String routeName;
  final double latitude;
  final double longitude;
  final double speedMph;

  LatLng get latLng => LatLng(latitude, longitude);
}

// ── Supabase fetch helper ─────────────────────────────────────────────────

Future<List<_LiveBus>> _fetchBuses(SupabaseClient client) async {
  final rows = await client.from('bus_locations').select('''
    bus_id, latitude, longitude, speed_mph,
    buses ( plate_number, trips ( status, routes ( name ) ) )
  ''');
  return (rows as List).map((r) {
    final m     = r as Map<String, dynamic>;
    final bus   = m['buses']  as Map<String, dynamic>? ?? {};
    final trips = bus['trips'] as List?;
    final route = trips?.isNotEmpty == true
        ? (trips!.first as Map<String, dynamic>)['routes']
            as Map<String, dynamic>?
        : null;
    return _LiveBus(
      busId:       m['bus_id']         as String,
      plateNumber: bus['plate_number'] as String? ?? '—',
      routeName:   route?['name']      as String? ?? '—',
      latitude:    double.tryParse(m['latitude'].toString())  ?? 0,
      longitude:   double.tryParse(m['longitude'].toString()) ?? 0,
      speedMph:    double.tryParse(m['speed_mph'].toString()) ?? 0,
    );
  }).toList();
}

// ── Realtime stream provider ──────────────────────────────────────────────

final _liveBusesStreamProvider =
    StreamProvider.autoDispose<List<_LiveBus>>((ref) {
  final client = SupabaseConfig.client;
  final ctrl   = StreamController<List<_LiveBus>>();

  _fetchBuses(client).then(ctrl.add).catchError(ctrl.addError);

  final channel = client
      .channel('passenger_tracking')
      .onPostgresChanges(
        event:    PostgresChangeEvent.all,
        schema:   'public',
        table:    'bus_locations',
        callback: (_) => _fetchBuses(client)
            .then(ctrl.add)
            .catchError(ctrl.addError),
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
    ctrl.close();
  });

  return ctrl.stream;
});

// ── TrackTab widget ───────────────────────────────────────────────────────

class TrackTab extends ConsumerStatefulWidget {
  const TrackTab({super.key});

  @override
  ConsumerState<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends ConsumerState<TrackTab> {
  final MapController _mapCtrl = MapController();
  _LiveBus? _selected;

  // Default center: New York City (will pan to first bus once data arrives)
  static const _defaultCenter = LatLng(40.7128, -74.0060);
  static const _defaultZoom   = 13.0;

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight     = Theme.of(context).brightness == Brightness.light;
    final headerColor = isLight
        ? AppTheme.lightBlueHeader
        : Colors.blue.shade900.withValues(alpha: 0.8);
    final busesAsync  = ref.watch(_liveBusesStreamProvider);

    // When new data arrives, pan the map to the selected bus
    ref.listen(_liveBusesStreamProvider, (_, next) {
      next.whenData((buses) {
        if (_selected != null) {
          final updated = buses
              .where((b) => b.busId == _selected!.busId)
              .firstOrNull;
          if (updated != null) {
            setState(() => _selected = updated);
            _mapCtrl.move(updated.latLng, _mapCtrl.camera.zoom);
          }
        }
      });
    });

    return Scaffold(
      backgroundColor: isLight ? Colors.white : AppTheme.backgroundDark,
      body: Stack(
        children: [
          // ── OpenStreetMap via flutter_map ────────────────────────
          Positioned.fill(
            child: busesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryColor)),
              error: (e, _) => Center(
                child: Text('Map error: $e',
                    style:
                        const TextStyle(color: AppTheme.errorColor)),
              ),
              data: (buses) => FlutterMap(
                mapController: _mapCtrl,
                options: MapOptions(
                  initialCenter: buses.isNotEmpty
                      ? buses.first.latLng
                      : _defaultCenter,
                  initialZoom:  _defaultZoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // ── Tile layer — OpenStreetMap ───────────────────
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.smart_bus_tracking_app',
                    maxZoom: 19,
                    // Respect OSM tile usage policy:
                    // cache tiles, identifiable User-Agent, attribution shown
                  ),

                  // ── Bus markers ──────────────────────────────────
                  MarkerLayer(
                    markers: buses.map((b) {
                      final isSelected = _selected?.busId == b.busId;
                      final markerColor = isSelected
                          ? Colors.green
                          : Colors.cyan.shade700;
                      return Marker(
                        point:  b.latLng,
                        width:  isSelected ? 48 : 40,
                        height: isSelected ? 48 : 40,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = b),
                          child: Container(
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
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_bus,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // ── OSM attribution (required by OSM tile policy) ─
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        '© OpenStreetMap contributors',
                        // onTap: opens osm copyright page — handled internally
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top:    MediaQuery.of(context).padding.top,
                bottom: 16,
                left:   16,
                right:  16,
              ),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft:  Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 20),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Live Tracking',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        busesAsync.maybeWhen(
                          data: (buses) => Text(
                            '${buses.length} bus${buses.length == 1 ? '' : 'es'} active',
                            style: TextStyle(
                                color: Colors.white
                                    .withValues(alpha: 0.8),
                                fontSize: 13),
                          ),
                          orElse: () => const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ).animate().slideY(begin: -1),

          // ── Selected bus card ────────────────────────────────────
          if (_selected != null)
            Positioned(
              bottom: 80, left: 20, right: 20,
              child: GlassCard(
                color: isLight ? Colors.white : null,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selected!.routeName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isLight
                                      ? Colors.black87
                                      : Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selected!.plateNumber,
                              style: TextStyle(
                                  color: isLight
                                      ? Colors.grey.shade600
                                      : Colors.white60,
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_selected!.speedMph.toStringAsFixed(0)} mph',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _selected!.speedMph > 40
                                      ? Colors.red
                                      : Colors.green),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selected = null),
                              child: Text('dismiss',
                                  style: TextStyle(
                                      color: isLight
                                          ? Colors.grey.shade500
                                          : Colors.white38,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(begin: 1).fadeIn(),
            )
          else
            Positioned(
              bottom: 80, left: 20, right: 20,
              child: GlassCard(
                color: isLight ? Colors.white : null,
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    busesAsync.maybeWhen(
                      data: (b) => b.isEmpty
                          ? 'No buses active right now'
                          : 'Tap a bus marker to track it',
                      orElse: () => 'Loading buses…',
                    ),
                    style: TextStyle(
                        color: isLight
                            ? Colors.grey.shade600
                            : Colors.white60),
                  ),
                ),
              ).animate().slideY(begin: 1).fadeIn(),
            ),
        ],
      ),
    );
  }
}
