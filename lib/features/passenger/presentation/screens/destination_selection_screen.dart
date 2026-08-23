import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';

class DestinationSelectionScreen extends StatefulWidget {
  const DestinationSelectionScreen({super.key});

  @override
  State<DestinationSelectionScreen> createState() =>
      _DestinationSelectionScreenState();
}

class _DestinationSelectionScreenState
    extends State<DestinationSelectionScreen> {
  // Default center — in production this would be the user's current location
  static const _defaultCenter = LatLng(40.7128, -74.0060);

  final MapController _mapCtrl = MapController();
  bool _isDestinationSelected = false;
  String _destinationLabel    = '';

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: Stack(
        children: [
          // ── OpenStreetMap full-screen ──────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapCtrl,
              options: const MapOptions(
                initialCenter: _defaultCenter,
                initialZoom:   14.0,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                      'com.example.smart_bus_tracking_app',
                  maxZoom: 19,
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                        '© OpenStreetMap contributors'),
                  ],
                ),
              ],
            ),
          ),

          // ── Centre pin (destination picker) ───────────────────────
          const Center(
            child: Icon(Icons.location_on,
                size: 50, color: AppTheme.primaryColor),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .slideY(begin: -0.2, end: 0, duration: 800.ms),

          // ── Search bar ─────────────────────────────────────────────
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
                    child: Icon(Icons.arrow_back,
                        color:
                            isLight ? Colors.black87 : Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    color: isLight ? Colors.white : null,
                    borderRadius: 16,
                    child: TextField(
                      style: TextStyle(
                          color: isLight
                              ? Colors.black87
                              : Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search destination...',
                        hintStyle: TextStyle(
                            color: isLight
                                ? Colors.grey
                                : Colors.white54),
                        border: InputBorder.none,
                        icon: const Icon(Icons.search,
                            color: AppTheme.primaryColor),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setState(() {
                            _isDestinationSelected = true;
                            _destinationLabel =
                                value.trim();
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ).animate().slideY(begin: -1.0).fadeIn(),
          ),

          // ── Confirm destination card ────────────────────────────────
          if (_isDestinationSelected)
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                color: isLight ? Colors.white : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                _destinationLabel,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isLight
                                        ? Colors.black87
                                        : Colors.white),
                              ),
                              Text(
                                'Selected destination',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isLight
                                        ? Colors.grey.shade600
                                        : Colors.white60),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AnimatedButton(
                      text: 'Confirm Destination',
                      onPressed: () => context.pop(),
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
