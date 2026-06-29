import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';

class TrackTab extends StatefulWidget {
  const TrackTab({super.key});

  @override
  State<TrackTab> createState() => _TrackTabState();
}

class _TrackTabState extends State<TrackTab> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.7128, -74.0060),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final headerColor = isLight ? AppTheme.lightBlueHeader : Colors.blue.shade900.withValues(alpha: 0.8);
    final mapStyle = isLight ? '[]' : '''[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]''';

    return Scaffold(
      backgroundColor: isLight ? Colors.white : AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Map Layer
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              style: mapStyle,
            ),
          ),

          // Top App Bar Area
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20, left: 16, right: 16),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Live Tracking',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bus 23A',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20), // Balance the back button
                ],
              ),
            ),
          ).animate().slideY(begin: -1),

          // Bottom Info Card
          Positioned(
            bottom: 30, // Since it's inside the dashboard, it needs space for the main bottom nav, or if it's pushed, it sits at bottom.
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('City Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isLight ? Colors.black87 : Colors.white)),
                          const SizedBox(height: 4),
                          Text('via Main Street', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.white60, fontSize: 14)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('3 min', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isLight ? Colors.black87 : Colors.white)),
                          const SizedBox(height: 4),
                          Text('Arrival', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.white60, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(color: isLight ? Colors.grey.shade200 : Colors.white12, height: 1),
                  const SizedBox(height: 20),
                  Text('Next Stop', style: TextStyle(color: isLight ? Colors.grey.shade500 : Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Central Library', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isLight ? Colors.black87 : Colors.white)),
                      Text('500 m', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: isLight ? Colors.black87 : Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Fake bottom nav for this card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniNav(Icons.route, 'Route', true, isLight),
                      _buildMiniNav(Icons.location_city, 'Stops', false, isLight),
                      _buildMiniNav(Icons.info_outline, 'Info', false, isLight),
                    ],
                  )
                ],
              ),
            ).animate().slideY(begin: 1).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniNav(IconData icon, String label, bool isSelected, bool isLight) {
    final color = isSelected ? Colors.blue.shade700 : (isLight ? Colors.grey.shade500 : Colors.white54);
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
