import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';

class DestinationSelectionScreen extends StatefulWidget {
  const DestinationSelectionScreen({super.key});

  @override
  State<DestinationSelectionScreen> createState() => _DestinationSelectionScreenState();
}

class _DestinationSelectionScreenState extends State<DestinationSelectionScreen> {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.7128, -74.0060),
    zoom: 14.4746,
  );

  bool _isDestinationSelected = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final mapStyle = isLight ? '[]' : '''[{"elementType":"geometry","stylers":[{"color":"#212121"}]},{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#181818"}]},{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]}]''';

    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              style: mapStyle,
              onCameraIdle: () {
                // When user stops moving map, maybe they selected a point
              },
            ),
          ),
          
          // Center Pin (for selecting destination by dragging map)
          const Center(
            child: Icon(Icons.location_on, size: 50, color: AppTheme.primaryColor),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).slideY(begin: -0.2, end: 0, duration: 800.ms),

          // Search Field Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    color: isLight ? Colors.white : null,
                    borderRadius: 16,
                    child: Icon(Icons.arrow_back, color: isLight ? Colors.black87 : Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    color: isLight ? Colors.white : null,
                    borderRadius: 16,
                    child: TextField(
                      style: TextStyle(color: isLight ? Colors.black87 : Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search destination...',
                        hintStyle: TextStyle(color: isLight ? Colors.grey : Colors.white54),
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: AppTheme.primaryColor),
                      ),
                      onSubmitted: (value) {
                        setState(() {
                          _isDestinationSelected = true;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ).animate().slideY(begin: -1.0).fadeIn(),
          ),

          // Bottom Confirmation Card
          if (_isDestinationSelected)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: GlassCard(
                color: isLight ? Colors.white : null,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Destination', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.white60, fontSize: 12)),
                              Text('University Road', style: TextStyle(color: isLight ? Colors.black87 : Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Distance', style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.white60, fontSize: 12)),
                            Text('5 km', style: TextStyle(color: isLight ? Colors.black87 : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AnimatedButton(
                      text: 'Confirm Destination',
                      onPressed: () {
                        context.pop();
                        // Navigate to Bus Results...
                      },
                    ),
                  ],
                ),
              ).animate().slideY(begin: 1.0).fadeIn(),
            ),
        ],
      ),
    );
  }
}
