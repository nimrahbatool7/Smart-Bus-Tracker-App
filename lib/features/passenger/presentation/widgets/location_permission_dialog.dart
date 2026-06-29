import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animated_button.dart';
import '../../../../core/widgets/glass_card.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback? onGranted;

  const LocationPermissionDialog({super.key, this.onGranted});

  static void show(BuildContext context, {required VoidCallback onGranted}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LocationPermissionDialog(
        onGranted: onGranted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      margin: const EdgeInsets.all(16),
      child: GlassCard(
        color: isLight ? Colors.white : null,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: isLight ? Colors.grey.shade300 : Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            
            // Animated Location Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1500.ms),
             
            const SizedBox(height: 30),
            
            Text(
              'Enable Current Location',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Allow location access to find nearby buses and calculate ETA.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLight ? Colors.grey.shade600 : Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),
            
            AnimatedButton(
              text: 'Enable Location',
              onPressed: () {
                // TODO: Request Geolocator permission here
                Navigator.pop(context);
                onGranted?.call();
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Not Now',
                style: TextStyle(
                  color: isLight ? Colors.grey.shade600 : Colors.white60,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 400.ms, curve: Curves.easeOut);
  }
}
