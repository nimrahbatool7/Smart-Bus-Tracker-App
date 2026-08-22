import 'dart:async';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

// ── Realtime bus-location stream (passenger view) ──────────────────────────
//
// Selects bus_locations with associated trip/route/bus metadata.
// Re-emits whenever a row changes (REPLICA IDENTITY FULL must be set on
// bus_locations — done in migration 00003).

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

Future<List<_LiveBus>> _fetchBuses(SupabaseClient client) async {
  final rows = await client.from('bus_locations').select('''
    bus_id, latitude, longitude, speed_mph,
    buses ( plate_number, trips ( status, routes ( name ) ) )
  ''');
  return (rows as List).map((r) {
    final m   = r as Map<String, dynamic>;
    final bus = m['buses'] as Map<String, dynamic>? ?? {};
    final trips = bus['trips'] as List?;
    final route = trips?.isNotEmpty == true
        ? (trips!.first as Map<String, dynamic>)['routes']
            as Map<String, dynamic>?
        : null;
    return _LiveBus(
      busId:       m['bus_id']          as String,
      plateNumber: bus['plate_number']  as String? ?? '—',
      routeName:   route?['name']       as String? ?? '—',
      latitude:    double.tryParse(m['latitude'].toString())  ?? 0,
      longitude:   double.tryParse(m['longitude'].toString()) ?? 0,
      speedMph:    double.tryParse(m['speed_mph'].toString()) ?? 0,
    );
  }).toList();
}

final _liveBusesStreamProvider =
    StreamProvider.autoDispose<List<_LiveBus>>((ref) {
  final client     = SupabaseConfig.client;
  final ctrl       = StreamController<List<_LiveBus>>();

  _fetchBuses(client).then(ctrl.add).catchError(ctrl.addError);

  final channel = client
      .channel('passenger_tracking')
      .onPostgresChanges(
        event:    PostgresChangeEvent.all,
        schema:   'public',
        table:    'bus_locations',
        callback: (_) =>
            _fetchBuses(client).then(ctrl.add).catchError(ctrl.addError),
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
    ctrl.close();
  });

  return ctrl.stream;
});

// ── TrackTab widget ────────────────────────────────────────────────────────

class TrackTab extends ConsumerStatefulWidget {
  const TrackTab({super.key});

  @override
  ConsumerState<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends ConsumerState<TrackTab> {
  GoogleMapController? _mapCtrl;
  _LiveBus?            _selected;

  static const _dark = '''[
    {"elementType":"geometry","stylers":[{"color":"#212121"}]},
    {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
    {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
    {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
    {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
  ]''';

  @override
  void dispose() {
    _mapCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight     = Theme.of(context).brightness == Brightness.light;
    final headerColor = isLight
        ? AppTheme.lightBlueHeader
        : Colors.blue.shade900.withValues(alpha: 0.8);
    final busesAsync  = ref.watch(_liveBusesStreamProvider);

    // When new data arrives, update camera if a bus is selected
    ref.listen(_liveBusesStreamProvider, (_, next) {
      next.whenData((buses) {
        if (_selected != null && _mapCtrl != null) {
          final updated = buses
              .where((b) => b.busId == _selected!.busId)
              .firstOrNull;
          if (updated != null) {
            setState(() => _selected = updated);
            _mapCtrl!.animateCamera(
              CameraUpdate.newLatLng(updated.latLng),
            );
          }
        }
      });
    });

    return Scaffold(
      backgroundColor:
          isLight ? Colors.white : AppTheme.backgroundDark,
      body: Stack(
        children: [
          // ── Map ─────────────────────────────────────────────────
          Positioned.fill(
            child: busesAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppTheme.primaryColor)),
              error: (e, _) => Center(
                child: Text('Map error: $e',
                    style: const TextStyle(
                        color: AppTheme.errorColor)),
              ),
              data: (buses) => GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(40.7128, -74.0060),
                  zoom: 13,
                ),
                myLocationEnabled:       true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled:     false,
                mapToolbarEnabled:       false,
                style: isLight ? null : _dark,
                onMapCreated: (c) => _mapCtrl = c,
                markers: buses.map((b) {
                  final isSelected = _selected?.busId == b.busId;
                  return Marker(
                    markerId: MarkerId(b.busId),
                    position: b.latLng,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      isSelected
                          ? BitmapDescriptor.hueGreen
                          : BitmapDescriptor.hueCyan,
                    ),
                    infoWindow: InfoWindow(
                      title:   b.routeName,
                      snippet: '${b.speedMph.toStringAsFixed(0)} mph',
                    ),
                    onTap: () => setState(() => _selected = b),
                  );
                }).toSet(),
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: 16,
                left: 16,
                right: 16,
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
              bottom: 80,
              left: 20,
              right: 20,
              child: GlassCard(
                color: isLight ? Colors.white : null,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
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
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
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
                            Text(
                              'Live',
                              style: TextStyle(
                                  color: isLight
                                      ? Colors.grey.shade600
                                      : Colors.white60,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: [
                        _miniNav(Icons.route,         'Route', true,  isLight),
                        _miniNav(Icons.location_city, 'Stops', false, isLight),
                        _miniNav(Icons.info_outline,  'Info',  false, isLight),
                      ],
                    ),
                  ],
                ),
              ).animate().slideY(begin: 1).fadeIn(),
            )
          else
            // Empty state — no bus selected
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

  Widget _miniNav(
      IconData icon, String label, bool selected, bool isLight) {
    final color = selected
        ? Colors.blue.shade700
        : (isLight ? Colors.grey.shade500 : Colors.white54);
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.normal)),
      ],
    );
  }
}
