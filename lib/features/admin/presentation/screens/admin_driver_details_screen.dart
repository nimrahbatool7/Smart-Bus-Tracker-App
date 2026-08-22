import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_button.dart';

class AdminDriverDetailsScreen extends StatelessWidget {
  final String driverId;

  const AdminDriverDetailsScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable — kept for potential light/dark use in future
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Driver Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F111A), Color(0xFF131521)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ).animate().scale(),
                      const SizedBox(height: 16),
                      Text('James Wilson', style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 8),
                      Text('ID: $driverId', style: const TextStyle(color: Colors.white54, fontSize: 16)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Status: Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Assigned Vehicle & Route
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Assignment', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.directions_bus, 'Vehicle', 'Bus A-102'),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.route, 'Route', 'Downtown Express'),
                    ],
                  ),
                ).animate().slideY(begin: 0.1).fadeIn(),

                const SizedBox(height: 24),

                // Safety & Documents
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.health_and_safety, color: Colors.green, size: 40),
                            const SizedBox(height: 12),
                            const Text('Safety Score', style: TextStyle(color: Colors.white54)),
                            const SizedBox(height: 4),
                            const Text('98/100', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('0 Violations', style: TextStyle(color: Colors.green, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.folder_shared, color: AppTheme.primaryColor, size: 40),
                            const SizedBox(height: 12),
                            const Text('Documents', style: TextStyle(color: Colors.white54)),
                            const SizedBox(height: 4),
                            const Text('Verified', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('License exp: 2028', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.1).fadeIn(delay: 100.ms),

                const SizedBox(height: 40),

                // Actions
                const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        text: 'Approve',
                        onPressed: () {
                          // Approve logic
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withValues(alpha: 0.2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {},
                        child: const Text('Suspend', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.2).fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 16)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
