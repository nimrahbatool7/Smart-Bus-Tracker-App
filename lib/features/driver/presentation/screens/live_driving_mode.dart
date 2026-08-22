import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../data/providers/driver_providers.dart';

class LiveDrivingMode extends ConsumerStatefulWidget {
  const LiveDrivingMode({super.key});

  @override
  ConsumerState<LiveDrivingMode> createState() => _LiveDrivingModeState();
}

class _LiveDrivingModeState extends ConsumerState<LiveDrivingMode> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.7128, -74.0060),
    zoom: 16.0,
    tilt: 45.0,
  );

  GoogleMapController? _mapController;

  // Cached trip/bus IDs loaded from the active trip
  String? _tripId;
  String? _busId;

  @override
  void initState() {
    super.initState();
    // Load assignment and start broadcasting once the widget tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _startBroadcast());
  }

  Future<void> _startBroadcast() async {
    // Pull the active trip from the provider
    final assignment = await ref.read(driverAssignmentProvider.future);
    if (assignment == null) return;

    _tripId = assignment.tripId;
    _busId  = assignment.busId;

    await ref
        .read(locationBroadcasterProvider.notifier)
        .start(busId: _busId!, tripId: _tripId!);
  }

  Future<void> _endTrip() async {
    if (_tripId == null || _busId == null) {
      context.go(AppRoutes.driverDashboard);
      return;
    }

    // Stop GPS stream first
    ref.read(locationBroadcasterProvider.notifier).stop();

    // Close trip in DB
    await ref.read(tripNotifierProvider.notifier).endTrip(
          tripId: _tripId!,
          busId:  _busId!,
        );

    if (mounted) {
      // Refresh dashboard assignment
      ref.invalidate(driverAssignmentProvider);
      context.go(AppRoutes.driverDashboard);
    }
  }

  @override
  void dispose() {
    ref.read(locationBroadcasterProvider.notifier).stop();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final speedMph  = ref.watch(locationBroadcasterProvider);
    final isSpeeding = speedMph > 40;

    return Scaffold(
      body: Stack(
        children: [
          // ── Map ─────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: _initialPosition,
            myLocationEnabled:      true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled:    false,
            mapToolbarEnabled:      false,
            onMapCreated: (c) => _mapController = c,
            style: '''[
              {"elementType":"geometry","stylers":[{"color":"#212121"}]},
              {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
              {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
              {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
              {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
              {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}
            ]''',
          ),

          // ── Speed violation overlay ──────────────────────────────────
          if (isSpeeding)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.red.withOpacity(0.5), width: 10),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .fade(duration: 500.ms),
            ),

          // ── Top info bar ─────────────────────────────────────────────
          Positioned(
            top: 50, left: 20, right: 20,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              borderRadius: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Trip Active',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12)),
                      const Text('GPS Broadcasting',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                       .fade(duration: 800.ms),
                      const SizedBox(width: 6),
                      const Text('LIVE',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.5).fadeIn(),
          ),

          // ── Speedometer ──────────────────────────────────────────────
          Positioned(
            bottom: 30, right: 20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.backgroundDark.withOpacity(0.85),
                border: Border.all(
                  color: isSpeeding
                      ? Colors.red
                      : AppTheme.primaryColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSpeeding
                            ? Colors.red
                            : AppTheme.primaryColor)
                        .withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    speedMph.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color:
                          isSpeeding ? Colors.red : Colors.white,
                    ),
                  ),
                  Text('MPH',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12)),
                ],
              ),
            ).animate().scale(delay: 400.ms),
          ),

          // ── Bottom left actions ──────────────────────────────────────
          Positioned(
            bottom: 30, left: 20,
            child: Column(
              children: [
                // QR scanner button
                _buildAction(
                  icon: Icons.qr_code_scanner,
                  color: AppTheme.accentColor,
                  onTap: () => context.push(AppRoutes.driverScanner),
                ),
                const SizedBox(height: 16),
                // End trip button
                _buildAction(
                  icon: Icons.stop_circle,
                  color: Colors.redAccent,
                  onTap: () => _showEndConfirmation(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 20,
        color: color.withOpacity(0.2),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    ).animate().slideX(begin: -0.5).fadeIn(delay: 500.ms);
  }

  void _showEndConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.backgroundDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white12)),
        title: const Text('End Trip?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will stop GPS tracking and mark the trip as completed.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _endTrip();
            },
            child: const Text('End Trip',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
