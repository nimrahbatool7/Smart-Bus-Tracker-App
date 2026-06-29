import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class LiveDrivingMode extends StatefulWidget {
  const LiveDrivingMode({super.key});

  @override
  State<LiveDrivingMode> createState() => _LiveDrivingModeState();
}

class _LiveDrivingModeState extends State<LiveDrivingMode> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.7128, -74.0060),
    zoom: 16.0,
    tilt: 45.0, // Tilted for driving view
  );

  bool _isSpeeding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Driving Map
          GoogleMap(
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            style: '''[
              { "elementType": "geometry", "stylers": [{ "color": "#212121" }] },
              { "elementType": "labels.icon", "stylers": [{ "visibility": "off" }] },
              { "elementType": "labels.text.fill", "stylers": [{ "color": "#757575" }] },
              { "elementType": "labels.text.stroke", "stylers": [{ "color": "#212121" }] },
              { "featureType": "administrative", "elementType": "geometry", "stylers": [{ "color": "#757575" }] },
              { "featureType": "poi", "elementType": "geometry", "stylers": [{ "color": "#181818" }] },
              { "featureType": "road", "elementType": "geometry.fill", "stylers": [{ "color": "#2c2c2c" }] },
              { "featureType": "water", "elementType": "geometry", "stylers": [{ "color": "#000000" }] }
            ]''', // Dark Map
          ),

          // Speed Warning Overlay
          if (_isSpeeding)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withOpacity(0.5), width: 10),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(duration: 500.ms),
            ),

          // Top Info Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              borderRadius: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next Stop', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      const Text('Central Station', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.arrow_upward, color: Colors.green),
                      const SizedBox(width: 4),
                      const Text('1.2 mi', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ).animate().slideY(begin: -0.5).fadeIn(),
          ),

          // Speedometer
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSpeeding = !_isSpeeding; // Toggle for demo
                });
              },
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.backgroundDark.withOpacity(0.8),
                  border: Border.all(
                    color: _isSpeeding ? Colors.red : AppTheme.primaryColor,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isSpeeding ? Colors.red.withOpacity(0.5) : AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSpeeding ? '45' : '30',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _isSpeeding ? Colors.red : Colors.white,
                      ),
                    ),
                    Text('MPH', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              ),
            ).animate().scale(delay: 400.ms),
          ),

          // Bottom Left Controls
          Positioned(
            bottom: 30,
            left: 20,
            child: Column(
              children: [
                _buildFloatingAction(
                  icon: Icons.qr_code_scanner,
                  color: AppTheme.accentColor,
                  onTap: () => context.push('/driver/scanner'),
                ),
                const SizedBox(height: 16),
                _buildFloatingAction(
                  icon: Icons.stop_circle,
                  color: Colors.redAccent,
                  onTap: () => context.go('/driver/dashboard'), // End trip
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAction({required IconData icon, required Color color, required VoidCallback onTap}) {
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
}
